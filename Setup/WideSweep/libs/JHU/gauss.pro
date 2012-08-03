;-------------------------------------------------------------
;+
; NAME:
;       GAUSS
; PURPOSE:
;       Return a fitted gaussian curve for a given histogram.
; CATEGORY:
; CALLING SEQUENCE:
;       fit = gauss(x,h)
; INPUTS:
;       x = array of histogram bin center values.       in
;       h = histogram array.                            in
; KEYWORD PARAMETERS:
;       Keywords:
;         MEAN=mn returned histogram mean.
;         SDEV=sd returned histogram standard deviation.
; OUTPUTS:
;       fit = expected histogram values for a gaussian.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 May, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function gauss, x, h, mean=mn, sdev=sd, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return a fitted gaussian curve for a given histogram.'
	  print,' fit = gauss(x,h)'
	  print,'   x = array of histogram bin center values.       in'
	  print,'   h = histogram array.                            in'
	  print,'   fit = expected histogram values for a gaussian.  out'
	  print,' Keywords:'
	  print,'   MEAN=mn returned histogram mean.'
	  print,'   SDEV=sd returned histogram standard deviation.'
	  return,-1
	endif
 
	bin = (max(x)-min(x))/(n_elements(x)-1)		; Bin width.
	n = total(h)					; Total counts.
	a = n*bin					; Area under histogram.
	mn = total(h*x)/n				; Mean.
	var = total(h*(x-mn)^2)/n			; Variance.
	sd = sqrt(var)					; Standard Deviation.
 
	tmp = check_math(0,1)				; Math errors off.
	y = a*exp(-.5*((x-mn)/sd)^2)/sqrt(2.*!pi)/sd
	tmp = check_math(0,0)				; math errors on.
 
	return, y
	end
