;-------------------------------------------------------------
;+
; NAME:
;       RADIAL_IMG
; PURPOSE:
;       Make an image array with a radial brightness distribution.
; CATEGORY:
; CALLING SEQUENCE:
;       out = radial_image(y,n)
; INPUTS:
;       y = brightness distribution curve (pixels from center). in
;       n = side length of square output array.                 in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = resulting image array.                            out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 6 Jul, 1990
;       R. Sterner, 27 Jan, 1993 --- cleaned up.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function radial_img, y,n, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make an image array with a radial brightness distribution.'
	  print,' out = radial_image(y,n)'
	  print,'   y = brightness distribution curve (pixels from center). in'
	  print,'   n = side length of square output array.                 in'
	  print,'   out = resulting image array.                            out'
	  return, -1
	endif
 
	diag = ceil(sqrt(2.*double(n/2.)^2))
	lsty = n_elements(y)-1
	y2 = y
	if lsty lt diag then begin
	  y2 = dblarr(diag)
	  y2(0) = y
	endif
 
	d = shift(dist(n),n/2,n/2)
	t = makex(0.,diag,1.)
 
	yy = interpolate(y2,t)
	return, yy(d)
 
	end
