;-------------------------------------------------------------
;+
; NAME:
;       SKEWF
; PURPOSE:
;       Computes skew inside a moving window.
; CATEGORY:
; CALLING SEQUENCE:
;       s = skewf(x,w)
; INPUTS:
;       x = array of input values.      in
;       w = width of window.            in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = resulting skew array.       out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 23 Aug, 1990.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION SKEWF,X,W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Computes skew inside a moving window.'
	  print,' s = skewf(x,w)'
	  print,'   x = array of input values.      in'
	  print,'   w = width of window.            in'
	  print,'   s = resulting skew array.       out'
	  return, -1
	endif
 
	sx = smooth(x,w)
	m3 = smooth(x^3,w) - 3*sx*smooth(x^2,w) + $
	     2*sx^3
	m2 = varf(x,w)
	ww = where(m2 eq 0.)
	m2(ww) = 1.
	m3(ww) = 0.
	return, m3/(m2^1.5)
 
	END
