;-------------------------------------------------------------
;+
; NAME:
;       IMG_PLOTP
; PURPOSE:
;       Do a plotp on a 24-bit image without using X windows.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_plotp(img1,x,y,p)
; INPUTS:
;       img1 = Original image.                 in
;       x,y = array of xy coordinates to plot. in
;       p = optional pen code array.           in
;           0: move to point, 1: draw to point.
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Plot color.
;           May also be a 3 element array: [R,G,B].
;         THICK=thk  Thickness (def=!p.thick).
;         LINESTYLE=sty  Linestyle (def=!p.linestyle).
;           Linestyle will not work well for antialiased plots.
;         PSYM=psym  Plot symbol (def=none).
;         SYMSIZE=symsz Symbol size (def=1.).
;         /DEVICE, /DATA (def), /NORMALIZED Coordinates to use.
;         /ANTIALIASED means do antialiasing.  A bit slower.
;         /CLIP means clip to plot window (def=no clipping).
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img2 = returned image.                   out
; COMMON BLOCKS:
; NOTES:
;       Note: uses Z buffer, save a copy before if using Z.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 11
;       R. Sterner, 2002 Nov 18 --- Must call with img, x, y.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_plotp, img, x, y, p, color=clr0, error=err,help=hlp, $
	  device=dev, data=dat, normalized=nrm, linestyle=sty, thick=thk, $
	  antialiased=anti, psym=psym, symsize=symsz, clip=clip
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Do a plotp on a 24-bit image without using X windows.'
	  print,' img2 = img_plotp(img1,x,y,p)'
	  print,'   img1 = Original image.                 in'
	  print,'   x,y = array of xy coordinates to plot. in'
	  print,'   p = optional pen code array.           in'
	  print,'       0: move to point, 1: draw to point.'
	  print,'   img2 = returned image.                   out'
	  print,' Keywords:'
	  print,'   COLOR=clr Plot color.'
	  print,'     May also be a 3 element array: [R,G,B].'
	  print,'   THICK=thk  Thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty  Linestyle (def=!p.linestyle).'
	  print,'     Linestyle will not work well for antialiased plots.'
	  print,'   PSYM=psym  Plot symbol (def=none).'
	  print,'   SYMSIZE=symsz Symbol size (def=1.).'
	  print,'   /DEVICE, /DATA (def), /NORMALIZED Coordinates to use.'
	  print,'   /ANTIALIASED means do antialiasing.  A bit slower.'
	  print,'   /CLIP means clip to plot window (def=no clipping).'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: uses Z buffer, save a copy before if using Z.'
	  return,''
	endif
 
	;-------  Check img,x,y  --------------------
	if n_elements(img) eq 0 then begin
	  print,' Error in img_plotp: Input image undefined.'
	  return,''
	endif
;	if n_elements(x) eq 0 then return, img
;	if n_elements(y) eq 0 then return, img
 
	;-------  Deal with color  --------------
	if n_elements(clr0) eq 0 then clr0 = !p.color	; Default color.
	clr = clr0					; Copy color.
	if n_elements(clr) eq 1 then begin
	   c2rgb, ulong(clr)<16777215, c1,c2,c3
	   clr = [c1,c2,c3]
	endif
	if n_elements(clr) ne 3 then begin
	  print,' Error in img_plotp: Must give a 3 elements plot color'
	  print,'   array: [r,g,b], or a 24-bit color value.'
	  err = 1
	  return,''
	endif
	mn = min(clr,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_plotp: Plot color out of range (0-255).'
	  err = 1
	  return,''
	endif
 
	;-------  Plot parameters  ------------------------
	if n_elements(sty) eq 0 then sty=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(psym) eq 0 then psym=0            ; Plot symbol.
	if n_elements(symsz) eq 0 then symsz=1          ; Symbol size.
 
	;------  Deal with coordinate system  ---------
	flag = 2
	if keyword_set(dev) then flag=1
	if keyword_set(nrm) then flag=3
 
	;---  Convert x,y to device: ix,iy  --------------
	case flag of
1:	begin
	  ix = round(x)
	  iy = round(y)
	end
2:	begin
	  t = round(convert_coord(x,y,/data,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
3:	begin
	  t = round(convert_coord(x,y,/norm,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
	endcase
 
	;------  Split input image  ---------------
	img_split, img, r, g, b, tr=tr
 
	;=============================================================
	;  Do plot
	;=============================================================
	img_shape, r, nx=nx,ny=ny	; Image size.
 
	;---------  Antialiased plot  ------------------
	if keyword_set(anti) then begin
	  zwindow,xs=3*nx,ys=3*ny	; Z buffer window (3x bigger).
	  plotp, /dev, 3*ix,3*iy,p, $	; Plot on it.
	    color=255, linestyl=sty, thick=1, $
	    psym=psym, symsize=symsz*2.4, clip=clip
	  t = tvrd()			; Read back plot.
	  zwindow,/close		; Close z buffer window.
	  if thk lt 2 then t2=3 else t2 = 2*(thk>1)+2
	  thicken,t,255,bold=t2,/quiet	; Thicken plot.
	  w = where(t ne 0, cnt)	; Find plotted pixels.
	  if cnt eq 0 then return, img	; Null plot.
	  r = rebin(r,3*nx,3*ny,/samp)	; Expand red.
	  r(w) = c1			; Plot in red.
	  r = rebin(r,nx,ny)		; Average down red.
	  if tr gt 0 then begin		; 24-bit image.
	    g = rebin(g,3*nx,3*ny,/samp); Expand green.
	    g(w) = c2			; Plot in green.
	    g= rebin(g,nx,ny)		; Average down green.
	    b = rebin(b,3*nx,3*ny,/samp); Expand blue.
	    b(w) = c3			; Plot in blue.
	    b= rebin(b,nx,ny)		; Average down blue.
	  endif else begin		; 8-bit image.
	    return, r			; Return 8-bit image.
	  endelse
	  
	;---------  Non-antialiased plot  ------------------
	endif else begin
	  zwindow,xs=nx,ys=ny		; Set up z buffer window.
	  plotp, /dev, ix,iy,p, $	; Plot on it.
	    color=255, linestyl=sty, thick=thk, $
	    psym=psym, symsize=symsz, clip=clip
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
