;-------------------------------------------------------------
;+
; NAME:
;       IMGARRAY
; PURPOSE:
;       Create an array of small images given a list.
; CATEGORY:
; CALLING SEQUENCE:
;       imgarray, list
; INPUTS:
;       list = list of GIF image file names.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         NX=nx, NY=ny  Array size: nx x ny images.
;         SAVE=gif  Name of GIF image for saving result.
;         Use only one of the following 3 keywords:
;         REDUCTION=fact  Size reduction factor (def=2).
;         XSIZE=xs  X size of reduced images.
;         YSIZE=ys  Y size of reduced images.
;         MARGIN=m  Size of margin to add around reduced images.
;         MCOLOR='r g b' Color of margin in R,G,B (0-255). Def=white.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Nov 08
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgarray, list, ysize=ys, xsize=xs, reduction=red, $
	  margin=m, mcolor=mclr, nx=nx, ny=ny, save=save, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Create an array of small images given a list.'
	  print,' imgarray, list'
	  print,'   list = list of GIF image file names.       in'
	  print,' Keywords:'
	  print,'   NX=nx, NY=ny  Array size: nx x ny images.'
	  print,'   SAVE=gif  Name of GIF image for saving result.'
	  print,'   Use only one of the following 3 keywords:'
	  print,'   REDUCTION=fact  Size reduction factor (def=2).'
	  print,'   XSIZE=xs  X size of reduced images.'
	  print,'   YSIZE=ys  Y size of reduced images.'
	  print,'   MARGIN=m  Size of margin to add around reduced images.'
	  print,"   MCOLOR='r g b' Color of margin in R,G,B (0-255). Def=white."
	  return
	endif
 
	;------  Read in first image file  ----------------
	n_img = n_elements(list)
	read_gif, list(0), img, r, g, b
	sz=size(img) & xs0=sz(1) & ys0=sz(2)
 
	;------  Defaults  --------------------------------
	if n_elements(m) eq 0 then m=0				; No margin.
	if n_elements(mclr) eq 0 then mclr='255 255 255'	; White.
	if n_elements(red) eq 0 then red=2.			; Half size.
	if n_elements(xs) ne 0 then red=float(xs0)/xs		; Force x size.
	if n_elements(ys) ne 0 then red=float(ys0)/ys		; Force y size.
	xs1=round(xs0/red) & ys1=round(ys0/red)			; Reduced img.
	if n_elements(nx) eq 0 then nx=2			; Imgs in X,
	if n_elements(ny) eq 0 then ny=fix(ceil(float(n_img)/nx)) ; in Y.
	if n_elements(save) eq 0 then save='temp.gif'
 
	;------  Deal with margin color  -------------------
	wordarray,string(mclr),del=',',/white,tclr & tclr=tclr+0
 
	;------  Make output image (as R,G,B)  -------------
	xs2=xs1+m+m & ys2=ys1+m+m	; Panel size.
	dx=nx*xs2 & dy=ny*ys2		; Total output size.
	print,' Output image: ',dx,dy
	rr = bytarr(dx,dy)+tclr(0)	; R.
	gg = bytarr(dx,dy)+tclr(1)	; G.
	bb = bytarr(dx,dy)+tclr(2)	; B.
	
	;------  Loop through input images  ----------------
	for i = 0, n_img-1 do begin
	  print,' Image ',i+1,' of ',n_img,' . . .'
	  read_gif, list(i), img, r0, g0, b0	; Read image.
	  img = congrid(img,xs1,ys1)
	  r = r0(img)				; Split into RGB components.
	  g = g0(img)
	  b = b0(img)
	  tvpos, [xs2,ys2], i, ix, iy, res=[dx,dy]	; Insertion point.
	  ix=ix+m & iy=iy+m
	  rr(ix,iy) = r
	  gg(ix,iy) = g
	  bb(ix,iy) = b
	endfor
 
	print,' Coloring image array . . .'
	c = color_quan(rr,gg,bb,r,g,b)
	write_gif, save, c, r, g, b	; Write image.
	print,' GIF image saved in '+save
 
	end
