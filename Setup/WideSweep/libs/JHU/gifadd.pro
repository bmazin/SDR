;-------------------------------------------------------------
;+
; NAME:
;       GIFADD
; PURPOSE:
;       Add R,G,B color components for list of GIF images.
; CATEGORY:
; CALLING SEQUENCE:
;       gifadd, list
; INPUTS:
;       list = string array with GIF image names.   in
; KEYWORD PARAMETERS:
;       Keywords:
;       /DITHER  means use dithering to combine images.
;       COLORS=clrs  number of colors to use in result (def=256).
;       /JPEG means use jpeg color combine algorithm.
;       /PIXMAP uses pixmap instead of screen.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Displays result on screen.  All images must be
;         same size.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 7
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro gifadd, list, dither=dither, colors=colors, jpeg=jpeg, $
	  pixmap=pix, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Add R,G,B color components for list of GIF images.'
	  print,' gifadd, list'
	  print,'   list = string array with GIF image names.   in'
	  print,' Keywords:'
	  print,' /DITHER  means use dithering to combine images.'
	  print,' COLORS=clrs  number of colors to use in result (def=256).'
	  print,' /JPEG means use jpeg color combine algorithm.'
	  print,' /PIXMAP uses pixmap instead of screen.'
	  print,' Notes: Displays result on screen.  All images must be'
	  print,'   same size.'
	  return
	endif
 
	n = n_elements(list)		; Number of images to sum.
	if n_elements(dither) eq 0 then dither=0
	if n_elements(colors) eq 0 then colors=256
	if n_elements(pix) eq 0 then pix=0
 
	print,' Adding image '+list(0)+' . . .'
	read_gif,list(0),a,r,g,b	; Read first.
	rr = fix(r(a))			; Init sums to first image.
	gg = fix(g(a))
	bb = fix(b(a))
	sz = size(a)
	nx0=sz(1) & ny0=sz(2)
 
	for i=1, n-1 do begin		; Loop through rest of images.
	  print,' Adding image '+list(i)+' . . .'
	  read_gif,list(i),a,r,g,b
          sz = size(a)
          nx=sz(1) & ny=sz(2)
	  if (nx ne nx0) or (ny ne ny0) then begin
	    print,' Error in rgbadd: all images must be same size.'
	    return
	  endif
	  rr = fix(r(a)) + rr
	  gg = fix(g(a)) + gg
	  bb = fix(b(a)) + bb
	endfor
 
	if keyword_set(jpeg) then begin
	  c=color_quanj(rr<255,gg<255,bb<255,r,g,b,colors=colors,dither=dither)
	endif else begin
	  c=color_quan(rr<255,gg<255,bb<255,r,g,b,colors=colors,dither=dither)
	endelse
 
	if !d.name eq 'X' then swindow,xs=nx,ys=ny,pixmap=pix
	tv,c
	tvlct,r,g,b
 
	return
	end
