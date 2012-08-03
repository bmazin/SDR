;-------------------------------------------------------------
;+
; NAME:
;       MANDEL_GIF
; PURPOSE:
;       Convert saved images from mandelbrot to gif images
; CATEGORY:
; CALLING SEQUENCE:
;       mandel_gif
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: run in directory with images saved from
;       within mandelbrot.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Dec 12
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mandel_gif, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Convert saved images from mandelbrot to gif images'
	  print,' mandel_gif'
	  print,'   No args.'
	  print,' Note: run in directory with images saved from'
	  print,' within mandelbrot.'
	  return
	endif
 
	f = findfile('*.mand', count=cnt)
	if cnt eq 0 then begin
	  print,' No *.mand images found.'
	  return
	endif
 
	device,decomp=0
	erase
 
	for i=0,cnt-1 do begin
	  filebreak,f(i),name=nam
	  gif = nam+'.gif'
	  restore2,f(i),img,reg,r,g,b
	  wdelete
	  sz=size(img) & nx=sz(1) & ny=sz(2)
	  window,xs=nx,ys=ny+40
	  tvlct,r,g,b
	  wht = tarclr(255,255,255)
	  blk = tarclr(0,0,0)
	  erase,wht
	  tvscl,img,0
	  mag = 'Mag = '+strtrim(4./(reg(1)-reg(0)),2)
	  xtxt = 'X = '+strtrim(reg(0),2)+' to '+strtrim(reg(1),2)
	  ytxt = 'Y = '+strtrim(reg(3),2)+' to '+strtrim(reg(4),2)
	  xyoutb,align=.5,nx/2,24,/dev,mag,col=blk,chars=1.5
	  xyoutb,align=.5,nx/2,4,/dev,xtxt+'  '+ytxt,col=blk,chars=1.5
	  gifscreen, gif
	endfor
 
	end
