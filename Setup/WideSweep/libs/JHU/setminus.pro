;-------------------------------------------------------------
;+
; NAME:
;       SETMINUS
; PURPOSE:
;       Eliminate elements from a set that are also in another set.
; CATEGORY:
; CALLING SEQUENCE:
;       c = setminus(a,b)
; INPUTS:
;       a = set (array) to process.                in
;       b = set (array) of elements to eliminate.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       c = resulting set (array).                 out
; COMMON BLOCKS:
; NOTES:
;       Notes: works for any type arrays.
;         Will not remove the element of a one element array.
;         This is because IDL does not have empty arrays
;         (corresponding to empty sets).
; MODIFICATION HISTORY:
;       R. Sterner, 7 Aug, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function setminus, a, b, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Eliminate elements from a set that are also in another set.'
	  print,' c = setminus(a,b)'
	  print,'   a = set (array) to process.                in'
	  print,'   b = set (array) of elements to eliminate.  in'
	  print,'   c = resulting set (array).                 out'
	  print,' Notes: works for any type arrays.'
	  print,'   Will not remove the element of a one element array.'
	  print,'   This is because IDL does not have empty arrays'
	  print,'   (corresponding to empty sets).'
	  return, -1
	endif
 
	c = a
	for i = 0, n_elements(b)-1 do begin
	  w = where(c ne b(i), count)
	  if count gt 0 then c = c(w)
	endfor
	return, c
	end
