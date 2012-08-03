;-------------------------------------------------------------
;+
; NAME:
;       IZOOM_SUB
; PURPOSE:
;       Zoom part of an image that has scale embedded by put_scale.
; CATEGORY:
; CALLING SEQUENCE:
;       izoom_sub
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SCALE=scale  New scale factor (def=2).
;         Other keywords: COLOR=clr, CHARSIZE=csz, XTITLE=ttx,
;           YTITLE=tty, XMAR1=xmar1 (left), XMAR2=xmar2 (right),
;           YMAR1=ymar1 (bottom), YMAR2=ymar2 (top).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Must have embedded scaling as placed there by
;       by the put_scale routine.  Magnifies by pixel replication.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Oct 19
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro izoom_sub, scale=scale, color=clr, charsize=csz, $
	  xtitle=ttx, ytitle=tty, xmar1=xmar1, xmar2=xmar2, $
	  ymar1=ymar1, ymar2=ymar2, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Zoom part of an image that has scale embedded by put_scale.'
	  print,' izoom_sub'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   SCALE=scale  New scale factor (def=2).'
	  print,'   Other keywords: COLOR=clr, CHARSIZE=csz, XTITLE=ttx,'
	  print,'     YTITLE=tty, XMAR1=xmar1 (left), XMAR2=xmar2 (right),'
	  print,'     YMAR1=ymar1 (bottom), YMAR2=ymar2 (top).'
	  print,' Notes: Must have embedded scaling as placed there by'
	  print,' by the put_scale routine.  Magnifies by pixel replication.'
	  return
	endif
 
 
	;-------  First get scaling info  ------------
	set_scale, x1=x1, x2=x2, y1=y1, y2=y2, $
	  ix1=ix1, ix2=ix2, iy1=iy1, iy2=iy2, nx=nx,ny=ny, $
	  err=err, /quiet
 
	wshow
	xhelp,['Drag mouse cursor to open a box on the image.',$
		'Drag inside box to move it, drag a side or',$
		'corner to move it.  Use left button to drag,',$	
		'any other button to exit.'], /nowait, wid=wid
 
	;-------  Selection box  ---------
	box2b,jx1,jx2,jy1,jy2,exit=ex
	;-------  Correct if out of bounds  ----------
	if jx1 lt ix1 then begin
	  jx1 = ix1
	  print,' Warning: corrected out of bounds selection box (min x).'
	endif
	if jx2 gt ix2 then begin
	  jx2 = ix2
	  print,' Warning: corrected out of bounds selection box (max x).'
	endif
	if jy1 lt iy1 then begin
	  jy1 = iy1
	  print,' Warning: corrected out of bounds selection box (min y).'
	endif
	if jy2 gt iy2 then begin
	  jy2 = iy2
	  print,' Warning: corrected out of bounds selection box (max y).'
	endif
	widget_control, wid, /dest
	if ex eq 1 then return
 
	;------  Get izoom image and coordinate arrays  ---------
	a = tvrd(ix1,iy1,nx,ny)		; Read image.
	x = maken(x1,x2,nx)
	y = maken(y1,y2,ny)
 
	;-------  Get selected x and y ranges  -------------
	xran = x([jx1,jx2]-ix1)
	yran = y([jy1,jy2]-iy1)
 
	;-------  Use existing margins if none given  ----------
	if n_elements(xmar1) eq 0 then xmar1 = ix1
	if n_elements(ymar1) eq 0 then ymar1 = iy1
	if n_elements(xmar2) eq 0 then xmar2 = !d.x_size-ix2-1
	if n_elements(ymar2) eq 0 then ymar2 = !d.y_size-iy2-1
 
	;------  Defaults  ----------
	if n_elements(scale) eq 0 then scale=2		; Default scale is 2.
	if n_elements(clr) eq 0 then clr=tarclr(255,255,255)	; Def clr=white.
	if n_elements(csz) eq 0 then csz=1.5
	if n_elements(ttx) eq 0 then ttx=''
	if n_elements(tty) eq 0 then tty=''
	xyouts,0,0,'!17'
 
	;-------  New image window and position  ------------
	nx2 = (jx2-jx1+1)*scale		; New image size.
	ny2 = (jy2-jy1+1)*scale
	pos = [xmar1,ymar1,xmar1+nx2,ymar1+ny2]
 
	;-------  Window size and window  -------
	xs = nx2+xmar1+xmar2
	ys = ny2+ymar1+ymar2
	if (xs gt 1000) or (ys gt 900) then begin
	  swindow,/free,xs=xs, ys=ys, x_scr=1000<xs, y_scr=900<ys
	endif else begin
	  window,/free,xs=xs, ys=ys
	endelse
	ticklen, -8,-8,tx,ty,pos=pos,/dev
	izoom,x,y,a,xran=xran,yran=yran,pos=pos,/dev, $
	  xticklen=tx, yticklen=ty, color=clr, charsize=csz, $
	  xtitle=ttx, ytitle=tty
	put_scale
 
	end
