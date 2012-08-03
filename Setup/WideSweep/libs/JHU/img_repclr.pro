;-------------------------------------------------------------
;+
; NAME:
;       IMG_REPCLR
; PURPOSE:
;       Replace a color in a 24-bit image.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_repclr(img1)
; INPUTS:
;       img1 = Original image.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         CLR1=clr1 [r1,g1,b1] RGB values (0-255) of target color.
;         CLR2=clr2 [r2,g2,b2] RGB values replacement color.
;         TOL=tol Tolerance, Euclidian distance in RGB space. Def=0.
;         COUNT=c Number of pixels changed.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img2 = Modified image.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 24
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_repclr, img, clr1=clr1, clr2=clr2, tol=tol, $
 	   count=c, error=err,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Replace a color in a 24-bit image.'
	  print,' img2 = img_repclr(img1)'
	  print,'   img1 = Original image.  in'
	  print,'   img2 = Modified image.  out'
	  print,' Keywords:'
	  print,'   CLR1=clr1 [r1,g1,b1] RGB values (0-255) of target color.'
	  print,'   CLR2=clr2 [r2,g2,b2] RGB values replacement color.'
	  print,'   TOL=tol Tolerance, Euclidian distance in RGB space. Def=0.'
	  print,'   COUNT=c Number of pixels changed.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  return,''
	endif
 
	;-------  Check for valid input values  --------------
	c = 0
	if n_elements(tol) eq 0 then tol=0
 
	if n_elements(clr1) ne 3 then begin
	  print,' Error in img_repclr: Must give a 3 elements target color'
	  print,'   array: [r1,g1,b1].'
	  err = 1
	  return,''
	endif
 
	if n_elements(clr2) ne 3 then begin
	  print,' Error in img_repclr: Must give a 3 elements replacement color'
	  print,'   array: [r2,g2,b2].'
	  err = 1
	  return,''
	endif
 
	mn = min(clr1,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_repclr: Target color value out of range (0-255).'
	  err = 1
	  return,''
	endif
	mn = min(clr2,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_repclr: Repolacement color value out of range (0-255).'
	  err = 1
	  return,''
	endif
 
	;------  Split input image  ---------------
	img_split, img, r, g, b, tr=tr
	r1=clr1(0)+0. & g1=clr1(1)+0. & b1=clr1(2)+0.
 
	;------  Compute squared distance from target color  ------
	d2 = (r-r1)^2 + (g-g1)^2 + (b-b1)^2
 
	;------  Find and replace pixles close to target color -----------
	w = where(d2 le float(tol)^2, c)
	if c gt 0 then begin
	  r(w) = clr2(0)
	  g(w) = clr2(1)
	  b(w) = clr2(2)
	endif
 
	;-------  Merge color channels back into a 24-bit image  -------
	return, img_merge(r,g,b,true=tr)
 
	end
