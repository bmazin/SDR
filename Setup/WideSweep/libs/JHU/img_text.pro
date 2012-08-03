;-------------------------------------------------------------
;+
; NAME:
;       IMG_TEXT
; PURPOSE:
;       Plot text on a 24-bit image without using X windows.
; CATEGORY:
; CALLING SEQUENCE:
;       img2 = img_text(img1,x,y,txt)
; INPUTS:
;       img1 = Original image. in
;       x,y = Text position.   in
;       txt = Text.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         CHARSIZE=csz Text size (def=!p.charsize).
;         ORIENTATION=ang Text angle (deg, def=0).
;         ALIGNMENT=align Text alignment (def=0.).
;         COLOR=clr Text color.
;           May also be a 3 element array: [R,G,B].
;         CHARTHICK=cthk  Text Thickness (def=!p.charthick).
;         /DEVICE, /DATA (def), /NORMALIZED Coordinates to use.
;         /ANTIALIASED means do antialiasing.  A bit slower.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       img2 = returned image. out
; COMMON BLOCKS:
; NOTES:
;       Note: Arrays are allowed for x,y,txt,csz, ang, and
;           align.  clr and cthk must be scalars.
;         Uses Z buffer, save a copy before if using Z.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 12
;       R. Sterner, 2002 Jul 24 --- Allowed size and angle to be arrays.
;       R. Sterner, 2002 Jul 25 --- Allowed alignment to be an array.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_text, img, x, y, txt, color=clr0, error=err,help=hlp, $
	  device=dev, data=dat, normalized=nrm, charthick=cthk, $
	  charsize=csz, orientation=ang, antialiased=anti, $
	  align=align,  _extra=extra
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot text on a 24-bit image without using X windows.'
	  print,' img2 = img_text(img1,x,y,txt)'
	  print,'   img1 = Original image. in'
	  print,'   x,y = Text position.   in'
	  print,'   txt = Text.            in'
	  print,'   img2 = returned image. out'
	  print,' Keywords:'
	  print,'   CHARSIZE=csz Text size (def=!p.charsize).'
	  print,'   ORIENTATION=ang Text angle (deg, def=0).'
	  print,'   ALIGNMENT=align Text alignment (def=0.).'
	  print,'   COLOR=clr Text color.'
	  print,'     May also be a 3 element array: [R,G,B].'
	  print,'   CHARTHICK=cthk  Text Thickness (def=!p.charthick).'
	  print,'   /DEVICE, /DATA (def), /NORMALIZED Coordinates to use.'
	  print,'   /ANTIALIASED means do antialiasing.  A bit slower.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: Arrays are allowed for x,y,txt,csz, ang, and'
	  print,'     align.  clr and cthk must be scalars.'
	  print,'   Uses Z buffer, save a copy before if using Z.'
	  return,''
	endif
 
	;-------  Check img,x,y  --------------------
	if n_elements(img) eq 0 then begin
	  print,' Error in img_text: Input image undefined.'
	  return,''
	endif
	if n_elements(x) eq 0 then return, img
	if n_elements(y) eq 0 then return, img
 
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
 
	;-------  Plot parameters  ------------------------
	if n_elements(csz) eq 0 then csz=!p.charsize
	if n_elements(cthk) eq 0 then cthk=!p.charthick
	if n_elements(ang) eq 0 then ang=0
	if n_elements(align) eq 0 then align=0.
 
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
	;  Do text
	;=============================================================
	img_shape, r, nx=nx,ny=ny	; Image size.
 
	;---------  Antialiased text  ------------------
	if keyword_set(anti) then begin
	  zwindow,xs=3*nx,ys=3*ny	; Z buffer window (3x bigger).
	  ;-----------------------------------------------
	  for i=0,n_elements(txt)-1 do begin
	    ix2 = (ix([i]))(0)
	    iy2 = (iy([i]))(0)
	    txt2 = (txt([i]))(0)
	    csz2 = (csz([i]))(0)
	    ang2 = (ang([i]))(0)
	    align2 = (align([i]))(0)
	    xyouts, /dev, 3*ix2,3*iy2,txt2, orient=ang2, $	; Plot on it.
	      color=255, charsize=csz2*3*0.75, align=align2, _extra=extra
	  endfor
	  ;-----------------------------------------------
	  t = tvrd()			; Read back plot.
	  zwindow,/close		; Close z buffer window.
	  if cthk lt 2 then t2=3 else t2 = 2*(cthk>1)+2
	  thicken, t, 255, bold=t2	; Thicken plot.
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
	  ;-----------------------------------------------
	  for i=0,n_elements(txt)-1 do begin
	    ix2 = (ix([i]))(0)
	    iy2 = (iy([i]))(0)
	    txt2 = (txt([i]))(0)
	    csz2 = (csz([i]))(0)
	    ang2 = (ang([i]))(0)
	    align2 = (align([i]))(0)
	    xyouts, /dev, ix2,iy2,txt2, $	; Plot on it.
	      color=255, charsize=csz2*0.75, $
	      charthick=cthk, orient=ang2, align=align2, _extra=extra
	  endfor
	  ;-----------------------------------------------
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
