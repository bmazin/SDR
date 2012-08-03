;+
; NAME:
;        HBRINFO
;
; PURPOSE:
;        This function returns a structure or an array of structures containing
;        information about the HBR data file(s) the USER has requested.
;
; CATEGORY:
;
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        Result = HBRINFO()
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        The following are SEARCH keywords the USER may specify to find
;        entries in the HBR database.  The wildcard character, '*'
;        is allowed in all keywords.  See the PROCEDURE below for a more
;        detailed description.
;
;        FILE:     Names of the HBR data files, string or strarr().
;                  The format of each name must be, SSS_TN_FN, where
;                  SSS = NRL sequence number, TN = NRL mag. tape number,
;                  and FN = File number on that mag. tape. Paths and/or
;                  extensions (e.g. \data\001_1_1.dat) are allowed.
;
;        SLACVOL:  SLAC volume serial number(s) of the SLAC silo cartridges
;                  containing the HBR data file(s), string or strarr().
;                  (e.g. RY2070)
;
;        SLACSEQ:  SLAC sequence number(s) of the HBR data file(s) residing on
;                  the SLAC silo cartridges, fix or intarr().
;
;        NRLseq:   NRL sequence number(s) of the HBR data file(s) associated
;                  with the NRL ANALOG tapes, fix or intarr().
;
;        NRLtape:  NRL magnetic tape number(s) of the HBR data file(s)
;                  associated with with NRL DIGITIZED tapes, fix or intarr().
;
;        NRLfile:  NRL file number(s) of the HBR data file(s) residing on the
;                  the NRL DIGITIZED tapes, fix or intarr().
;
;        DATE:     The date of the HBR data file(s), string.  It must be of the
;                  form, MN-DD-YY, where MN=month, DD=day, YY=year.  The wildcard
;                  character is also allowed here by replacing MN, DD and/or YY
;                  with '*',(e.g. '*-*-77', '1-*-78').
;
;        TIME:     The time of the HBR data file(s), string.  It must be of the
;                  form, HH-MM-SS, where HH=hour, MM=month, SS=second.  The
;                  wildcard character is also allowed here by replacing HH, MM
;                  and/or SS with '*', (e.g. '15-*-*').
;
;        DOY:      Day(s) of the year, fix or intarr().
;
;        HBRM:     HBR mode(s), string or strarr(), ('B'=Bit, 'F'=Frame, 'W'=Word).
;
;        NRZM:     NRZ mode(s), fix or intarr(2), (5=5ms, 320=320ms).
;
;        SATM:     HEAO satellite mode(s), string or starr(2), ('P'=Pointing,
;                  'S'=Scanning).
;
;        SELECT:   Specify which modules have been selected for the HBR data,
;                  fix or intarr(2), (3=Modules 1-4, 7=Module 7)
;
;        REV:      HEAO satellite revolution number(s), fix or intarr().
;
;        TARGET:   Name(s) of celestial targets, string or strarr().
;                  (e.g. 'Cyg X-1')
;
; OUTPUTS:
;        A structure or an array of structures is returned for each requested HBR
;        data file found in the database.  The tags of this structure are:
;
;             SLAC:     Structure describing the location of the file in
;                       the SLAC silos. The tags of this structure are:
;
;                       volser:   Volume serial number
;                       seq:      Sequence number
;
;             NRL:      Structure describing the location of the file at NRL.
;                       The tags of this structure are:
;
;                       seq:      Sequence number of the ANALOG tape ..
;                       tape:     Tape number of the DIGITIZED tape ..
;                       file:     File number on the DIGITIZED tape ..
;                                 .. containing this HBR data file.
;
;             chron:    Structure describing when the HBR data was downlinked
;                       to the ground station. The tags of this structure are:
;
;                       dd:       Day of the month (1-31)
;                       mn:       Month (1-12)
;                       yy:       Year (1977-1978)
;                       hh:       Hour (0:23)
;                       mm:       Minute (0:59)
;                       ss:       Seconds (0:59)
;                       doy:      Day of the year (1:365)
;                       JD:       Julian day number, long
;
;             mode:     Structure describing the current modes of the HEAO
;                       electronics and satellite. The tags of this structure are:
;
;                       config:   String describing K. Woods configuration notes
;                       HBR:      Mode of HEAO Random Decommutator,
;                                 {'bit','frame' or 'word')
;                       PM:       Describes which modules have been selected for
;                                 HBR data,(3 = Scan modules, 1-4; 7 = Module 7).
;                       NRZ:      Mode of the NRZ data, (5 = 5ms; 320 = 320ms).
;                       sat:      Describes the state of the satellite,
;                                 ('S' = spinning/scanning; 'P' = pointing)
;
;             rev:      HEAO satellite revolution number, integer.
;
;             pass:     Ground station pass abbreviation, ('H' = Hawaii;
;                       'G' = 'Guam';...).
;
;             length:   Length of the data in MINUTES, float.
;
;             target:   Description of the celestial target, string.
;
;             comments: Miscellaneous comments, string.
;
; COMMON BLOCKS:
;        DEF_HBRDBS:    Contains the HBR database information.
;
; RESTRICTIONS:
;        The DEF_HBRDBS routine must be called once, before calling
;        this routine, to set up the HBR database.
;
; PROCEDURE:
;        If a search keyword is specified by an array, then all array elements
;        are ORed together in the database search.  Multiple keywords, if they
;        are so specified, are ANDed together in the database search.
;        If NO parameter is provided, then HBRINFO switches to interactive mode.
;        A widget menu will appear allowing the USER to specify various search
;        parameters. If any entries are found following the aformentioned
;        search prescription, then the associated structure(s) are returned.
;        If NO entries are found, then a -1 is returned.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August, 1995.
;        26-SEP-1995    Replaced hbrsilo.dat with hbrdbs.sav; changed pro ->
;                       function. Eliminated NRL and SLAC output keywords.
;                       Added multiple search keywords and interactive mode.
;        27-SEP-1995    Improved search algorithm; search for sub-text
;                       instead of exact matches.
;        07-AUG-1996    Eliminate call to VERSION().
;-
function HBRINFO,  FILE=File, SLACVOL=SLACvol, SLACSEQ=SLACseq, NRLSEQ=NRLseq,$
                   NRLTAPE=NRLtape, NRLFILE=NRLfile, DATE=Date, TIME=Time, $
                   DOY=DoY, HBRM=HBRm, NRZM=NRZm, SELECT=Select, SATM=Satm, $
                   REV=Rev, TARGET=Target

         common DEF_HBRDBS

         nk   = 0
         if keyword_set(File)     then nk=nk+1 else File='*'
         if keyword_set(SLACvol)  then nk=nk+1 else SLACvol='*'
         if keyword_set(SLACseq)  then nk=nk+1 else SLACseq='*'
         if keyword_set(NRLseq)   then nk=nk+1 else NRLseq='*'
         if keyword_set(NRLtape)  then nk=nk+1 else NRLtape='*'
         if keyword_set(NRLfile)  then nk=nk+1 else NRLfile='*'
         if keyword_set(Date)     then nk=nk+1 else Date='*-*-*'
         if keyword_set(Time)     then nk=nk+1 else Time='*:*:*'
         if keyword_set(DoY)      then nk=nk+1 else DoY='*'
         if keyword_set(HBRm)     then nk=nk+1 else HBRm='*'
         if keyword_set(NRZm)     then nk=nk+1 else NRZm='*'
         if keyword_set(Select)   then nk=nk+1 else Select='*'
         if keyword_set(Satm)     then nk=nk+1 else Satm='*'
         if keyword_set(Rev)      then nk=nk+1 else Rev='*'
         if keyword_set(Target)   then nk=nk+1 else Target='*'

         if (nk gt 0) then goto, SEARCH_

QUSER:   Q_Def = [ $
              'Filename (sss_tn_fn)','*',$
              'SLAC vol. serial #','*',$
              'SLAC sequence #','*',$
              'NRL sequence #','*',$
              'NRL mag tape #','*',$
              'NRL file #','*',$
              'Date (mm-dd-yy)','*-*-*',$
              'Time (hh:mm:ss)','*:*:*',$
              'Day of the Year (1-365)','*',$
              'HBR data mode (B=bit, F=Frame, W=Word)','*',$
              'NRZ data mode (5=5ms, 320=320ms)','*',$
              'Selected modules (3=mods 1-4, 7=mod 7)','*',$
              'HEAO satellite mode (S=scanning, P=pointing)','*',$
              'HEAO satellite revolution number','*',$
              'Target name (e.g. Cyg X-1)','*' ]
         nQs  = N_ELEMENTS(Q_Def)/2
         Q_Def= REFORM( Q_Def, 2, nQs, /OVERWRITE )
         Qs   = REFORM(Q_def(0,*))
         Defs = REFORM(Q_def(1,*))

         rp   = XQUERY(Qs, Defs, TITLE='HBR Database Search Parameters')
         if (N_ELEMENTS(rp) eq 1) then return,-1

;   Stuff rp into appropriate keywords

         rp        = strupcase(strcompress(rp,/REMOVE_ALL))
         File      = rp(0)
         SLACvol   = rp(1)
         SLACseq   = rp(2)
         NRLseq    = rp(3)
         NRLtape   = rp(4)
         NRLfile   = rp(5)
         Date      = rp(6)
         Time      = rp(7)
         DoY       = rp(8)
         HBRm      = rp(9)
         NRZm      = rp(10)
         Select    = rp(11)
         Satm      = rp(12)
         Rev       = rp(13)
         Target    = rp(14)

SEARCH_:

         ndbs      = N_ELEMENTS(hbrdbs_)
         inds      = indgen(ndbs)

;______________________________________________________________________________
;
;   Search on SIMPLE keywords

         keys      =['File'    ,$
                     'SLACvol' ,$
                     'SLACseq' ,$
                     'NRLseq'  ,$
                     'NRLtape' ,$
                     'NRLfile' ,$
                     'DoY'     ,$
                     'HBRm'    ,$
                     'NRZm'    ,$
                     'Select'  ,$
                     'Satm'    ,$
                     'Rev'     ,$
                     'Target'  ]
         nk        = n_elements(keys)
         for k=0,nk-1 do begin

         ;    Assign current keyword to the "search text" variable, txt

              case keys(k) of
               'File'    : txt = File
               'SLACvol' : txt = SLACvol
               'SLACseq' : txt = SLACseq
               'NRLseq'  : txt = NRLseq
               'NRLtape' : txt = NRLtape
               'NRLfile' : txt = NRLfile
               'DoY'     : txt = DoY
               'HBRm'    : txt = HBRm
               'NRZm'    : txt = NRZm
               'Select'  : txt = Select
               'Satm'    : txt = Satm
               'Rev'     : txt = Rev
               'Target'  : txt = Target
              endcase

         ;    See if we need to search database for this keyword
         ;    (i.e. <> wildcard,* or null string,'')

              txt       = STRUPCASE(STRCOMPRESS(txt,/REMOVE_ALL))
              ntxt      = N_ELEMENTS(txt)
              if (ntxt eq 1) then begin
                   txt  = txt(0)
                   pos  = strpos(txt,'*')
                   if (pos ne -1) or (txt eq '') then ntxt=0
              endif
              if (ntxt eq 0) then goto, SKIP

         ;    Convert/parse "search text" variable, txt into
         ;    its appropriate type/form.  Assign database array
         ;    to the "target" of the search, src.

              VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
              case keys(k) of
               'File'    : begin
                             if VERSION_OS eq 'win' $
                             then tok='\' else tok='/'
                             src  = hbrdbs_(*).name
                             for j=0,ntxt-1 do begin
                              pos       = rstrpos(txt(j),tok)
                              if (pos ne -1) then txt(j)=strmid(txt(j),pos+1,1000)
                              pos       = rstrpos(txt(j),'.')
                              if (pos ne -1) then txt(j) = strmid(txt(j),0,pos)
                              txt(j)    = STRCOMPRESS(txt(j),/REMOVE_ALL)
                             endfor
                           end
               'SLACvol' : src    = hbrdbs_(*).SLAC.volser
               'SLACseq' : begin
                             src  = hbrdbs_(*).SLAC.seq
                             txt  = fix(txt)
                           end
               'NRLseq'  : begin
                             src  = hbrdbs_(*).NRL.seq
                             txt  = fix(txt)
                           end
               'NRLtape' : begin
                             src  = hbrdbs_(*).NRL.tape
                             txt  = fix(txt)
                           end
               'NRLfile' : begin
                             src  = hbrdbs_(*).NRL.file
                             txt  = fix(txt)
                           end
               'DoY'     : begin
                             src  = hbrdbs_(*).chron.doy
                             txt  = fix(txt)
                           end
               'HBRm'    : begin
                             src  = hbrdbs_(*).mode.hbr
                             case txt of
                                  'B' : txt='bit'
                                  'F' : txt='frame'
                                  'W' : txt='word'
                                  else: txt=''
                             endcase
                           end
               'NRZm'    : begin
                             src  = hbrdbs_(*).mode.nrz
                             txt  = fix(txt)
                           end
               'Select'  : begin
                             src  = hbrdbs_(*).mode.pm
                             txt  = fix(txt)
                           end
               'Satm'    : src    = hbrdbs_(*).mode.sat
               'Rev'     : begin
                             src  = hbrdbs_(*).rev
                             txt  = fix(txt)
                           end
               'Target'  : begin
                             src  = STRUPCASE(hbrdbs_(*).target)
                             src  = STRCOMPRESS(src,/REMOVE_ALL)
                           end
              endcase

         ;    Finally, actually search the "target", src for
         ;    the "search text", txt for each txt element

              nf   = 0
              for i=0,ntxt-1 do begin
                   pos       = strpos( src(inds), txt(i) )
                   here      = where( pos ne -1, nfind )
                   if (nfind gt 0) then begin
                        if (nf eq 0) then jnds = inds(here) $
                        else jnds=[jnds,inds(here)]
                        nf   = nf + nfind
                   endif
              endfor
              if (nf eq 0) then return,-1

         ;    Only need unique indices to the "target" array.

              i    = UNIQ(jnds)
              inds = jnds(i)

         ;    These indices, inds actually point to the appropriate
         ;    elements in the HBR database.
SKIP:
         endfor

;______________________________________________________________________________
;
;   Search on DATE keyword


;   Assign current keyword to the "search text" variable, txt

         txt  = date

;   See if we need to search database for this keyword
;   (i.e. <> wildcard,* or null string,'')

         txt       = STRUPCASE(STRCOMPRESS(txt,/REMOVE_ALL))
         ntxt      = N_ELEMENTS(txt)
         if (ntxt eq 1) then $
              if (txt eq '*-*-*') or (txt eq '') then ntxt=0
         if (ntxt eq 0) then goto, SKIPD

         txt  = txt(0)       ; Only allow 1 date parameter
         ntxt = 1

;   Convert/parse "search text" variable, txt into
;   its appropriate type/form.  Assign database array
;   to the "target" of the search, src.

         ntxt2     = 0

;    Extract MONTH key

         posM = strpos(txt,'-')
         if (posM ne -1) then begin
              mn   = strmid(txt,0,posM)
              mn   = strcompress(mn,/REMOVE_ALL)
              if (mn eq '*') or (mn eq '') then goto, GETDAY
              if (ntxt2 eq 0) then begin
                   txt2 = fix(mn)
                   type2= 'mn'
              endif else begin
                   txt2 = [txt2,fix(mn)]
                   type2= [type2,'mn']
              endelse
              ntxt2     = ntxt2 + 1
         endif else goto, NEXTDATE

;    Extract all DAY keys

GETDAY:  posD = strpos(txt,'-',posM+1)
         if (posD ne -1) then begin
              dd   = strmid(txt,posM+1,posD-posM-1)
              dd   = strcompress(dd,/REMOVE_ALL)
              if (dd eq '*') or (dd eq '') then goto, GETYR
              if (ntxt2 eq 0) then begin
                   txt2 = fix(dd)
                   type2= 'dd'
              endif else begin
                   txt2 = [txt2,fix(dd)]
                   type2= [type2,'dd']
              endelse
              ntxt2     = ntxt2 + 1
         endif else goto, NEXTDATE

;   Extract all YEAR keys

GETYR:   yy   = strmid(txt,posD+1,1000)
         yy   = strcompress(yy,/REMOVE_ALL)
         if (yy eq '*') or (yy eq '') then goto, NEXTDATE
         if (ntxt2 eq 0) then begin
              txt2 = fix(yy) + 1900
              type2= 'yy'
         endif else begin
              txt2 = [txt2,fix(yy)+1900]
              type2= [type2,'yy']
         endelse
         ntxt2     = ntxt2 + 1

NEXTDATE:

         if (ntxt2 eq 0) then goto, SKIPD

         for k=0,2 do begin
              case k of
              0    : begin
                        here = where( type2 eq 'mn', ntxt )
                        src  = hbrdbs_(*).chron.mn
                     end
              1    : begin
                        here = where( type2 eq 'dd', ntxt )
                        src  = hbrdbs_(*).chron.dd
                     end
              2    : begin
                        here = where( type2 eq 'yy', ntxt )
                        src  = hbrdbs_(*).chron.yy
                     end
              endcase

              if (ntxt gt 0) then begin
                   txt  = txt2(here)

                   nf   = 0
                   for i=0,ntxt-1 do begin
                        pos       = strpos( src(inds), txt(i) )
                        here      = where( pos ne -1, nfind )
                        if (nfind gt 0) then begin
                             if (nf eq 0) then jnds = inds(here) $
                             else jnds=[jnds,inds(here)]
                             nf   = nf + nfind
                        endif
                   endfor
                   if (nf eq 0) then return,-1

                   i    = UNIQ(jnds)
                   inds = jnds(i)

              endif
         endfor
SKIPD:

;______________________________________________________________________________
;
;   Search on TIME keyword


;   Assign current keyword to the "search text" variable, txt

         txt  = time

;   See if we need to search database for this keyword
;   (i.e. <> wildcard,* or null string,'')

         txt       = STRUPCASE(STRCOMPRESS(txt,/REMOVE_ALL))
         ntxt      = N_ELEMENTS(txt)
         if (ntxt eq 1) then $
              if (txt eq '*:*:*') or (txt eq '') then ntxt=0
         if (ntxt eq 0) then goto, SKIPT

         txt  = txt(0)       ; Only allow 1 time parameter
         ntxt = 1

;   Convert/parse "search text" variable, txt into
;   its appropriate type/form.  Assign database array
;   to the "target" of the search, src.

         ntxt2     = 0

;    Extract HOUR key

         posH = strpos(txt,':')
         if (posH ne -1) then begin
              hh   = strmid(txt,0,posH)
              hh   = strcompress(hh,/REMOVE_ALL)
              if (hh eq '*') or (hh eq '') then goto, GETMIN
              if (ntxt2 eq 0) then begin
                   txt2 = fix(hh)
                   type2= 'hh'
              endif else begin
                   txt2 = [txt2,fix(hh)]
                   type2= [type2,'hh']
              endelse
              ntxt2     = ntxt2 + 1
         endif else goto, NEXTTIME

;    Extract all DAY keys

GETMIN:  posM = strpos(txt,':',posH+1)
         if (posM ne -1) then begin
              mm   = strmid(txt,posH+1,posM-posH-1)
              mm   = strcompress(mm,/REMOVE_ALL)
              if (mm eq '*') or (mm eq '') then goto, GETSEC
              if (ntxt2 eq 0) then begin
                   txt2 = fix(mm)
                   type2= 'mm'
              endif else begin
                   txt2 = [txt2,fix(mm)]
                   type2= [type2,'mm']
              endelse
              ntxt2     = ntxt2 + 1
         endif else goto, NEXTTIME

;   Extract all YEAR keys

GETSEC:  ss   = strmid(txt,posM+1,1000)
         ss   = strcompress(ss,/REMOVE_ALL)
         if (ss eq '*') or (ss eq '') then goto, NEXTTIME
         if (ntxt2 eq 0) then begin
              txt2 = fix(ss) + 1900
              type2= 'ss'
         endif else begin
              txt2 = [txt2,fix(ss)+1900]
              type2= [type2,'ss']
         endelse
         ntxt2     = ntxt2 + 1

NEXTTIME:
         if (ntxt2 eq 0) then goto, SKIPT

         for k=0,2 do begin
              case k of
              0    : begin
                        here = where( type2 eq 'hh', ntxt )
                        src  = hbrdbs_(*).chron.hh
                     end
              1    : begin
                        here = where( type2 eq 'mm', ntxt )
                        src  = hbrdbs_(*).chron.mm
                     end
              2    : begin
                        here = where( type2 eq 'ss', ntxt )
                        src  = hbrdbs_(*).chron.ss
                     end
              endcase

              if (ntxt gt 0) then begin
                   txt  = txt2(here)

                   nf   = 0
                   for i=0,ntxt-1 do begin
                        pos       = strpos( src(inds), txt(i) )
                        here      = where( pos ne -1, nfind )
                        if (nfind gt 0) then begin
                             if (nf eq 0) then jnds = inds(here) $
                             else jnds=[jnds,inds(here)]
                             nf   = nf + nfind
                        endif
                   endfor
                   if (nf eq 0) then return,-1

                   i    = UNIQ(jnds)
                   inds = jnds(i)

              endif
         endfor
SKIPT:

         return, hbrdbs_(inds)
end
