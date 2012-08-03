;-------------------------------------------------------------
;+
; NAME:
;       CTOOL
; PURPOSE:
;       Modify a color table using widgets.
; CATEGORY:
; CALLING SEQUENCE:
;       ctool
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 13 Oct, 1993
;       R. Sterner, 1998 Jan 15 --- Dropped the use of !d.n_colors.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro set_vlt, wids, rgb=rgb, hsv=hsv
 
	;--------  Get color table index  ---------
	widget_control, wids.index, get_val=index
	index = index(0) + 0
 
	;--------  Get corresponding color table value  ------
	tvlct, r, g, b, /get
	rr = r(index)		; These will only be used if no
	gg = g(index)		; keyword (/rgb or /hsv) is given.
	bb = b(index)
	rgb_to_hsv, rr, gg, bb, hh, ss, vv
	ss = fix(ss*100.+.5)
	vv = fix(vv*100.+.5)
 
	;---------  Working in RGB  -----------
	if keyword_set(rgb) then begin
	  widget_control, wids.red, get_val=rr
	  widget_control, wids.green, get_val=gg
	  widget_control, wids.blue, get_val=bb
	  rgb_to_hsv, rr, gg, bb, hh, ss, vv
	  ss = fix(ss*100.+.5)
	  vv = fix(vv*100.+.5)
	endif
 
	;---------  Working in HSV  -----------
	if keyword_set(hsv) then begin
	  widget_control, wids.hue, get_val=hh
	  widget_control, wids.sat, get_val=ss
	  widget_control, wids.val, get_val=vv
	  hsv_to_rgb, hh, ss/100., vv/100., rr, gg, bb
	endif
 
	;---------  Given r, g, b, values  -------
	if n_params(0) ge 2 then begin
	  rgb_to_hsv, rr, gg, bb, hh, ss, vv
	  ss = fix(ss*100.+.5)
	  vv = fix(vv*100.+.5)
	endif
 
	;--------  Update color table  ----------
	r(index) = rr
	g(index) = gg
	b(index) = bb
	tvlct, r, g, b
	wset, wids.draw
	tv, bytarr(!d.x_size, !d.y_size)+index
 
	;-------  Update sliders  ------------
	widget_control, wids.red,   set_val=rr(0)
	widget_control, wids.green, set_val=gg(0)
	widget_control, wids.blue,  set_val=bb(0)
	widget_control, wids.hue,   set_val=hh
	widget_control, wids.sat,   set_val=ss
	widget_control, wids.val,   set_val=vv
 
	return
	end
 
;==================================================
;	set_index.pro = Set color table index and draw
;	R. Sterner, 13 Oct, 1993
;==================================================
 
	pro set_index, dat, val
 
	val = val(0)>0<(!d.table_size-1)
	widget_control, dat.index, set_val=strtrim(val,2)
	widget_control, dat.slider, set_val=val
	if dat.status eq 1 then begin
	  wset, dat.draw
	  tv, bytarr(!d.x_size, !d.y_size)+val
	  set_vlt, dat
	endif
	wset, dat.bar
	tvlct,r,g,b,/get
	c = fix(r)+g+b
	imx = (where(c eq max(c)))(0)
	imn = (where(c eq min(c)))(0)
	tv, dat.barimg
	plots, /dev, val, [0,4], color=imx(0)		   ; Current index.
	plots, /dev, val, !d.y_size-1-[0,4], color=imn(0)
	plots, /dev, dat.markval, [0,4], color=imx(0)	   ; Marked index.
	plots, /dev, dat.markval, !d.y_size-1-[0,4], color=imn(0)
 
	dat.rs = r
	dat.gs = g
	dat.bs = b
	widget_control, dat.base, set_uval=dat
	return
	end
 
;==================================================
;	ctool_event.pro = event handler
;	R. Sterner, 13 Oct, 1993
;==================================================
 
	pro ctool_event, ev
 
        widget_control, ev.id, get_uval=name
        widget_control, ev.top, get_uval=uval
 
	;----------  Quit  ----------------
	if name eq 'QUIT' then begin
	  widget_control, /dest, ev.top
	  return
	endif
 
	;----------  Cancel  ----------------
	if name eq 'CANCEL' then begin
	  tvlct, uval.r, uval.g, uval.b
	  widget_control, /dest, ev.top
	  return
	endif
 
	;-----------  Help  --------------
	if name eq 'HELP' then begin
	  txt = ['Color Table Tool',$
		' ',$
		'May modify or build a color table.  The controls are',$
		'grouped into 4 main groups.  Each group is described',$
		'in more detail below.  The groups are:',$
		' ',$
		'1. Color Systems: two subpanels, RGB and HSV.',$
		'2. Exit and Help buttons.',$
		'3. Color table index selection panel.',$
		'4. Color table interpolation panel.',$
		' ',$
		'Overview',$
		'--------',$
		' There are a number of color systems in common use.  Colors',$
		' are typically described by a point in a 3-d coordinate',$
		' system.  Two such coordinate systems are provided here and',$
		' they may be used together.  They will be described below.',$
		' The left side of this widget delas with selecting a color.',$
		' ',$
		' The buttons at the right side top are used to exit this',$
		' tool or obtain this help message.',$
		' The DONE button exits with all changes kept.',$
		' The CANCEL button restores the entry color table.',$
		' ',$
		' Below these buttons are displayed the current color bar and',$
		' a color patch corresponding to the color for the currently',$
		' selected color table index.  The color bar also shows two',$
		' pointers, one for the current index, and one for an index',$
		' marked using the Set Start button in the interpolation',$
		' panel.',$
		' ',$
		' The next panel gives a number of options for selecting the',$
		' color table index.  These options will be described below.',$
		' ',$
		' The final panel is for interpolation between the current',$
		' color table index and one marked previously using the Set',$
		' Start button.  One of a number of interpolation modes may',$
		' selected using the Set Mode pull down menu.  These are',$
		' described below.',$
		' ',$
		'1. Color Systems',$
		'----------------',$
		' The color corresponding to the currently selected color',$
		' table index is always the color being modified.  It is',$
		' displayed in the color patch just to the right of the',$
		' color bar.',$
		' RGB: A color can be considered to be composed of various',$
		' amounts of the primary colors Red, Green, and Blue.  These',$
		' amounts are controlled by the three sliders which range',$
		' from 0 to 255.  The resulting combination is displayed',$
		' in the color patch.',$
		' HSV: An alternate way to consider a color is as a hue with',$
		' a specified saturation (color intensity) and value',$
		' (brightness).  Hue is considered an angle in degrees and',$
		' ranges from 0 for red, through 120 for green, through', $
		' 240 for blue, with the other colors falling between.',$
		' Hue, Saturation, and Value are controlled by three sliders',$
		' With the Hue slider ranges from 0 to 360 degrees, and the',$
		' Saturation and Value sliders ranging from 0 to 100%.',$
		' ',$
		' ',$
		'2. Exit and Help buttons',$
		'------------------------',$
		' DONE means exit keeping all changes.',$
		' CANCEL means undo all changes before exiting.',$
		' HELP gives this help text.',$
		' ',$
		' ',$
		'3. Color table index selection panel',$
		'------------------------------------',$
		' IDL will use up to 256 colors to display an image.  Often',$
		' the windowing system will use a number of these, leaving',$
		' fewer for IDL.  The color bar allows for up to 256 colors',$
		' but will usually not be full for this reason.  A color',$
		' table index is the number of one of the displayed colors.',$
		' This tool gives 4 different ways to select this index.',$
		' 1. An Index selector slider bar may be used to quickly',$
		'    scan through the colors.',$
		' 2. The color index may be typed from the keyboard into the',$
		'    Color index field.',$
		' 3. The current index may be stepped up or down one step at',$
		'    a time with the Index Down and Index Up buttons.',$
		' 4. The Pan button may be used to zoom up a small region of',$
		'    a displayed image and selected a desired pixel.  The',$
		'    index is set to the color value of this pixel.  The',$
		'    number on the Pan button is the IDL window number that',$
		'    will be zoomed.  Any available window may be selected',$
		'    from the Pan Window pull down menu.']
	  txt = [txt,$
		' Normally, changing the index will update the color',$
		' displayed in the color patch.  To move a color from one',$
		' location in the table to another this update feature',$
		' may be turned off by clicking on the No button in this',$
		' panel.  The update is turned back on by the Yes button.',$
		' If update is turned off,  the color may be inserted at',$
		' the new index using the Insert Color button.  Any',$
		' changes made since the index was last moved may may be',$
		' undone by the Undo button.',$
		' ',$
		' ',$
		'4. Color table interpolation panel',$
		'----------------------------------',$
		' The options in this panel make it easy to modify a range',$
		' of colors.  The range is always from the current color',$
		' index to the start index.  The start index is 0 at first',$
		' but may be set to the current index using the Set Start',$
		' button.  A useful technique is to use Set Start to set the',$
		' index of an inserted color and then move the index to',$
		' interpolate outward to blend it into the nearby colors.',$  
		' ',$
		' There are a number of interpolation modes provided.  A',$
		' mode is selected using the pull down menu button Set Mode.',$
		' The modes are:',$
		' ',$
		' Copy:  Not really an interpolation.  This mode just copies',$
		'   the current index color to the entire range.',$
		' RGB:  Linearly interpolates between the RGB values at the',$
		'   range endpoints to find the colors in the range.',$
		' HSV straight:  The HSV coordinate system may be considered',$
		'   to be a cylinder with Value (brightness) along its axis,',$
		'   0% at the bottom and 100% at the top.  A cross-section',$
		'   at the top of the cylinder shows bright colors around',$
		'   the outer edge and blending to white at the center where',$
		'   the Saturation is 0%.  Lower cross-sections are similar',$
		'   but darker the closer they are to the bottom.  This mode',$
		'   of interpolation will the colors on the line between the',$
		'   HSV values at the range endpoints.  If these endpoints',$
		'   are near opposite sides of the cylinder then the line',$
		'   between them will pass near the axis which is white or',$
		'   a shade of gray.',$
		' HSV curved:  This mode is similar to the one above except',$
		'   that the interpolation is done in polar coordinates,',$
		'   that is, the radius various linearly between the end-',$
		'   points.  This will typically give more saturated colors',$
		'   between the endpoints, especially if the endpoints are',$
		'   more saturated themselves.',$
		' Reversed:  Not really an interpolation.  This mode just',$
		'   reverses the colors in the range.',$
		' Ramp:  Not really an interpolation.  This mode just ramps',$
		'   the value from 1 at the current index to 0 at the start.', $
		'   Use Copy before Ramp to ramp a single color.',$
		' ',$
		' The Interpolate button actually does the interpolation.',$
		' ',$
		' The Undo button will undo the interpolation as long as the',$
		'   color index has not been change since.']
	  xhelp, txt, lines=20
	  return
	endif
 
	;-----------  Yes  ----------------
	if name eq 'YES' then begin
	  uval.status = 1
	  widget_control, ev.top, set_uval=uval
	  return
	endif
 
	;-----------  No  ----------------
	if name eq 'NO' then begin
	  uval.status = 0
	  widget_control, ev.top, set_uval=uval
	  return
	endif
 
	;----------  Insert  --------------
	if name eq 'INSERT' then begin
	  set_vlt, uval, /rgb
	  return
	endif
 
	;-----------  Mark  ---------------
	if name eq 'MARK' then begin
	  widget_control, uval.index, get_val=index
	  index = index(0)
	  widget_control, uval.marklab, set_val='Marked index is now '+index
	  uval.markval = index+0
	  widget_control, ev.top, set_uval=uval
	  set_index, uval, index+0
	  return
	endif
 
	;-----------  Mode  ---------------
	if name eq 'MODE' then begin
	  widget_control, ev.id, get_val=modeval
	  uval.modeval = modeval
	  widget_control, ev.top, set_uval=uval
	  widget_control, uval.modelab, set_val='Mode is now '+modeval
	  return
	endif
 
	;-----------  Interp  ---------------
	if name eq 'INTERP' then begin
	  tvlct, r, g, b, /get				; Get current ct.
          widget_control, uval.index, get_val=index	; Get current index.
          i1 = index(0)+0
	  i2 = uval.markval				; Get marked index.
	  modeval = uval.modeval			; Get interp mode.
	  case modeval of				; Convert to a number.
'Copy':		mode = 0
'RGB':		mode = 1
'HSV straight':	mode = 2
'HSV curved':	mode = 3
'Reverse':	mode = 4
'Ramp':		mode = 5
else:	  begin
	    print,' Unkown interpolation mode: ',modeval
	    bell
	  end
	  endcase
	  ctint, r, g, b, i1, i2, mode
	  return
	endif
 
	;-----------  RGB  ----------------
	if name eq 'RGB' then begin
	  set_vlt, uval, /rgb
	  return
	endif
 
	;-----------  HSV  ----------------
	if name eq 'HSV' then begin
	  set_vlt, uval, /hsv
	  return
	endif
 
	;------  Color Table Index  -------
	;----------  Index  ---------------
	if name eq 'INDEX' then begin
	  widget_control, ev.id, get_val=val
	  val = val(0)
	  if isnumber(val) ne 1 then begin
	    bell
	    set_index, uval, !d.table_size-1
	    return
	  endif
	  set_index, uval, val+0
	  return
	endif
 
	;----------  Undo  ---------------
	if name eq 'UNDO' then begin
	  tvlct, uval.rs, uval.gs, uval.bs
	  set_vlt, uval
	  return
	endif
 
	;----------  Pan  ----------------
	if name eq 'PAN' then begin
	  pan, val, inwin=uval.panwin, outwin=uval.outwin
	  wdelete, uval.outwin		; Remove zoom window.
	  set_index, uval, val
	  return
	endif
 
	;----------  Win  ----------------
	if name eq 'WIN' then begin
	  widget_control, ev.id, get_val=panwin		; Get selected pan win.
	  widget_control,uval.pan,set_val='Pan '+panwin	; Update pan label.
	  uval.panwin = panwin + 0			; Convert to number.
	  widget_control, ev.top, set_uval=uval		; Store in top uval.
	  return
	endif
 
	;----------  Step Up  ------------
	if name eq 'UP' then begin
	  widget_control, uval.index, get_val=val
	  set_index, uval, val+1
	  return
	endif
 
	;----------  Step Down  --------
	if name eq 'DN' then begin
	  widget_control, uval.index, get_val=val
	  set_index, uval, val-1
	  return
	endif
 
	;----------  Slider  ------------
	if name eq 'SLIDER' then begin
	  widget_control, ev.id, get_val=val
	  set_index, uval, val
	  return
	endif
 
	end
 
 
;==================================================
;	ctool.pro = Tune a color table entry
;	R. Sterner, 13 Oct, 1993
;==================================================
 
	pro ctool, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Modify a color table using widgets.'
	  print,' ctool'
	  print,'   No args.  Uses widgets.'
	  return
	endif
 
	;--------  Find available windows  ---------
	device, window=win		; Status of all windows.
	w1 = where(win eq 1, cnt1)	; Available windows are 1.
	if cnt1 eq 0 then begin		; No windows.
	  panwin = 0			; Pan on 0.
	  outwin = 1			; Zoom into 1.
	  win = [0]			; List of available windows.
	endif else begin
	  panwin = w1(0)		; Pan on first.
	  w0 = where(win eq 0, cnt0)	; Find unused windows.
	  outwin = w0(0)		; Zoom into first.
	  win = w1			; List of available windows.
	endelse
 
	;--------  Layout widget  ----------
	base = widget_base(title='Color Tool',/row)
	  ;--------  Left side  -------------
	  bleft = widget_base(base, /column)
	  id = widget_label(bleft, value='Color Systems')
	  b1 = widget_base(bleft, /column)
	    ;--------   R,G,B  ----------------
	    b11 = widget_base(b1, /column, frame=1)
	    id = widget_label(b11,value='Red, Green, Blue')
	    id_r = widget_slider(b11,max=255,xsize=255, /drag,uval='RGB')
	    id = widget_label(b11,value='Red  (0 to 255)')
	    id_g = widget_slider(b11,max=255,xsize=255, /drag,uval='RGB')
	    id = widget_label(b11,value='Green  (0 to 255)')
	    id_b = widget_slider(b11,max=255,xsize=255, /drag,uval='RGB')
	    id = widget_label(b11,value='Blue  (0 to 255)')
	    ;--------   H,S,V  ----------------
	    id = widget_label(b1,val=' ')
	    b12 = widget_base(b1, /column, frame=1)
	    id = widget_label(b12,value='Hue, Saturation, Value')
	    id_h = widget_slider(b12,max=360,xsize=255, /drag,uval='HSV')
	    id = widget_label(b12,value='Hue  (0 to 360)')
	    id_s = widget_slider(b12,max=100,xsize=255, /drag,uval='HSV')
	    id = widget_label(b12,value='Saturation  (0 to 100%)')
	    id_v = widget_slider(b12,max=100,xsize=255, /drag,uval='HSV')
	    id = widget_label(b12,value='Value  (0 to 100%)')
	  ;--------  Right side  ------------
	  b2 = widget_base(base, /column)
	    bq = widget_base(b2, /row)
	    idq = widget_button(bq,value='DONE', uval='QUIT')
	    idc = widget_button(bq,value='CANCEL', uval='CANCEL')
	    id = widget_button(bq,val='HELP',uval='HELP')
	    b20 = widget_base(b2,/row)
	      id_bar = widget_draw(b20,retain=2,xsize=256,ysize=44,/frame)
	      id_draw = widget_draw(b20, retain=2,xsize=40, ysize=40, /frame)
	    bind = widget_base(b2, /column, frame=1)
	    id = widget_label(bind,val='Index control panel')
	    cmax = !d.table_size-1
	    id_slider = widget_slider(bind, max=cmax, xsize=cmax+1,/drag, $
	      uval='SLIDER')
	    id = widget_label(bind,value='Index selector')
	    b22 = widget_base(bind, /row)
	      b221 = widget_label(b22, value='Color Index')
	      id_index = widget_text(b22,/edit, xsize=5,uval='INDEX')
	      id_pan=widget_button(b22,val='Pan '+strtrim(panwin,2),uval='PAN')
	      pdw = widget_button(b22,val='Pan Window', menu=2)
	      for i = 0, n_elements(win)-1 do begin
		id = widget_button(pdw, val=strtrim(win(i),2), uval='WIN')
	      endfor
	    b21 = widget_base(bind, /row)
	      iddn = widget_button(b21,value='Index Down', $
		uval='DN')
	      idup = widget_button(b21,value='Index Up', $
		uval='UP')
	      id = widget_button(b21,value='Insert Color',uval='INSERT')
	      id = widget_button(b21,val='Undo',uval='UNDO')
	    b23 = widget_base(bind,/row)
	      b231 = widget_base(b23,/column)
	        id = widget_label(b231,val='Update color when index changes?')
	        b2311 = widget_base(b231,/row,/exclus)
	          id = widget_button(b2311, value='Yes', uval='YES')
		  widget_control, id, /set_button
	          id = widget_button(b2311, value='No', uval='NO')
	    bint = widget_base(b2, /column, frame=1)
	      id = widget_label(bint,value='Interpolation panel')
	      bintm = widget_base(bint, /row)
		id = widget_button(bintm, value='Set Start',uval='MARK')
		marklab = widget_label(bintm, value='Start index is now 0',$
			/dynamic)
		markval = 0
	      bints = widget_base(bint, /row)
		idpd = widget_button(bints, value='Set Mode   ', menu=2)
		id = widget_button(idpd, value='Copy', uval='MODE')
		id = widget_button(idpd, value='RGB', uval='MODE')
		id = widget_button(idpd, value='HSV straight', uval='MODE')
		id = widget_button(idpd, value='HSV curved', uval='MODE')
		id = widget_button(idpd, value='Reverse', uval='MODE')
		id = widget_button(idpd, value='Ramp', uval='MODE')
		modelab = widget_label(bints, value='Mode is now RGB',/dynamic)
		modeval = 'RGB'
	      bintd = widget_base(bint, /row)
		id = widget_button(bintd, value='Interpolate',uval='INTERP')
 
	;----------  Create widget  -------------
	widget_control, base, /real
 
	;----------  Draw widget index  ----------------
	widget_control, id_draw, get_val=draw_win
 
	;----------  Make color bar  -------
	widget_control, id_bar, get_val=bar_win
	wset, bar_win
	nc = !d.table_size
	barimg = rebin(reform(maken(0,nc-1,nc),nc,1),nc,!d.y_size)
	tv,barimg
 
	;------- Get entry color table  ----------
	tvlct, rr0, gg0, bb0, /get
 
	;---------  Pack all needed data into a structure  -----------
	dat = {dat, base:base, red:id_r, green:id_g, blue:id_b, $
		hue:id_h, sat:id_s, val:id_v, $
		index:id_index, slider:id_slider, draw:draw_win, $
	  	bar:bar_win, barimg:barimg, r:rr0, g:gg0, b:bb0, $
		rs:rr0, gs:gg0, bs:bb0, status:1, panwin:panwin, $
		outwin:outwin, marklab:marklab, markval:markval, $
		modelab:modelab, modeval:modeval, pan:id_pan}
 
	;---------  Initialize draw widget  ----------
	set_index, dat, !d.table_size-1
 
	;---------  Save widget IDs in base uval  ----------
	widget_control, base, set_uval=dat
 
	xmanager, 'ctool', base
 
	return
	end
