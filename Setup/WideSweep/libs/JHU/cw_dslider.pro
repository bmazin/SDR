;-------------------------------------------------------------
;+
; NAME:
;       CW_DSLIDER
; PURPOSE:
;       Slider using draw widget. Generates drag events.
; CATEGORY:
; CALLING SEQUENCE:
;       id = cw_dslider(parent)
; INPUTS:
;       parent = Widget ID of parent.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         SIZE=sz  Slider size in pixels (def=100).
;         MINIMUM=min Slider min value (def=0).
;         MAXIMUM=max Slider max value (def=100).
;         /HORIZONTAL make a horizontal slider (def).
;         /VERTICAL make a vertical slider.
;         VALUE=val Initial slider value (def=(min+max)/2).
;         UVALUE=uval  Set user value.
;         /FRAME include a frame.
;         COLOR=clr 24-bit color of slider.
; OUTPUTS:
;       id = Widget ID of draw slider.  out
; COMMON BLOCKS:
; NOTES:
;       Note: Can return floating values.  Set MIN, MAX, and VALUE
;         floats.
;         Make sure to use a numeric value for SET_VAL=val in
;         widget_control.  To change the slider color use
;         widget_control, wid, set_val='color=clr'
;         where clr is a 24-bit color value.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 06
;       R. Sterner, 2002 Dec 17 --- Was clobbering window 0.  Fixed.
;       R. Sterner, 2003 Dec 04 --- Added note of returning floating values.
;       R. Sterner, 2006 Oct 23 --- Allowed SET_VAL=val to make color change.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function cw_dslider_get_value, id
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	return, s.v0				; Current value.
 
	end
 
 
;----------------------------------------------------------------------
;	cw_dslider_set_value = set cw_dslider value.
;
;	val must be 'color=xxxx' where xxxx is a 24-bit color.
;----------------------------------------------------------------------
 
	pro cw_dslider_set_value, id, val
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	;-------  Change slider color here  -------
	if isnumber(val) eq 0 then begin
	  clr = getwrd(val,del='=',1) + 0L	; Assume string: color=clr.
	  cw_dslider_make_img, clr,s.phwid,s.wwid,s.px1,s.hvflag, out
	  s.img = out.img
	  s.c_bak = out.c_bak
	  wsave = !d.window			; Save current window.
	  wset, s.win
	  erase, s.c_bak
	  px0 = round((s.v0-s.v1)/s.sc+s.px1)>s.px1<s.px2
	  if s.hvflag eq 0 then begin		; Horizontal.
	    tv,tr=1,s.img,px0-s.phwid,0
	  endif else begin			; Vertical.
	    tv,tr=1,s.img,0,px0-s.phwid
	  endelse
	  wset, wsave				; Restore original window.
	  widget_control,ch_id,set_uval=s	; Save state.
	  return
	endif
 
	;-------  Save state  -------------
	s.v0 = val				; Current value.
	widget_control,ch_id,set_uval=s		; Save state.
 
	if s.win lt 0 then return		; Not yet realized.
 
	;---------  Update slider position  ------------
	wsave = !d.window			; Save current window.
	wset, s.win
	erase, s.c_bak
	px0 = round((s.v0-s.v1)/s.sc+s.px1)>s.px1<s.px2
	if s.hvflag eq 0 then begin	; Horizontal.
	  tv,tr=1,s.img,px0-s.phwid,0
	endif else begin		; Vertical.
	  tv,tr=1,s.img,0,px0-s.phwid
	endelse
	wset, wsave				; Restore original window.
 
	end
 
;----------------------------------------------------------------------
;	cw_dslider_event = Internal event handler.
;----------------------------------------------------------------------
 
	function cw_dslider_event, ev
 
	;-------  Get state structure  ------------
	parent = ev.handler
	ch_id = widget_info(parent,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	if ev.press eq 1 then s.mode=1		; Update drag mode.
	if ev.release eq 1 then s.mode=0
	widget_control,ch_id,set_uval=s		; Save new state.
 
	if s.mode le 0 then return,''		; Ignore all but drag mode.
 
	;------  Get click position in slider  -------
	if s.hvflag eq 0 then px0=ev.x else px0=ev.y
	px0 = px0>s.px1<s.px2
 
	;------  Update marker  ----------------------
	wsave = !d.window			; Save current window.
	wset, s.win				; Set to slider window.
	erase, s.c_bak				; Erase marker.
	if s.hvflag eq 0 then begin		; Horizontal.
	  tv,tr=1,s.img,px0-s.phwid,0
	endif else begin			; Vertical.
	  tv,tr=1,s.img,0,px0-s.phwid
	endelse
	wset, wsave				; Restore original window.
 
	;----  Contruct and return the event for this CW  -----
	val = (px0-s.px1)*s.sc + s.v1		; Slider value.
	s.v0 = val				; Save value.
	widget_control,ch_id,set_uval=s		; Save new state.
	new_ev = {CW_DSLIDER, ID:parent, TOP:ev.top, HANDLER:0L, $
		  VALUE:val}
 
	return, new_ev
 
	end
 
 
;----------------------------------------------------------------------
;	cw_dslider_realize: set up slider when widget realized
;----------------------------------------------------------------------
 
	pro cw_dslider_realize, root
 
	ch_id = widget_info(root,/child)		; Widget ID of child.
	widget_control, ch_id, get_uval=s		; Grab state info.
 
	widget_control, s.id_drw, get_value=win		; Now can get window.
	s.win = win					; Save draw window.
	widget_control, ch_id, set_uval=s
 
	wsave = !d.window			; Save current window.
	wset, s.win
	erase, s.c_bak
	px0 = ((s.v0-s.v1)/s.sc+s.px1)>s.px1<s.px2
	if s.hvflag eq 0 then begin	; Horizontal.
	  tv,tr=1,s.img,px0-s.phwid,0
	endif else begin		; Vertical.
	  tv,tr=1,s.img,0,px0-s.phwid
	endelse
	wset, wsave				; Restore original window.
 
	empty
 
	end
 
;----------------------------------------------------------------------
;	cw_dslider_make_img: Make slider marker image
;----------------------------------------------------------------------
 
	pro cw_dslider_make_img, clr, phwid, wwid, px1, hvflag, out
 
	c_mrk = clr
	c_bak = c_adjhsv(c_mrk,val=.6)	; Darken background.
	c_shd = c_adjhsv(c_mrk,val=.7)	; Marker shadow.
	c_bri = c_adjhsv(c_mrk,val=1.2,sat=.7)	; Marker highlight.
	c_pnt = tarclr(0,0,0)		; Pointer color.
	window,xs=50,ys=50,/pixmap,/free
	erase, c_mrk
	plots,[0,0,2*phwid+1],[0,wwid,wwid],col=c_bri,/dev
	plots,[1,1,2*phwid],[1,wwid-1,wwid-1],col=c_bri,/dev
	plots,[1,2*phwid+1,2*phwid+1],[0,0,wwid-1],col=c_shd,/dev
	plots,[2,2*phwid,2*phwid],[1,1,wwid-2],col=c_shd,/dev
	plots,[px1,px1],[0,wwid],col=c_pnt,/dev
	img = tvrd(tr=1,0,0,2*phwid+1,wwid)
	wdelete
	if hvflag eq 1 then img=transpose(img,[0,2,1])
	out = {img:img, c_bak:c_bak}
 
	end
 
;----------------------------------------------------------------------
;	Main routine
;----------------------------------------------------------------------
 
	function cw_dslider, parent, size=sz, minimum=vmn, maximum=vmx, $
	  horizontal=hor, vertical=ver, value=v0, uvalue=uval, $
	  frame=frame, color=clr, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Slider using draw widget. Generates drag events.'
	  print,' id = cw_dslider(parent)'
	  print,'   parent = Widget ID of parent.   in'
	  print,'   id = Widget ID of draw slider.  out'
	  print,' Keywords:'
 	  print,'   SIZE=sz  Slider size in pixels (def=100).'
	  print,'   MINIMUM=min Slider min value (def=0).'
	  print,'   MAXIMUM=max Slider max value (def=100).'
	  print,'   /HORIZONTAL make a horizontal slider (def).'
	  print,'   /VERTICAL make a vertical slider.'
	  print,'   VALUE=val Initial slider value (def=(min+max)/2).'
	  print,'   UVALUE=uval  Set user value.'
	  print,'   /FRAME include a frame.'
	  print,'   COLOR=clr 24-bit color of slider.'
	  print,' Note: Can return floating values.  Set MIN, MAX, and VALUE'
	  print,'   floats.'
	  print,'   Make sure to use a numeric value for SET_VAL=val in'
	  print,'   widget_control.  To change the slider color use'
	  print,"   widget_control, wid, set_val='color=clr'"
	  print,'   where clr is a 24-bit color value.'
	  return, ''
	endif
 
	on_error, 2
 
	;---------------------------------------------
	;  Set defaults and constants
	;---------------------------------------------
	if n_elements(uval) eq 0 then uval=0	; UVAL.
	if n_elements(sz) eq 0 then sz=100	; Slider size.
	if n_elements(vmn) eq 0 then vmn=0	; Slider min value.
	if n_elements(vmx) eq 0 then vmx=100	; Slider max value.
	if n_elements(v0) eq 0 then v0=float(vmn+vmx)/2. ; Slider current value.
	if n_elements(clr) eq 0 then clr=tarclr(200,200,200) ; Marker color.
	hvflag = -1				; Horizontal or vertical?
	if keyword_set(hor) then hvflag=0
	if keyword_set(ver) then hvflag=1
	hvflag = hvflag>0			; Def = horizontal.
 
	wwid = 15			; Draw widget width (pixels).
	phwid = 8			; Slider pointer half width (pixels).
	wlen = sz			; Draw widget length (pixels).
	wlen0 = wlen + 2*phwid + 1	; Total draw wid length (pixels).
	px1 = phwid			; Position of slider min (pixels).
	px2 = wlen + phwid		; Position of slider max (pixels).
	sc = float(vmx-vmn)/(px2-px1)	; Slider scale.
	mode = -1			; Mode: 1=drag, 0=not, -1=undefined.
	;------  Make marker image  --------
	cw_dslider_make_img, clr, phwid, wwid, px1, hvflag, out
	img = out.img
	c_bak = out.c_bak
 
	;---------------------------------------------
	;  Set up widget
	;	notify_realize needed to get draw
	;	widget window ID after widget realized.
	;---------------------------------------------
	;--------  CW widget root base  ------------------------
	root = widget_base( parent, uvalue=uval,       $
		event_func='cw_dslider_event',         $
		pro_set_value='cw_dslider_set_value',  $
		func_get_value='cw_dslider_get_value', $
		notify_realize='cw_dslider_realize')
 
	;--------  Child base for saving widget state  ----------
	base = widget_base(root,frame=frame)
 
	;--------  Draw widget for slider  -----------------------
	xs = wlen0			; Dimensions for horizontal slider.
	ys = wwid	
	if hvflag eq 1 then swap,xs,ys	; Swap dimensions for vertical.
	id_drw = widget_draw(base, xsize=xs,ysize=ys, /motion,/button_ev)
 
	;--------  Collect state info and save  ------------------
	s = {id_drw:id_drw, win:-1, v1:vmn, v2:vmx, v0:v0, hvflag:hvflag, $
	     px1:px1, px2:px2, phwid:phwid, sc:sc, img:img, c_bak:c_bak, $
	     mode:mode, wwid:wwid}
	widget_control, base, set_uval=s  ; Save widget state in first child.
 
	;--------  See if realized (adding to existing widget)  ------
	if widget_info(root,/real) then cw_dslider_realize, root
 
	;--------  Return Widget ID for this compound widget  ---------
	return, root
 
	end
