;-------------------------------------------------------------
;+
; NAME:
;       IMAGE_ALIGN
; PURPOSE:
;       Align two images.
; CATEGORY:
; CALLING SEQUENCE:
;       image_align, img1, img2
; INPUTS:
;       img1, img2 = two images of the same size.  in
;         img2 is returned modified.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: slider bars will shift and rotate img2.
;       img1 is displayed as green, img2 as red.  Align the red
;       image with the green.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 25
;       R. Sterner, 2003 May 16 --- Changed from blue to green channel.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro image_align, img1, img2, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Align two images.'
	  print,' image_align, img1, img2'
	  print,'   img1, img2 = two images of the same size.  in'
	  print,'     img2 is returned modified.'
	  print,' Note: slider bars will shift and rotate img2.'
	  print,' img1 is displayed as green, img2 as red.  Align the red'
	  print,' image with the green.'
	  return
	endif
 
	sz=size(img1) & nx=sz(1) & ny=sz(2)
	window,/free,xs=nx,ys=ny
 
	tv,img1,chan=2
	tv,img2,chan=1
 
	s = size(img1,/dim)
	ixmx = strtrim(s(0),2)
	iymx = strtrim(s(1),2)
	s = size(img2,/dim)
	nx2 = s(0)
	ny2 = s(1)
 
	nx0 = strtrim(nx2,2)+' '
	ny0 = strtrim(ny2,2)+' '
	dx = strtrim(nx2/2,2)+' '
	dy = strtrim(ny2/2,2)+' '
	x1 = strtrim(dx-50,2)+' '
	x2 = strtrim(dx+50,2)+' '
	y1 = strtrim(dy-50,2)+' '
	y2 = strtrim(dy+50,2)+' '
 
	t = ['eq: tv,rot(p1,ang,mag,dx,dy,cub=-.5),ix,iy,chan=1', $
		'par: ang 0 360 0', $
		'par: mag .10 1.90 1.0', $
		'par: dx 0 '+nx0+dx, $
		'par: dy 0 '+ny0+dy, $
		'par:ix 0 '+ixmx+' 0', $
		'par:iy 0 '+iymx+' 0']
 
	eqv3, t, p1=img2, /wait, exit=ex, parvals=s
 
	if ex eq 1 then return
 
	img2 = rot(img2,s.pval(0),s.pval(1),s.pval(2),s.pval(3),cub=-.5)
 
	end
