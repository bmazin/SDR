;-------------------------------------------------------------
;+
; NAME:
;       CONVERT_IND
; PURPOSE:
;       Convert a text description of runs of indices to numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       ind = convert_ind(txt)
; INPUTS:
;       txt = text string or array.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ind = long array of indices.    out
; COMMON BLOCKS:
; NOTES:
;       Notes: txt contains a list of integers.  A range may
;         be indicated by the syntax b:e where b = beginning,
;         and e = end of the range.  A step, s, may also be
;         given: b:e:s.  An example list might be:
;         txt=['2,3,4,10:20:2,25:30','34,35,38:40','50:100:10,111']
;         print,convert_ind(txt) gives:
;         2   3   4  10  12  14  16  18  20  25  26  27  28  29  30
;         34  35  38  39  40  50  60  70  80  90 100 111
;	  Inverse of LISTRUNS.PRO.
; MODIFICATION HISTORY:
;       R. Sterner, 24 Jul, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function convert_ind, txt0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a text description of runs of indices to numbers.'
	  print,' ind = convert_ind(txt)'
	  print,'   txt = text string or array.     in'
	  print,'   ind = long array of indices.    out'
	  print,' Notes: txt contains a list of integers.  A range may'
	  print,'   be indicated by the syntax b:e where b = beginning,'
	  print,'   and e = end of the range.  A step, s, may also be'
	  print,'   given: b:e:s.  An example list might be:'
	  print,"   txt=['2,3,4,10:20:2,25:30','34,35,38:40','50:100:10,111']"
	  print,'   print,convert_ind(txt) gives:'
	  print,'   2   3   4  10  12  14  16  18  20  25  26  27  28  29  30'
	  print,'   34  35  38  39  40  50  60  70  80  90 100 111'
	  print,'   Inverse of LISTRUNS.PRO.'
	  return, ''
	endif
 
	;--------  Replace all commas with spaces  ------
	txt = repchr(txt0,',')		; Commas.
 
	;--------  Split into single items  -------------
	wordarray, txt, w
 
	;--------  Loop through items converting to indices  ------
	ind = [0L]					; Get array started.
 
	for i = 0, n_elements(w)-1 do begin
	  t1 = getwrd(w(i),0, delim=':')		; Get 1st value.
	  t2 = getwrd('',1)				; Get 2nd value.
	  t3 = getwrd('',2)				; Get 3rd value.
	  t1 = t1 + 0L					; Convert to numbers.
	  if t2 eq '' then t2 = t1 else t2 = t2 + 0L	; Def = t1.
	  if t3 eq '' then begin			; t3 is NULL, set def.
	    if (t2+0) lt (t1+0) then begin		; Step backward?
	      t3 = -1					; Yes.
	    endif else begin
	      t3 = 1					; No.
	    endelse
	  endif else begin
	    t3 = t3 + 0L				; t3 is given.
	  endelse
	  ind = [ind, makei(t1,t2,t3)]			; Add indices.
	endfor
 
	ind = ind(1:*)		; Trim off first value.
 
	return, ind
 
	end
