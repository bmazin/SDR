;==============================================================================
;  magbub object = Bubble magnifier
;
;  R. Sterner, 2003 Jul 16
;  R. Sterner, 2003 Sep 24 --- Fixed to work for B&W.
;
;  Methods:
;
;  ===  External  ===
;  pro magbub::magup
;  pro magbub::magdown
;  pro magbub::show, x0, y0, restore=res
;  pro magbub::adjsize
;  pro magbub::help
;  pro magbub::list
;  pro magbub::set, image=img, mag=mag, width=wid, frac=fr, $
;
;  ===  Internal  ===
;  function magbub::radial, rr, t
;  pro magbub::indices
;  pro magbub::cleanup
;  function magbub::init
;
;==============================================================================
 
	;***********************************************************
	;***********************************************************
	;
	;  External routines
	;
	;***********************************************************
	;***********************************************************
 
	;========================================================
	;  MAGUP = Increase mag factor.
	;========================================================
	pro magbub::magup
	self.mag = fix((self.mag*1.5)<25)
	self->indices
	end
 
	;========================================================
	;  MAGDOWN = Decrease mag factor.
	;========================================================
	pro magbub::magdown
	self.mag = fix((self.mag/1.5)>2)
	self->indices
	end
 
	;========================================================
	;  SHOW = Show image mag bubble
	;  x,y = cursor position
	;  /restore restore original image (x,y not needed).
	;========================================================
 
	pro magbub::show, x0, y0, restore=res
 
	;------  Restore saved subarea  ----
	if keyword_set(res) then begin
	  if ptr_valid(self.p_save) then begin
	    win_redirect
	    tv, true=self.true, *self.p_save, self.subx, self.suby
	    win_copy
	  endif
	  device, /cursor_crosshair
	  self.crs_state = 1
	  return
	endif
 
	;----  Make sure cursor is not shown  ----------
	if self.crs_state eq 1 then begin
	  cmsk = intarr(16)
	  device, cursor_image=cmsk, cursor_mask=cmsk
	  self.crs_state = 0
	endif
 
	;----  Offset from area center to LL corner  -----
	x = round(x0 - self.width2-1)
	y = round(y0 - self.width2-1)
 
	;-------  Find inbounds coordinates  -----------
	dx = self.width
	dy = self.width
	lx = self.lx
	ly = self.ly
	x1 = x>0<lx			; Keep actual subarea corner in bounds.
	y1 = y>0<ly
	dxc = dx<(lx-x1+1)<(x+dx)	; Keep actual subarea size in bounds.
	dyc = dy<(ly-y1+1)<(y+dy)
 
	;-------  Subarea outside image (should not happen) ------
	if dxc le 0 then return
	if dyc le 0 then return
 
	;-------  Grab subarea from image  ----------
	t = img_subimg(*self.p_img,x1,y1,dxc,dyc)
 
	;-------  Grab indexing array subareas  ------
	ix = -(0<x)
	iy = -(0<y)
	ixx2 = img_subimg(*self.p_ixx,ix,iy,dxc,dyc)-ix
	iyy2 = img_subimg(*self.p_iyy,ix,iy,dxc,dyc)-iy
	if self.true eq 3 then $
	  izz2 = img_subimg(*self.p_izz,ix,iy,dxc,dyc)
 
	;------  Remap subarea  ------------
	if self.true eq 3 then begin
	  t2 = t(ixx2,iyy2,izz2)
	endif else begin
	  t2 = t(ixx2,iyy2)
	endelse
 
	;------  Highlight central pixel  ------
	if self.crds_flag then begin
	  lox = (self.width2 - ix)>0
	  hix = (lox + self.mag)<(dxc-1)
	  loy = (self.width2 - iy)>0
	  hiy = (loy + self.mag)<(dyc-1)
	  lox1 = (lox+1)<(dxc-1)
	  loy1 = (loy+1)<(dyc-1)
	  hix1 = (hix-1)>lox1
	  hiy1 = (hiy-1)>loy1
	  t2(lox:hix,loy,*) = 0
	    t2(lox1:hix1,loy1,*) = 255
	  t2(lox:hix,hiy,*) = 0
	    t2(lox1:hix1,hiy1,*) = 255
	  t2(lox,loy:hiy,*) = 0
	    t2(lox1,loy1:hiy1,*) = 255
	  t2(hix,loy:hiy,*) = 0
	    t2(hix1,loy1:hiy1,*) = 255
	endif
 
	;------  Restore saved subarea  ----
	win_redirect
	;-------  Sub area to restore  --------
	if ptr_valid(self.p_save) then begin
	  tv, true=self.true, *self.p_save, self.subx, self.suby
	;-------  First time, init image  -------
	endif else begin
	  tv, true=self.true, *self.p_img
	endelse
	ptr_free, self.p_save
	self.p_save = ptr_new(t)
	self.subx = x1
	self.suby = y1
 
	;------  Display remapped subarea  -----
	tv, true=self.true, t2, x1, y1
 
	;------  Cursor coordinates  -----------
	if self.crds_flag then begin
	  if x0 lt self.nx/2 then begin
	    algn = -0.05
	    xoff = self.mag
	  endif else begin
	    algn = 1.05
	    xoff = 0
	  endelse
	  if y0 lt self.ny/2 then yoff=10 else yoff=-15
	  if self.order eq 1 then y02=(!d.y_size-1)-y0 $  ; Reverse Y.
	    else y02=y0
	  txt = strtrim(x0,2)+' '+strtrim(y02,2)
	  blk = 0
	  wht = tarclr(255,255,255)
	  xyoutb,/dev,x0+xoff,y0+yoff,txt,chars=self.chars,align=algn, $
	    bold=self.bold,col=[blk,wht]
	endif
 
	win_copy
 
	end
 
 
	;========================================================
	;  adjsize = Adjust size interactively.
	;========================================================
 
	pro magbub::adjsize, ix0=ix, iy0=iy
 
	r = [1.,self.frac]*self.width2
	if n_elements(ix) eq 0 then ix=!d.x_size/2
	if n_elements(iy) eq 0 then iy=!d.y_size/2
	wshow
	xadjcirc,r,ix0=ix,iy0=iy
	frac = float(min(r))/max(r)
	width = 2*max(r)
	csz = ((width/300.)*2)<2>0.5
	self->set, width=width, frac=frac, chars=csz
 
	end
 
 
	;========================================================
	;  HELP = Help on methods
	;========================================================
 
	pro magbub::help, out=txt
 
	tprint,/init
	tprint,' '
	tprint,' Magbubble object.  Displays a magnified area of an image.'
	tprint,' '
	tprint,' To create a Magbubble object:'
	tprint,"   b = obj_new('magbub')"
	tprint,' '
	tprint,' Setup:'
	tprint,'   b->set, image=img  ; Set working image'
	tprint,'     mag=mag          ; Set initial mag factor (def=5)'
	tprint,'     width=wid        ; Set mag area width (def=240)'
	tprint,'     frac=fr          ; Set full mag fraction (def=0.7)'
	tprint,'     smooth=sm        ; Set smoothing for transition (def=21)'
	tprint,'     window=win       ; Set working window (def=current)'
	tprint,'     /COORDINATES     ; Display cursor coordinates'
	tprint,'     /ORDER           ; Set image origin to top left (def=LL)'
	tprint,'     charsize=csz     ; Set character size for coords (def=1.6)'
	tprint,' '
	tprint,' Show magnified image area:'
	tprint,'   b->show, x0, y0    ; Show image area centered at x0,y0'
	tprint,'   b->show, /restore  ; Show original image (erase mag bubble)'
	tprint,' '
	tprint,' Change magnification:'
	tprint,'   b->magup           ; Increase magnification'
	tprint,'   b->magdown         ; Decrease magnification'
	tprint,' '
	tprint,' Interactively adjust magnified area size:'
	tprint,'   b->adjsize         ; Drag inner and outer parts of area'
	tprint,' '
	tprint,' List settings:'
	tprint,'   b->list            ; List internal values and settings'
	tprint,' '
	tprint,' Help:'
	tprint,'   b->help, [out=txt] ; Display (and return) this help text.'
	tprint,/print,out=txt
	
	end
 
 
 
	;========================================================
	;  LIST = List internal values
	;========================================================
 
	pro magbub::list
 
	print,' '
	print,' Mag factor = ',self.mag
	print,' Mag area width = ',self.width
	print,' Mag area fraction = ',self.frac
	print,' Mag bubble smoothing = ',self.sm
	print,' Show center coordinates? '+(['No','Yes'])(self.crds_flag)
	print,' Order = ',self.order
	print,' Charsize = ',self.chars
	print,' Bold = ',self.bold
	print,' '
	if self.win lt 0 then begin
	  print,' No window specified.'
	endif else begin
	  print,' Window = ',self.win
	  print,' '
	endelse
	if ptr_valid(self.p_img) then begin
	  print,' Image true = ',self.true
	  print,' Image size: nx, ny = ',self.nx, self.ny
	endif else begin
	  print,' No image set.'
	endelse
 
	end
 
 
	;========================================================
	;  SET = magbub set routine.
	;========================================================
 
	pro magbub::set, image=img, mag=mag, width=wid, frac=fr, $
	  smooth=sm, window=win, coordinates=crds, order=order, $
	  charsize=csz
 
	;-----  Charsize  -----------------
	if n_elements(csz) ne 0 then begin
	  self.chars = csz
	  if csz lt 1.5 then self.bold=[2,1] else self.bold=[4,2]
	endif
 
	;-----  Order  -----------------
	if n_elements(order) ne 0 then self.order=order
 
	;-----  Coordinate listing  ----
	if n_elements(crds) ne 0 then self.crds_flag=crds
 
	;-----  Window -----------------
	if n_elements(win) ne 0 then self.win=win
 
	flag = 0	; Need new indexing arrays?
 
	;-----  New image  -------------
	if n_elements(img) ne 0 then begin
	  ptr_free,self.p_img, self.p_save		; Free image pointer.
	  img_shape, img, nx=nx, ny=ny, true=true	; Image info.
	  if (true gt 0) and (true ne 3) then begin	; New image pointer.
	    self.p_img = ptr_new(img_redim(img,true=3))	; Make true=3.
	    true = 3
	  endif else begin
	    self.p_img = ptr_new(img)			; true was 3 or 0.
	  endelse
	  self.nx = nx
	  self.ny = ny
	  self.lx = nx-1
	  self.ly = ny-1
	  if true ne self.true then begin
	    self.true = true
	    flag = 1
	  endif
	endif
 
	;-------  Mag factor --------------
	if n_elements(mag) ne 0 then begin
	  if mag ne self.mag then begin
	    self.mag = mag
	    flag = 1
	  endif
	endif
 
	;-------  Mag area width --------------
	if n_elements(wid) ne 0 then begin
	  if wid ne self.width then begin
	    self.width = wid
	    self.width2 = (wid-1)/2
	    flag = 1
	  endif
	endif
 
	;-------  Mag area frac --------------
	if n_elements(fr) ne 0 then begin
	  if fr ne self.frac then begin
	    self.frac = fr
	    flag = 1
	  endif
	endif
 
	;-------  Smoothing --------------
	if n_elements(sm) ne 0 then begin
	  if sm ne self.sm then begin
	    self.sm = sm
	    flag = 1
	  endif
	endif
 
	;-------  New indexing arrays  ----------
	if flag then self->indices
 
	end
 
 
	;***********************************************************
	;***********************************************************
	;
	;  Internal routines
	;
	;***********************************************************
	;***********************************************************
 
	;========================================================
	;  RADIAL = Compute radial remapping.
	;========================================================
	function magbub::radial, rr, t
 
	mx = max(rr)/sqrt(2)	; Max working radius (to edge of square).
 
	w1 = where(rr le t,cnt1)			; Inside T.
	w2 = where((rr gt t) and (rr lt mx),cnt2)	; From T to edge.
 
	rr2 = rr
	if cnt1 gt 0 then rr2(w1)=rr(w1)/self.mag	; Central magged area.
	if cnt2 gt 0 then rr2(w2)= $			; Transition.
	  (rr(w2)-t)*(mx-t/self.mag)/(mx-t)+t/self.mag
 
	if self.sm ne 0 then begin
	  w = where((rr lt mx) and (rr gt t/2))
	  rs = smooth(rr2,self.sm)
	  rr2(w) = rs(w)
	endif
 
	return, rr2
 
	end
 
 
	;========================================================
	;  INDICES = Compute indexing arrays.
	;========================================================
	pro magbub::indices
 
;print,' Computing new indices ...'
;
	;-------  2-d arrays, no remapping  -----
	n = self.width				; Mag area width.
	self.width2 = (n-1)/2			; Half width.
	s = (n-1.)/2.				; Limits.
	t = self.frac*s				; Mag zone radius (pixels).
	makenxy,-s,s,n,-s,s,n,xx,yy		; Raw 2-d indexing arrays.
	recpol,xx,yy,rr,aa			; Convert to polar.
 
	;-------  2-d arrays, remapped  ---------
	rr2 = self->radial(rr,t)  		; Remap radial.
	polrec,rr2,aa,xx2,yy2			; Remapped back to rect.
 
	;-----  3-D arrays for color  -------
	if self.true gt 0 then begin
	  xx2 = rebin(xx2,n,n,3)		; Convert to 3-d.
	  yy2 = rebin(yy2,n,n,3)
	  z = fltarr(1,1,3)+findgen(3)		; Generate z indexing.
	  zz2 = rebin(z,n,n,3)
	  izz = round(zz2)
	  ptr_free, self.p_izz			; Free pointer to old z index.
	  self.p_izz = ptr_new(izz)		; Pointer to new.
	endif
 
	;-----  Rounded indices  ------------
	ixx = round(xx2+s)			; Nearest neighbor.
	iyy = round(yy2+s)
	ptr_free, self.p_ixx, self.p_iyy	; Old pointers.
	self.p_ixx = ptr_new(ixx)		; New pointers.
	self.p_iyy = ptr_new(iyy)
 
	end
 
 
	;========================================================
	;  CLEANUP = Cleanup when terminating.
	;========================================================
	pro magbub::cleanup
	ptr_free, self.p_img, self.p_ixx, self.p_iyy, $
	  self.p_izz, self.p_save
	end
 
	;========================================================
	;  INIT = set up initial values
	;========================================================
	function magbub::init
 
	self.mag = 5
	self.width = 240
	self.width2 = (self.width-1)/2
	self.frac = 0.7
	self.sm = 21
	self.win = -1
	self.crs_state = 1
	self.chars = 1.6
	self.bold = [4,2]
	window,xs=50,ys=50,/free,/pixmap
	device, /cursor_crosshair	; Forces a window.
	wdelete
	self->indices
 
	return, 1
	end
 
	;========================================================
	;  magbub object structure
	;========================================================
 
	pro magbub__define
 
	tmp = {magbub, $
		p_img: ptr_new(), $	; Pointer to image.
		nx: 0, $		; Size of image in x.
		ny: 0, $		; Size of image in y.
		lx: 0, $		; Last image x.
		ly: 0, $		; Last image y.
		true: 0, $              ; Image type (0=bw, 3=color).
		mag: 0, $		; Mag factor (2-25).
		width: 0, $		; Mag area width (pixels).
		width2: 0, $		; Mag area half width (pixels).
		frac: 0.0, $		; Mag area fraction (0.-1.).
		sm: 0, $		; Smoothing size.
		p_ixx: ptr_new(), $	; Pointer to x indexing array.
		p_iyy: ptr_new(), $	; Pointer to y indexing array.
		p_izz: ptr_new(), $	; Pointer to z indexing array.
		win: 0, $		; Display window index.
		p_save: ptr_new(), $	; Pointer to saved subarea.
		subx: 0, $		; Saved subarea x.
		suby: 0, $		; Saved subarea y.
		crds_flag: 0, $		; Cursor coordinate list flag.
		chars: 0., $		; Coordinates charsize.
		bold: [0,0], $		; Bold text thick array.
		crs_state:0, $		; Cursor state (0=off, 1=on).
		order: 0, $		; Image origin: 0=bottom, 1=top.
		dum:0 }
 
	end
