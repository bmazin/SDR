;-------------------------------------------------------------
;+
; NAME:
;       ARRAY_LIST
; PURPOSE:
;       List an array in a form useful to cut and paste.
; CATEGORY:
; CALLING SEQUENCE:
;       array_list, a
; INPUTS:
;       a = array to list.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=out Returned list in a text array.
;         FRONT=frnt Text to add to front (def=none).
;           Can space in and give a variable name: '  a = '
;           Use spaces, not tabs, to get correct line length.
;         INDENT=itxt Text string used to indent continued lines.
;            Default is 10 spaces.
;         /QUIET do not display list.
;         MAXLEN=mx Max length before line continue (def=72).
;           May be one longer for continued lines.
;         FORMAT=fmt Format for values (def=none).
;         /TRIM means trim leading and trailing 0s (and spaces).
;           Useful with FORMAT to get minimum strings.
;         TYPE=typ  Name of data type function (def=none).
;           Will apply to array.  Ex: uint([1,2,3])
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Nov 30
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro array_list, a, type=type, front=front, maxlen=maxlen, $
	  format=fmt, out=out, quiet=quiet, trim=trim, indent=itxt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' List an array in a form useful to cut and paste.'
	  print,' array_list, a'
	  print,'   a = array to list.       in'
	  print,' Keywords:'
	  print,'   OUT=out Returned list in a text array.'
	  print,'   FRONT=frnt Text to add to front (def=none).'
	  print,"     Can space in and give a variable name: '  a = '"
	  print,'     Use spaces, not tabs, to get correct line length.'
	  print,'   INDENT=itxt Text string used to indent continued lines.'
	  print,'      Default is 10 spaces.'
	  print,'   /QUIET do not display list.'
	  print,'   MAXLEN=mx Max length before line continue (def=72).'
	  print,'     May be one longer for continued lines.'
	  print,'   FORMAT=fmt Format for values (def=none).'
	  print,'   /TRIM means trim leading and trailing 0s (and spaces).'
	  print,'     Useful with FORMAT to get minimum strings.'
	  print,'   TYPE=typ  Name of data type function (def=none).'
	  print,'     Will apply to array.  Ex: uint([1,2,3])'
	  return
	endif
 
	;-----  Defaults  ----------
	if n_elements(type) eq 0 then type=''		; Type convers functn.
	typ = type
	if typ ne '' then typ=typ+'(' 
	if n_elements(front) eq 0 then front=''		; Front end.
	if n_elements(itxt) eq 0 then itxt='          '	; Indent text.
	if n_elements(maxlen) eq 0 then maxlen=72	; Max line length.
	if n_elements(fmt) eq 0 then fmt=''		; Format.
 
	;-----  Convert numbers to strings  ---------
	n = n_elements(a)			; How many elements?
	s = strarr(n)				; Storage for string version.
	;------  No format case  -------------
	if fmt eq '' then begin
	  wi = where((a mod 1) eq 0, ci)	; Find integers.
	  wf = where((a mod 1) ne 0, cf)	; Find floats.
	  ;----  Convert integers  ---------
	  if !version.release ge 5 then begin	; Use ulong64 if available.
	    if ci gt 0 then s(wi) = strtrim(ulong64(a(wi)),2)
	  endif else begin
	    if ci gt 0 then s(wi) = strtrim(long(a(wi)),2)
	  endelse
	  ;----  Convert floats  -----------
	  if cf gt 0 then begin
	    for j=0,cf-1 do s(wf(j)) = strtrm2(a(wf(j)),2,'0')	; Trm trlng 0s.
	  endif
	;-----  Use given format  -------------
	endif else begin
	  s = string(a,form=fmt)
	  if keyword_set(trim) then begin	; Trim leading and trailing 0s.
	    for j=0,n_elements(s)-1 do $
	      s(j) = strtrm2(s(j),2,'0')
	  endif
	endelse
 
	;-----  Start output string  -----------
	out = ['']				; Total output.
	line = front + typ + '['		; Start first line.
	len = strlen(line)			; Length.
	lst = n-1				; Index of last value.
	if typ eq '' then begin			; Deal with data type.
	  ltyp=0				; Length of termination string.
	  trm = ']'				; Termination string.
	endif else begin
	   ltyp=1				; Length of termination string.
	   trm = '])'				; Termination string.
	endelse
	
	;-----  Loop through all values  ----------
	for i=0, lst do begin			; Loop through values.
	  t = s(i)				; Next value.
	  if i lt lst then t=t+',' else t=t+trm	; Add separator.
	  ln = strlen(t)			; How long?
	  if (len+ln) gt (maxlen-ltyp) then begin  ; Line overflow.
	    out = [out,line+'$']		; Output line with continue.
	    line = itxt+t			; Indent value on next line.
	    len = strlen(line)
	  endif else begin			; OK to add value.
	    line = line + t			; Add value to current line.
	    len = len + ln
	  endelse
	endfor
	out = [out,line]			; Add last line.
 
	;-----  list result  ------------
	out = out(1:*)
	if not keyword_set(quiet) then begin
	  for i=0,n_elements(out)-1 do print,out(i)
	endif
 
	return
	end
