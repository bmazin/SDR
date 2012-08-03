;-------------------------------------------------------------
;+
; NAME:
;       SIMP
; PURPOSE:
;       Does Simpson numerical integration on an array of y values.
; CATEGORY:
; CALLING SEQUENCE:
;       i = simp(y, h)
; INPUTS:
;       y = array of y values of function.                 in
;       h = separation between evenly spaced x values.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       i = value of integral.                             out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 19 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	function simp,y,h, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Does Simpson numerical integration on an array of y values.'
	  print,' i = simp(y, h)' 
	  print,'   y = array of y values of function.                 in'
	  print,'   h = separation between evenly spaced x values.     in' 
	  print,'   i = value of integral.                             out'
	  return, -1
	endif
 
	last = n_elements(y) - 1   ; index of last element in Y vector.
	if (last mod 2) eq 0 then n = last else n = last - 1  ; force even.
 
	w = 4. - 2.*(lindgen(n-1) mod 2)
	i = h/3.*total([1.,w,1.]*y(0:n))
 
	if (last gt n) then i = i + (y(last-1)+y(last))*h/2.
	return,i
	end
