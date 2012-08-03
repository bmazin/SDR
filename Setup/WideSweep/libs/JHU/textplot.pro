;-------------------------------------------------------------
;+
; NAME:
;       TEXTPLOT
; PURPOSE:
;       Plot text with 2-d alignment.  Also return bounding box.
; CATEGORY:
; CALLING SEQUENCE:
;       textplot, x, y, txt
; INPUTS:
;       x,y = Text x,y position.   in
;       text = text to plot.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ANTI means use antialiased text.  Slow but looks better.
;         CHARSIZE=character size (def=1).
;         COLOR=clr Text color (may be 1-d array).
;           If not given defaults to !p.color first time.  If you
;           switch to PS color you may have to set to non-white.
;         BOLD=bld Text bold value (=CHARSIZE. may be 1-d array).
;         SHIFT=shft Shift between colors (for drop shadows).
;         PIXELS=p number of pixels to use for each shift (def=1).
;           For hardcopy try 5 or 10.
;           SHIFT and PIXELS do not apply if /ANTI used.
;         ORIENTATION=ang Text angle CCW from horizontal (deg).
;         ALIGNMENT=fx or [fx,fy] Text alignment as fraction of
;           text size in x or x and y relative to x,y
;           (def=lower left corner = [0,0]).
;         OFFSET=off Along text offset in characters (def=0).
;           Useful with alignment fx=0 and off=1 to offset 1 char.
;         /DEVICE,/NORMAL,/DATA coordinate system to use (def=DATA).
;         MARGIN=mar  Expand bounding box by margin (pixels, def=0).
;         FACTOR=fact Text height factor (def=1) for current font.
;           This factor is applied to bounding box height.
;         BOX=bclr Set bounding box color (-1 for none).
;         FILL=fclr Set bounding box fill color (-1 for none).
;         /TEST plot bounding box and reference point.
;         /SET save any given keyword values for future calls.
;         HREF=href Give a URL to be used in an image map when
;           clicking inside the bounding box.  Def=none.
;         CODE=code  Returned image map code if given a non-null
;           URL.
;         FRONT_CODE=front HTML code for the image and start of
;           the image map.
;         TAIL_CODE=tail  HTML code to terminate the image map.
;         IMAGE=img  Name of image map image (def=IMAGE).
;         XCROP=[x1,x2]  Min and Max image pixels to keep in X.
;         YCROP=[y1,y2]  Min and Max image pixels to keep in Y.
;         XBOX=bx, YBOX=by returned bounding box (device).  Useful
;           for avoiding crowded labels.
;         /NOPLOT do not plot text (useful for just finding size).
; OUTPUTS:
; COMMON BLOCKS:
;       textplot_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Nov 13
;       R. Sterner, 2001 May 11 --- Made /DATA default system.
;       R. Sterner, 2002 Jan 07 --- Returned bounding box.
;       R. Sterner, 2002 Feb 10 --- Added /NOPLOT.
;       R. Sterner, 2002 Feb 21 --- Added OFFSET=off
;       R. Sterner, 2002 Jul 26 --- Added /ANTI.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro textplot, x, y, txt, charsize=csz, orient=ang, alignment=jst, $
	  device=dev, normalized=nrm, data=dat, factor=fact, $
	  test=test, margin=mrg, help=hlp, bold=bold, color=color, $
	  shift=shft, pixels=pixels, box=box, fill=fill, set=set, $
	  code=code, href=href, front_code=front, tail_code=tail, $
	  image=img, xcrop=xcrp, ycrop=ycrp, xbox=xx2, ybox=yy2, $
	  noplot=noplot, offset=offset, anti=anti
 
	common textplot_com, csz0, ang0, jst0, fact0, mrg0, bold0, $
	  color0, shft0, pixels0, fill0, box0, fill_flag, box_flag, $
	  xcrp0, ycrp0, href0, img0
 
	if keyword_set(help) then begin
hlp:	  print,' Plot text with 2-d alignment.  Also return bounding box.'
	  print,' textplot, x, y, txt'
	  print,'   x,y = Text x,y position.   in'
	  print,'   text = text to plot.       in'
	  print,' Keywords:'
	  print,'   /ANTI means use antialiased text.  Slow but looks better.'
	  print,'   CHARSIZE=character size (def=1).'
	  print,'   COLOR=clr Text color (may be 1-d array).'
	  print,'     If not given defaults to !p.color first time.  If you'
	  print,'     switch to PS color you may have to set to non-white.'
	  print,'   BOLD=bld Text bold value (=CHARSIZE. may be 1-d array).'
	  print,'   SHIFT=shft Shift between colors (for drop shadows).'
	  print,'   PIXELS=p number of pixels to use for each shift (def=1).'
	  print,'     For hardcopy try 5 or 10.'
	  print,'     SHIFT and PIXELS do not apply if /ANTI used.'
	  print,'   ORIENTATION=ang Text angle CCW from horizontal (deg).'
	  print,'   ALIGNMENT=fx or [fx,fy] Text alignment as fraction of'
	  print,'     text size in x or x and y relative to x,y'
	  print,'     (def=lower left corner = [0,0]).'  
	  print,'   OFFSET=off Along text offset in characters (def=0).'
	  print,'     Useful with alignment fx=0 and off=1 to offset 1 char.'
	  print,'   /DEVICE,/NORMAL,/DATA coordinate system to use (def=DATA).'
	  print,'   MARGIN=mar  Expand bounding box by margin (pixels, def=0).'
	  print,'   FACTOR=fact Text height factor (def=1) for current font.'
	  print,'     This factor is applied to bounding box height.'
	  print,'   BOX=bclr Set bounding box color (-1 for none).'
	  print,'   FILL=fclr Set bounding box fill color (-1 for none).'
	  print,'   /TEST plot bounding box and reference point.'
	  print,'   /SET save any given keyword values for future calls.'
	  print,'   HREF=href Give a URL to be used in an image map when'
	  print,'     clicking inside the bounding box.  Def=none.'
	  print,'   CODE=code  Returned image map code if given a non-null'
	  print,'     URL.'
	  print,'   FRONT_CODE=front HTML code for the image and start of'
	  print,'     the image map.'
	  print,'   TAIL_CODE=tail  HTML code to terminate the image map.'
	  print,'   IMAGE=img  Name of image map image (def=IMAGE).'
	  print,'   XCROP=[x1,x2]  Min and Max image pixels to keep in X.'
	  print,'   YCROP=[y1,y2]  Min and Max image pixels to keep in Y.'
	  print,'   XBOX=bx, YBOX=by returned bounding box (device).  Useful'
	  print,'     for avoiding crowded labels.'
	  print,'   /NOPLOT do not plot text (useful for just finding size).'
	  return
	endif
 
	if (n_params(0) eq 0) and (not keyword_set(set)) then goto, hlp
 
	;----------------------------------------------
	;  Define values in common
	;----------------------------------------------
	if n_elements(csz0) eq 0 then begin
	  csz0 = 1.
	  ang0 = 0.
	  jst0 = [0.,0.]
	  fact0 = 1.
	  mrg0 = 0
	  bold0 = 1
	  color0 = !p.color
	  shft0	= 0
	  pixels0 = 1
	  fill0 = -1 
	  box0 = -1
	  fill_flag = 0
	  box_flag = 0
	  href0 = ''
	  img0 = 'IMAGE'
	  xcrp0 = [0,!d.x_size-1]
	  ycrp0 = [0,!d.y_size-1]
	endif
 
	;----------------------------------------------
	;  Default values
	;----------------------------------------------
	if n_elements(bold) eq 0 then bold=bold0
	if n_elements(color) eq 0 then color=color0
	if n_elements(shft) eq 0 then shft=shft0
	if n_elements(pixels) eq 0 then pixels=pixels0
	if n_elements(csz) eq 0 then csz=csz0
	if n_elements(ang) eq 0 then ang=ang0
	if n_elements(fact) eq 0 then fact=fact0
	if n_elements(mrg) eq 0 then mrg=mrg0
	if n_elements(jst) eq 0 then jst=jst0
	fx = jst(0)
	fy = 0.
	if n_elements(jst) gt 1 then fy=jst(1)
	if n_elements(offset) eq 0 then offset=0.
	if n_elements(fill) eq 0 then fill=fill0
	if n_elements(box) eq 0 then box=box0
	if fill eq -1 then fill_flag=0 else fill_flag=1
	if box eq -1 then box_flag=0 else box_flag=1
	if n_elements(href) eq 0 then href=href0
	if n_elements(img) eq 0 then img=img0
	if n_elements(xcrp) eq 0 then xcrp=xcrp0
	if n_elements(ycrp) eq 0 then ycrp=ycrp0
 
	;----------------------------------------------
	;  Set new default values
	;----------------------------------------------
	if keyword_set(set) then begin
	  if n_elements(bold) ne 0 then bold0=bold
	  if n_elements(color) ne 0 then color0=color
	  if n_elements(shft) ne 0 then shft0=shft
	  if n_elements(pixels) ne 0 then pixels0=pixels
	  if n_elements(csz) ne 0 then csz0=csz
	  if n_elements(ang) ne 0 then ang0=ang
	  if n_elements(fact) ne 0 then fact0=fact
	  if n_elements(mrg) ne 0 then mrg0=mrg
	  if n_elements(jst) ne 0 then jst0=jst
	  if n_elements(fill) ne 0 then fill0=fill
	  if n_elements(box) ne 0 then box0=box
	  if n_elements(txt) ne 0 then return
	  if n_elements(href) ne 0 then href0=href
	  if n_elements(img) ne 0 then img0=img
	  if n_elements(xcrp) ne 0 then xcrp0=xcrp
	  if n_elements(ycrp) ne 0 then ycrp0=ycrp
	  if n_params(0) lt 3 then return
	endif
 
	;----------------------------------------------
	;  Determine coordinate system
	;----------------------------------------------
	cflag = 0					  ; None.
	if keyword_set(dev) then cflag=1		  ; /DEVICE
	if keyword_set(nrm) then cflag=2		  ; /NORM
	if keyword_set(dat) then cflag=3		  ; /DATA
	if cflag eq 0 then cflag=3			  ; Default to /DATA.
	;----------------------------------------------
 
	;----------------------------------------------
	;  Convert reference point to device.
	;----------------------------------------------
	case cflag of
1:	begin
	  x1 = x
	  y1 = y
	end
2:	begin
	  x1 = x*!d.x_size
	  y1 = y*!d.y_size
	end
3:	begin
	  tmp = convert_coord(x,y,/data,/to_dev)
	  x1 = tmp(0)	
	  y1 = tmp(1)
	end
	endcase
 
	;----------------------------------------------
	;  Size of text bounding box
	;----------------------------------------------
	dy = 0.665*fact*csz*!d.y_ch_size/(!d.y_size+0.)		; Normalize.
	xyouts,/norm,-10,-10,txt,charsize=csz, width=dx
	dx = dx*!d.x_size					; Device.
	dy = dy*!d.y_size
	xyouts,/norm,-10,-10,'M',charsize=csz, width=dx_m	; 1 char width.
	dx_m = dx_m*!d.x_size					; Device.
 
	;----------------------------------------------
	;  Offset from ref point to text corner (dev).
	;----------------------------------------------
	xoff0 = dx*fx - offset*dx_m	; Non-rotated offset.
	yoff0 = dy*fy
	rotate_xy,-xoff0,-yoff0,ang,/deg,0,0,xoff,yoff
 
	;----------------------------------------------
	;  Bounding box
	;----------------------------------------------
	xx = [-mrg,dx+mrg,dx+mrg,-mrg,-mrg] - xoff0		; Device.
	yy = [-mrg,-mrg,dy+mrg,dy+mrg,-mrg] - yoff0
	rotate_xy,xx,yy,ang,/deg,0,0,xx2,yy2	; Relative to ref point.
	xx2 = xx2 + x1				; Translate to ref pt.
	yy2 = yy2 + y1
 
	;----------------------------------------------
	;  Fill bounding box.
	;----------------------------------------------
	if fill_flag then begin
	  polyfill,/dev,xx2,yy2,color=fill
	endif
 
	;----------------------------------------------
	;  Draw bounding box.
	;----------------------------------------------
	if box_flag then begin
	  plots,xx2,yy2,/dev,color=box
	endif
 
	;----------------------------------------------
	;  Plot text
	;----------------------------------------------
	if not keyword_set(noplot) then begin
	  if keyword_set(anti) then begin
	    aatext,x1+xoff,y1+yoff,txt,chars=csz,orient=ang,/dev, $
	      charthick=bold, color=color
	  endif else begin
	    xyoutb,x1+xoff,y1+yoff,txt,chars=csz,orient=ang,/dev, $
	      bold=bold, color=color, shift=shft, pixels=pixels
	  endelse
	endif
 
	;----------------------------------------------
	;  Test plot bounding box and ref pt.
	;----------------------------------------------
	if keyword_set(test) then begin
	  plots,xx2,yy2,/dev			; Bounding box.
	  plots,x1,y1,psym=2,/dev		; Reference point.
	endif
 
	;----------------------------------------------
	;  Image map html code.
	;----------------------------------------------
	front = ['<html>','<head>','<title>Image map</title>',$
	         '</head>',' ','<body bgcolor="black">','<center>', $
	         '<img src="'+img+'" usemap="#map">',$
	         ' ','<map name="map">']
	tail = ['<area shape="default" nohref>','</map>',$
	        '</body>','</html>']
	if n_elements(href) eq 0 then href=''		 ; No href, no code.
	if href eq '' then begin
	  code = ''
	endif else begin				 ; Have href, do code.
	  pxx = round(xx2-xcrp(0))			 ; Polygon points.
	  pyy = round(ycrp(1) - yy2)
	  t = ''
	  for i=0,3 do begin				 ; Loop through 4 pts.
	    if t ne '' then t=t+','
	    t = t + strtrim(pxx(i),2)+','+strtrim(pyy(i),2)
	  endfor
	  code = ['<area shape="poly"','    coords="'+t+'"',$
	    '    href="'+href+'">']
	endelse
 
	end
