;-------------------------------------------------------------
;+
; NAME:
;       POLY_FIT2
; PURPOSE:
;       Returns fitted Y values for each given X value.
; CATEGORY:
; CALLING SEQUENCE:
;       yfit = poly_fit2(x, y, ndeg)
; INPUTS:
;       x, y = curve points to fit.		in.
;       ndeg = degree of polynomial to fit.	in.
; KEYWORD PARAMETERS:
;       Keywords:
;         XFIT=xfit  X values for fitted Y (def=x).
; OUTPUTS:
;       yfit = fitted Y values for each X.	out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 13 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function poly_fit2, x, y, ndeg, xfit=xfit, help=hlp
 
	if (n_params(0) ne 3) or keyword_set(hlp) then begin
	  print,' Returns fitted Y values for each given X value.'
	  print,' yfit = poly_fit2(x, y, ndeg)'
	  print,'   x, y = curve points to fit.		in.'
	  print,'   ndeg = degree of polynomial to fit.	in.'
	  print,'   yfit = fitted Y values for each X.	out.'
	  print,' Keywords:'
	  print,'   XFIT=xfit  X values for fitted Y (def=x).'
	  return, -1
	endif
 
	if n_elements(xfit) eq 0 then xfit = x
 
	return, gen_fit(xfit, [0,0,0,ndeg,transpose(poly_fit(x,y,ndeg))])
 
	end
