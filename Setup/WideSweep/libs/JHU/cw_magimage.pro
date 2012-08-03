;-------------------------------------------------------------
;+
; NAME:
;       CW_MAGIMAGE
; PURPOSE:
;       Image with magnified view compound widget.
; CATEGORY:
; CALLING SEQUENCE:
;       id = cw_magimage( parent)
; INPUTS:
;       parent = Widget ID of parent base.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         REDUCTION=fact  Reduction factor for given image.
;           Must indicate how much to reduce displayed images.
;           Start with largest needed value, may be set later.
;         XSIZE=xs  Main image X size (pixels, def=512).
;         YSIZE=xs  Main image Y size (pixels, def=512).
;         DX=dx  Mag window image X size (pixels, def=300).
;         DY=dy  Mag window image Y size (pixels, def=180).
;         UVALUE=uval User value (def=none).
;         /FRAME frame around widget (def=one).
;         TITLE=ttl Image title (def=none).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Certain values may be changed using widget_control:
;         New image: widget_control, id, set_val=img
;         New title: widget_control, id, set_val='title=new title'
;         New reduction: widget_control, id, set_val='red=1'
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 11
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro cw_magimage_update, s
 
	;---------  Resize image for display  ------------
	sz=size(s.img) & nx=sz(1) & ny=sz(2)	; Image size.
	img2 = rebin(s.img,nx/s.red,ny/s.red)	; Reduce full image.
	;---------  Update displayed image  ------------
	wset, s.win1		; Set to main image window.
	tv, img2		; Display main image (after reduction).
	if s.mode eq 0 then return
	;---------  Mag area in displayed image  -------
	dx = s.dx/s.mag
	dy = s.dy/s.mag
	wset, s.win1
	ix1 = s.x-dx/2	; Area LL point in main image.
	iy1 = s.y-dy/2
	ix2 = ix1+dx	; Area UR point in main image.
	iy2 = iy1+dy
	plots,[ix1,ix2,ix2,ix1,ix1],[iy1,iy1,iy2,iy2,iy1],/dev
	;---------  Update mag window  -----------------
	x = s.x*s.red		; Center of area to magnify
	y = s.y*s.red		;   in full size image.
	dx2 = s.red*s.dx/s.mag	; Size of mag area in full image.
	dy2 = s.red*s.dy/s.mag
	ix1 = x-dx2/2		; Starting point in full image.
	iy1 = y-dy2/2
	sub = tvrd2(image=s.img, ix1, iy1, dx2, dy2)	; Grab sub image.
	sub2 = congrid(sub, s.dx, s.dy)	; Magnified area.
	wset, s.win2
	tv, sub2
	empty
 
	end
 
 
;----------------------------------------------------------------------
;	cw_magimage_get_value = get cw_magimage value.
;----------------------------------------------------------------------
 
	function cw_magimage_get_value, id
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	return, s.img				; Current value.
 
	end
 
 
;----------------------------------------------------------------------
;	cw_magimage_set_value = set cw_magimage value.
;----------------------------------------------------------------------
 
	pro cw_magimage_set_value, id, img
 
	;-------  Get state structure  ------------
	ch_id = widget_info(long(id),/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	;-------  Check for command  ------------
	if datatype(img) eq 'STR' then begin
	  cmd = strmid(strupcase(getwrd(img,del='=')),0,2)
	  val = getwrd('',1)
	  case cmd of
'RE':	    begin
	      print,' Setting reduction factor to '+val
	      s.red = val+0
	    end
'TI':	    begin
	      print,' Setting title to '+val
	      if s.id_title gt 0 then widget_control,s.id_title,set_value=val
	    end
else:	    begin
	      print,' Ignoring unknown command: '+img
	    end
	  endcase
	  widget_control,ch_id,set_uval=s		; Save state.
	  return
	endif else begin
	  ;-------  Save new values  ----------------
	  a = s.img
	  a(0,0) = img
	  s.img = a
;	  s.img(0,0) = img				; Save new full image.
	  widget_control,ch_id,set_uval=s		; Save state.
	endelse
 
	;---------  Update display  ------------------
	cw_magimage_update, s
 
	end
 
;----------------------------------------------------------------------
;	cw_magimage_event = Internal event handler.
;----------------------------------------------------------------------
 
	function cw_magimage_event, ev
 
	;-------  Get state structure  ------------
	parent = ev.handler
	ch_id = widget_info(parent,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	widget_control, ev.id,get_uval=uval	; Get event name.
 
	;-------  Display full image  --------------------
	if uval eq 'FULL' then begin
	  img_disp, s.img
	  return, ''
	endif
 
	;-------  Clicked in main image window  ----------
	if uval eq 'MAIN' then begin
	  if ev.press eq 1 then s.drag=1
	  if ev.release eq 1 then s.drag=0
	  if (ev.press eq 0) and (s.drag eq 0) then begin
	    widget_control,ch_id,set_uval=s	; Save state.
	    return,''
	  endif
	  s.x = ev.x				; Save position.
	  s.y = ev.y
	  s.mode = 1				; Display mag area.
	  widget_control,ch_id,set_uval=s	; Save state.
	  cw_magimage_update, s			; Update display.
	  return, ''
	endif
 
	;-------  Clicked in mag window  ---------------
	if uval eq 'SUB' then begin
	  if ev.press eq 0 then return,''	; Ignore release.
	  s.mode = 0				; Don't display mag area.
	  widget_control,ch_id,set_uval=s	; Save state.
	  cw_magimage_update, s			; Update display.
	  return, ''
	endif
 
	;-------  Assume clicked on mag factor  ----------
	if ev.select eq 0 then return, ''
	s.mag = getwrd(uval,1,del='=')
	widget_control,ch_id,set_uval=s	; Save state.
	cw_magimage_update, s			; Update display.
	return, ''
 
	end
 
 
;----------------------------------------------------------------------
;	cw_magimage_realize: set up magimage when widget realized
;----------------------------------------------------------------------
 
	pro cw_magimage_realize, root
 
	wsave = !d.window			; Save current window.
	ch_id = widget_info(root,/child)	; Widget ID of child.
	widget_control, ch_id, get_uval=s	; Grab state info.
 
	;-----  Main plot window  --------------
	widget_control, s.id_d1, get_value=win	; Now can get window.
	s.win1 = win				; Save draw window.
 
	;-----  Mag window  --------------------
	widget_control,s.id_d2,get_value=win	; Now can get window.
	s.win2 = win				; Save draw window.
	
	widget_control, ch_id, set_uval=s	; Save updated widget state.
 
	wset, wsave				; Restore original window.
 
	end
 
;----------------------------------------------------------------------
;	Main routine
;----------------------------------------------------------------------
 
	function cw_magimage, parent, xsize=xsize, ysize=ysize, $
	  dx=dx, dy=dy, reduction=red, uvalue=uval, help=hlp, $
	  frame=frame, title=title
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Image with magnified view compound widget.'
	  print,' id = cw_magimage( parent)'
	  print,'   parent = Widget ID of parent base.   in'
	  print,' Keywords:'
	  print,'   REDUCTION=fact  Reduction factor for given image.'
	  print,'     Must indicate how much to reduce displayed images.'
	  print,'     Start with largest needed value, may be set later.'
	  print,'   XSIZE=xs  Main image X size (pixels, def=512).'
	  print,'   YSIZE=xs  Main image Y size (pixels, def=512).'
	  print,'   DX=dx  Mag window image X size (pixels, def=300).'
	  print,'   DY=dy  Mag window image Y size (pixels, def=180).'
	  print,'   UVALUE=uval User value (def=none).'
	  print,'   /FRAME frame around widget (def=one).'
	  print,"   TITLE=ttl Image title (def=none)."
	  print,' Note: Certain values may be changed using widget_control:'
	  print,'   New image: widget_control, id, set_val=img'
	  print,"   New title: widget_control, id, set_val='title=new title'"
	  print,"   New reduction: widget_control, id, set_val='red=1'"
	  return,''
	endif
 
	on_error, 2
 
	;---------------------------------------------
	;  Set defaults and constants
	;---------------------------------------------
	if n_elements(red) eq 0 then begin
	  print,' Error in cw_magimage: must give reduction factor.'
	  print,' Aborting.'
	  stop
	endif
	if n_elements(title) eq 0 then title='' 	; Title.
	if n_elements(xsize) eq 0 then xsize=512	; Main X size.
	if n_elements(ysize) eq 0 then ysize=512	; Main Y size.
	if n_elements(dx) eq 0 then dx=300		; Mag X size.
	if n_elements(dy) eq 0 then dy=180		; Mag Y size.
	if n_elements(uval) eq 0 then uval=''		; UVAL.
 
	;---------------------------------------------
	;  Set up widget
	;	notify_realize needed to get draw
	;	widget window ID after widget realized.
	;---------------------------------------------
	;--------  CW widget root base  ------------------------
	root = widget_base( parent, uvalue=uval,frame=frame, $
		event_func='cw_magimage_event',         $
		pro_set_value='cw_magimage_set_value',  $
		func_get_value='cw_magimage_get_value', $
		notify_realize='cw_magimage_realize')
 
	;--------  Child base for saving widget state  ----------
	base = widget_base(root,/col,space=0)
 
	;--------  Main image window  ------------------------
	id_title = -1
	if title ne '' then id_title = widget_label(base,val=title)
	id_d1 = widget_draw(base,xsize=xsize,ysize=ysize, $
	  /button_events,uval='MAIN',/motion,/frame)
	img = bytarr(xsize*red,ysize*red)
 
	;--------  Controls and Mag image window  -------------------------
	b = widget_base(base,/row)
	;--------  Left side  -----------
	bb = widget_base(b,/col)
	id =widget_label(bb,val='Click above for new area')
	bbb = widget_base(bb,/exclusive,/row)
	id = widget_button(bbb,val='2',uval='mag=2')
	widget_control, id, /set_button
	id = widget_button(bbb,val='4',uval='mag=4')
	id = widget_button(bbb,val='8',uval='mag=8')
	id = widget_button(bbb,val='16',uval='mag=16')
	bbb = widget_base(bb,/row)
	id = widget_button(bbb,val='Full image',uval='FULL')
	;--------  Right side = mag window  ---------
	id_d2 = widget_draw(b,xsize=dx,ysize=dy,/button_events,$
	  uval='SUB',/frame)
 
	;--------  Collect state info and save  ------------------
	;  root=CW base, win1, win2=main and sub window indices,
	;  red=reduction factor, dx,dy=mag area size, mag=mag factor,
	;  img=full image, mode:1=display mag,0=don't, drag:1=dragging,
	;  x,y=center of mag area in main window.
	;----------------------------------------------------------
	s = {root:root, id_d1:id_d1, id_d2:id_d2, red:red, $
		win1:-1, win2:-1, dx:dx, dy:dy, mag:2, img:img, $
		mode:1, drag:0, x:dx/2, y:dy/2, id_title:id_title }
	 
	widget_control, base, set_uval=s  ; Save widget state in first child.
 
	;--------  See if realized (adding to existing widget)  ------
	if widget_info(root,/real) then cw_magimage_realize, root
 
	;--------  Return Widget ID for this compound widget  ---------
	return, root
 
	end
