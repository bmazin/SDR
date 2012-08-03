;-------------------------------------------------------------
;+
; NAME:
;       IMG_CPOLY
; PURPOSE:
;       Plot a transparent color polygon on an image.
; CATEGORY:
; CALLING SEQUENCE:
;       img_cpoly, px, py, [img]
; INPUTS:
;       px, py = X and Y arrays of polygon points. in
;       img = Optional image to use (def=current). in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE px,py are in device coordinates.
;         /DATA   px,py are in data coordinates (default).
;           Polygons are not clipped to the plot window.
;         /NORM   px,py are in normalized coordinates.
;         COLOR=clr Polygon color (def=yellow).
;         /NODISPLAY Do not display result.  If img is not
;           given the current screen image will be used and
;           updated by default.  If img is given the updated
;           version will not be displayed.
;         /DISP Display updated image.  Needed if img is given.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Apr 09
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_cpoly, px0, py0, img, device=dev, data=dat, normal=nrm, $
	  color=clr, nodisplay=nodisp, disp=disp, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a transparent color polygon on an image.'
	  print,' img_cpoly, px, py, [img]'
	  print,'   px, py = X and Y arrays of polygon points. in'
	  print,'   img = Optional image to use (def=current). in'
	  print,' Keywords:'
	  print,'   /DEVICE px,py are in device coordinates.'
	  print,'   /DATA   px,py are in data coordinates (default).'
	  print,'     Polygons are not clipped to the plot window.'
	  print,'   /NORM   px,py are in normalized coordinates.'
	  print,'   COLOR=clr Polygon color (def=yellow).'
	  print,'   /NODISPLAY Do not display result.  If img is not'
	  print,'     given the current screen image will be used and'
	  print,'     updated by default.  If img is given the updated'
	  print,'     version will not be displayed.'
	  print,'   /DISP Display updated image.  Needed if img is given.'
	  return
	endif
 
	;---  Make sure working image is available  ----
	uflag = 0		; Do not display updated image.
	if n_elements(img) eq 0 then begin
	  img = tvrd(tr=3)	; Read current screen image.
	  uflag = 1		; Display updated image.
	endif
 
	;--- Deal with display/no display request  ----
	if keyword_set(nodisp) then uflag=0	; Do not display updated image.
	if keyword_set(disp)   then uflag=1	; Do display updated image.
 
	;---  Make sure color is available  ----
	if n_elements(clr) eq 0 then clr=tarclr(/hsv,60,.5,1)
	c2rgb, clr, r, g, b
 
	;---  Deal with coordinate system  ----
	if keyword_set(dev) then dvflag=1 else dvflag=0
	if keyword_set(dat) then dtflag=1 else dtflag=0
	if keyword_set(nrm) then nmflag=1 else nmflag=0
	if (dvflag>dtflag>nmflag) eq 0 then dtflag=1
	if dvflag eq 1 then begin
	  px = round(px0+0.5)
	  py = round(py0+0.5)
	endif
	if nmflag eq 1 then begin
	  t = convert_coord(px0,py0,/norm,/to_dev)
	  px = round(reform(t[0,*])+0.5)
	  py = round(reform(t[1,*])+0.5)
	endif
	if dtflag eq 1 then begin
	  t = convert_coord(px0,py0,/data,/to_dev)
	  px = round(reform(t[0,*])+0.5)
	  py = round(reform(t[1,*])+0.5)
	endif
 
	;---  Create polygon filter  -----
	img_shape, img, nx=nx, ny=ny
	rr = bytarr(nx,ny) + 255B
	gg = bytarr(nx,ny) + 255B
	bb = bytarr(nx,ny) + 255B
	in = polyfillv(px, py, nx, ny)
	rr[in] = r
	gg[in] = g
	bb[in] = b
	cfilt = img_merge(rr,gg,bb)
	
	;---  Apply filter  -----
	img = img_cfilter(img,cfilt)
 
	;---  Display result  ----
	if uflag eq 1 then img_disp,img,/curr
 
	end
