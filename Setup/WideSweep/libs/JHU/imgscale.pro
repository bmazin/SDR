;-------------------------------------------------------------
;+
; NAME:
;       IMGSCALE
; PURPOSE:
;       Interactive image scaling.
; CATEGORY:
; CALLING SEQUENCE:
;       imgscale, in, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /SATURATE  Means display saturation colors as warning.
;         EXIT_CODE=code  Exit code: 0=ok, 1=cancel.
; OUTPUTS:
;       in=[inlo,inhi]     Input image low and high values.   out
;       out=[outlo,outhi]  Output image low and high values.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: in and out define the requested grayscale mapping.
;         The input image value inlo maps to the output image value
;         outlo, and inhi maps to outhi.  All values are in the
;         range 0 to 1 and are image value (as in hue,sat,val).
;         The routine imgscale is used to select the desired
;         scaling, it does not actually do it.  To scale do:
;            new = scalearray(old,in(0),in(1),out(0),out(1))>0<1
;         Where new and old are the image values.  For BW images
;         just multiply imgscale results by 255 first:
;         in=in*255 & out=out*255
;            new = scalearray(old,in(0),in(1),out(0),out(1))>0<255
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Dec 3
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 1999 Aug 10 --- Fixed the problem of locked windows.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgscale, input, output, exit_code=code, saturate=sat, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Interactive image scaling.'
	  print,' imgscale, in, out'
	  print,'   in=[inlo,inhi]     Input image low and high values.   out'
	  print,'   out=[outlo,outhi]  Output image low and high values.  out'
	  print,' Keywords:'
	  print,'   /SATURATE  Means display saturation colors as warning.'
	  print,'   EXIT_CODE=code  Exit code: 0=ok, 1=cancel.'
	  print,' Notes: in and out define the requested grayscale mapping.'
	  print,'   The input image value inlo maps to the output image value'
	  print,'   outlo, and inhi maps to outhi.  All values are in the'
	  print,'   range 0 to 1 and are image value (as in hue,sat,val).'
	  print,'   The routine imgscale is used to select the desired'
	  print,'   scaling, it does not actually do it.  To scale do:'
	  print,'      new = scalearray(old,in(0),in(1),out(0),out(1))>0<1'
	  print,'   Where new and old are the image values.  For BW images'
	  print,'   just multiply imgscale results by 255 first:'
	  print,'   in=in*255 & out=out*255'
	  print,'      new = scalearray(old,in(0),in(1),out(0),out(1))>0<255'
	  return
	endif
 
	;-------  Control window  ----------
	top = topc()
	nx = 256.
	ny = 256.
	nx2 = nx/2
	ny2 = ny/2
	window,/free,xs=nx+1,ys=ny+1,title='Adjust Color Table'
	polyfill,/dev,[0,nx-1,nx-1,0],[0,0,ny2,ny2],col=255
	plot,[-1,1],[-1,1],/nodata,xstyl=5,ystyl=5,pos=[.01,.01,.99,.99],$
	  /noerase
	xyouts,-0.05,0.02,'+CONTRAST -->',chars=1.,orient=90.
	xyouts,0.05,-0.02,'-CONTRAST -->',chars=1.,orient=-90.,col=0
	xyouts,-0.8,0.4,'<-- BRIGHTER',chars=1.
	xyouts,0.8,0.4,'DARKER -->',chars=1.,align=1
	xyouts,-0.8,-0.44,'<-- DARKER',chars=1.,col=0
	xyouts,0.8,-0.44,'BRIGHTER -->',chars=1.,align=1,col=0
	xyouts,/dev,93,10,'INPUT   VALUES',chars=1.,col=0
	xyouts,/dev,18,84,'OUTPUT',chars=1.,orient=90.,col=0
	xyouts,/dev,18,120,'   VALUES',chars=1.,orient=90.,col=255
	xyouts,-0.05,0.87,'BUTTONS',align=1
	xyouts,0.05,0.87,'LEFT: CHANGE (DRAG)'
	xyouts,0.05,0.77,'MIDDLE: MOVE IMAGE'
	xyouts,0.05,0.67,'RIGHT: QUIT'
	device,set_graph=6
	plot,[-1,1],[-1,1],/nodata,xstyl=1,ystyl=1,pos=[.01,.01,.99,.99],$
	  /noerase
	hor,[-.5,0,.5]
	ver,0
	vx = maken(-1,1,200)
	vy = vx
	oplot,vx,vy
	win = !d.window
	x = 0
	y = .5
	x2 = x			; Remember last used coordinates.
	y2 = y
	tvcrs,nx2,ny*3/4
	device,set_graph=3
	plots,x,y,psym=6
	device,set_graph=6
	!mouse.button = 0
 
	;-------  Color table  ---------------
	tvlct,r0,g0,b0,/get
	color_convert,r0,g0,b0,h0,s0,v0,/rgb_hsv
	v1 = 2*v0 - 1.
	s = 1.
	off = 0.
 
	;-------  Main loop  -----------------
loop:	repeat begin
	  cursor,x,y,/data,/change
	  if !mouse.button eq 1 then begin
	    oplot,vx,vy			; Erase old.
	    yy = (90*y)<90>(-90)	; Angle.
	    s = tan(yy/!radeg)		; Slope.
	    xx = x*(1+1/abs(s))			; Offset.
;            print,xx,yy
	    off = xx
	    v2 = s*(v1-off)>(-1)<1
	    v = .5*(v2+1)
	    color_convert,h0,s0,v,r,g,b,/hsv_rgb
	    if keyword_set(sat) then begin	; Saturation warning colors.
	      w1 = where(v eq 0,c1)		; How many values eq 0?
	      w2 = where(v eq 1,c2)		; How many values eq 1?
	      if c1 gt 0 then begin		; Deal with clip at 0.
	        g(w1)=255			; Turn on green.
	        if s gt 0 then begin		; Except bottom.
		  g(0) = 0			; + Slope.
	        endif else begin
		  g(top) = 0			; - Slope.
		endelse
	      endif
	      if c2 gt 0 then begin		; Deal with clip at 1.
	        g(w2)=0				; Turn off green
	        b(w2)=0				; and blue (to get red).
		if s gt 0 then begin		; Except top.
	          g(top) = 255			; + Slope.
	          b(top) = 255
		endif else begin
	          g(0) = 255			; - Slope.
	          b(0) = 255
		endelse
	      endif
	    endif ; sat.
	    tvlct,r,g,b
	    vy = s*(vx-off)>(-1)<1
	    oplot,vx,vy
	    x2 = x				; Remember used coordinates.
	    y2 = y
	  endif
	endrep until !mouse.button ge 2
 
	if !mouse.button eq 2 then begin
	  xmess,'Scroll window, click OK to continue'
	  t = convert_coord(x2,y2,/to_dev)
	  tvcrs,t(0),t(1)
	  goto, loop
	endif
 
	if !mouse.button eq 4 then begin
	  opt = xoption(['Quit','Cancel','Continue'],val=['Q','CAN','CON'])
	  if opt eq 'Q' then begin
	    code = 0 
	  endif
	  if opt eq 'CAN' then begin
	    code = 1 
	  endif
	  if opt eq 'CON' then begin
	    t = convert_coord(x2,y2,/to_dev)
	    tvcrs,t(0),t(1)
	    goto, loop
	  endif
	endif
 
	;------  Return scaling info  -------------
	if code eq 0 then begin
	  if abs(s) le 1 then begin	; Small slope.
	    vy = s*([-1,1]-off)		; For x=[-1,1] find y.
	    in = [0.,1.]		; X was set, remapped would be this.
	    out = .5*(vy+1)		; Remap Y.
	  endif else begin		; Large slope.
	    vx = ([-1,1]/s + off)	; For y=[-1,1] find x.
	    out = [0.,1.]		; Y was set, remapped would be this.
	    in = .5*(vx+1)		; Remap X.
	  endelse
	  vclip,in,out,input,output
	endif else tvlct,r0,g0,b0
	wdelete,win
	device,set_graph=3
 
	;-----  Undo saturation colors  ----------
	if code eq 0 then begin
	  if keyword_set(sat) and n_elements(c1) ne 0 then begin
	    if c1 gt 0 then begin	; Deal with clip at 0.
	       g(w1)=0			; Turn on green.
	    endif
	    if c2 gt 0 then begin	; Deal with clip at 1.
	       g(w2)=255		; Turn off green
	       b(w2)=255		; and blue (to get red).
	    endif
	    tvlct,r,g,b			; Load corrected table.
	  endif ; sat.
	endif ; code
 
	return
	end
