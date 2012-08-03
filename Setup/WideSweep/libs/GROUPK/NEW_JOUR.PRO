;+
; NAME:
;        NEW_JOURNAL
;
; PURPOSE:
;        Closes any open journal file and opens a new one.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        NEW_JOURNAL [,Name]
;
; OPTIONAL INPUTS:
;        Name:     A string containing the name of the journal file to be opened.
;                  If Name is not supplied then the system's time is used to
;                  construct the name of the form: MNDDHHMM.log where,
;                  MN=Month (01-12), DD=Day (01-31), HH=Hour (00-23)
;                  and MM=Minutes (00-59).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;        PATH      A string containing the path of the new journal file.  The PATH
;                  string is appended to the beginning of the Name string and the
;                  resulting string is used as the argument to the JOURNAL routine.
;                  (''=Default)
;
; EXAMPLE:
;        To begin journaling a "daily" journal file, enter:
;
;        NEW_JOURNAL
;
;        Any commands entered at the IDL prompt are recorded in the file until
;        IDL is exited or the JOURNAL command is entered without an argument.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;-
pro NEW_JOURNAL, Name, PATH=PATH

     if (!JOURNAL ne 0) then journal

     NP = N_PARAMS()
     if (NP eq 0) then begin


          dt_arr = BIN_DATE(SYSTIME())           ; Extract the date & time
          dt_arr = dt_arr(1:4)
          dt_str = STRING(dt_arr,FORMAT='(4I2)')

          i_last = strpos(dt_str,' ')            ; Replace any blanks with 0's
          while (i_last ne -1) do begin
              strput,dt_str,'0',i_last
              i_last = strpos(dt_str,' ',i_last)
          endwhile

          Name   = dt_str+'.log'
     endif

     if (keyword_set(PATH)) then filen=PATH+Name else filen=Name

     ;   Form journal filename
     message,'Starting journal file:'+filen,/INF,/NONAME
     journal,filen
end
