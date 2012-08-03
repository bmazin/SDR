;-------------------------------------------------------------
;+
; NAME:
;       CW_STRIPCHART
; PURPOSE:
;       Strip chart compound widget.
; CATEGORY:
; CALLING SEQUENCE:
;       id = cw_stripchart( parent, nx, ny)
; INPUTS:
;       parent = Widget ID of parent base.   in
;       nx = Max number of samples to be plotted.
;       ny = Number of channels.
; KEYWORD PARAMETERS:
;       Keywords:
;         X_SCROLL=x_sc Size in X on screen (pixels, def=100).
;         XWIDTH=xwid  Width in x units of visible section (def=10).
;           This is not exact, usually more is covered.
;         XRANGE=xran  Total range in X (def=[0,100]).
;         /NO25 means do not use multiples of 2.5 for axis ticks.
;         KEY=key  Optional 24-bit image to display as a legend.
;           May later set a new key by sending the image as a new
;           value using widget_control,id,set_val=key.
;         YSIZE=ys  Size in Y (pixels, def=100).
;         YRANGE=yran  Range in Y (def=[0,1]).
;         YTITLE=yttl Y axis title (def=none).
;         /YFIXED include a fixed Y axis.
;         /NOMINOR suppress y axis minor ticks.
;         UVALUE=uval User value (def=none).
;         /FRAME frame around widget (def=one).
;         TITLE=ttl Main title (def='Strip Chart').
;         RPOS=[x1,y1,x2,y2]  Offset from window sides:
;           [left,bottom,right,top].  Def=[30,30,-10,-10].
;         CHARSIZE=csz  Character size (def=1).
;         C_BACK=c_bak Background color (def=white).
;         C_AXES=c_ax axes color (def=black).
;         C_PLOT=c_plt Plot color(s) (def=red, green, blue).
;           May give an array of plot colors, one ofr each channel.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note:  May have multiple plot channels. May specify colors
;         for each, default are set up if none given.  Use
;         widget_control, wid, set_val=val to plot new data points,
;         val is [x, val1, val2, ..., valn] where x is
;         the x value, val1, ... are the plot values.
;         May plot less than # channels set, but not more.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 01
;       R. Sterner, 2003 Mar 05 --- Minor help text change.
;       R. Sterner, 2003 Mar 14 --- Major upgrades, zoom, ...
;       R. Sterner, 2003 Mar 17 --- Fixed scaling bug.
;       R. Sterner, 2003 Mar 24 --- Allowed key to be set at a later time.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;----------------------------------------------------------------------
;	cw_stripchart_replot = Replot data (after a rescale)
;----------------------------------------------------------------------
 
	pro cw_stripchart_replot, s
 
	for i=0,s.ny-1 do begin		; Loop through channels.
	  x = s.xval(0:s.inx)		; Data x values.
	  y = s.data(0:s.inx,i)		; Data y values.
	  p = s.pcode(0:s.inx,i)	; Pen codes (1=down,0=up).
	  c = s.c_plt(i)		; Plot color.
	  plotp,x,y,p,col=c,/clip	; Plot data.
	endfor
 
	end
 
 
;----------------------------------------------------------------------
;	cw_stripchart_get_value = get cw_stripchart value.
;----------------------------------------------------------------------
 
	function cw_stripchart_get_value, id
 
	;-------  Get state structure  ------------
	ch_id = widget_info(long(id),/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	ss = {data:s.data(0:s.inx,*), xval:s.xval(0:s.inx), $
	      pcode:s.pcode(0:s.inx,*)}
 
	return, ss				; Current values.
 
	end
 
 
;----------------------------------------------------------------------
;	cw_stripchart_set_value = set cw_stripchart value.
;----------------------------------------------------------------------
 
	pro cw_stripchart_set_value, id, val
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s,/no_copy	; Get state.
 
	;-------  Check if incoming value is a new key image  -----
	sz = size(val)
	if sz(0) eq 3 then begin
	  ptr_free, s.key
	  s.key = ptr_new(val)
	  goto, done
	endif
 
	;-------  Check # of plot channels  -------
	nlast = n_elements(s.last_val)
	nnow = n_elements(val)
	if nlast lt nnow then begin
	  print,' Error in cw_stripchart: Wrong number of plot channels.'
	  print,'   Set for '+strtrim(nlast-1,2)+' channels, trying to plot'
	  print,' '+strtrim(nnow-1,2)+' channels.'
	  print,' '
	  print,' Trying to plot too many channels.  May plot fewer but'
	  print,' not more than specified when stripchart set up.'
	  print,' Remember to give new time as first in array:'
	  print,' widget_control, wid, set_val=[time,v0,v1,...,vn]'
	  print,' Plot ignored.'
	  goto, done
	endif
 
	if s.win2 lt 0 then goto, done		; Not yet realized.
 
	if s.inx ge s.lstx then goto, done	; No more plot space.
 
	;-------  Save new values  ----------------
	last_val = s.last_val			; Grab last values.
	s.last_val = val			; Set new values.
 
	s.inx = s.inx + 1			; Index of current point.
	s.xval(s.inx) = val(0)			; X value.
	for i=1,n_elements(val)-1 do begin	; Loop through channels.
	  s.data(s.inx,i-1) = val(i)		; Save i'th chan value.
	  s.pcode(s.inx,i-1) = 1		; Set pen code.
	endfor
 
	if last_val(0) eq -1 then goto, done	; First point.
 
	;---------  Update Plot  ------------
	wsave = !d.window			; Save current window.
	wset, s.win2				; Restore scaling.
	!x = s.xsave
	!y = s.ysave
	!p = s.psave
 
	tm0 = last_val(0)			; Plot values.
	y0 = last_val(1:*)
	tm1 = val(0)
	y1 = val(1:*)
	clr = s.c_plt
	lstc = n_elements(clr)-1
 
	if s.track eq 1 then begin		; Scroll plot window.
	  t = convert_coord(tm1,0,/to_dev)
	  ivx = (t(0)-0.8*s.xvwid)>0
	  widget_control, s.id_d2, set_draw_view=[ivx,0]
	endif
 
	for i=0, n_elements(y1)-1 do begin
	  oplot,[tm0,tm1],[y0(i),y1(i)],col=clr(i<lstc)
	endfor
 
	wset, wsave		; Restore original window (but not scaling).
 
done:
	widget_control,ch_id,set_uval=s,/no_copy	; Restore state.
 
	end
 
;----------------------------------------------------------------------
;	cw_stripchart_event = Internal event handler.
;----------------------------------------------------------------------
 
	function cw_stripchart_event, ev
 
	;-------  Get state structure  ------------
	parent = ev.handler
	ch_id = widget_info(parent,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	;------  Get event trigger uval  -----------
	widget_control, ev.id,get_uval=uval
 
	if uval eq 'TRACK' then begin		; Autoscroll plot.
	  track = ev.select
	  s.track = track
	  widget_control,ch_id,set_uval=s	; Save new state.
	  return,''				; Null string gets ignored.
	endif
 
	if uval eq 'KEY' then begin		; Display plot legend.
	  widget_getoffset,ev.id,x,y,/pos
	  img_disp, *s.key, xpos=x, ypos=y,title='Legend'
	  return,''				; Null string gets ignored.
	endif
 
	if uval eq 'HELP' then begin
	  widget_getoffset,ev.id,x,y
	  txt = ['Click on the Track button to stop', $
		'plot scrolling.  Then the slider bar',$
		'under the plot can be used to examine',$
		'the plot.',' ',$
		'Left click on the plot for a vertical',$
		'stretch, middle click to unstretch.',$
		'Right click to reset to original Y scale.',$
		'If the Key button exists (under Options)',$
		'it will display a plot legend.', $
		'Reset (under Options) will erase current', $
		'plot and start plotting new incoming data', $
		'(Current data will be lost).', ' ', $
		'Current window: '+s.title, $
		'Max samples: '+strtrim(s.nx,2), $
		'Current samples: '+strtrim(s.inx,2), $
		'Window width (pixels): '+strtrim(fix(s.xsize),2), $
		'% visible: '+string(100*s.x_scroll/s.xsize, $
		  form='(F5.1)'), $
		'Max channels: '+strtrim(s.ny,2)]
	  xhelp,txt,/wait,title='Stripchart options',xoff=x,yoff=y
	  return,''				; Null string gets ignored.
	endif
 
	if uval eq 'DRAW' then begin		; Change Y scale.
	  press = ev.press			; Mouse button code (1,2,4).
	  if press eq 0 then return,''
	  ix=ev.x  &  iy=ev.y			; Device coords where clicked.
	  wsave = !d.window			; Save current window.
	  wset, s.win2				; Set to chart window.
	  !x=s.xsave & !y=s.ysave & !p=s.psave	; Restore current scaling.
	  t = convert_coord(ix,iy,/dev,/to_data) ; Find data x/y where clicked.
	  x=t(0)  &  y=t(1)
	  ;------  New Y range  -----------------
	  case press of
1:	  begin					; Magnify Y scale.
	    s.yran = new_range(s.yran,2.,y,lim=s.yran0)
	  end
2:	  begin					; Demagnify Y scale.
	    s.yran = new_range(s.yran,.5,y,lim=s.yran0)
	  end
4:	  begin					; Reset to original scale.
	    s.yran = s.yran0
	  end
	  endcase
	  widget_control,ch_id,set_uval=s	; Save new values.
	  cw_stripchart_realize, s.root		; Redo plot scale.
	  cw_stripchart_replot, s		; Replot data.
	  wset, wsave				; Restore original window.
	endif
 
;---  Not useful here since incoming x value will not be
;---  reset.  But externally, using the set_value command,
;---  a reset could be given.  Check if incoming value is
;---  a command or a value array.
;	if uval eq 'RESET' then begin		; Restart plot.
;	  print,' RESET'
;	  tt = ['Reset: erase current plot and restart',$
;		'The current plot will be lost and cannot',$
;		'be replotted if reset is done.  New',$
;		'incoming data will be plotted.']
;	  ans = xyesno('Reset plot? Y/N',title=tt)
;	  if ans ne 'Y' then return,''
;	  s.inx = -1				; Reset data point index.
;	  wsave = !d.window			; Save current window.
;	  wset, s.win2				; Set to chart window.
;	  !x=s.xsave & !y=s.ysave & !p=s.psave	; Restore current scaling.
;	  widget_control,ch_id,set_uval=s	; Save new values.
;	  cw_stripchart_realize, s.root		; Redo plot scale.
;	  wset, wsave				; Restore original window.
;	endif
 
 
	return, ''
 
	end
 
 
;----------------------------------------------------------------------
;	cw_stripchart_cleanup: Cleanup pointer when widget is killed.
;----------------------------------------------------------------------
 
	pro cw_stripchart_cleanup, id
 
	widget_control, id, get_uval=s
 
	ptr_free, s.key		; Clean up legend key image.
 
	end
 
 
 
;----------------------------------------------------------------------
;	cw_stripchart_realize: set up stripchart when widget realized
;----------------------------------------------------------------------
 
	pro cw_stripchart_realize, root
 
	wsave = !d.window			; Save current window.
	ch_id = widget_info(root,/child)	; Widget ID of child.
	widget_control, ch_id, get_uval=s	; Grab state info.
 
	;-----  Main plot window  --------------
	widget_control, s.id_d2, get_value=win	; Now can get window.
	s.win2 = win				; Save draw window.
	wset, win
	erase, s.c_bak
	pos = s.rpos + [0,0,!d.x_size-1,!d.y_size-1]	; Plot position (/dev).
	ix1 = pos(0)		; Position of LL corner of plot window.
	iy1 = pos(1)
	dx = pos(2)-ix1+1	; Length of x axis.
	dy = pos(3)-iy1+1	; Length of y axis.
	plot,/noerase,pos=pos,/dev,[0,1],/nodata,xran=s.xran,yran=s.yran, $
	  xstyle=5, ystyle=5
	s.xsave = !x
	s.ysave = !y
	s.psave = !p
	csz = s.csz
	tklen = 8*csz
	;-------  X axes  --------------
	axis2,ix1,iy1,len=dx,range=s.xran, chars=s.csz, ticklen=-tklen, $
	  laboff=-0.5, col=s.c_ax, no25=s.no25
	axis2,ix1,iy1+dy,len=dx,range=s.xran,ticklen=tklen,/nolab, $
	  col=s.c_ax, no25=s.no25
	;-------  Y axes  ---------------
	if s.rpos(0) gt 0 then begin
	  axis2,ix1,iy1,len=dy,range=s.yran, chars=s.csz, ticklen=-tklen, $
	    laboff=-.5, col=s.c_ax, orient=90, nominor=s.nominor, $
	    title=s.ytitle, side=1
	endif
	if s.rpos(2) lt 0 then begin
	  axis2,ix1+dx,iy1,len=dy,range=s.yran, ticklen=-tklen, $
	    /nolabels, col=s.c_ax, orient=90, nominor=s.nominor
	endif
 
 
	widget_control, ch_id, set_uval=s	; Save updated widget state.
 
	;-----  Y axis window  ----------------
	if s.id_d1 gt 0 then begin
	  widget_control,s.id_d1,get_value=win	; Now can get window.
	  s.win1 = win				; Save draw window.
	  wset, win				; Set to window and
	  erase, s.c_bak			; erase to background color.
	  ix1 = !d.x_size-1
	  axis2,ix1,iy1-2,len=dy,range=s.yran, chars=s.csz, ticklen=tklen, $
	    laboff=2.5, col=s.c_ax, orient=90, nominor=s.nominor, tspace=50, $
	    title=s.ytitle, side=1
	endif
 
	wset, wsave				; Restore original window.
 
	end
 
;----------------------------------------------------------------------
;	Main routine
;----------------------------------------------------------------------
 
	function cw_stripchart, parent, nx, ny, ysize=ysize, $
	  x_scroll=x_scroll, value=v0, uvalue=uval, help=hlp, $
	  frame=frame, ytitle=ytitle, title=title, rpos=rpos, $
	  xrange=xran, yrange=yran, xwidth=xwidth, charsize=csz, $
	  yfixed=yfixed, nominor=nominor, c_back=c_bak, c_plot=c_plt, $
	  c_axes=c_ax, no25=no25, key=key
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Strip chart compound widget.'
	  print,' id = cw_stripchart( parent, nx, ny)'
	  print,'   parent = Widget ID of parent base.   in'
	  print,'   nx = Max number of samples to be plotted.'
	  print,'   ny = Number of channels.'
	  print,' Keywords:'
	  print,'   X_SCROLL=x_sc Size in X on screen (pixels, def=100).'
	  print,'   XWIDTH=xwid  Width in x units of visible section (def=10).'
	  print,'     This is not exact, usually more is covered.'
	  print,'   XRANGE=xran  Total range in X (def=[0,100]).'
	  print,'   /NO25 means do not use multiples of 2.5 for axis ticks.'
	  print,'   KEY=key  Optional 24-bit image to display as a legend.'
	  print,'     May later set a new key by sending the image as a new'
	  print,'     value using widget_control,id,set_val=key.'
	  print,'   YSIZE=ys  Size in Y (pixels, def=100).'
	  print,'   YRANGE=yran  Range in Y (def=[0,1]).'
	  print,"   YTITLE=yttl Y axis title (def=none)."
	  print,'   /YFIXED include a fixed Y axis.'
	  print,'   /NOMINOR suppress y axis minor ticks.'
	  print,'   UVALUE=uval User value (def=none).'
	  print,'   /FRAME frame around widget (def=one).'
	  print,"   TITLE=ttl Main title (def='Strip Chart')."
	  print,'   RPOS=[x1,y1,x2,y2]  Offset from window sides:'
	  print,'     [left,bottom,right,top].  Def=[30,30,-10,-10].'
	  print,'   CHARSIZE=csz  Character size (def=1).'
	  print,'   C_BACK=c_bak Background color (def=white).'
	  print,'   C_AXES=c_ax axes color (def=black).'
	  print,'   C_PLOT=c_plt Plot color(s) (def=red, green, blue).'
	  print,'     May give an array of plot colors, one ofr each channel.'
	  print,' Note:  May have multiple plot channels. May specify colors'
	  print,'   for each, default are set up if none given.  Use'
	  print,'   widget_control, wid, set_val=val to plot new data points,'
	  print,'   val is [x, val1, val2, ..., valn] where x is'
	  print,'   the x value, val1, ... are the plot values.'
	  print,'   May plot less than # channels set, but not more.'
	  return,''
	endif
 
	on_error, 2
 
	;---------------------------------------------
	;  Set defaults and constants
	;---------------------------------------------
	if n_elements(uval) eq 0 then uval=0		; UVAL.
	if n_elements(rpos) eq 0 then $
	  rpos=[30,30,-10,-10]	; Pixels from edge: [left, bottom, right, top]
	xmar = float(rpos(0)-rpos(2))			; Margins in X (pixels).
	if n_elements(title) eq 0 then title='Stripchart' ; Title.
	if n_elements(ytitle) eq 0 then ytitle=''	; Y Title.
	if n_elements(xwidth) eq 0 then xwidth=10	; Visible width in x units.
	if n_elements(x_scroll) eq 0 then x_scroll=100	; X scroll size in pxls.
	if n_elements(xran) eq 0 then xran=[0,100]	; X range.
	dx = float(xran(1)-xran(0))			; Total x units.
	xsize = dx*x_scroll/xwidth + xmar		; Window pixels in x.
	if n_elements(no25) eq 0 then no25=0		; /NO25.
	if n_elements(ysize) eq 0 then ysize=100	; Y size.
	if n_elements(yran) eq 0 then yran=[0,1]	; Y range.
	if n_elements(csz) eq 0 then csz=1		; Char size.
	if ytitle eq '' then dx1 = 30.*csz else dx1=50.*csz ; Space for y ttl.
	if n_elements(nominor) eq 0 then nominor=0	; Y axis minor ticks.
	if n_elements(c_bak) eq 0 then c_bak=tarclr(255,255,255)
	if n_elements(c_ax) eq 0 then c_ax=tarclr(0,0,0)
	if n_elements(c_plt) eq 0 then begin		; Default plot colors.
	  h = maken(0,300,ny)
	  c_plt = lonarr(ny)
	  for i=0,ny-1 do c_plt(i)=tarclr(/hsv,h(i),1,1)
	endif
	last_val = [-1.,fltarr(ny)]			; [time, all channels].
	data = fltarr(nx,ny)				; Memory for plot data.
	xval = fltarr(nx)				; Plot x values.
	pcode = bytarr(nx,ny)				; Pen code: 0=up,1=down.
	inx = -1					; Index into data.
 
	;---------------------------------------------
	;  Set up widget
	;	notify_realize needed to get draw
	;	widget window ID after widget realized.
	;---------------------------------------------
	;--------  CW widget root base  ------------------------
	root = widget_base( parent, uvalue=uval,frame=frame, $
		event_func='cw_stripchart_event',         $
		pro_set_value='cw_stripchart_set_value',  $
		func_get_value='cw_stripchart_get_value', $
		notify_realize='cw_stripchart_realize')
 
	;--------  Child base for saving widget state  ----------
	base0 = widget_base(root,/col,space=0, $
	  kill_notify='cw_stripchart_cleanup')
 
	;--------  Upper area  ------------------------
	base = widget_base(base0,/row)
	id = widget_label(base,val=title)
	b = widget_base(base,/nonexclusive)
	id = widget_button(b,value='Track',uval='TRACK')
	widget_control, id, /set_button
	b = widget_base(base)
	idm = widget_button(b,value='Help',menu=2)
	id = widget_button(idm,value='Help',uval='HELP')
	if n_elements(key) ne 0 then begin
	  id = widget_button(idm,value='Key',uval='KEY')
	endif
 
	;--------  Draw widgets  -----------------------
	base = widget_base(base0,/row,space=0)
	if keyword_set(yfixed) then begin
	  id_d1 = widget_draw(base,xsize=dx1,ysize=ysize)
	endif else id_d1=-1
	id_d2 = widget_draw(base,xsize=xsize,x_scr=x_scroll, $
	  y_scr=ysize+2, ysize=ysize, /scroll, /button_events, $
	  uval='DRAW')
 
	g = widget_info(id_d2,/geom)
	xvwid = g.scr_xsize		; Visible width of stripchart.
 
	;--------  Collect state info and save  ------------------
	if n_elements(key) eq 0 then key=0
	s = {root:root, nx:nx, ny:ny, id_d1:id_d1, id_d2:id_d2, $
		win1:-1, win2:-1, title:title, ytitle:ytitle, $
		xvwid:xvwid, xran:float(xran), yran:float(yran), $
		yran0:float(yran), csz:csz, $
		xsize:xsize, x_scroll:x_scroll, rpos:rpos, nominor:nominor, $
		c_bak:c_bak, c_ax:c_ax, c_plt:c_plt, track:1, psave:!p, $
		xsave:!x, ysave:!y, last_val:last_val, no25:no25, $
		key:ptr_new(key),data:data, xval:xval, pcode:pcode, $
		inx:inx, lstx:nx-1 }
	 
	widget_control, base0, set_uval=s  ; Save widget state in first child.
 
	;--------  See if realized (adding to existing widget)  ------
	if widget_info(root,/real) then cw_stripchart_realize, root
 
	;--------  Return Widget ID for this compound widget  ---------
	return, root
 
	end
