;-------------------------------------------------------------
;+
; NAME:
;       INTERSECT
; PURPOSE:
;       Return the elements common to two given arrays.
; CATEGORY:
; CALLING SEQUENCE:
;       z = intersect(x,y)
; INPUTS:
;       x, y = arrays (not necessarily same size).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       z = array of elements in common.            out
; COMMON BLOCKS:
; NOTES:
;       Note: if z is a scalar 0 then no elements were
;         in common.
; MODIFICATION HISTORY:
;       R. Sterner  19 Mar, 1986.
;       R. Sterner, 4 Mar, 1991 --- converted to IDL v2.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function intersect,x,y, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return the elements common to two given arrays.'
	  print,' z = intersect(x,y)'
	  print,'   x, y = arrays (not necessarily same size).  in'
	  print,'   z = array of elements in common.            out'
	  print,' Note: if z is a scalar 0 then no elements were'
	  print,'   in common.'
	  return, -1
	endif
 
	xs = runlength(x(sort(x)))	; Keep only unique elements.
	ys = runlength(y(sort(y)))
 
	zs = [xs,ys]			; Merge the 2 arrays.
	zs = zs(sort(zs))		; Sort.
 
	d = zs - shift(zs,1)		; Find differences between elements.
 
	w = where(d eq 0, count)	; Elements common to both arrays
					; occur twice, giving 0 diffs.
 
	if count eq 0 then return, 0	; Scalar 0 means no common elements.
	return, zs(w)			; Vector of common elements.
 
	end
