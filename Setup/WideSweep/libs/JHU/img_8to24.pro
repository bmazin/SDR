;-------------------------------------------------------------
;+
; NAME:
;       IMG_8TO24
; PURPOSE:
;       Convert an 8-bit image to 24-bit using a color lookup table.
; CATEGORY:
; CALLING SEQUENCE:
;       cimg = img_8to24(img, r, g, b)
; INPUTS:
;       img = Input 8-bit image.                in
;       r,g,b = Option color table components.  in
;         256 byte arrays for red, green, and blue.
;         May give one arg here which is the loadct index.
;         Default is the current color lookup table.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 may 11
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_8to24, img, r0, g0, b0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert an 8-bit image to 24-bit using a color lookup table.'
	  print,' cimg = img_8to24(img, r, g, b)'
	  print,'   img = Input 8-bit image.                in'
	  print,'   r,g,b = Option color table components.  in'
	  print,'     256 byte arrays for red, green, and blue.'
	  print,'     May give one arg here which is the loadct index.'
	  print,'     Default is the current color lookup table.'
	  return,''
	endif
 
	;-----  Get color table  -----
	if n_params(0) eq 1 then begin
	  tvlct,/get,r,g,b
	endif
	if n_params(0) eq 2 then begin
	  loadct,r0
	  tvlct,/get,r,g,b
	endif
	if n_params(0) eq 4 then begin
	  r = r0
	  g = g0
	  b = b0
	endif
	if n_elements(r) eq 0 then begin
	  print,' Error in img_8to24: Wrong number of arguments.'
	  return,''
	endif
 
	;------  Convert image  -------
	cimg = [[[r[img]]],[[g[img]]],[[b[img]]]]
	return, cimg
 
	end
