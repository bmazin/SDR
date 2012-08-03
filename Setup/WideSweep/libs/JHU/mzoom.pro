;-------------------------------------------------------------
;+
; NAME:
;       MZOOM
; PURPOSE:
;       Compute new region needed to zoom a mandelbrot image.
; CATEGORY:
; CALLING SEQUENCE:
;       mzoom, rin, img, rout
; INPUTS:
;       rin = complex plane region to zoom into.   in
;         Same format as for mandlebrot.
;       img = mandelbrot image to zoom into.       in
;         Image for region rin.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       rout = new complex plane region.           out
;         Use as input to mandlebrot.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 20 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro mzoom, rin0, img, rout, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Compute new region needed to zoom a mandelbrot image.'
	  print,' mzoom, rin, img, rout'
	  print,'   rin = complex plane region to zoom into.   in'
	  print,'     Same format as for mandlebrot.'
	  print,'   img = mandelbrot image to zoom into.       in'
	  print,'     Image for region rin.'
	  print,'   rout = new complex plane region.           out'
	  print,'     Use as input to mandlebrot.'
	  return
	endif
 
	bx1 = 0
	by1 = 0
	dx = 20
	dy = 20
 
	tvscl, img
 
	print,' Use box to select new area to zoom.'
	print,' Press right button to select area.'
	movbox, bx1, by1, dx, dy, code, xsize=1., /noerase
 
	rin = float(rin0)
 
	x1a = rin(0)  & x2a = rin(1)  & nxa = rin(2)
	y1a = rin(3)  & y2a = rin(4)  & nya = rin(5)
	bx2 = bx1 + dx - 1
	by2 = by1 + dy - 1
 
	x1b = (x2a - x1a)*bx1/nxa + x1a
	x2b = (x2a - x1a)*bx2/nxa + x1a
	y1b = (y2a - y1a)*by1/nya + y1a
	y2b = (y2a - y1a)*by2/nya + y1a
 
	rout = [x1b, x2b, nxa, y1b, y2b, nya]
 
	return
	end
