;-------------------------------------------------------------
;+
; NAME:
;       COLOR_PICK
; PURPOSE:
;       Color picker widget.
; CATEGORY:
; CALLING SEQUENCE:
;       color_pick, new, old
; INPUTS:
;       old = Original color.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt  Title text.
;         XOFFSET=xoff, YOFFSET=yoff, position.
;         GROUP_LEADER=grp Group leader.
; OUTPUTS:
;       new = New color (-1 for Cancel). out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 13
;       R. Sterner, 2004 Mar 11 --- Dropped /modal on xmanager.  Not yet.
;       R. Sterner, 2005 Mar 30 --- Fixed wheel marker erase problem.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	;-----------------------------------------------------
	;  Update marker to incoming color
	;-----------------------------------------------------
	pro color_pick_update_mark, hue, sat, val, s
 
	wset, s.win_whl				; Set to wheel window.
	!x = s.x_w				; Restore !x, !y.
	!y = s.y_w
	b = 0.05
   	if sat eq 0 then rad=0. else rad=sat*(1.-b)+b
	color_pick_update_wheel, hue, rad, s	; Update wheel.
	wset, s.win_bar
	!x = s.x_b				; Restore !x, !y.
	!y = s.y_b
	color_pick_update_bar, val, s
 
	end
 
	;-----------------------------------------------------
	;  Update bar marker
	;-----------------------------------------------------
	pro color_pick_update_bar, val, s
 
	val = val>0.0<1.0
	device, get_graphics=gmode		; Current graphics mode.
	device, set_graphics=6			; XOR mode.
	if s.xlst_b ne (-999.) then begin
	  plots,s.xlst_b,0.5,psym=4		; Erase last marker.
	  empty
	endif
	plots,val,0.5,psym=4			; Plot new marker.
	empty
	device, set_graphics=gmode		; Restore plot mode.
	;------  Save new values  ---------------
	s.xlst_b = val			; Save position.
	s.val = val
	widget_control,s.top,set_uval=s	; Save new state.
	;------  Update color value listings  ----------
	color_pick_update, s
 
	end
 
 
	;-----------------------------------------------------
	;  Update wheel marker and bar color
	;	hue = angle, rad=actual radius from center.
	;-----------------------------------------------------
	pro color_pick_update_wheel, hue, rad, s
 
	polrec, rad, hue, x, y, /deg		; Keep sat in range.
	x=float(x) & y=float(y)			; RES 2005 Mar 30.
	b = 0.05				; Convert radius to saturation.
	rad2 = rad > b
	sat = (rad2-b)/(1.-b)
	sat = sat<1.				; Keep sat in range.
	device, get_graphics=gmode		; Current graphics mode.
	device, set_graphics=6		; XOR mode.
	if s.xlst_w ne (-999) then begin
	  plots,s.xlst_w,s.ylst_w,psym=4	; Erase last marker.
	  empty
	endif
	plots,x,y,psym=4			; Plot new marker.
	empty
	device, set_graphics=gmode		; Restore plot mode.
	;------  Save new values  ---------------
	s.xlst_w = x				; Save position.
	s.ylst_w = y
	s.hue = hue				; Save color.
	s.sat = sat
	widget_control,s.top,set_uval=s	; Save new state.
	;------  Update brightness bar  ----------
	wset, s.win_bar	; Set to bar window.
	win_redirect
	erase,tarclr(/hsv,0,0,.75)
	bvv = s.bvv		; Only saved brightness.
	bss = bvv*0. + sat	; Set new sat and hue.
	bhh = bvv*0. + hue
	x = s.x		; Saved izoom x and y.
	y = s.y
	pos = s.pos		; Saved izoom position.
        color_convert,bhh,bss,bvv,brr,bgg,bbb,/hsv_rgb
	izoom,x,y,[[[brr]],[[bgg]],[[bbb]]],pos=pos,xstyl=5,ystyl=5,/noerase
	device, get_graphics=gmode		; Current graphics mode.
	device, set_graphics=6		; XOR mode.
	plots,s.xlst_b,0.5,psym=4		; Replot last marker.
	empty
	device, set_graphics=gmode		; Restore plot mode.
	win_copy
	;------  Update color value listings  ----------
	color_pick_update, s
 
	end
 
 
	;-----------------------------------------------------
	;  Update color listing and patch
	;-----------------------------------------------------
	pro color_pick_update, s
 
	;------  Update color value listings  ----------
	color_convert,s.hue,s.sat,s.val,r,g,b,/hsv_rgb
	c24 = tarclr(r+0,g+0,b+0)
	txt = 'RGB: '+string(r+0,form='(I3.3)')+', '+ $
	  string(g+0,form='(I3.3)')+', '+string(b+0,form='(I3.3)')
	widget_control, s.id_rgb, set_val=txt
	txt = 'HSV: '+string(round(s.hue),form='(I3.3)')+', '+$
	  string(s.sat,form='(F4.2)')+', '+string(s.val,form='(F4.2)')
	widget_control, s.id_hsv, set_val=txt
	txt = 'C24: '+string(c24)
	widget_control, s.id_c24, set_val=txt
	;------  Update color patch  -------------------
	wset, s.win_new
	erase, tarclr(r+0,g+0,b+0)
 
	end
 
 
	;-----------------------------------------------------
	;  color_pick_event = event handler.
	;-----------------------------------------------------
	pro color_pick_event, ev
 
	widget_control, ev.id, get_uval=uval
 
	if uval eq 'OK' then begin
	  widget_control, ev.top, get_uval=s
	  widget_control, ev.top, /dest
	  clr = tarclr(/hsv, s.hue, s.sat, s.val)
	  widget_control, s.res, set_uval=clr
	  return
	endif
 
	if uval eq 'CAN' then begin
	  widget_control, ev.top, /dest
	  return
	endif
 
	widget_control, ev.top, get_uval=s
	if ev.press eq 1 then s.mode=1		; Update drag mode.
	if ev.release eq 1 then s.mode=0
	widget_control,ev.top,set_uval=s	; Save new state.
 
	if s.mode le 0 then return		; Ignore all but drag mode.
 
	if uval eq 'WHL' then begin
	  ;------  Update hue/sat marker  ------------
	  wset, s.win_whl			; Set to wheel window.
	  ix = ev.x				; Cursor x,y.
	  iy = ev.y
	  !x = s.x_w				; Restore !x, !y.
	  !y = s.y_w
	  t = convert_coord(ix,iy,/dev,/to_data)  ; Want data coords.
	  x=t(0) & y=t(1)
	  recpol, x, y, rad, hue, /deg		; Convert to sat, hue.
	  rad = rad<1.0				; Keep rad < 1.0
	  color_pick_update_wheel, hue, rad, s
	endif
 
	if uval eq 'BAR' then begin
	  ;------  Update val (brightness) marker  ------------
	  wset, s.win_bar			; Set to bar window.
	  ix = ev.x				; Cursor x,y.
	  iy = ev.y
	  !x = s.x_b				; Restore !x, !y.
	  !y = s.y_b
	  t = convert_coord(ix,iy,/dev,/to_data)  ; Want data coords.
	  val=t(0)
	  color_pick_update_bar, val, s
	endif
 
	end
 
	;-----------------------------------------------------
	;  color_pick.pro = Main color picker routine.
	;
	;  Color wheel uses modified radius to give a finite
	;  white spot.  The transformations between actual
	;  radius (rad) and sat are as follows:
	;    rad ---> sat
	;       rad2 = rad>b
	;       sat = (rad2-b)/(1.-b)
	;    sat ---> rad
	;       if sat eq 0 then rad=0 else
	;       rad = sat*(1.-b)+b
	;-----------------------------------------------------
	pro color_pick, new, old0, xoffset=xoff, yoffset=yoff, $
	  group_leader=group, title=ttl, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Color picker widget.'
	  print,' color_pick, new, old'
	  print,'   new = New color (-1 for Cancel). out'
	  print,'   old = Original color.            in'
	  print,' Keywords:'
	  print,'   TITLE=tt  Title text.'
	  print,'   XOFFSET=xoff, YOFFSET=yoff, position.'
	  print,'   GROUP_LEADER=grp Group leader.'
	  return
	endif
 
	;--------  Defaults  -----------
	siz = 200	; Widget size.
 
	d = 0.8*siz
 
	top = widget_base(/col,xoff=xoff,yoff=yoff,group=group)
	if n_elements(ttl) ne 0 then id=widget_label(top,val=ttl)
 	top2 = widget_base(top,/row)
 
	;------  Left side of widget  -------------
	left = widget_base(top2,/col)
	id_whl = widget_draw(left,xsize=d,ysize=d,/button,/motion,uval='WHL')
	id_bar = widget_draw(left,xsize=d,ysize=d/4,/button,/motion,uval='BAR')
 
	;------  Right side of widget  ------------
	right = widget_base(top2,/col)
 
	id = widget_label(right,val='Click on color')
	id = widget_label(right,val='and brightness')
 
	if n_elements(old0) ne 0 then begin
	  b = widget_base(right,/row)
	  id_old = widget_draw(b,xsize=d/4,ysize=d/4)
	  id = widget_label(b,val='Original',/align_left)
	endif
	b = widget_base(right,/row)
	id_new = widget_draw(b,xsize=d/4,ysize=d/4)
	id = widget_label(b,val='New color',/align_left)
 
	id_rgb = widget_label(right,val='RGB: 000, 000, 000',/dynamic)
	id_hsv = widget_label(right,val='HSV: 000, 0.00, 0.00',/dynamic)
	id_c24 = widget_label(right,val='C24: 0',/dynamic)
 
	b = widget_base(right,/row)
	id = widget_button(b,val='OK',uval='OK')
	id = widget_button(b,val='Cancel',uval='CAN')
 
	;--------  Activate widget  -------------------
	widget_control, top, /real
 
	;--------  Find window indices ---------------
	widget_control, id_whl, get_val=win_whl
	widget_control, id_bar, get_val=win_bar
	if n_elements(old0) ne 0 then begin
	  widget_control, id_old, get_val=win_old
	endif
	widget_control, id_new, get_val=win_new
 
	;-----  Init old color  ---------
	new = 16777215L
	if n_elements(old0) ne 0 then begin
	  old = old0
	  if old lt 0 then old=16777215L	; Allow -1 but fix.
	  wset, win_old
	  erase, old
	  new = old
	endif
 
	;----  Init new color to start at old ----------
	wset, win_new
	erase, new
	c2hsv, new, hue, sat, val	; Initial values.
 
	;-----  Init color wheel  -------
	wset, win_whl
	pos = [.05,.05,.95,.95]
	plot,[-1,1],[-1,1],pos=pos,xstyle=5,ystyle=5,/nodata
	x_w = !x
	y_w = !y
	n = ([!x.window(1)-!x.window(0)]*!d.x_size)(0)
	makenxy, -1., 1., n, -1., 1., n, xx, yy
        recpol,xx,yy,wrr,whh,/deg	; wrr=radius, whh=angle.
	b=0.05		; Compute modified r to get a finite white spot.
	wrr2 = wrr > b	; Any r<b will have 0 sat.
	wss = (wrr2-b)/(1.-b)
        wvv = wss*0+1.
        w = where(wss gt 1)
        wvv(w) = 0.75
        wss(w) = 0.0
        color_convert,whh,wss,wvv,wrr,wgg,wbb,/hsv_rgb
	x = maken(-1,1,n)
	erase,tarclr(/hsv,0,0,.75)
	izoom,x,x,[[[wrr]],[[wgg]],[[wbb]]],pos=pos,xstyl=5,ystyl=5,/noerase
 
	;-----  Init brightness bar  -----------
	wset, win_bar
	pos = [.05,.15,.95,.85]
	plot,[0,1],[0,1],pos=pos,xstyle=5,ystyle=5,/nodata
	nx = ([!x.window(1)-!x.window(0)]*!d.x_size)(0)
	ny = ([!y.window(1)-!y.window(0)]*!d.y_size)(0)
	x = maken(0.,1.,nx)
	y = maken(0.,1.,ny)
	makenxy,0.,1.,nx,0.,1.,ny,bvv,byy
        bhh = 0*bvv + hue
        bss = 0*bvv + sat
	erase,tarclr(/hsv,0,0,.75)
        color_convert,bhh,bss,bvv,brr,bgg,bbb,/hsv_rgb
	izoom,x,y,[[[brr]],[[bgg]],[[bbb]]],pos=pos,xstyl=5,ystyl=5,/noerase
	x_b = !x
	y_b = !y
	device, get_graphics=gmode		; Current graphics mode.
	device, set_graphics=6			; XOR mode.
	plots,1.0,0.5,psym=4		; Replot last marker.
	empty
	device, set_graphics=gmode		; Restore plot mode.
 
	;--------  Return value  ---------------------------------
	res = widget_base()
	widget_control, res, set_uval=-1
 
	;--------  Save state structure  -------------------------
	s = {win_whl:win_whl, win_bar:win_bar, win_new:win_new, $
	  id_rgb:id_rgb, id_hsv:id_hsv, id_c24:id_c24, x_w:x_w, y_w:y_w, $
	  x_b:x_b, y_b:y_b, mode:0, hue:hue, sat:sat, val:val, $
	  xlst_w:-999., ylst_w:-999., xlst_b:-999., $
	  bvv:bvv, x:x, y:y, pos:pos, res:res, top:top }
 
	widget_control, top, set_uval=s
 
	;---------  Set marker to incoming color  ------------
	color_pick_update_mark, hue, sat, val, s
 
	;---------  Manage widget  -----------------
	xmanager, 'color_pick', top, /modal
;	xmanager, 'color_pick', top
 
	widget_control, res, get_uval=new
 
	end
