;-------------------------------------------------------------
;+
; NAME:
;       DISKCENTER
; PURPOSE:
;       Find center and radius of a disk in an image.
; CATEGORY:
; CALLING SEQUENCE:
;       diskcenter, img, xc, yc, rd
; INPUTS:
;       img = input image containing the disk.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /GRID plots fit to disk.
; OUTPUTS:
;       xc, yc = array indices of disk center.   out
;       rd = estimated radius of disk in pixels. out
; COMMON BLOCKS:
; NOTES:
;       Note: Image is assumed 0 outside disk, non-zero inside.
;         Also center of array must be inside the disk.
; MODIFICATION HISTORY:
;       R. Sterner, 21 Feb, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro diskcenter, img, x0, y0, r, help=hlp, grid=grid
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find center and radius of a disk in an image.'
	  print,' diskcenter, img, xc, yc, rd'
	  print,'   img = input image containing the disk.   in'
	  print,'   xc, yc = array indices of disk center.   out'
	  print,'   rd = estimated radius of disk in pixels. out'
	  print,' Keywords:'
	  print,'   /GRID plots fit to disk.'
	  print,' Note: Image is assumed 0 outside disk, non-zero inside.'
	  print,'   Also center of array must be inside the disk.'
	  return
	endif
 
	;--------  Image size  --------
	sz = size(img)
	nx = sz(1)
	ny = sz(2)
	
	;--------  Estimates of center and radius --------
	w = where(img(*,ny/2) ne 0)
	x0 = midv(w)
	rx = .5*(max(w) - min(w))
	w = where(img(nx/2,*) ne 0)
	y0 = midv(w)
	ry = .5*(max(w) - min(w))
	r = .5*(rx + ry)
 
	;--------  Plot grid  -----------------
	if keyword_set(grid) then begin
	  plots, x0 + [-rd, -rd], y0 + [-rd, rd], /dev
	  plots, x0 + [0, 0],     y0 + [-rd, rd], /dev
	  plots, x0 + [rd, rd],   y0 + [-rd, rd], /dev
	  plots, x0 + [-rd, rd],  y0 + [-rd, -rd], /dev
	  plots, x0 + [-rd, rd],  y0 + [0, 0], /dev
	  plots, x0 + [-rd, rd],  y0 + [rd, rd], /dev
	endif
 
	return
	end
