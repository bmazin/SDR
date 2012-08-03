;-------------------------------------------------------------
;+
; NAME:
;       VARF
; PURPOSE:
;       Computes variance inside a moving window.
; CATEGORY:
; CALLING SEQUENCE:
;       v = varf(x,w)
; INPUTS:
;       x = array of input values.      in
;       w = width of window.            in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v = resulting variance array.   out
; COMMON BLOCKS:
; NOTES:
;	Notes: This filter may have problems if the variance
;	  is small relative to the values in x.  The performance
;	  may be improved by subtracting the mean first:
;	  v=varf(x-mean(x),w).
; MODIFICATION HISTORY:
;       Written by R. Sterner, 3 Jan, 1984.
;	R. Sterner, 25 Sep, 1991 --- added notes.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION VARF,X,W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Computes variance inside a moving window.'
	  print,' v = varf(x,w)'
	  print,'   x = array of input values.      in'
	  print,'   w = width of window.            in'
	  print,'   v = resulting variance array.   out'
	  print,' Notes: This filter may have problems if the variance'
	  print,'   is small relative to the values in x.  The performance'
	  print,'   may be improved by subtracting the mean first:'
	  print,'   v=varf(x-mean(x),w).'
	  return, -1
	endif
 
	RETURN, SMOOTH(X^2,W) - SMOOTH(X,W)^2
	END
