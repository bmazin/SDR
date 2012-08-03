;-------------------------------------------------------------
;+
; NAME:
;       CONGRID8C
; PURPOSE:
;       Do 24 bit congrid interpolation on 8 bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = congrid8c(in, nx, ny)
; INPUTS:
;       in = input 8 bit color image.                in
;       nx,ny = New output image dimensions.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         INRED=r1   Input image red color table.
;         INGREEN=g1 Input image green color table.
;         INBLUE=b1  Input image blue color table.
;           If these are not given the current color table is used.
;         RED=r1   Output image red color table.
;         GREEN=g1 Output image green color table.
;         BLUE=b1  Output image blue color table.
;         /INTERP, /CUBIC, and /MINUS_ONE work as for congrid.
; OUTPUTS:
;       out = interpolated output image.             out
; COMMON BLOCKS:
; NOTES:
;       Notes: Intended for 8 bit color images such as GIF or TIFF.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 May 4
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function congrid8c, in, nx, ny, inred=r1, ingreen=g1, $
	  inblue=b1, red=r2, green=g2, blue=b2, $
	  _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Do 24 bit congrid interpolation on 8 bit color image.'
	  print,' out = congrid8c(in, nx, ny)'
	  print,'   in = input 8 bit color image.                in'
	  print,'   nx,ny = New output image dimensions.         in'
	  print,'   out = interpolated output image.             out'
	  print,' Keywords:'
	  print,'   INRED=r1   Input image red color table.'
	  print,'   INGREEN=g1 Input image green color table.'
	  print,'   INBLUE=b1  Input image blue color table.'
	  print,'     If these are not given the current color table is used.'
	  print,'   RED=r1   Output image red color table.'
	  print,'   GREEN=g1 Output image green color table.'
	  print,'   BLUE=b1  Output image blue color table.'
	  print,'   /INTERP, /CUBIC, and /MINUS_ONE work as for congrid.'
	  print,' Notes: Intended for 8 bit color images such as GIF or TIFF.'
	  return, ''
	endif
 
	;---------  Input image color table  --------------
	tvlct, /get, r0, g0, b0
	if n_elements(r1) eq 0 then r1 = r0
	if n_elements(g1) eq 0 then g1 = g0
	if n_elements(b1) eq 0 then b1 = b0
 
	;---------- Convert image to RGB components  ----------
	r = r1(in)
	g = g1(in)
	b = b1(in)
 
	;---------  Resize  --------------------
	r = congrid(r,nx,ny,_extra=extra)
	g = congrid(g,nx,ny,_extra=extra)
	b = congrid(b,nx,ny,_extra=extra)
 
	;--------  Recombine  ------------------
	c = color_quan(r,g,b, r2,g2,b2)
 
	return, c
 
	end
