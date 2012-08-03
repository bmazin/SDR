;-------------------------------------------------------------
;+
; NAME:
;       SCALEBAR
; PURPOSE:
;       Make an image bar indicating image min/max and scaling.
; CATEGORY:
; CALLING SEQUENCE:
;       scalebar
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DATA=[min,max] 2 element array with data min and max.
;           For example, 12 bit data would be data=[0,4095].
;         IMAGE=[min,max] 2 element array with image min and max.
;           For example, image=[452,3245].
;         SCALED=[min,max] 2 element array with scaling min and max.
;           For example, scaled=[2234,2778].
;         SAVE=png  Name of PNG image to save bar in (def=none).
;         SIZE=[dx,dy]  X and Y size of bar in pixels.  Bar
;           may be horizontal or vertical format depending on shape.
;           Default: size=[100,20].
;         ICOLOR=iclr  Color for image min/max (def=yellow).
;         SCOLOR=sclr  Color for scaling min/max (def=orange).
;         /SHOW means show the resulting color bar on the screen.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: The three keywords DATA, IMAGE, SCALED are required.
;         Bar is created in it's own window.  No values are listed
;         with the bar, it is a simple graphical indicator.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 23
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro scalebar, data=data, image=image, scaled=scaled, save=png, $
	  size=sz, icolor=iclr, scolor=sclr, show=show, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Make an image bar indicating image min/max and scaling.'
	  print,' scalebar'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   DATA=[min,max] 2 element array with data min and max.'
	  print,'     For example, 12 bit data would be data=[0,4095].'
	  print,'   IMAGE=[min,max] 2 element array with image min and max.'
	  print,'     For example, image=[452,3245].'
	  print,'   SCALED=[min,max] 2 element array with scaling min and max.'
	  print,'     For example, scaled=[2234,2778].'
	  print,'   SAVE=png  Name of PNG image to save bar in (def=none).'
	  print,'   SIZE=[dx,dy]  X and Y size of bar in pixels.  Bar'
	  print,'     may be horizontal or vertical format depending on shape.'
	  print,'     Default: size=[100,20].'
	  print,'   ICOLOR=iclr  Color for image min/max (def=yellow).'
	  print,'   SCOLOR=sclr  Color for scaling min/max (def=orange).'
	  print,'   /SHOW means show the resulting color bar on the screen.'
	  print,' Note: The three keywords DATA, IMAGE, SCALED are required.'
	  print,"   Bar is created in it's own window.  No values are listed"
	  print,'   with the bar, it is a simple graphical indicator.'
	  return
	endif
 
	;-------  Check for all needed info  --------------
	if (n_elements(data) eq 0) or (n_elements(image) eq 0) or $
	   (n_elements(scaled) eq 0) then begin
	  print,' Error in scalebar: must specify all three of'
	  print,'   DATA, IMAGE, and SCALED.'
	  return
	endif
 
	;-------  Defaults  --------------------
	if n_elements(sz) eq 0 then sz=[100,20]
	if n_elements(sclr) eq 0 then sclr=tarclr(255,255,100)
	if n_elements(iclr) eq 0 then iclr=tarclr(255,150,100)
 
	;--------  Shape flag  ------------------
	if sz(0) gt sz(1) then flag=0 else flag=1	; 0=H, 1=V.
 
	;---------  Make bar  -------------------
	dx = max(sz, min=dy)			; Create bar horizontal.
	window,/free,xs=dx,ys=dy,/pixmap	; Use pixmap.
	
	;---  find pixel coordinates into bar for image and scaled min/max  ---
	dmn = float(data(0))
	dmx = float(data(1))
	idx1 = 1.			; Allow a 1 pixel border.
	idx2 = dx-2.
	k = (idx2-idx1)/(dmx-dmn)
	iix1 = k*(image(0)-dmn) + idx1
	iix2 = k*(image(1)-dmn) + idx1
	if (iix2-iix1) lt 1. then begin	; Won't plot if too thin.
	  iix2 = (iix2-.5)>0.
	  iix2 = iix1+1
	endif
	isx1 = k*(scaled(0)-dmn) + idx1
	isx2 = k*(scaled(1)-dmn) + idx1
	if (isx2-isx1) lt 1. then begin	; Won't plot if too thin.
	  isx2 = (isx2-.5)>0.
	  isx2 = isx1+1
	endif
	iiy1 = 3			; 2 pixel margin.
	iiy2 = dy-4
	isy1 = iiy1
	isy2 = iiy2
 
	;-----  Set up ramp and make bar  ------------
	rmp = rebin(maken(0,255,dx-2),dx-2,dy-2)
	tvscl,rmp,1,1
	polyfill,[iix1,iix2,iix2,iix1],[iiy1,iiy1,iiy2,iiy2],col=iclr,/dev
	polyfill,[isx1,isx2,isx2,isx1],[isy1,isy1,isy2,isy2],col=sclr,/dev
 
	;------  Read back and display  ----------------
	a = tvrd(tr=1)
	wdelete
	if flag eq 1 then a=transpose(a,[0,2,1])	; Want vertical.
	if keyword_set(show) then begin
	  window,xs=sz(0),ys=sz(1)
	  tv,a,tr=1
	endif
 
	;------  Save bar  -----------------
	if !version.release le 5.3 then a=img_rotate(a,7)
	if n_elements(png) ne 0 then write_png, png, a
 
	end
