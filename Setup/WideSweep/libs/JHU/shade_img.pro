;-------------------------------------------------------------
;+
; NAME:
;       SHADE_IMG
; PURPOSE:
;       Shade a given image based on a shading array.
; CATEGORY:
; CALLING SEQUENCE:
;       shade_img, shd, c, r, g, b
; INPUTS:
;       shd = shade at each image point (0.0 to 1.0).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         IMAGE=img  Input image (def=current image).
;         RIN=ri, GIN=gi, BIN=bi = input color table (def=current).
; OUTPUTS:
;       c = resulting color image.                     out
;       r,g,b = corresponding color table.             out
; COMMON BLOCKS:
; NOTES:
;       Notes: The current color table is used to split the
;         current image into r,g,b components.  These components
;         are modified based on the given shading array and then
;         recombined to form a new color image and color table.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Sep 27
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro shade_img, shd, c, r, g, b, image=img, rin=rin, $
	  gin=gin, bin=bin, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Shade a given image based on a shading array.'
	  print,' shade_img, shd, c, r, g, b'
	  print,'   shd = shade at each image point (0.0 to 1.0).  in'
	  print,'   c = resulting color image.                     out'
	  print,'   r,g,b = corresponding color table.             out'
	  print,' Keywords:'
	  print,'   IMAGE=img  Input image (def=current image).'
	  print,'   RIN=ri, GIN=gi, BIN=bi = input color table (def=current).'
	  print,' Notes: The current color table is used to split the'
	  print,'   current image into r,g,b components.  These components'
	  print,'   are modified based on the given shading array and then'
	  print,'   recombined to form a new color image and color table.'
	  return
	endif
 
	;--------  Defaults  ------------
	if n_elements(img) eq 0 then img = tvrd()
	if n_elements(rin) eq 0 then tvlct, /get, rin,gin,bin
 
	;--------  Split image into r,g,b components  ----------
	rr = rin(img)
	gg = gin(img)
	bb = bin(img)
 
	;---------  Modify based on shading array  ---------
	rr = byte(round(rr*shd))
	gg = byte(round(gg*shd))
	bb = byte(round(bb*shd))
 
	;-------  Recombine  --------------
	c = color_quan(rr,gg,bb,r,g,b)
 
	return
	end
