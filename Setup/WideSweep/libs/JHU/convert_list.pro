;-------------------------------------------------------------
;+
; NAME:
;       CONVERT_LIST
; PURPOSE:
;       Convert a text description of numbers to a numeric array.
; CATEGORY:
; CALLING SEQUENCE:
;       arr = convert_list(txt)
; INPUTS:
;       txt = text string or array.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       arr = array of numbers.         out
; COMMON BLOCKS:
; NOTES:
;       Notes: txt contains a list of numbers.  A range may
;         be indicated by the syntax b:e where b = beginning,
;         and e = end of the range.  A step, s, may also be
;         given: b:e:s.  An example list might be:
;         txt='.2:1:.2,3:8:2,1.234,2.345,3.456'
;         print,convert_list(txt) gives the array:
;          0.200, 0.400, 0.600, 0.800, 1.000, 3.000,
;          5.000, 7.000, 1.234, 2.345, 3.456
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Dec 13
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function convert_list, txt0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a text description of numbers to a numeric array.'
	  print,' arr = convert_list(txt)'
	  print,'   txt = text string or array.     in'
	  print,'   arr = array of numbers.         out'
	  print,' Notes: txt contains a list of numbers.  A range may'
	  print,'   be indicated by the syntax b:e where b = beginning,'
	  print,'   and e = end of the range.  A step, s, may also be'
	  print,'   given: b:e:s.  An example list might be:'
	  print,"   txt='.2:1:.2,3:8:2,1.234,2.345,3.456'"
	  print,'   print,convert_list(txt) gives the array:'
	  print,'    0.200, 0.400, 0.600, 0.800, 1.000, 3.000,'
	  print,'    5.000, 7.000, 1.234, 2.345, 3.456'
	  return, ''
	endif
 
	;--------  Replace all commas with spaces  ------
	txt = repchr(txt0,',')		; Commas.
 
	;--------  Split into single items  -------------
	wordarray, txt, w
 
	;--------  Loop through items converting to indices  ------
	arr = [0.]					; Get array started.
 
	for i = 0, n_elements(w)-1 do begin
	  t1 = getwrd(w(i),0, delim=':')		; Get 1st value.
	  t2 = getwrd('',1)				; Get 2nd value.
	  t3 = getwrd('',2)				; Get 3rd value.
	  t1 = t1 + 0.					; Convert to numbers.
	  if t2 eq '' then t2 = t1 else t2 = t2 + 0.	; Def = t1.
	  if t3 eq '' then begin			; t3 is NULL, set def.
	    if (t2+0) lt (t1+0) then begin		; Step backward?
	      t3 = -1.					; Yes.
	    endif else begin
	      t3 = 1.					; No.
	    endelse
	  endif else begin
	    t3 = t3 + 0.				; t3 is given.
	  endelse
	  arr = [arr, makex(t1,t2,t3)]			; Add numbers.
	endfor
 
	arr = arr(1:*)		; Trim off first value.
 
	return, arr
 
	end
