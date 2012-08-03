;-------------------------------------------------------------
;+
; NAME:
;       IN_COMMON
; PURPOSE:
;       Find elements of two arrays that are common (or not).
; CATEGORY:
; CALLING SEQUENCE:
;       res = in_common(list1, list2)
; INPUTS:
;       list1, list2 = arrays to compare.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         /inverse means return elements not in common.
; OUTPUTS:
;       res = returned array of common elements.  out
;         Scalar 0 means no elements found.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Dec 01
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function in_common, list1, list2, inverse=inverse, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find elements of two arrays that are common (or not).'
	  print,' res = in_common(list1, list2)'
	  print,'   list1, list2 = arrays to compare.         in'
	  print,'   res = returned array of common elements.  out'
	  print,'     Scalar 0 means no elements found.'
	  print,' Keywords:'
	  print,'   /inverse means return elements not in common.'
	  return,''
	endif
 
	lst1 = runlength(list1(sort(list1)))	; Squeeze out any repeats.
	lst2 = runlength(list2(sort(list2)))
 
	lst = [lst1,lst2]			; Merge.
	lst = lst(sort(lst))			; Sort merged list.
 
	a = lst eq shift(lst,1)			; Item eq last item?
	b = lst eq shift(lst,-1)		; Item eq next item?
 
	if keyword_set(inverse) then begin
	  w = where(a+b eq 0, c)		; Not in common.
	endif else begin
	  w = where(a+b eq 1, c)		; In common.
	endelse
 
	if c eq 0 then return, 0		; No elements found.
 
	return, runlength(lst(w))		; Squeeze out any repeats.
 
	end
