;-------------------------------------------------------------
;+
; NAME:
;       UNIQUE
; PURPOSE:
;       Return the unique elements of an array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = unique(in, count)
; INPUTS:
;       in = input array to process.                    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /SORT means sort array before selecting unique elements.
; OUTPUTS:
;       out = returned unique elements from in.         out
;       count = cw# occurances of each unique element.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: unsorted arrays only have repeated elements
;         dropped, use /SORT to drop all extra repeated elements.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Oct, 1993
;       R. Sterner, 5 Oct, 1993 --- added count.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function unique, in0, count, sort=sort, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the unique elements of an array.'
	  print,' out = unique(in, count)'
	  print,'   in = input array to process.                    in'
	  print,'   out = returned unique elements from in.         out'
	  print,'   count = cw# occurances of each unique element.  out'
	  print,' Keywords:'
	  print,'   /SORT means sort array before selecting unique elements.'
	  print,' Notes: unsorted arrays only have repeated elements'
	  print,'   dropped, use /SORT to drop all extra repeated elements.'
	  return, -1
	endif
 
	in = in0
	if keyword_set(sort) then in = in(sort(in))
	w = where(in ne shift(in,1),cnt)
	if cnt eq 0 then begin
	  w = [0]		; Handle 1 element array.
	  count = [n_elements(in0)]
	endif else begin
	  count = [w(1:*),n_elements(in0)] - w	; # occurances of unique els.
	endelse
 
	return, in(w)
 
	end
