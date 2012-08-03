;-------------------------------------------------------------
;+
; NAME:
;       PSIMG
; PURPOSE:
;       Display an image on postscript printer.
; CATEGORY:
; CALLING SEQUENCE:
;       psimg, img
; INPUTS:
;       img = image to display.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         FACTOR=fct  Factor used to scale the image (def=1.0).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: img must be correctly scaled,
;         tv is used (not tvscl).  psimg displays
;         image at maximum size that shows entire image
;         in the page window.
; MODIFICATION HISTORY:
;       R. Sterner, 28 Aug, 1990
;       R. Sterner, 1997 Jun 30
;       R. Sterner, 2001 Jun 04 --- Upgrading to 24-bit color.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro psimg, img, factor=fct, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display an image on postscript printer.'
	  print,' psimg, img'
	  print,'   img = image to display.       in'
	  print,' Keywords:'
	  print,'   FACTOR=fct  Factor used to scale the image (def=1.0).'
	  print,' Notes: img must be correctly scaled,'
	  print,'   tv is used (not tvscl).  psimg displays'
	  print,'   image at maximum size that shows entire image'
	  print,'   in the page window.'
	  return
	endif
 
	if n_elements(fct) eq 0 then fct=1.0
 
;	sz = size(img)
;	nx = float(sz(1))
;	ny = float(sz(2))
	img_shape, img, nx=nx, ny=ny, true=tr
 
	px = !d.x_size/!d.x_px_cm
	py = !d.y_size/!d.y_px_cm
	xoff = px*(1-fct)/2.		; Offset to center image on page.
	yoff = py*(1-fct)/2.
 
	y = py
	x = py*nx/ny
	if x gt px then begin
	  x = px
	  y = px*ny/nx
	endif
	tv, img, xoff, yoff, xsize=x*fct, ysize=y*fct, /cent, true=tr
 
	return
	end
