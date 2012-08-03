;===================================================================
;	iwindow object = Image Window.  Resizeable. Selectable
;	  image scaling.
;
;	R. Sterner, 2003 Jul 03
;	R. Sterner, 2003 Sep 23 --- Adding help.  Minor cleanup.
;	R. Sterner, 2005 Feb 11 --- Added a few menu accelerators.
;
;	Methods:
;	------ External --------
;       pro iwindow::help, out=out
;       pro iwindow::list, out=out
;	pro iwindow::get, help=hlp, image=raw, $
;       pro iwindow::set, help=hlp, title=tt, image=img, x_scroll=xscr0, $
;       pro iwindow::wshow
;	------ Internal --------
;       pro iwindow::resize, x, y
;       pro iwindow::zimg
;       pro iwindow::zsize
;	pro iwindow::zreset
;       pro iwindow::zshow, ix, iy, restore=rest
;       pro iwindow::zdown
;       pro iwindow::zup
;       pro iwindow::zctog
;	function iwindow::get_id_draw
;	function iwindow::list_scale
;	pro iwindow::togdrag
;	pro iwindow::getdragxy, x, y
;	pro iwindow::savedragxy, x, y
;	pro iwindow::cleardrag
;	pro iwindow::setdrag
;	function iwindow::drag
;       pro iwindow::settimer
;       pro iwindow::getxy, x, y
;       pro iwindow::savexy, x, y
;       pro iwindow::clearflag
;       pro iwindow::setflag
;       function iwindow::flag
;       pro iwindow::draw
;       pro iwindow::scrollsize, xsize, ysize, xscr0, yscr0, xscr, yscr
;       pro iwindow::cleanup
;       function iwindow::init, img, x_scroll=x_max, y_scroll=y_max
;
;===================================================================
 
	;***********************************************************
	;***********************************************************
	;
	;  External routines
	;
	;***********************************************************
	;***********************************************************
 
	;===========================================================
	;  help = iwindow help
	;===========================================================
 
	pro iwindow::help, out=out, quiet=quiet
 
	tprint,/init
 
	tprint,' '
	tprint,' iwindow object help'
	tprint,' '
	tprint,' iwindow objects are resizeable image display windows'
	tprint,'   with various builtin functions.'
	tprint,' '
	tprint,' To set up an iwindow object:'
	tprint,"   a = obj_new('iwindow',[image],[/menu])"
	tprint,' where a is a new iwindow object.'
	tprint,'       image is an optional initial image.'
	tprint,'       /menu gives an optional menu with scaling,'
	tprint,'         zoom, and save options.'
	tprint,' '
	tprint,' a->set, image=img, title=tt, x_scroll=xscr, y_scroll=yscr, $'
	tprint,'   view=view'
	tprint,'   img = new image'
	tprint,'   tt = new title'
	tprint,'   xscr, yscr = new window size (must be used together)'
	tprint,'   view = new viewport [ix,iy] of lower left corner.'
	tprint,'   scaling = sc  Set image scaling option (0-7).'
	tprint,'   par = par  Set new parameter structure'
	tprint,'      Do help,img_scale(/help) for more details.'
	tprint,'   drag = drag  Turn image drag mode on (1) or off (0).'
	tprint,' '
	tprint,' a->get,image=img,raw=raw,view=vw,scaling=sc,par=p, $'
	tprint,'        true=tr,mid=mid,win=win,id_draw=id_draw'
	tprint,'   img = returned scaled image.'
	tprint,'   raw = returned raw image.'
	tprint,'   vw = returned viewport (visible lower left corner).'
	tprint,'   mid = viewport midpoint.'
	tprint,'   sc = scaling option in effect.'
	tprint,'   p = scaling parameters in effect.'
	tprint,'   tr = image pixel interleaving (0=B&W, else color).'
	tprint,'   win = win IDL window index (used in wshow,win).'
	tprint,'   id_draw = id_draw  Draw widget ID.'
	tprint,' '
	tprint,' a->list, [out=txt]'
	tprint,'   List current settings and image details.'
	tprint,' '
	tprint,' a->wshow'
	tprint,'   Brings window to front of screen (even if iconified).'
	tprint,' '
	tprint,' a->help, [out=txt], /quiet'
	tprint,'   Display iwindow object help (txt is optionally returned).'
	tprint,' '
 
	if keyword_set(quiet) then begin
	  tprint,out=out
	endif else begin
	  tprint,/print,out=out
	endelse
 
	end
 
 
 
	;===========================================================
	;  LIST = List iwindow object parameters.
	;===========================================================
 
	pro iwindow::list, out=out
 
	tprint,/init
	tprint,' '
	tprint,' Current settings of iwindow object:'
	tprint,' '
	tprint,' Image size: '+strtrim(self.nx,2)+' x '+$
		strtrim(self.ny,2)
	if self.true eq 0 then begin
	  tprint,' Image type: B&W'
	endif else begin
	  tprint,' Image type: Color. True='+strtrim(self.true,2)
	endelse
	tprint,' Raw image data type: '+datatype(*self.p_raw,1)
	tprint,' Image display scaling: '+self->list_scale()
	tprint,' Window size: '+strtrim(self.x_scr,2)+' x '+$
		strtrim(self.y_scr,2)
	tprint,' IDL window index: '+strtrim(self.win,2)
	widget_control, self.id_draw, get_draw_view=view
	tprint,' Window viewport: '+strtrim(view(0),2)+', '+strtrim(view(1),2)
 
	tprint,/print,out=out
	
 
	end
 
 
	;===========================================================
	;  GET = iwindow get routine.
	;===========================================================
 
	pro iwindow::get, help=hlp, image=img, $
	  view=view, scaling=sc, par=par, true=true, $
	  win=win,id_draw=id_draw, raw=raw, mid=mid
 
		;-------  Help  ----------------
	if keyword_set(hlp) then begin
	  print,' '
	  print,' Get parameters for an iwindow object.'
	  print,'   RAW=raw return raw image.'
	  print,'   IMAGE=img return scaled image.'
	  print,'   TRUE=tr  Return image pixel interleave dimension.'
	  print,'     0=B&W, else color image.'
	  print,'   VIEW=vw  Return current viewport ([x,y] = LL corner).'
	  print,'   MID=mid  Return viewport midpoint ([x,y]).'
	  print,'   SCALING=sc Return scaling option.'
	  print,'   PAR=par  Return scaling parameter structure.'
	  print,'   WIN=win  Return the IDL window index.'
	  print,'   ID_DRAW=id  Return the widget ID of the draw widget.'
	  return
	endif
 
	raw = *self.p_raw
	img = *self.p_img
	widget_control, self.id_draw, get_draw_view=view
	mid = view + [self.x_scr, self.y_scr]/2
	if self.true eq 0 then sc=self.bwsc else sc=self.clsc
	par = *self.p_par
	true = self.true
	win = self.win
	id_draw = self.id_draw
 
	end
 
 
	;===========================================================
	;  SET = iwindow set routine.
	;===========================================================
 
	pro iwindow::set, help=hlp, title=tt, image=raw, x_scroll=xscr0, $
	  y_scroll=yscr0, view=view, scaling=scale, par=par, drag=drag
 
	;-------  Help  ----------------
	if keyword_set(hlp) then begin
	  print,' '
	  print,' Set parameters for an iwindow object.'
	  print,' x->set'
	  print,'   x is the name of the object.  All values are keywords.'
	  print,'   TITLE=tt  Set window title.'
	  print,'   IMAGE=img Set new image.  Keeps same window size'
	  print,'      unless new image is smaller than old.'
	  print,'   X_SCROLL=xscr, Y_SCROLL=yscr Set new window size.'
	  print,'     Both x and y size must be given.'
	  print,'   VIEW=[ix0,iy0] Set viewport into scrolling window'
	  print,'     by giving window pixel to show at lower left corner.'
	  print,'   SCALING=sc  Set image scaling option (0-7).'
	  print,'   PAR=par  Set new parameter structure'
	  print,'      Do help,img_scale(/help) for more details.'
	  print,'   DRAG=drag  Turn image drag mode on (1) or off (0).'
	  return
	endif
 
	;-------  Window title  ----------
	if n_elements(tt) ne 0 then begin
	  widget_control, self.top, tlb_set_title=tt
	endif
 
	;-------  Image drag on/off  ------
	if n_elements(drag) ne 0 then begin
	  widget_control, self.id_draw, draw_motion_events=drag, $
	    draw_button_events=drag
	endif
 
	scroll_flag = 0			; Scroll size used yet?
	xscr_flag = 0
	yscr_flag = 0
	if n_elements(xscr0) gt 0 then xscr_flag=1
	if n_elements(yscr0) gt 0 then yscr_flag=1
	if (xscr_flag + yscr_flag) eq 1 then begin
	  print,' Error in iwindow object set method: when giving new'
	  print,'   scroll size must give both x and y scroll size.'
	  return
	endif
 
	scale_flag = 0			; Rescale image?
	draw_flag = 0			; Redraw image?
	par_flag = 0			; par given?
 
	;--------  New image  ------------
	if n_elements(raw) ne 0 then begin
	  sz = size(raw)
	  if sz(0) lt 2 then begin
	    print,' Error in iwindow object set method: when giving a new'
	    print,'   image it must be 2-d (B&W) or 3-d (full color).'
	    return
	  endif
	  ptr_free, self.p_raw		; Free pointer to old image.
	  self.p_raw = ptr_new(raw)	; Pointer to new image.
	  img_shape, raw, nx=nx, ny=ny, true=true
	  self.nx = nx
	  self.ny = ny
	  self.true = true
	  scale_flag = 1
	  ;-----  Display new image  ------
	  self->scrollsize, self.nx,self.ny,self.x_scr, self.y_scr, xscr, yscr
	  if xscr_flag ne 0 then begin
	    xscr = xscr0
	    yscr = yscr0
	    scroll_flag = 1		; Scroll size used.
	  endif
	  self->resize, xscr, yscr
	  draw_flag = 1
	endif
 
	;-------- New window size  -----------
	if (xscr_flag ne 0) and ( scroll_flag eq 0) then begin
	  self->resize, xscr0, yscr0
	  draw_flag = 1
	endif
 
	;-------- Set viewport  --------------
	if n_elements(view) eq 2 then begin
	  widget_control,self.id_draw,set_draw_view=view
	endif
 
	;-------  Set scaling paramaters  ---------
	if n_elements(par) ne 0 then begin
	  ptr_free, self.p_par
	  self.p_par = ptr_new(par)
	  scale_flag = 1
	  draw_flag = 1
	  par_flag = 1
	endif
 
	;-------  Set image scaling option  -------
	if n_elements(scale) ne 0 then begin
	  if self.true eq 0 then begin		; B&W.
	    if scale ne self.bwsc then begin
	      if par_flag eq 0 then begin
	        ptr_free, self.p_par
	        self.p_par = ptr_new({null:0})
	      endif
	      self.bwsc = scale
	      scale_flag = 1
	      draw_flag = 1
	    endif
	  endif else begin			; Color.
	    if scale ne self.clsc then begin
	      if par_flag eq 0 then begin
	        ptr_free, self.p_par
	        self.p_par = ptr_new({null:0})
	      endif
	      self.clsc = scale
	      scale_flag = 1
	      draw_flag = 1
	    endif
	  endelse
	endif
 
	if scale_flag then begin
	  ptr_free, self.p_img		; Free pointer to old image.
	  ;-----  Scale new image  --------
	  if self.true eq 0 then begin	; B&W image
	    raw = *self.p_raw
	    par = *self.p_par
	    if (self.bwsc eq 6) or (self.bwsc eq 7) then begin
	      if self.bwsc eq 7 then begin
	        if tag_test(par,'RX') eq 0 then begin
	          xmess,['Interactive scaling parameters unavailable.',$
			'Must scale interactively before using this',$
			'scaling option.  Also the scaling is lost',$
			'after some other scaling options are used.']
		  return
		endif
	      endif
	      d = datatype(raw) 
	      if (d eq 'FLO') or (d eq 'DOU') then begin
	        raw = uint(vnorm(raw)*60000)
	      endif
	    endif
	    self.p_img = ptr_new(img_scale(raw,self.bwsc,par))
	    if self.bwsc eq 6 then begin
	      ptr_free,self.p_par
	      self.p_par = ptr_new(par)
	    endif
	  endif else begin		; Color image
	    self.p_img = ptr_new(img_scale(*self.p_raw,self.clsc,*self.p_par))
	  endelse
	  if obj_valid(self.magbub) then self.magbub->set,image=*self.p_img
	endif
 
	if draw_flag then self->draw
 
	end
 
 
	;===========================================================
	;  WSHOW = Show window.
	;===========================================================
	pro iwindow::wshow
	  widget_control, self.top, iconify=0
	  wshow, self.win
	end
 
 
	;***********************************************************
	;***********************************************************
	;
	;  Internal routines
	;
	;***********************************************************
	;***********************************************************
 
 
	;===========================================================
	;  iwindow_cleanup = Cleanup routine for iwindow object
	;===========================================================
 
	pro iwindow_cleanup, top
 
	widget_control, top, get_uval=p_s	; uval is pointer to object.
	s = *p_s				; iwindow object itself.
 
	ptr_free, p_s				; Kill pointer to object.
	widget_control, top, /destroy		; Kill window widget.
	obj_destroy, s				; Kill object itself.
 
	end
 
 
	;===========================================================
	;  iwindow_event = Event handler for iwindow object
	;===========================================================
 
	pro iwindow_event, ev
 
	ev_name = tag_names(ev,/structure_name)
	widget_control, ev.top, get_uval=p_s
	s = *p_s
 
	;------ Timer event: process last resize event  --------
	if ev_name eq 'WIDGET_TIMER' then begin
	  s->getxy,x,y
	  s->resize, x, y
	  s->draw
	  s->clearflag
	  return
	endif
 
	;------  Resize event  ------------------	
	if ev_name eq 'WIDGET_BASE' then begin
 
	  if s->flag() eq 0 then begin	; New event.
	    s->setflag			; Set event flag.
	    s->savexy,ev.x,ev.y		; Save new size.
	    s->settimer			; Set timer.
	    return
	  endif
 
	  if s->flag() eq 1 then begin	; Repeat event
	    s->savexy,ev.x,ev.y		; Save new size.
	    return
	  endif
 
	endif
 
 
	;-------  Other options  ---------------
	widget_control, ev.id, get_uval=uval
 
	;-------  Image drag  ------------------
	if uval eq 'DRAW' then begin
	  ;-----  Start dragging image  --------
	  if ev.press eq 1 then begin
	    s->setdrag
	    s->savedragxy, ev.x, ev.y
	    return
	  endif
	  ;-----  End dragging image  ----------
	  if ev.release eq 1 then begin
	    s->cleardrag
	    return
	  endif
	  if s->drag() eq 0 then return
	  id_draw = s->get_id_draw()
	  widget_control, id_draw, get_draw_view=view
	  s->getdragxy,x0,y0
	  delta = [x0-ev.x,y0-ev.y]
	  widget_control, id_draw, set_draw_view=view+delta
	  return
	endif
 
	;------  Zoom menu  ------------
	if uval eq 'ZOOM' then begin
	  s->wshow
	  for i=0,2000 do begin
	    cursor,ix,iy,/change,/dev
	    if !mouse.button eq 4 then break
	    if !mouse.button eq 2 then s->zdown 
	    if !mouse.button eq 1 then s->zup
	    s->zshow,ix,iy
	  endfor
	  s->zshow, /restore
	  return
	endif
 
	if uval eq 'ZOOMCRD' then begin
	  s->zctog
	  return
	endif
 
	if uval eq 'ZOOMSIZ' then begin
	  s->zsize
	  return
	endif
 
	if uval eq 'ZOOMRES' then begin
	  s->zreset
	  return
	endif
 
	;------  Options menu  -----------
	if uval eq 'DRAG'then begin
	  s->togdrag	; Toggle.
	  return
	endif
 
	if uval eq 'JPG'then begin
	  s->get,image=img, true=tr
	  jdef = dt_tm_fromjs(dt_tm_tojs(systime()),form='y$n$0d$_h$m$s$.jpg')
	  tt = 'Save image as a JPEG'
	  lab = ['JPEG name:/20','Quality (0-100):']
	  row = [1,2]
	  def = [jdef,'75']
	  xgetvals,title=tt,lab=lab,row=row,val=val,def=def,exit=ex
	  if ex lt 0 then return
	  jpg = val(0)
	  q = val(1)+0
	  write_jpeg,jpg,img,qual=q,true=tr
	  print,' Image saved as JPEG in '+jpg
	  return
	endif
 
	if uval eq 'PNG'then begin
	  s->get,image=img, true=tr
	  pdef = dt_tm_fromjs(dt_tm_tojs(systime()),form='y$n$0d$_h$m$s$.png')
	  tt = 'Save image as a PNG'
	  lab = 'PNG name:/20'
	  row = 1
	  def = pdef
	  xgetvals,title=tt,lab=lab,row=row,val=val,def=def,exit=ex
	  if ex lt 0 then return
	  png = val(0)
	  if tr gt 1 then img=img_redim(img,true=1)
	  write_png,png,img
	  print,' Image saved as PNG in '+png
	  return
	endif
 
	;------  Help Menu  ----------
	if strmid(uval,0,6) eq 'HELP_B' then begin
	  s->help,out=txt,/quiet
	  xhelp,txt,save='iwindow_help.txt'
	  return
	endif
	if strmid(uval,0,4) eq 'HELP' then begin
	  hfile = getwrd(uval,1)
	  whoami, dir
	  file = filename(dir,hfile,/nosym)
	  txt = getfile(file,err=err)
	  if err ne 0 then return
	  xhelp,txt,save=hfile,group=ev.top
	  return
	endif
 
	;------  Menu scaling  ------------
	cmd = getwrd(uval)		; Command.
	val = getwrd(uval,1)+0		; Value.
	s->get,par=par,true=true,$	; Get some current items.
	  scaling=sc
 
	case val of
2:	begin	; Scale image to specified min/max.
	  tt = ['Set image scaling parameters:',$
		'Set lower (min) and upper (max)',$
		'cutoff values for scaling.']
	  row = [1,1]
	  if true eq 0 then begin
	    lab = ['Image min:','Image max:']
	    if sc eq val then def=[par.min,par.max] else def=[0,255]
	  endif else begin
	    lab = ['Image value min:','Image value max:']
	    if sc eq val then def=[par.min,par.max] else def=[0.,1.]
	  endelse
	  xgetvals,title=tt,lab=lab,row=row,val=p,def=def,exit=ex
	  if ex eq -1 then return
	  par = {min:p(0)+0.,max:p(1)+0.}
	end
3:	begin	; Percentile scaling.
	  tt = ['Set image percentile scaling parameters:',$
		'Set lower (lo) and upper (hi) percentile',$
		'cutoff values for scaling.  May also set',$
		'# histogram bins to use.  Set quiet to 0',$
		'for scaling info, 1 for none.']
	  row = [1,1,2,2]
	  lab = ['Low cutoff:','High cutoff:','Number of bins:','Quiet:']
	  if sc eq val then def=[par.lo,par.hi,par.nbins,par.quiet] $
	    else def=[1,1,2000,0]
	  xgetvals,title=tt,lab=lab,row=row,val=p,def=def,exit=ex
	  if ex eq -1 then return
	  par = {lo:p(0)+0.,hi:p(1)+0.,nbins:p(2)+0,quiet:p(3)+0}
	end
4:	begin	; Variance scaling.
	  tt = ['Set image variance scaling parameters:',$
		'Set variance neighborhood width and',$
		'a cutoff threshold.  Note for B&W images',$
		'the cutoff may be >> 1, but << 1 for color',$
		'images.']
	  row = [3,1]
	  lab = ['Width:','Cutoff:']
	  if sc eq val then def=[par.width,par.thresh] $
	    else def=[3,1]
	  xgetvals,title=tt,lab=lab,row=row,val=p,def=def,exit=ex
	  if ex eq -1 then return
	  par = {width:p(0)+0.,thresh:p(1)+0.}
	end
5:	begin	; Unsharp masking.
	  tt = ['Set image unsharp masking parameters:',$
		'A weighted smoothed copy is subtracted from',$
		'the original image.  The result is percentile',$
		'scaled.  Enter the weighting factor and the', $
		'smoothing window size, and the percentile scaling.',$
		'parameters.']
	  row = [1,1,2,2,3,3]
	  lab = ['Weight:','Width:','Low cutoff:','High cutoff:', $
	         'Number of bins:','Quiet:']
	  if sc eq val then def=[par.wt, par.width, $
	    par.lo,par.hi,par.nbins,par.quiet] $
	    else def=[0.5,5,1,1,2000,0]
	  xgetvals,title=tt,lab=lab,row=row,val=p,def=def,exit=ex
	  if ex eq -1 then return
	  par = {wt:p(0)+0.,width:p(1)+0,lo:p(2)+0.,hi:p(3)+0., $
	    nbins:p(4)+0,quiet:p(5)+0}
	end
; 6, 7    These scaling options are handled in the SET method.
else:
	endcase
 
	;-----  Scale new image  --------
	s->set,scaling=val,par=par
	s->zimg
 
	end
 
 
	;===========================================================
	;  RESIZE = Set display window to given size
	;===========================================================
 
	pro iwindow::resize, x, y
 
	xdrw = self.nx		; Image size.
	ydrw = self.ny
 
	x_max = (xdrw+31)<x	; Max allowed window size.
	y_max = (ydrw+31)<y
 
	;------ Deal with scroll size  ------------
	self->scrollsize, xdrw, ydrw, x_max, y_max, xscr, yscr
 
	;------  Set window size  -----------------
	widget_control, self.id_draw, $
	  draw_xsize=xdrw, draw_ysize=ydrw, scr_xs=xscr, scr_ys=yscr
 
	;------  Make sure it got set correctly  ------
	for i=1,4 do begin
	  g=widget_info(self.top,/geom)
	  if (g.scr_xsize gt (xscr+40)) or $
	     (g.scr_ysize gt (yscr+40)) then begin
;print,' Resize retry ',i
	   ;---------------------------------------------------
	   ;  If the size is set it may not take.  Setting
	   ;  it over doesn't always help. But changing the
	   ;  size does seem to take reliably.
	   ;---------------------------------------------------
	    widget_control, self.id_draw, $
	      draw_xsize=xdrw, draw_ysize=ydrw, scr_xs=xscr-1, scr_ys=yscr-1
	    widget_control, self.id_draw, $
	      draw_xsize=xdrw, draw_ysize=ydrw, scr_xs=xscr, scr_ys=yscr
	  endif else break
	  wait,.1
	endfor
 
	;------  Make sure viewport is correct  -----
	widget_control, self.id_draw, get_draw_view=view
	widget_control, self.id_draw, set_draw_view=view
 
	self.x_scr = xscr
	self.y_scr = yscr
 
	end
 
 
	;===========================================================
	;  ZIMG = Set new mag option.
	;===========================================================
	pro iwindow::zimg
	wset,self.win
	self.magbub->set, image=*self.p_img
	return
	end
 
	;===========================================================
	;  ZSIZE = Set image mag area size.
	;===========================================================
	pro iwindow::zsize
	self->get, mid=mid, win=win
	wset,win
	self.magbub->adjsize, ix=mid(0), iy=mid(1)
	return
	end
 
	;===========================================================
	;  ZRESET = Set image mag area to default size.
	;===========================================================
	pro iwindow::zreset
	self.magbub->set, width=240,frac=0.7,smooth=21,mag=2,chars=1.6
	return
	end
 
	;===========================================================
	;  ZSHOW = Show zoomed image.
	;===========================================================
	pro iwindow::zshow, ix, iy, restore=rest
	wset,self.win
	self.magbub->show, ix, iy, restore=rest
	return
	end
 
	;===========================================================
	;  ZDOWN = Decrease mag factor.
	;===========================================================
	pro iwindow::zdown
	self.magbub->magdown
	return
	end
 
	;===========================================================
	;  ZUP = Increase mag factor.
	;===========================================================
	pro iwindow::zup
	self.magbub->magup
	return
	end
 
	;===========================================================
	;  ZCTOG = Toggle zoom coordinates on/off.
	;===========================================================
	pro iwindow::zctog
	self.magbub_crd = 1 - self.magbub_crd
	self.magbub->set, coord=self.magbub_crd
	return
	end
 
	;===========================================================
	;  GET_ID_DRAW = Get draw widget ID
	;===========================================================
	function iwindow::get_id_draw
	return, self.id_draw
	end
 
	;===========================================================
	;  LIST_SCALE = List iwindow object parameters.
	;===========================================================
	function iwindow::list_scale
	sc = ['0 = No scaling',$
	      '1 = Scale to image min/max',$
	      '2 = Scale to specified min/max',$
	      '3 = Percentile scaling',$
	      '4 = Variance scaling',$
	      '5 = Unsharp masking',$
	      '6 = Interactive scaling',$
	      '7 = Apply scaling from last interactive']
	if self.true eq 0 then txt=sc(self.bwsc) else txt=sc(self.clsc)
	return, txt
	end
 
	;===========================================================
	;  TOGDRAG = Toggle drag mode.
	;===========================================================
	pro iwindow::togdrag
	self.drag_on = 1-self.drag_on
	drag = self.drag_on
	widget_control, self.id_draw, draw_motion_events=drag, $
	  draw_button_events=drag
	end
 
	;===========================================================
	;  GETDRAGXY = Get last drag x,y.
	;===========================================================
	pro iwindow::getdragxy, x, y
	x = self.drag_x
	y = self.drag_y
	end
 
	;===========================================================
	;  SAVEDRAGXY = Save drag x,y.
	;===========================================================
	pro iwindow::savedragxy, x, y
	self.drag_x = x
	self.drag_y = y
	end
 
	;===========================================================
	;  CLEARDRAG = Clear image drag mode flag.
	;===========================================================
	pro iwindow::cleardrag
	self.drag_mode = 0
	end
 
	;===========================================================
	;  SETDRAG = Set image drag mode flag.
	;===========================================================
	pro iwindow::setdrag
	self.drag_mode = 1
	end
 
	;===========================================================
	;  DRAG = get image drag mode flag.
	;===========================================================
	function iwindow::drag
	return, self.drag_mode
	end
 
	;===========================================================
	;  SETTIMER = Set timer.
	;===========================================================
	pro iwindow::settimer
	widget_control, self.id_time, timer=0.1  ; Set timer.
	end
 
	;===========================================================
	;  GETXY = Get new window size.
	;===========================================================
	pro iwindow::getxy, x, y
	x = self.new_x
	y = self.new_y
	end
 
	;===========================================================
	;  SAVEXY = Save new window size.
	;===========================================================
	pro iwindow::savexy, x, y
	self.new_x = x
	self.new_y = y
	end
 
	;===========================================================
	;  CLEARFLAG = Clear event processing flag.
	;===========================================================
	pro iwindow::clearflag
	self.flag = 0
	end
 
	;===========================================================
	;  SETFLAG = Set event processing flag.
	;===========================================================
	pro iwindow::setflag
	self.flag = 1
	end
 
	;===========================================================
	;  FLAG = get event processing flag.
	;===========================================================
	function iwindow::flag
	return, self.flag
	end
 
	;===========================================================
	;  DRAW = Display image
	;===========================================================
 
	pro iwindow::draw
 
	winsave = !d.window	; Save current window.
	wset, self.win		; Set to draw widget.
	win_redirect
	erase			; Erase old image.
	tv, *self.p_img, true=self.true
	win_copy
	wset, winsave		; Set back to original window.
 
	end
 
 
	;===========================================================
	;  SCROLLSIZE = Compute window scroll size.
	;	xsize, ysize = image size.
	;	xscr0, yscr0 = input scroll size.
	;	xscr, yscr = corrected scroll size.
	;  The rules for setting the window scrolling sizes
	;  are rather complex.
	;  >>>===> This routine needs cleaned up.
	;===========================================================
 
	pro iwindow::scrollsize, xsize, ysize, xscr0, yscr0, xscr, yscr
 
	if n_elements(xscr0) gt 0 then xscr=xscr0
	if n_elements(yscr0) gt 0 then yscr=yscr0
 
	device, get_screen_size=ss			; Get screen size.
	xmx = ss(0)*2/3					; Max allowed default
	ymx = ss(1)*2/3					;   window size.
 
	;-----  X SCROLL  -----------------
	if n_elements(xscr) eq 0 then xscr=0
	;-----  Not Given  ----------------
	if xscr eq 0 then begin				; Default scroll size.
	  if xsize lt xmx then begin
	    if ysize lt ymx then xscr=0 else xscr=xsize+2
	  endif else begin
	    xscr = xmx
	  endelse
	;-----  Given  --------------------
	endif else xscr=xscr<(xsize+31)<(ss(0)-100)
	;-----  Y SCROLL  -----------------
	if n_elements(yscr) eq 0 then yscr=0
	;-----  Not Given  ----------------
	if yscr eq 0 then begin
	  if ysize lt ymx then begin
	    if xsize lt xmx then yscr=0 else yscr=ysize+2
	  endif else begin
	    yscr = ymx
	  endelse
	;-----  Given  --------------------
	endif else yscr=yscr<(ysize+31)<(ss(1)-100)
 
	;-------------------------------------------------------------
	;  Limitations on scroll sizes:
	;    Can give to the draw widget scroll sizes of 0, but
	;  can only have both x and y scroll sizes of 0 when
	;  both xsize and ysize are < screen size.  If one is bigger
	;  use a scroll size < screen on that dimension and
	;  a scroll size of window size + 2 on smaller dimension.
	;  For a window with both x and y size < screen cannot use
	;  scroll size = size+2 on both dimensions, use scroll size
	;  of 0 on both.
	;-------------------------------------------------------------
	;-----  can't have one 0 (none or both is ok) -------
	tmp = [xscr,yscr]
	if (min(tmp) eq 0) and (max(tmp) gt 0) then begin
	  if xscr eq 0 then xscr=(xsize+31)<(ss(0)-100)
	  if yscr eq 0 then yscr=(ysize+31)<(ss(1)-100)
	endif
	;------ If both eq max allowed then set both to size+4  ------
	if (xscr gt xsize) and (yscr  gt ysize) then begin
	  xscr = xsize+4
	  yscr = ysize+4
	endif
	;------ If both eq 0 then set both to size+4  ------
	if (xscr eq 0) and (yscr eq 0) then begin
	  xscr = xsize+4
	  yscr = ysize+4
	endif
 
	end
 
 
	;===========================================================
	;  CLEANUP = Cleanup when terminating.
	;===========================================================
 
	pro iwindow::cleanup
 
	ptr_free, self.p_img, self.p_raw, self.p_par  ; Free pointers.
 
	obj_destroy, self.magbub	; Zoom object.
 
	;-----  If window exists destroy it  -------
	if widget_info(self.top,/valid_id) then begin
	  widget_control, self.top, /destroy
	endif
 
	end
 
 
	;===========================================================
	;  INIT = set up initial values
	;===========================================================
 
	function iwindow::init, raw, x_scroll=x_max, y_scroll=y_max, $
	  menu=menu
 
	;------  Deal with image  -----------------
	if n_elements(raw) eq 0 then raw=makez(300,300)
	ptr_free, self.p_raw
	self.p_raw = ptr_new(raw)
	img_shape, raw, nx=nx, ny=ny, true=true
	self.nx = nx
	self.ny = ny
	self.true = true
 
	;------  Default scaling options  ---------
	self.bwsc = 1		; bytscl.
	self.clsc = 0		; as is (no scaling).
	ptr_free, self.p_par
	self.p_par = ptr_new({null:0})
 
	;-----  Scale new image  --------
	ptr_free, self.p_img		; Free pointer to old image.
	if self.true eq 0 then begin	; B&W image
	  self.p_img = ptr_new(img_scale(*self.p_raw,self.bwsc,*self.p_par))
	endif else begin		; Color image
	  self.p_img = ptr_new(img_scale(*self.p_raw,self.clsc,*self.p_par))
	endelse
 
	;------ Deal with scroll size  ------------
	self->scrollsize, self.nx,self.ny,x_max,y_max, xscr, yscr
 
	;------  Set up display widget  -----------
	if keyword_set(menu) then begin
	  top = widget_base(/tlb_size_events, mbar=bar)
	endif else begin
	  top = widget_base(/tlb_size_events)
	endelse
	id_time = widget_base(top)		; For timer.
	self.id_time = id_time
	self.top = top
	;------  Can't seem to avoid margins.  -----
	self.id_draw = widget_draw(id_time,xs=self.nx,ys=self.ny, $
	  x_scr=0.9*self.nx, y_scr=0.9*self.ny, uval='DRAW', $
	  /motion_events, /button_events)
	self.drag_on = 1	; Drag mode is on.
 
	;----  Seem to need this to drop margins where scroll bars would be.
	widget_control, self.id_draw, $
	  draw_xsize=self.nx, draw_ysize=self.ny, $
	  scr_xs=xscr, scr_ys=yscr
	self.x_scr = xscr
	self.y_scr = yscr
 
	;---- Set up menu bar if requested  --------
	if keyword_set(menu) then begin
	  idsc = widget_button(bar,value='Scaling')
	    id = widget_button(idsc, $
	      value='0 = No scaling',uval='SC 0')
	    id = widget_button(idsc, $
	      value='1 = Scale to image min/max',uval='SC 1')
	    id = widget_button(idsc, $
	      value='2 = Scale to specified min/max',uval='SC 2')
	    id = widget_button(idsc, $
	      value='3 = Percentile scaling',uval='SC 3')
	    id = widget_button(idsc, $
	      value='4 = Variance scaling',uval='SC 4')
	    id = widget_button(idsc, $
	      value='5 = Unsharp masking',uval='SC 5')
	    id = widget_button(idsc, $
	      value='6 = Interactive scaling',uval='SC 6')
	    id = widget_button(idsc, $
	      value='7 = Apply scaling from last interactive',uval='SC 7')
 
	  idopt = widget_button(bar,value='Options')
	    id = widget_button(idopt, $
	      value='Toggle image drag on/off',uval='DRAG')
	    id = widget_button(idopt, $
	      value='Save image as a JPEG',uval='JPG')
	    id = widget_button(idopt, $
	      value='Save image as a PNG',uval='PNG')
 
	  izoom = widget_button(bar,value='Zoom')
	    id = widget_button(izoom, $
	      value='Zoom image area',uval='ZOOM',accel='Ctrl+Z')
	    id = widget_button(izoom, $
	      value='Toggle coordinates on/off',uval='ZOOMCRD',accel='Ctrl+C')
	    id = widget_button(izoom, $
	      value='Resize zoom area',uval='ZOOMSIZ',accel='Ctrl+R')
	    id = widget_button(izoom, $
	      value='Reset to default zoom area',uval='ZOOMRES')
 
	  ihelp = widget_button(bar,value='Help')
	    id = widget_button(ihelp, $
	      value='iwindow overview',uval='HELP iwin_help_using.txt')
	    id = widget_button(ihelp, $
	      value='Quick examples',uval='HELP iwin_help_ex.txt')
	    id = widget_button(ihelp, $
	      value='iwindow menu Scaling',uval='HELP iwin_help_scale.txt')
	    id = widget_button(ihelp, $
	      value='iwindow menu Options',uval='HELP iwin_help_opt.txt')
	    id = widget_button(ihelp, $
	      value='iwindow zoom',uval='HELP iwin_help_zoom.txt')
	    id = widget_button(ihelp, $
	      value='----------------------------')
	    id = widget_button(ihelp, $
	      value='iwindow built-in object help',uval='HELP_B')
	    id = widget_button(ihelp, $
	      value='Setting scaling by program', $
	      uval='HELP iwin_help_pscale.txt')
	    id = widget_button(ihelp, $
	      value='Known problems', $
	      uval='HELP iwin_help_problems.txt')
 
	  ;----  Set up magbub object  ------
	  obj_destroy, self.magbub
	  self.magbub = obj_new('magbub')
	  self.magbub->set,image=*self.p_img, mag=2
	endif
 
	widget_control, top, /real, set_uval=ptr_new(self) ; Put object in uval.
	widget_control, self.id_draw, get_val=win
	self.win= win
 
	;------  Display image  --------------------
	self->draw
 
	xmanager, 'iwindow', top, /no_block, cleanup='iwindow_cleanup'
 
	return, 1
	end
 
 
	;===========================================================
	;  iwindow object structure
	;===========================================================
 
	pro iwindow__define
 
	tmp = {iwindow, $
		p_img: ptr_new(), $	; Pointer to scaled image.
		p_raw: ptr_new(), $	; Pointer to raw image.
		nx: 0, $		; Size of image in x.
		ny: 0, $		; Size of image in y.
		bwsc: 0, $		; B&W scaling option.
		clsc: 0, $		; Color scaling option.
		true: 0, $		; Color interleave (0=bw).
		p_par: ptr_new(), $	; Scaling parameter structure.
		x_scr: 0, $		; Current window x size.
		y_scr: 0, $		; Current window y size.
		top: 0L, $		; Top level base widget ID.
		id_draw: 0L, $		; Draw widget ID.
		win:0, $		; Draw window index.
		new_x:0, $		; Requested new window x size.
		new_y:0, $		; Requested new window y size.
		flag:0, $		; Resize event processing flag.
		id_time:0L, $		; Timer widget ID.
		drag_mode: 0, $		; Image drag mode.
		drag_x: 0, $		; Last image drag x.
		drag_y: 0, $		; Last image drag y.
		drag_on: 0, $		; Drag mode on?
		magbub: obj_new(), $	; For magbubble object.
		magbub_crd: 0, $	; Magbub coords list off.
		dum:0 }
 
	end
