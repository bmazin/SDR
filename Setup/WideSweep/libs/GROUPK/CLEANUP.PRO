;+
; NAME:
;        CLEAN_UP
;
; PURPOSE:
;        Cleans up "garbage" log files created by the
;        NEW_JOURNAL routine.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        CLEAN_UP, LogPath
;
; INPUTS:
;
;        LogPath:  Path to your existing NEW_JOURNAL log files,
;                  (e.g. 'd:\rsi\idl40\bob\log\')
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        TODAY:    Mark all log files created today for possible deletion, (0=Default).
;                  If this keyword is set then the CUTOFF keyword is ignored.
;
;        CUTOFF:   The largest NEW_JOURNAL log file in BYTES to potentially
;                  delete, (1000=Default).
;
;        ALL:      Set this keyword to mark ALL log files found, (0=Default).
;
;        NOCONFIRM:     Set this keyword to AUTOMATICALLY delete any
;                  NEW_JOURNAL log files smaller than CUTOFF.  The USER
;                  will NOT be notified, (0=Default).
;
; PROCEDURE:
;        A list of NEW_JOURNAL files that are smaller than CUTOFF is displayed
;        to the USER.  The USER may then select any of these files to view
;        their contents and either keep or delete the log files.
;
; RESTRICTIONS:
;        Currently the only OS platforms supported by this routine
;        are: Windows/DOS and Unix.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1995.
;        21-AUG-1995    Keep string lengths < 80 characters, added TODAY keyword,
;                       delete log files together.
;        27-SEP-1995    Eliminated text-wrap for efficiency.  Read in text more
;                       efficiently into arrays; concatenation is VERY inefficient.
;                       Added ALL keyword.
;        29-SEP-1995    Only display first 900 lines of text for efficiency.  A
;                       More ... line will appear if the log file is > 900 lines.
;                       Check for 0-length files.
;        06-DEC-1995    Forgot to close any 0-length files before attempting to
;                       delete them.
;        07-AUG-1996    Eliminate call to VERSION().
;-
pro CLEANUP, LogPath, CUTOFF=Cutoff, NOCONFIRM=Noconfirm, TODAY=Today, ALL=All

         NP        = N_PARAMS()
         if (NP ne 1) then message,'Must be called with 1 parameter: LogPath'

;   Find all log files

         files     = findfile(LogPath+'*.log')
         names     = strmid(files,strlen(LogPath),100)
         dates     = long('0'+names)

;   Determine which ones are NEW_JOURNAL log files

         DAY1      = 01010000L         ; "Smallest" date number, corresponding to
                                       ;    January 1st, 0 hours, 0 minutes.

         here      = where(dates ge DAY1,nkeep)
         if (nkeep eq 0) then return

         files     = files(here)
         names     = names(here)
         dates     = dates(here)

;   If the TODAY keyword is set, find the corresponding log files

         dt_arr = BIN_DATE(SYSTIME())            ; Extract the date & time
         dt_arr = [dt_arr(1:2),0,0]
         dt_str = STRING(dt_arr,FORMAT='(4I2)')

         i_last = strpos(dt_str,' ')             ; Replace any blanks with 0's
         while (i_last ne -1) do begin
             strput,dt_str,'0',i_last
             i_last = strpos(dt_str,' ',i_last)
         endwhile
         DAYcur    = long(dt_str)

         if keyword_set(TODAY) then begin

              here      = where(dates ge DAYcur,nkeep)
              if (nkeep eq 0) then return

              files     = files(here)
              names     = names(here)
              dates     = dates(here)
         endif

;   Sort the dates and corresponding arrays

         here      = sort(dates)
         here      = reverse(here)     ; Sort in descending order
         files     = files(here)
         names     = names(here)
         dates     = dates(here)

;   Extract their file sizes

         fsize     = lonarr(nkeep)
         iss_j     = FSTAT(!journal)
         for i=0,nkeep-1 do begin
              openr,lu,files(i),/GET_LUN
              iss       = FSTAT(lu)
              if (strupcase(iss.NAME) ne $
                  strupcase(iss_j.NAME)) then fsize(i) = iss.SIZE $
              else fsize(i) = -1
              free_lun,lu
         endfor

;   Eliminate any currently opened log files

         DAYlast = DAYcur + 9999
         here = where( (fsize gt 0) or ( (fsize eq 0) and $
                     ( (dates lt DAYcur) or (dates gt DAYlast))), nkeep )

         if (nkeep eq 0) then return
         files     = files(here)
         names     = names(here)
         dates     = dates(here)
         fsize     = fsize(here)

;   Select NEW_JOURNAL log files smaller than CUTOFF

         if (NOT keyword_set(ALL)) and $
            (NOT keyword_set(TODAY)) then begin
              if (N_ELEMENTS(Cutoff) eq 0) then Cutoff = 1000   ; bytes
              here = WHERE( fsize lt CUTOFF, nkeep )
              if (nkeep eq 0) then return

              files = files(here)
              names = names(here)
              fsize = fsize(here)
         endif

         view  = strarr(nkeep)
         view(*) = strpad('No',14,12)

         line = ''
         VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
         case VERSION_OS of
              'win'     : delcmd = 'del'
              'vms'     : message,'vms platform not supported.'
              'mac'     : message,'MacOS platform not supported.'
              else      : delcmd = 'rm'
         endcase

;   Check AUTO-delete

         if keyword_set(NOCONFIRM) then begin
              rp = YNCANCEL('Are you sure?',$
                             TITLE='Deleting NEW_JOURNAL Log files...')
              case rp of
                   1 : SYSTEM, delcmd+' '+files
                   0 :
                  -1 : return
              endcase
         endif

;   Display list of NEW_JOURNAL log files to USER

         header = [ strpad('Journal file',20) + $
                    strpad('Size (bytes)',20) + $
                    strpad('Viewed ?',32)]
DEL:     i    = XLIST(names + '  ' + strtrim(fsize) + '  ' + view,$
                        TITLE='Select a Journal File',$
                        HEADER=header, /INDEX)
         if (i eq -1) then goto, RUNBAT
         lines= '' & line= ''
         openr,lu,files(i),/GET_LUN
         iss  = FSTAT(lu)
         if (iss.SIZE eq 0) then begin
              free_lun,lu
              goto, KILL
         endif
         POINT_LUN, -lu, pos

         nline     = 0
         repeat begin
              readf,lu,line
              nline     = nline + 1
         endrep until EOF(lu) or (nline gt 900)
         POINT_LUN, lu, pos

         lines     = strarr(nline)
         for j=0,nline-1 do begin
              readf,lu,line
              lines(j)  = strmid(line,0,80)
         endfor
         free_lun,lu
         if (nline gt 900) then lines = [lines,'More ...']

;   View selected NEW_JOURNAL log file and choose to discard or keep

         rp   = YNCANCEL(lines,TITLE='Delete Journal file, '+names(i)+'?',/ALIGN)
         case rp of
              1    : BEGIN
KILL:              if (N_ELEMENTS(dellist) eq 0) then dellist = files(i) $
                   else dellist = [dellist,files(i)]

                   ncur = N_ELEMENTS(names)
                   if (ncur eq 1) then goto, RUNBAT
                   icur = indgen(ncur)
                   here  = where( icur ne i )
                   files = files(here)
                   names = names(here)
                   fsize = fsize(here)
                   view  = view(here)
                   END
              0    : view(i) = strpad('Yes',14,11)
             -1    : return
         endcase
         goto, DEL

RUNBAT:  ndel = N_ELEMENTS(dellist)
         if (ndel gt 0) then SYSTEM, delcmd+' '+dellist, DT=ndel*0.2

end
