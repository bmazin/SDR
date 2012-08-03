;-------------------------------------------------------------
;+
; NAME:
;       KURF
; PURPOSE:
;       Computes kurtosis inside a moving window.
; CATEGORY:
; CALLING SEQUENCE:
;       k = kurf(x,w)
; INPUTS:
;       x = array of input values.      in
;       w = width of window.            in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       k = resulting kurtosis array.   out
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
 
	FUNCTION KURF,X,W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Computes kurtosis inside a moving window.'
	  print,' k = kurf(x,w)'
	  print,'   x = array of input values.      in'
	  print,'   w = width of window.            in'
	  print,'   k = resulting kurtosis array.   out'
	  return, -1
	endif
 
	sx = smooth(x,w)
	m4 = smooth(x^4,w) - 4*sx*smooth(x^3,w) + $
	     6*sx^2*smooth(x^2,w) - 3*sx^4
	m2 = varf(x,w)
	ww = where(m2 eq 0.)
	m2(ww) = 1.
	m4(ww) = 0.
	return, m4/(m2^2)
 
	END
