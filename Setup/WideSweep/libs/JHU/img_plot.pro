;-------------------------------------------------------------
;+
; NAME:
;       IMG_PLOT
; PURPOSE:
;       Plot on a 24-bit image without using X windows.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_plot(img1,x,y)
; INPUTS:
;       img1 = Original image.    in
;       x,y = x,y arrays to plot. in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Plot color.
;           May also be a 3 element array: [R,G,B].
;         THICK=thk  Curve thickness *def=!p.thickness).
;         CHARSIZE=csz Text size (def=!p.charsize).
;         CHARTHICK=cthk  Text Thickness (def=!p.charthick).
;         POSITION=pos plot position in normalized coordinates.
;         /DEVICE  means pos is in device coordinates.
;         /ANTIALIASED means do antialiasing.  A bit slower.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img2 = returned image.    out
; COMMON BLOCKS:
; NOTES:
;       Note: uses Z buffer, save a copy before if using Z.
;         XTHICK and YTHICK control the thickness of the axes
;         but either one will control both.  They are not
;         independent in this routine.  Also antialiased
;         LINESTYLE will not exactly match normal linestyle.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 15
;       R. Sterner, 2007 Feb 05 --- Made sure background is 0.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_plot, img, x0, y0, color=clr0, error=err,help=hlp, $
	  device=dev, position=pos0, thick=thk0, charthick=cthk0, $
	  charsize=csz0, antialiased=anti, xthick=xthick, ythick=ythick, $
	  psym=psym0, symsize=symsiz0, linestyle=lsty, nodata=nodata, $
	  title=ttl, xtitle=xttl, ytitle=yttl, _extra=extra0
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot on a 24-bit image without using X windows.'
	  print,' img2 = img_plot(img1,x,y)'
	  print,'   img1 = Original image.    in'
	  print,'   x,y = x,y arrays to plot. in'
	  print,'   img2 = returned image.    out'
	  print,' Keywords:'
	  print,'   COLOR=clr Plot color.'
	  print,'     May also be a 3 element array: [R,G,B].'
;	  print,'   THICK=thk  Curve thickness *def=!p.thickness).'
;	  print,'   CHARSIZE=csz Text size (def=!p.charsize).'
;	  print,'   CHARTHICK=cthk  Text Thickness (def=!p.charthick).'
;	  print,'   POSITION=pos plot position in normalized coordinates.'
;	  print,'   /DEVICE  means pos is in device coordinates.'
	  print,'   /ANTIALIASED means do antialiasing.  A bit slower.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: uses Z buffer, save a copy before if using Z.'
	  print,'   XTHICK and YTHICK control the thickness of the axes'
	  print,'   but either one will control both.  They are not'
	  print,'   independent in this routine.  Also antialiased'
	  print,'   LINESTYLE will not exactly match normal linestyle.'
	  return,''
	endif
 
	;-------  Check img  --------------------
	if n_elements(img) eq 0 then begin
	  print,' Error in img_plot: Input image undefined.'
	  err = 1
	  return,''
	endif
 
	;--------  Deal with x,y  ----------------
	if n_elements(x0) eq 0 then begin
	  print,' Error in img_plot: must give x,y or y to plot.'
	  err = 1
	  return,img
	endif
	if n_elements(y0) eq 0 then begin
	  y = x0
	  x = indgen(n_elements(y))
	endif else begin
	  x = x0
	  y = y0
	endelse
 
	;-------  Deal with color  --------------
	if n_elements(clr0) eq 0 then clr0 = !p.color	; Default color.
	clr = clr0					; Copy color.
	if n_elements(clr) eq 1 then begin
	   c2rgb, ulong(clr)<16777215, c1,c2,c3
	   clr = [c1,c2,c3]
	endif
	if n_elements(clr) ne 3 then begin
	  print,' Error in img_text: Must give a 3 elements plot color'
	  print,'   array: [r,g,b], or a 24-bit color value.'
	  err = 1
	  return,''
	endif
	mn = min(clr,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_text: Text color out of range (0-255).'
	  err = 1
	  return,''
	endif
 
	;----  Make sure _extra background color is 0  ----
	if n_elements(extra0) gt 0 then begin
	  extra = extra0	; Working copy.
	  if tag_test(extra,'backkground',minlen=2,index=ind) eq 1 then begin
	    bgclr = extra.(ind)	; Given background color.
	    extra.(ind) = 0	; Force background to 0.
	  endif
	endif
 
	;-------  Plot parameters  ------------------------
	csz = !p.charsize
	thk = !p.thick
	cthk = !p.charthick
	symsiz = !p.symsize
	psym = !p.psym
	if n_elements(csz0) ne 0 then csz=csz0
	if n_elements(thk0) ne 0 then thk=thk0
	if n_elements(cthk0) ne 0 then cthk=cthk0
	if n_elements(symsiz0) ne 0 then symsiz=symsiz0
	if n_elements(psym0) ne 0 then psym=psym0
	if csz eq 0 then csz=1.0
 
	;------  Deal with coordinate system  ---------
	if n_elements(pos0) ne 0 then begin
	  if keyword_set(dev) then begin
	    pos = pos0*3
	  endif else begin
	    pos = pos0
	  endelse
	endif
 
	;------  Split input image  ---------------
	img_split, img, r, g, b, tr=tr
 
	;=============================================================
	;  Do plot
	;=============================================================
	img_shape, r, nx=nx,ny=ny	; Image size.
 
	;---------  Antialiased text  ------------------
	if keyword_set(anti) then begin
	  zwindow,xs=3*nx,ys=3*ny	; Z buffer window (3x bigger).
	  ;---  Do axes  ------------
	  csz = csz*3*0.75
	  ;---  Axes only  ---------
	  plot,x,y,pos=pos,dev=dev,color=255,xtickn=strarr(31)+' ', $
	    ytickn=strarr(31)+' ',/nodata,chars=csz,_extra=extra
	  t1 = tvrd()			; Read back plot.
	  athk = 1
	  if keyword_set(xthick) then athk=xthick
	  if keyword_set(ythick) then athk=ythick
	  th1 = 3
	  if athk ge 2 then th1=2*athk+2
	  ;---  Axes with tick labels  ---------
	  plot,x,y,pos=pos,dev=dev,color=255,/nodata,chars=csz, $
	    title=ttl, xtitle=xttl, ytitle=yttl, _extra=extra
	  t2 = tvrd()			; Read back plot.
	  t2 = t2-t1			; Tick labels only.
	  th2 = 3
	  if cthk ge 2 then th2=2*cthk+2
	  ;----  Do curve  ----------
	  if not keyword_set(nodata) then begin
	    erase
	    oplot,x,y,psym=psym,symsize=symsiz*2.4, linestyle=lsty
	    t3 = tvrd()
	    th3 = 3
	    if thk ge 2 then th3=2*thk+2
	  endif
	  ;-----  Thicken  -----------
	  zwindow,/close		; Close z buffer window.
	  thicken, t1, 255, bold=th1	; Thicken axes.
	  thicken, t2, 255, bold=th2	; Thicken tick labels.
	  if not keyword_set(nodata) then begin
	    thicken, t3, 255, bold=th3	; Thicken curve.
	    t = t1>t2>t3
	  endif else begin
	    t = t1>t2
	  endelse
	  w = where(t ne 0, cnt)	; Find plotted pixels.
	  if cnt eq 0 then return, img	; Null plot.
	  r = rebin(r,3*nx,3*ny,/samp)	; Expand red.
	  r(w) = c1			; Plot in red.
	  r = rebin(r,nx,ny)		; Average down red.
	  if tr gt 0 then begin		; 24-bit image.
	    g = rebin(g,3*nx,3*ny,/samp); Expand green.
	    g(w) = c2			; Plot in green.
	    g = rebin(g,nx,ny)		; Average down green.
	    b = rebin(b,3*nx,3*ny,/samp); Expand blue.
	    b(w) = c3			; Plot in blue.
	    b = rebin(b,nx,ny)		; Average down blue.
	  endif else begin		; 8-bit image.
	    return, r			; Return 8-bit image.
	  endelse
	  
	;---------  Non-antialiased plot  ------------------
	endif else begin
	  zwindow,xs=nx,ys=ny		; Set up z buffer window.
	  plot,x,y,pos=pos,dev=dev,color=255,chars=csz*0.75, $
	    title=ttl, xtitle=xttl, ytitle=yttl, $
	    psym=psym,symsize=symsiz,linestyle=lsty, $
	    xthick=xthick, ythick=ythick, thick=thk0, charthick=cthk0, $
	    _extra=extra
	  t = tvrd()			; Read back plot.
	  zwindow,/close		; Close z buffer window.
	  w = where(t ne 0, cnt)	; Find plotted pixels.
	  if cnt eq 0 then return, img	; Null plot.
	  r(w) = c1			; Set in red component.
	  if tr gt 0 then begin		; 24-bit image.
	    g(w) = c2			; Set in green and blue
	    b(w) = c3			;   components.
	  endif else begin		; 8-bit image.
	    return, r			; Return 8-bit image.
	  endelse
  
	endelse
 
	;-------  Merge color channels back into a 24-bit image  -------
	return, img_merge(r,g,b,true=tr)
 
	end
