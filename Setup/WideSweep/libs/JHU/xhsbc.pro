;-------------------------------------------------------------
;+
; NAME:
;       XHSBC
; PURPOSE:
;       Adjust image hue, saturation, brightness, & contrast. Widget.
; CATEGORY:
; CALLING SEQUENCE:
;       xhsbc
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Oct 14
;       R. Sterner, 1994 Oct 14
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xhsbc_update, x, m, win, sz
 
	x = x>0<399
	wset, win
	erase
	polyfill, /dev, [0,x,x,0],[0,0,sz,sz]
	ver,/dev,199,col=0
	ver,/dev,200
	ver,/dev,201,col=0
	h = m.h0+(m.hx-200)			; Hue.
	s = m.s0*m.tb(m.sx)<1.			; Sat.
	v = (m.v0+(m.bx-200.)/200.)>0<1		; Bri.
	vm = mean(v)				; Con.
	v = ((v-vm)*m.tb(m.cx) + vm)>0<1
	color_convert, h, s, v, r,g,b, /hsv_rgb
	tvlct,r,g,b
	widget_control, m.top, set_uval=m
	return
 
	end
 
 
;==========================================================
;	xhsbc_event = xhsbc event handler.
;==========================================================
 
	pro xhsbc_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=m
 
	if uval eq 'QUIT' then begin
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'CANCEL' then begin
	  tvlct, m.r0,m.g0,m.b0
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'H' then begin
	  if ev.release eq 1 then begin
	    m.h_mode=0 
	    widget_control, ev.top, set_uval=m
	    return
	  endif
	  if ev.press eq 1 then begin
	    m.h_mode=1 
	    widget_control, ev.top, set_uval=m
	  endif
	  if m.h_mode eq 1 then begin
	    m.hx = ev.x>0<399
	    xhsbc_update, ev.x, m, m.hwin, m.hysz
	    return
	  endif
	endif
 
	if uval eq 'S' then begin
	  if ev.release eq 1 then begin
	    m.s_mode=0 
	    widget_control, ev.top, set_uval=m
	    return
	  endif
	  if ev.press eq 1 then begin
	    m.s_mode=1 
	    widget_control, ev.top, set_uval=m
	  endif
	  if m.s_mode eq 1 then begin
	    m.sx = ev.x>0<399
	    xhsbc_update, ev.x, m, m.swin, m.sysz
	    return
	  endif
	endif
 
	if uval eq 'B' then begin
	  if ev.release eq 1 then begin
	    m.b_mode=0 
	    widget_control, ev.top, set_uval=m
	    return
	  endif
	  if ev.press eq 1 then begin
	    m.b_mode=1 
	    widget_control, ev.top, set_uval=m
	  endif
	  if m.b_mode eq 1 then begin
	    m.bx = ev.x>0<399
	    xhsbc_update, ev.x, m, m.bwin, m.bysz
	    return
	  endif
	endif
 
	if uval eq 'C' then begin
	  if ev.release eq 1 then begin
	    m.c_mode=0 
	    widget_control, ev.top, set_uval=m
	    return
	  endif
	  if ev.press eq 1 then begin
	    m.c_mode=1 
	    widget_control, ev.top, set_uval=m
	  endif
	  if m.c_mode eq 1 then begin
	    m.cx = ev.x>0<399
	    xhsbc_update, ev.x, m, m.cwin, m.cysz
	    return
	  endif
	endif
 
	return
	end
 
;===========================================================
;	xhsbc.pro = Widget based image color adjustment.
;	R. Sterner, 1994 Oct 14.
;===========================================================
 
	pro xhsbc, in, out, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Adjust image hue, saturation, brightness, & contrast. Widget.'
	  print,' xhsbc'
	  print,'   No arguments.  Modifies color table.'
	  return
	endif
 
	;----------  Widget layout  ----------------
	top = widget_base(/column, $
	  title='Adjust overall image Hue, Saturation, Brightness, Contrast')
	b = widget_base(top, /row)		; Avoid wide buttons.
	id = widget_button(b, value='Done', uval='QUIT')
	id = widget_button(b, value='Cancel', uval='CANCEL')
	id = widget_label(b,val='   Drag sliders to adjust image')
	;------  Hue  -------------
	b = widget_base(top,/row)
	id_h = widget_draw(b, xsize=400, ysize=10, retain=2, /button, $
	  /motion, uval='H')
	id = widget_label(b, val='Hue')
	;------  Sat  -------------
	b = widget_base(top,/row)
	id_s = widget_draw(b, xsize=400, ysize=10, retain=2, /button, $
	  /motion, uval='S')
	id = widget_label(b, val='Saturation')
	;------  Bri  -------------
	b = widget_base(top,/row)
	id_b = widget_draw(b, xsize=400, ysize=10, retain=2, /button, $
	  /motion, uval='B')
	id = widget_label(b, val='Brightness')
	;------  Con  -------------
	b = widget_base(top,/row)
	id_c = widget_draw(b, xsize=400, ysize=10, retain=2, /button, $
	  /motion, uval='C')
	id = widget_label(b, val='Contrast')
 
	;------  Realize widget  -------
	widget_control, top, /real
	;------  H  -------
	widget_control, id_h, get_val=hwin
	wset, hwin
	hysz = !d.y_size
	erase
	polyfill, /dev, [0,200,200,0],[0,0,hysz,hysz]
	;------  S  -------
	widget_control, id_s, get_val=swin
	wset, swin
	sysz = !d.y_size
	erase
	polyfill, /dev, [0,200,200,0],[0,0,sysz,sysz]
	;------  B  -------
	widget_control, id_b, get_val=bwin
	wset, bwin
	bysz = !d.y_size
	erase
	polyfill, /dev, [0,200,200,0],[0,0,bysz,bysz]
	;------  C  -------
	widget_control, id_c, get_val=cwin
	wset, cwin
	cysz = !d.y_size
	erase
	polyfill, /dev, [0,200,200,0],[0,0,cysz,cysz]
 
	;-------  Pass needed info  ----------
	tvlct,r0,g0,b0,/get			; Get initial color table.
	color_convert,r0,g0,b0, h0,s0,v0, /rgb_hsv	; Want as HSV.
	h_mode = 0				; Slider bar modes: 0=inactive.
	s_mode = 0
	b_mode = 0
	c_mode = 0
	a1 = makenlog(.2,1,201)		; Generate logarithmic lookup table.
	a2 = makenlog(1,5,200)
	a = [a1,a2(1:*)]
	map = {top:top, r0:r0, g0:g0, b0:b0, h0:h0, s0:s0, v0:v0, tb:a, $
	       id_h:id_h, h_mode:h_mode, hwin:hwin, hysz:hysz, hx:200, $
	       id_s:id_s, s_mode:s_mode, swin:swin, sysz:sysz, sx:200, $
	       id_b:id_b, b_mode:b_mode, bwin:bwin, bysz:bysz, bx:200, $
	       id_c:id_c, c_mode:c_mode, cwin:cwin, cysz:cysz, cx:200}
	widget_control, top, set_uval=map
 
	;--------  Register  ------------------
	xmanager, 'xhsbc', top
 
	return
	end
 
	
