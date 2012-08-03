;-------------------------------------------------------------
;+
; NAME:
;       JS2V
; PURPOSE:
;       Read a time (in "Julian seconds") vs value file.
; CATEGORY:
; CALLING SEQUENCE:
;       js2v, file, time, data
; INPUTS:
;       file = name of file containing time vs value data.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       time = Array of times in "Julian Seconds".           out
;         (Seconds since 0:00 1 Jan 2000).
;       data = Array of values at those time.                out
; COMMON BLOCKS:
; NOTES:
;       Notes: File format: Lines starting with * or ;, and null
;         lines are considered comment lines and ignored.
;         Data lines have a date/time string followed by a value
;         which must be the last item on the line.  Ex:
;         Thu Apr  1 09:32:51 1993  23.45
;         Date/time strings have Year, Month, Day, and time, with
;         the month being a name (at least the first 3 letters).
;       
;         To interpolate at time t (in Jul. Sec) using these arrays:
;         v = interpol(data, time, t)
;         PLOT does not work very well with Julian Seconds.
;         This is an IDL limitation related to single precision.
;         One fix is to plot relative time: plot,ta-ta(0),va
;         where ta and va are time and interpolated value arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Apr, 1993
;	R. Sterner, 28 Apr, 1993 --- changed from a function to a procedure.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro js2v, file, time, data, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Read a time (in "Julian seconds") vs value file.'
	  print,' js2v, file, time, data'
	  print,'   file = name of file containing time vs value data.   in'
	  print,'   time = Array of times in "Julian Seconds".           out'
	  print,'     (Seconds since 0:00 1 Jan 2000).
	  print,'   data = Array of values at those time.                out'
	  print,' Notes: File format: Lines starting with * or ;, and null'
	  print,'   lines are considered comment lines and ignored.'
	  print,'   Data lines have a date/time string followed by a value'
	  print,'   which must be the last item on the line.  Ex:'
	  print,'   Thu Apr  1 09:32:51 1993  23.45'
	  print,'   Date/time strings have Year, Month, Day, and time, with'
	  print,'   the month being a name (at least the first 3 letters).'
	  print,' '
	  print,'   To interpolate at time t (in Jul. Sec) using these arrays:'
	  print,'   v = interpol(data, time, t)
 	  print,'   PLOT does not work very well with Julian Seconds.'
	  print,'   This is an IDL limitation related to single precision.'
	  print,'   One fix is to plot relative time: plot,ta-ta(0),va'
	  print,'   where ta and va are time and interpolated value arrays.'
	  return
	endif
 
	;---------  Read in time vs value file  -----------------
	a = getfile(file, error=err)
	;--------  Make sure file was read ok  --------------
	if err ne 0 then begin
	  print,' Error in js2v: file not opened. File: '+file
	  return
	endif
	one = strmid(a,0,1)	; Pick off first character.
	;--------  Make sure file has some non-comment lines  ------
	w = where((one ne '*') or (one ne ';'), c)
	if c eq 0 then begin
	  print,' Error in js2v: No non-comment lines in the file '+file
	  return
	endif
	a = a(w)		; Drop comment lines.
	;-------  Make sure file has some data lines  --------
	w = where(a ne '', c)
        if c eq 0 then begin
          print,' Error in js2v: No data lines in the file '+file
          return
        endif
	a = a(w)		; Drop null lines.
	n = n_elements(a)	; Number of data values.
	time = dblarr(n)		; Storage for JS and values.
	data = dblarr(n)
	;---------  Loop through data lines  -----------
	for i = 0, n-1 do begin	; Process each data line.
	  ;----------  Make sure enough items were given  ---------
	  if nwrds(a(i)) lt 4 then begin
	    print,' Error in js2v: Data line must have at least 4 items:'
	    print,'   Year, Month, Day, Value (Time assumed 0:00:00).'
	    print,'   Data line: '+a(i)
	    print,'   From file: '+file
	    return
	  endif
	  ;--------  Pick off date/time and value  -----------
	  t=getwrd(a(i),-9,-1,/last)	; Pick off all but last item.
	  v=getwrd('',/last)		; Get last item.
	  ;----------  Check if date/time OK  ------------------
	  if not dt_tm_chk(t+' 0:00') then begin   ; 1 or 2 times ok, 0 not.
	    print,' Error in js2v: data line time format error.'
	    print,'   Data line: '+a(i)
	    print,'   From file: '+file
	    return
	  endif
	  ;--------  Passed all checks  -----------------
	  time(i) = dt_tm_tojs(t)	; Convert and store time.
	  data(i) = v + 0.d0		; Convert and store value.
	endfor
 
	return
 
	end
