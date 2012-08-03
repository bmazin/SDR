PRO QuerySimbad, name, ra, de, id, Found = found, NED = ned, ERRMSG = errmsg, $
    Verbose = verbose, CADC = cadc, CFA=cfa, Server=server, SILENT=silent
;+
; NAME: 
;   QUERYSIMBAD
;
; PURPOSE: 
;   Query the SIMBAD/NED/Vizier astronomical name resolver to obtain coordinates
;
; EXPLANATION: 
;   Uses the IDL SOCKET command to query either the SIMBAD or NED nameserver 
;   over the Web to return J2000 coordinates.     ;   By default, QuerySimbad 
;   first queries the Simbad database, then (if no match found) the NED 
;   database, and then the Vizier database.
;    
;   For details on the SIMBAD service, see http://simbad.u-strasbg.fr/Simbad 
;   and for the NED service, see http://ned.ipac.caltech.edu/
;
; CALLING SEQUENCE: 
;    QuerySimbad, name, ra, dec, [ id, Found=, /NED, /CADC, ERRMSG=, /VERBOSE]
;
; INPUTS: 
;    name - a scalar string containing the target name in SIMBAD (or NED)
;           nomenclature. For SIMBAD details see
;           http://vizier.u-strasbg.fr/cgi-bin/Dic-Simbad .
;
; OUTPUTS: 
;     ra - the right ascension of the target in J2000.0 in *degrees* 
;     dec - declination of the target in degrees
;
; OPTIONAL INPUT KEYWORD:
;     /CFA - if set, then use the Simbad server at the Center for Astrophysics
;             rather than the default server in Strasbourg, France.
;     /NED - if set, then only the nameserver of the NASA Extragalactic database
;            is used to resolve the name and return coordinates.   Note that
;           /NED cannot be used with Galactic objects
;     /VERBOSE - If set, then the HTTP-GET command is displayed 
;     /SILENT - If set, then don't print warnings if multiple SIMBAD objects
;             correspond to the supplied name.
; OPTIONAL OUTPUT: 
;     id - the primary SIMBAD (or NED) ID of the target, scalar string
;          As of June 2009, a more reliable ID seems to be found when using 
;          CFA (/CFA) server.
;
; OPTIONAL KEYWORD OUTPUT:
;     found - set to 1 if the translation was successful, or to 0 if the
;           the object name could not be translated by SIMBAD or NED
;     Errmsg - if supplied, then any error messages are returned in this
;            keyword, rather than being printed at the terminal.   May be either
;            a scalar or array.
;     Server - Character indicating which server was actually used to resolve
;           the object, 'S'imbad, 'N'ed or 'V'izier
;            
; EXAMPLES:
;     (1) Find the J2000 coordinates for the ultracompact HII region
;         G45.45+0.06 
;
;      IDL> QuerySimbad,'GAL045.45+00.06', ra, dec
;      IDL> print, adstring(ra,dec,1)
;           ===>19 14 20.77  +11 09  3.6
; PROCEDURES USED:
;       REPSTR(), WEBGET()
;
; NOTES:
;     The actual  query is made to the Sesame name resolver 
;     ( see http://cdsweb.u-strasbg.fr/doc/sesame.htx ).     The Sesame
;     resolver first searches the Simbad name resolver, then  NED and then
;     Vizier.   
; MODIFICATION HISTORY: 
;     Written by M. Feldt, Heidelberg, Oct 2001   <mfeldt@mpia.de>
;     Minor updates, W. Landsman   August 2002
;     Added option to use NED server, better parsing of SIMBAD names such as 
;          IRAS F10190+5349    W. Landsman  March 2003
;     Turn off extended name search for NED server, fix negative declination
;     with /NED    W. Landsman  April 2003
;     Use Simbad Sesame sever, add /Verbose, /CADC keywords 
;       B. Stecklum, TLS Tautenburg/ W. Landsman, Feb 2007
;    Update NED query to account for new IPAC format, A. Barth  March 2007
;    Update NED query to account for another new IPAC format, A. Barth  
;                                                   July 2007
;     Update message when NED does not find object  W.L.  October 2008
;     Remove CADC keyword, add CFA keyword, warning if more than two
;         matches  W.L. November 2008 
;     Make NED queries through the Sesame server, add Server output 
;          keyword  W.L.  June 2009
;     Don't get primary name if user didn't ask for it  W.L. Aug 2009
;     Added /SILENT keyword W.L. Oct 2009
;-
  On_error,2
  compile_opt idl2
  if N_params() LT 3 then begin
       print,'Syntax - QuerySimbad, name, ra, dec, [ id, ]
       print,'                 Found=, /CFA, /NED, ERRMSG=, /VERBOSE]'
       print,'   Input - object name, scalar string'
       print,'   Output -  Ra, dec of object (degrees)'
       return
  endif
  ;;
  printerr = not arg_present(errmsg)
  object = repstr(name,'+','%2B')
 object = repstr(strcompress(object),' ','%20')
 if keyword_set(Cadc) then message,'CADC keyword is no longer supported'
 if keyword_set(cfa) then base = 'vizier.cfa.harvard.edu/viz-bin' else $
 base = 'cdsweb.u-strasbg.fr/cgi-bin'
    if keyword_set(NED) then begin
 QueryURL = "http://" + base + "/nph-sesame/-o/N?" + $
               strcompress(object,/remove)
 endif else begin
 QueryURL = "http://" + base + "/nph-sesame/-o/?" + $
               strcompress(object,/remove)

  endelse
  ;;
  if keyword_set(verbose) then print,queryURL
  Result = webget(QueryURL)
  found = 0
  ;;
   Result=Result.Text
   if arg_present(server) then $ 
        server = strmid(result[1],2,1)
; look for J2000 coords
  idx=where(strpos(Result, '%J ') ne -1,cnt)

  if cnt GE 1 then begin
    if cnt GT 1 then begin 
        if not keyword_set(SILENT) then $
	 message,/INF,'Warning - More than one match found for name '  + name
        idx = idx[0]
    endif 	
    found=1   
    ra = 0.0d & de = 0.0d
    reads,strmid(Result[idx],2),ra,de
        if N_params() GT 3 then begin 

     idx2= where(strpos(Result, '%I.0 ') ne -1,cnt)
     if cnt GT 0 then id = strtrim(strmid(Result[idx2],4),2) else $
	    if not keyword_set(SILENT) then $
	       message,'Warning - could not determine primary ID',/inf 
     endif	    
  ENDIF ELSE BEGIN 
      errmsg = ['No objects returned by SIMBAD.   The server answered:' , $
                 strjoin(result)]
      if printerr then begin
         message, errmsg[0], /info	
	 message,strjoin(result),/info
      endif	 
  ENDELSE
  
  return 
END 
  
