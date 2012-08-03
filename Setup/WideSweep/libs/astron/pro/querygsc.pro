function Querygsc, target, dis,magrange = magrange, HOURS = hours, $
   VERBOSE=verbose, BOX = box
;+
; NAME: 
;   QUERYGSC
;
; PURPOSE: 
;   Query the Guide Star Catalog (GSC V2.3.2) at STScI by position
; 
; EXPLANATION:
;   Uses the IDL SOCKET command to query the GSC 2.3.2 database over the Web.    
;
;   Alternatively, the user can query the GSC 2.3.2 catalog using
;   queryvizier.pro and the VIZIER database, e.g.  
;     IDL> st = queryvizier('GSC2.3',[23,35],10,/all)
; 
;   GSC2.3 is an all-sky export of calibrated photographic survey plate 
;   source parameters from the COMPASS database.  The number of unique
;   objects is approximately 945,592,683.   All sources are 
;   from the second-generation plate-processing pipeline with the exception
;   of Tycho-2 and Skymap sources in the case of very bright objects. The 
;   Skymap sources are exported when there is no matching GSC or Tycho 
;   sources.  Each GSC 2.3 entry contains only one position and one 
;   magnitude per bandpass for each unique sky object
;
; CALLING SEQUENCE: 
;     info = QueryGSC(targetname_or_coords, [ dis, /HOURS] )
;
; INPUTS: 
;      TARGETNAME_OR_COORDS - Either a scalar string giving a target name, 
;          (with J2000 coordinates determined by SIMBAD), or a 2-element
;          numeric vector giving the J2000 right ascension in *degrees* (or 
;          hours if /HOURS is set) and the target declination in degrees.
;
; OPTIONAL INPUT:
;    dis - Numeric scalar giving search radius in arcminutes to search around 
;          specified target    Default is 5 arcminutes
;
; OPTIONAL INPUT KEYWORDS:
;
;    /BOX - if set, then radius gives  a box width in arcminutes
;    /HOURS - If set, then the right ascension is both input and output (in
;             the info .ra tag) in hours instead of degrees
;    /VERBOSE - If set, then the CGI command to the Webserver will be displayed
;;
; OUTPUTS: 
;   info - IDL structure containing information on the GSC stars within the 
;          specified distance of the specified center.   There are (currently)
;          23 tags in this structure  -- for further information see
;          www-gsss.stsci.edu/Catalogs/GSC/GSC2/gsc23/gsc23_release_notes.htm
;
;          .HSTID - GSC 2.3 name for HST operations
;          .GSC1ID - GSC1 name
;          .RA,.DEC - Position in degrees (double precision).   RA is given in
;                   hours if the /HOURS keyword is set.
;          .RAERR, .DECERR - uncertainty (in arcseconds) in the RA and Dec
;          .EPOCH - mean epoch of the observation
;          .FPGMAG, .FPGERR - magnitude and error in photographic F
;          .JPGMAG, .JPGERR - magnitude and error in photographic J
;          .VPGMAG, .VPGERR - V magnitude and error 
;          .NPGMAG, .NPGERR - magnitude and error
;          .UMAG, .UERR - magnitude and error
;          .BMAG, .BERR - magnitude and error
;          .VMAG, .VERR - magnitude and error
;          .RMAG, .RERR - magnitude and error
;          .IMAG, .IERR - magnitude and error
;          .JMAG, .JERR - magnitude and error
;          .HMAG, .HERR - magnitude and error
;          .KMAG, .KERR - magnitude and error
;          .A - semi-major axis in pixels
;          .PA - Position angle of extended objects in degrees
;          .E - eccentricity of extended objects
;          .CLASS - classification (0-5): 0-star, 1-galaxy, 2-blend, 
;                         3-nonstar, 4-unclassified, 5-defect
;          .STATUS -10 digit field  used to encode more detailed information 
;              about the properties of the catalog object.   For more info, see
;http://www-gsss.stsci.edu/Catalogs/GSC/GSC2/gsc23/gsc23_release_notes.htm#ClassificationCodes
;           .VFLAG, MFLAG - Variability nad multiplicity flags
;            .FPGBAND, .NPGBAND, .JPGBAND. UBAND, BBAND, .VBAND - flag as 
;            to wether given bandpass is available
; EXAMPLE: 
;          Plot a histogram of the photographic J magnitudes of all GSC 2.3.2 
;          stars within 10 arcminutes of the center of the globular cluster M13 
;
;          IDL> info = querygsc('M13',10)
;          IDL> plothist,info.jpgmag,xran=[10,20]
;
; PROCEDURES USED:
;          QUERYSIMBAD, RADEC, WEBGET()
;
; MODIFICATION HISTORY: 
;         Written by W. Landsman  SSAI  August 2002
;         Fixed parsing of RA and Dec  W. Landsman September 2002
;         Major rewrite to use new STScI Web server, remove magrange
;           keyword   W. Landsman Dec 2007
;         Update server name, added /BOX,/ VERBOSE keywords W.L 19 Dec 2007
;         Web server now also returns infrared data  W.L. Feb 2010
;         Fixed case where dec neg. and deg or min 0 Pat Fry Jul 2010
;
;-
  compile_opt idl2
  if N_params() LT 2 then begin
       print,'Syntax - info = QueryGSC(targetname_or_coord, dis,'
       print,'                        [/Hours, /Box, /VERBOSE} )'
       print,'   RA (degrees), Dec (degrees) -- search coordinates of center)'
       print,'  dis -- search radius in arcminutes'
       if N_elements(info) GT 0 then return,info else return, -1
  endif
  if N_elements(dis) EQ 0 then dis = 5
    if N_elements(target) EQ 2 then begin
      ra = float(target[0])
      dec = float(target[1])
  endif else begin
       QuerySimbad, target, ra,dec, Found = Found
       if found EQ 0 then message,'Target name ' + target + $
                 ' could not be translated by SIMBAD'
  endelse  
  radius = keyword_set(box)? 'Box' : 'Radius'
  
   radec,ra,dec,hr,mn,sc,deg,dmn,dsc,hours=keyword_set(hours)
   deg = string(deg,'(i3.2)')
   dsn = strmid(deg,0,1)
   deg = strmid(deg,1,2)
   if (dmn lt 0 || dsc lt 0) then begin
       dmn = abs(dmn)
       dsc = abs(dsc)
       dsn = '-'
   endif
   sc = round(sc)
   dsc = round(dsc)
   if dsn EQ ' ' then dsn = '%2B'
  ;;
  QueryURL = "http://gsss.stsci.edu/webservices/GSC2/GSC2DataReturn.aspx?" + $
   'RAH=' + string(hr,'(i2.2)') + '&RAM=' + string(mn,'(i2.2)') + $
   '&RAS=' + string(sc,'(i2.2)') + '&DSN=' + dsn + '&DD=' + deg +  $
   '&DM=' + string(dmn,'(i2.2)') + '&DS=' + string(dsc,'(i2.2)') + $
    '&EQ=2000&SIZE=' + strtrim(dis,2) + '&SRCH=' + radius + $
    '&FORMAT=CSV&CAT=GSC23&HSTID=&GSC1ID='
    
  if keyword_set(verbose) then print,queryurl
  ;;  
  Result = webget(QueryURL)
 ;
  t = result.text

  nstar = N_elements(t) -1
  if strmid(t[0],0,5) NE 'Usage' and nstar GT 0 THEN BEGIN
  headers = strsplit(t[0],',',/extract)
  
  info = create_struct(Name='gsc',headers, '','',0.0d,0.0d,0.0,0.0,0.0, $
   0.0, 0, 0.0, $   ;Fpg
   0.0, 0, 0.0, $ ;Jpg
   0.0, 0, 0.0, $   ;Npg 
   0.0, 0, 0.0,  $   ;U 
   0.0, 0, 0.0, $ ;B
   0.0, 0, 0.0, $ ;V
   0.0, 0, 0.0, $ ;R
   0.0, 0, 0.0, $ ;I
   0.0, 0, 0.0, $ ;J
   0.0, 0, 0.0, $ ;H
   0.0, 0, 0.0, $ ;K
   0, 0ULL, 0.0, 0.0, 0.0,0,0 )
  info = replicate(info,nstar)

  for i=0,nstar-1 do begin
      temp = strsplit(t[i+1],',',/extract)
       for j=0,N_elements(temp)-1 do info[i].(j) = temp[j]
  endfor
   ENDIF ELSE BEGIN 
      message, 'No objects returned by server. The server answered:', /info
      print, Result.Text
      if N_elements(info) GT 0 then return, info else return, -1
  ENDELSE 
  if keyword_set(hours) then info.ra = info.ra/15.0d 
 return,info
END 
  
