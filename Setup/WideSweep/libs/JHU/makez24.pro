;-------------------------------------------------------------
;+
; NAME:
;       MAKEZ24
; PURPOSE:
;       Make a test 24-bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       img = makez24( nx, ny, w)
; INPUTS:
;       nx, ny = size of image to make.                       in
;       w = smoothing window size (def = 5% of sqrt(nx*ny)).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /PERIODIC   forces data to match at ends.  Will not work
;           for smoothing windows much more than about 30% of n.
;         SEED=s      Set random seed for repeatable results.
;         LASTSEED=s  returns last random seed used.
; OUTPUTS:
;       img = resulting 24-bit color image (true=3).          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Sep 24
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function makez24, nx, ny, w, seed=seed, lastseed=lastseed, $
	  periodic=periodic, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a test 24-bit color image.'
	  print,' img = makez24( nx, ny, w)'
	  print,' nx, ny = size of image to make.                       in'
	  print,' w = smoothing window size (def = 5% of sqrt(nx*ny)).  in'
	  print,' img = resulting 24-bit color image (true=3).          out'
	  print,' Keywords:'
	  print,'   /PERIODIC   forces data to match at ends.  Will not work'
	  print,'     for smoothing windows much more than about 30% of n.'
	  print,'   SEED=s      Set random seed for repeatable results.'
	  print,'   LASTSEED=s  returns last random seed used.'
	  return,''
	endif
 
	t = makez(nx,ny,w,seed=seed,lastseed=lastseed,periodic=periodic)
	r = bytscl(t+binbound(t gt .5)/2.)
	t = makez(nx,ny,w,seed=seed,lastseed=lastseed,periodic=periodic)
	g = bytscl(t+binbound(t gt .5)/2.)
	t = makez(nx,ny,w,seed=seed,lastseed=lastseed,periodic=periodic)
	b = bytscl(t+binbound(t gt .5)/2.)
 
	img = img_merge(r,g,b)
 
	return, img
 
	end
