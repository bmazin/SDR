	;========================================================
	;  TO DO:
	;  Look into pxcm for procedure,'map_set', adjust
	;    as needed (shouldn't be needed).
	;  Deal with embedded scaling for plot and map_set.
	;  Add /NOFILL to MULTIPOLY method (just outline,
	;    see point.pro).
	;========================================================
 
	;========================================================
	;  img_aa__define.pro = Anti alias image object.
	;  Put antialiased graphics on an image using z buffer.
	;  X-Windows not used.
	;
	;  R. Sterner, 2006 Sep 22
	;  R. Sterner, 2006 Oct 03 --- Added /matchpos to plot.
	;  R. Sterner, 2006 Oct 03 --- Added list method.
	;  R. Sterner, 2006 Oct 09 --- Added debug method.
	;  R. Sterner, 2006 Oct 09 --- Added /clip to multipoly.
	;  R. Sterner, 2007 Apr 03 --- Added big method.
	;
	;  Methods:
	;  ------ External --------
	;  pro img_aa::help
	;  pro img_aa::debug
	;  pro img_aa::list
	;  pro img_aa::show
	;  pro img_aa::set, autoshow=ash
	;  pro img_aa::get, img
	;  pro img_aa::save
	;  pro img_aa::erase, [clr]
	;  pro img_aa::text, txt, x, y
	;  pro img_aa::procedure, name, p1,p2,p3,p4,p5,p6,p7,p8,p9
	;  pro img_aa::plotp, x, y, pen=p, color=clr0, error=err
	;  pro img_aa::multipoly, x, y
	;  pro img_aa::plot, [x], y, <plot keywords>'
	;
	;  ------ Internal --------
	;  pro img_aa::color, clr, c1, c2, c3, multi=multi, error=err
	;  pro img_aa::cleanup
        ;  function img_aa::init, img or xsize=xs,ysize=ys,...
	;
	;========================================================
 
        ;***********************************************************
        ;***********************************************************
        ;
        ;  External routines
        ;
        ;***********************************************************
        ;***********************************************************
 
        ;===========================================================
        ;  HELP = help
        ;===========================================================
	pro img_aa::help
 
	print,' Image Antialias object.  Add antialiased graphics to an image.'
	print,' Uses the Z-Buffer, not X-Windows unless image is displayed.'
	print,' '
	print,' To create an img_aa object:'
        print,"   a = obj_new('img_aa', img)"
	print,'     img = Color image to process.  in'
	print,'       If img is a plot or map with embedded scaling it is set.'
	print,'     Instead of img may give the keywords: xsize=xs,'
	print,'     ysize=xs,bgcolor=bclr, true=tr'
	print,'     to set up a working window.  The GET method will use tr.'
	print,'     /autoshow will display the results after each method call.'
	print,' '
	print,'   a->show'
	print,'   Display the current image.  Will average down the larger'
	print,'   internal copy, merge colors, and display on screen.'
	print,'   Allows same keywords as img_disp. Like MAG=mag, SMAG=smag,...'
	print,' '
	print,'   a->set, autoshow=ash'
	print,'   Set the autoshow flag to 0 or 1.  If set the image will'
	print,'   be automatically displayed after each method call.'
	print,' '
	print,'   a->erase, [clr]'
	print,'   Erase image to given color (def=white).'
	print,' '
	print,'   a->get, img2, [TRUE=tr]'
	print,'   Get resulting image.'
	print,'     img2 = Returned averaged down, merged image.'
	print,'     May specify TRUE, default is the original image value.'
	print,' '
	print,'   a->big, put=img_in, get=img_out'
	print,'   Get or Put internal large working image.'
	print,'     Use only one of get or put.  Get always uses true=3.'
	print,'     Make sure image is right size and shape for put.'
	print,' '
	print,'   a->debug'
	print,'   Stop inside object for debugging.'
	print,' '
	print,'   a->save, pngfile'
	print,'   Save image as a PNG image.'
	print,'     pngfile = Name of PNG file to save in.   in'
	print,' '
	print,'   a->plot, [x], y'
	print,'   Plot a graph on the image.'
	print,'     x,y = arrays to plot.  in'
	print,'     BGCOLOR=bclr Background color.'
	print,'     Plus most other keywords known by plot.'
	print,' '
	print,'   a->plotp, [x], y'
	print,'   Plot a curve on the image.  Almost like oplot but allows'
	print,'   a pen up/down code array.'
	print,'     x,y = arrays to plot.  in'
	print,'     PEN=pen Pen up (0)/down (1) code array.'
	print,'     Plus most other keywords known by oplot.'
	print,'     Allows color to be an array to make color vary'
	print,'     along the curve (or symbols).'
	print,' '
	print,'   a->text, txt, x, y'
	print,'   Plot text on the image.'
	print,'     txt = Text or array of text to plot.  in'
	print,'     x,y = text location(s).               in'
	print,'     Allows most keywords known by xyouts.'
	print,' '
	print,'   a->multipoly, x, y'
	print,'   Plot polygons on the image.'
	print,'     x, y = polygon center positions.  in'
	print,'     May work in /device, /data,or /normal coordinates.'
	print,'     All polygons are the same shape, given by'
	print,'     PX=px,PY=py polygon vertices relative to center.'
	print,'     Size and color is given for each polygon:'
	print,'     SIZE=sz, COLOR=clr.'
	print,'     An outline is given by OCOLOR=oclr, OTHICK=othk'
	print,'     (scalars) and is the same for each polygon.'
	print,' '
	print,'   a->procedure, name, p1, p2, ...'
	print,'   Apply a graphics command to the internal working image.'
	print,'     name = name of graphics procedure.'
	print,'     p1, p2, ... = whatever positional parameters needed.'
	print,'     Also give any needed keywords for the procedure.'
	print,'   Notes: The plot window for the Z-buffer differs by default.'
	print,'   To match an ordinary window, first make the plot in a'
	print,'   window of matching size.  Then get the position values'
	print,'   from !x.window and !y.window:'
	print,'   pos = [!x.window[0],!y.window[0],!x.window[1],!y.window[1]]'
	print,'   Also make sure to multiply device coordinates by 3 to match'
	print,'   internal working image (like calling polyfill with device'
	print,'   coordinate array. If giving charsize make sure to use a'
	print,'   floating value, like 1. and not just 1 as an integer.'
	print,' '
	return
	end
 
 
        ;===========================================================
	;  DEBUG = Do a debug stop
        ;===========================================================
	pro img_aa::debug
 
	print,' Do .con to continue:'
	stop,' Debug STOP in img_aa object.'
 
	end
 
 
        ;===========================================================
	;  LIST = List current status
        ;===========================================================
	pro img_aa::list
 
	print,' '
	print,' Current status:'
	if self.iflag eq 1 then print,'   Image loaded in window.' $
	  else print,'   Non-image Window.'
	print,'   Window size: '+strtrim(self.nx,2)+' x '+ $
	  strtrim(self.ny,2)
	if self.iflag eq 1 then print, $
	  '   Original image color interleave dimension: '+strtrim(self.tr,2)
	print,'   Internal working window size: '+strtrim(self.nx3,2)+' x '+ $
	  strtrim(self.ny3,2)
	print,'   Autoshow is turned '+(['off','on'])(self.autoshow)
	if self.lstcmd ne '' then print,'   Last command: '+self.lstcmd
 
	end
 
 
        ;===========================================================
	;  SHOW = Show current image
        ;===========================================================
	pro img_aa::show, _extra=extra
 
	self->get, img=img
	img_disp,/curr,img, _extra=extra
 
	end
 
 
        ;===========================================================
	;  SET = Set some control parameters
        ;===========================================================
	pro img_aa::set, autoshow=ash
 
	if n_elements(ash) ne 0 then self.autoshow=ash
 
	end
 
 
        ;===========================================================
	;  GET = Return final image
        ;===========================================================
	pro img_aa::get, img=img, true=tr, nx=nx, ny=ny
 
	if arg_present(img) then begin
	  rr = rebin(*self.rr,self.nx,self.ny)
	  gg = rebin(*self.gg,self.nx,self.ny)
	  bb = rebin(*self.bb,self.nx,self.ny)
	  if n_elements(tr) eq 0 then tr=self.tr
	  img = img_merge(rr,gg,bb,true=tr)
	endif
 
	nx = self.nx
	ny = self.ny
 
	end
 

        ;===========================================================
	;  BIG = Get or Put internal large copy of image
        ;===========================================================
	pro img_aa::big, get=img_out, put=img_in
 
	if arg_present(img_out) then begin
	  rr = *self.rr
	  gg = *self.gg
	  bb = *self.bb
	  img_out = img_merge(rr,gg,bb,true=3)
	endif

	if n_elements(img_in) ne 0 then begin
	  img_split, img_in, rr, gg, bb
	  self.rr = ptr_new(rr)
	  self.gg = ptr_new(gg)
	  self.bb = ptr_new(bb)
	endif

	end

 
        ;===========================================================
	;  SAVE = Save final image as a PNG image
        ;===========================================================
	pro img_aa::save, png
 
	if n_elements(png) eq 0 then begin
	  print,' Error in img_aa::save: Must give a PNG file name.'
	  return
	end
 
	self->get, img, true=1
	write_png,png,img
	self.lstcmd = 'save'
 
        print,' Image saved in PNG file '+png
 
	end
 
 
        ;===========================================================
	;  ERASE = Erase current image
        ;===========================================================
	pro img_aa::erase, clr0
 
	self->color, clr0, c1, c2, c3, error=err
	if err ne 0 then return
 
	;------  Replace color image components  ----
	(*self.rr)(*,*) = c1
	(*self.gg)(*,*) = c2
	(*self.bb)(*,*) = c3
	self.lstcmd = 'erase'
 
	if self.autoshow eq 1 then self->show
 
	end
 
        ;===========================================================
	;  TEXT = Do text on current image
        ;===========================================================
	pro img_aa::text, txt, x, y, color=clr0, error=err, $
	  device=dev, data=dat, normalized=nrm, charthick=cthk, $
	  charsize=csz, orientation=ang, $
	  align=align,  _extra=extra
 
	if n_params(0) lt 3 then begin
	  print,' Error in img_aa::text: Must give x,y,txt.'
	  return
	endif
 
	self->color, clr0, c1, c2, c3, error=err
	if err ne 0 then return
 
	;-------  Plot parameters  ------------------------
	if n_elements(csz) eq 0 then csz=!p.charsize
	if n_elements(cthk) eq 0 then cthk=!p.charthick
	if n_elements(ang) eq 0 then ang=0
	if n_elements(align) eq 0 then align=0.
 
	;------  Deal with coordinate system  ---------
	flag = 2
	if keyword_set(dev) then flag=1
	if keyword_set(nrm) then flag=3
 
	;---  Convert x,y to device: ix,iy  --------------
	zwindow,xs=self.nx,ys=self.ny	; Z buffer window.
	case flag of
1:	begin
	  ix = round(x)
	  iy = round(y)
	end
2:	begin
	  t = round(convert_coord(x,y,/data,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
3:	begin
	  t = round(convert_coord(x,y,/norm,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
	endcase
	zwindow,/close
 
	zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
	;-----------------------------------------------
	for i=0,n_elements(txt)-1 do begin
	  ix2 = (ix([i]))(0)
	  iy2 = (iy([i]))(0)
	  txt2 = (txt([i]))(0)
	  csz2 = (csz([i]))(0)
	  ang2 = (ang([i]))(0)
	  align2 = (align([i]))(0)
	  xyouts, /dev, 3*ix2,3*iy2,txt2, orient=ang2, $	; Plot on it.
	    color=255, charsize=csz2*3*0.75, align=align2, _extra=extra
	endfor
	;-----------------------------------------------
	t = tvrd()			; Read back plot.
	zwindow,/close			; Close z buffer window.
	if cthk lt 2 then t2=3 else t2 = 2*(cthk>1)+2
	thicken, t, 255, bold=t2	; Thicken plot.
	w = where(t ne 0, cnt)		; Find plotted pixels.
	if cnt eq 0 then return	; Null plot.
 
	;-----  Copy plot to color components  -----
	(*self.rr)(w) = c1
	(*self.gg)(w) = c2
	(*self.bb)(w) = c3
	self.lstcmd = 'text'
 
	if self.autoshow eq 1 then self->show
 
	end
 
 
        ;===========================================================
	;  PROCEDURE = Do call_procedure on image
        ;===========================================================
	;  Notes:
	;    Make sure to call with charsize=1. not 1, must be float.
        ;===========================================================
	pro img_aa::procedure, name, p1,p2,p3,p4,p5,p6,p7,p8,p9,$
	  _extra=extra, color=clr0, thick=thk0, matchpos=matchpos, $
	  noautoadjust=noautoadj
 
	n = n_params(0)-1
	if n lt 0 then return
 
	;--------  Deal with color  -------------- 
	self->color, clr0, c1, c2, c3, error=err, /multi
	if err ne 0 then return
 
	;-------  Plot parameters  ------------------------
	thk = !p.thick
	if n_elements(thk0) ne 0 then thk=thk0
 
	;---  Autoadjust certain values  -------
	;  Force certain values to be defined
	;  in case they are needed for position
	;  matching.
	;---------------------------------------
	if not keyword_set(noautoadj) then begin
	  if n_elements(extra) eq 0 then extra={dum:0}	; Force defined.
	  ;-----  MAP_SET  -------
	  if strupcase(strmid(name,0,7)) eq 'MAP_SET' then begin
	    ;---  Deal with CHARSIZE  ----
	    val = tag_value(extra,'charsize',minlen=5)
	    if val eq 0 then val=1
	    tag_add, extra, 'charsize',minlen=5, val
	  endif
	  ;-----  PLOT  ------
	  if strupcase(name) eq 'PLOT' then begin
	    ;---  Deal with CHARSIZE  ----
	    val = tag_value(extra,'charsize',minlen=5)
	    if val eq 0 then val=1
	    tag_add, extra, 'charsize',minlen=5, val
	    ;---  Deal with SYMSIZE  -----
	    val = tag_value(extra,'symsize',minlen=4)
	    if val eq 0 then val=1
	    tag_add, extra, 'symsize',minlen=4, val
	  endif
	endif
 
	;---  Match position to a normal window (needs X windows) ----
	if keyword_set(matchpos) then begin
	  self->get, nx=nx,ny=ny		; Window size.
	  window,/free,xs=nx,ys=ny,/pixmap	; Make a normal window.
	  ;---  Do graphics command  -----
	  case n of
0:	  call_procedure,name,_extra=extra
1:	  call_procedure,name,_extra=extra,p1
2:	  call_procedure,name,_extra=extra,p1,p2
3:	  call_procedure,name,_extra=extra,p1,p2,p3
4:	  call_procedure,name,_extra=extra,p1,p2,p3,p4
5:	  call_procedure,name,_extra=extra,p1,p2,p3,p4,p5
6:	  call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6
7:	  call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7
8:	  call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7,p8
9:	  call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7,p8,p9
else:
	  endcase
	  pos = [!x.window[0],!y.window[0],!x.window[1],!y.window[1]]
	  tag_add,extra,'POSITION',pos,minlen=3
	  wdelete				; Delete normal window.
	endif
 
	;---  Autoadjust certain values  -------
	;  Deal with values that need adjusted
	;  for larger size working window.
	;---------------------------------------
	if not keyword_set(noautoadj) then begin
	  ;-----  MAP_SET  -------
	  if strupcase(strmid(name,0,7)) eq 'MAP_SET' then begin
	    ;---  Deal with SCALE  ----
	    if tag_test(extra,'scale',minlen=2) then begin
	      val = tag_value(extra,'scale',minlen=2)
	      tag_add, extra,'scale',minlen=2,val/3./1.54	; zbuff: 1.54.
	    endif
	    ;---  Deal with CHARSIZE  ----
	    val = tag_value(extra,'charsize',minlen=5)
	    if val eq 0 then val=1
	    tag_add, extra, 'charsize',minlen=5, val*3.*0.75	; zbuff: 0.75.
	  endif
	  ;-----  PLOT  ------
	  if strupcase(name) eq 'PLOT' then begin
	    ;---  Deal with CHARSIZE  ----
	    val = tag_value(extra,'charsize',minlen=5)
	    if val eq 0 then val=1
	    tag_add, extra, 'charsize',minlen=5, val*3*0.75
	    ;---  Deal with SYMSIZE  -----
	    val = tag_value(extra,'symsize',minlen=4)
	    if val eq 0 then val=1
	    tag_add, extra, 'symsize',minlen=4, val*3*0.75
	  endif
	endif
 
	;---  Set z window  ----
	zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
	;---  Do graphics command  -----
	tag_add, extra, 'color',minlen=3,255 
	case n of
0:	call_procedure,name,_extra=extra;,col=255
1:	call_procedure,name,_extra=extra,p1;,col=255
2:	call_procedure,name,_extra=extra,p1,p2;,col=255
3:	call_procedure,name,_extra=extra,p1,p2,p3;,col=255
4:	call_procedure,name,_extra=extra,p1,p2,p3,p4;,col=255
5:	call_procedure,name,_extra=extra,p1,p2,p3,p4,p5;,col=255
6:	call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6;,col=255
7:	call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7;,col=255
8:	call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7,p8;,col=255
9:	call_procedure,name,_extra=extra,p1,p2,p3,p4,p5,p6,p7,p8,p9;,col=255
else:
	endcase
	t = tvrd()				; Read back plot.
	zwindow,/close			; Close z buffer window.
	;---  Thicken  ------	
	if thk lt 2 then t2=3 else t2 = 2*(thk>1)+2
	thicken,t,255,bold=t2,/quiet		; Thicken plot.
	w = where(t ne 0, cnt)		; Find plotted pixels.
	if cnt eq 0 then return		; Null plot.
	;-----  Copy plot to color components  -----
	(*self.rr)(w) = c1
	(*self.gg)(w) = c2
	(*self.bb)(w) = c3
	self.lstcmd = name
 
	if self.autoshow eq 1 then self->show
 
	end
 
 
        ;===========================================================
	;  PLOTP = Do plotp on image
        ;===========================================================
	pro img_aa::plotp, x0, y0, pen=p, color=clr0, error=err, $
	  device=dev, data=dat, normalized=nrm, linestyle=sty, thick=thk, $
	  psym=psym, symsize=symsz, clip=clip
 
	;--------  Deal with x,y  ----------------
	if n_elements(x0) eq 0 then begin
	  print,' Error in img_aa::plotp must give x and y to plot.'
	  err = 1
	  return
	endif
	if n_params(0) eq 1 then begin
	  y = x0
	  x = findgen(n_elements(y))
	endif else begin
	  x = x0
	  y = y0
	endelse
 
	;--------  Deal with color  -------------- 
	self->color, clr0, c1, c2, c3, error=err, /multi
	if err ne 0 then return
 
	;-------  Plot parameters  ------------------------
	if n_elements(sty) eq 0 then sty=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(psym) eq 0 then psym=0            ; Plot symbol.
	if n_elements(symsz) eq 0 then symsz=1          ; Symbol size.
 
	;------  Deal with coordinate system  ---------
	flag = 2				; Data.
	if keyword_set(dev) then flag=1		; Dev.
	if keyword_set(nrm) then flag=3		; Norm.
 
	;---  Convert x,y to device: ix,iy  --------------
	zwindow,xs=self.nx,ys=self.ny	; Z buffer window.
	case flag of
1:	begin			; Dev.
	  ix = round(x)
	  iy = round(y)
	end
2:	begin			; Data.
	  t = round(convert_coord(x,y,/data,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
3:	begin			; Norm.
	  t = round(convert_coord(x,y,/norm,/to_dev))
	  ix = reform(t(0,*))
	  iy = reform(t(1,*))
	end
	endcase
	zwindow,/close
 
	;---  Single color only ---
	if n_elements(clr0) eq 1 then begin
	  ;---  Do plotp  -----
	  zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
	  plotp, /dev, 3*ix,3*iy,p, $	; Plot on it.
	    color=255, linestyl=sty, thick=1, $
	    psym=psym, symsize=symsz*2.4, clip=clip
	  t = tvrd()			; Read back plot.
	  zwindow,/close			; Close z buffer window.
	  ;---  Thicken  ------	
	  if thk lt 2 then t2=3 else t2 = 2*(thk>1)+2
	  thicken,t,255,bold=t2,/quiet	; Thicken plot.
	  w = where(t ne 0, cnt)		; Find plotted pixels.
	  if cnt eq 0 then return		; Null plot.
 
	  ;-----  Copy plot to color components  -----
	  (*self.rr)(w) = c1
	  (*self.gg)(w) = c2
	  (*self.bb)(w) = c3
	endif else begin
	;---  Multicolor lines ---
	  ;-----  Get image color components  -----
	  r = *self.rr			; Red image component.
	  g = *self.gg			; Green image component.
	  b = *self.bb			; Blue image component.
 
	  zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
 
	  ;---  Do red ---
	  tv, r				; Load red.
	  plotp, /dev, 3*ix,3*iy,p, $	; Plot on it.
	    color=c1, linestyl=sty, thick=3*thk, $
	    psym=psym, symsize=symsz*2.4, clip=clip
	  r = tvrd()			; Read back.
 
	  ;---  Do green ---
	  tv, g				; Load green.
	  plotp, /dev, 3*ix,3*iy,p, $	; Plot on it.
	    color=c2, linestyl=sty, thick=3*thk, $
	    psym=psym, symsize=symsz*2.4, clip=clip
	  g = tvrd()			; Read back.
 
	  ;---  Do blue ---
	  tv, b				; Load blue.
	  plotp, /dev, 3*ix,3*iy,p, $	; Plot on it.
	    color=c3, linestyl=sty, thick=3*thk, $
	    psym=psym, symsize=symsz*2.4, clip=clip
	  b = tvrd()			; Read back.
	
	  zwindow,/close			; Close z buffer window.
 
	  ;------  Replace color image components  ----
	  (*self.rr)(0,0) = r
	  (*self.gg)(0,0) = g
	  (*self.bb)(0,0) = b
	endelse
	self.lstcmd = 'plotp'
 
	if self.autoshow eq 1 then self->show
 
	end
 
 
        ;===========================================================
	;  MULTIPOLY = Plot multiple polygons on image
	;  Polygons are all the same shape and have the same
	;  outline color and thickness but may vary in
	;  size and color.
	;    x, y = Polygon centers.  Centers may be given in
	;      /DEVICE (def), /DATA, or /NORMALIZED coordinates.
	;    px=px, py=py Polygon relative vertices (device only).
	;    These are pixels relative to the center.
	;    SIZE=sz Polygon scale factor (def=1).
	;    COLOR=clr Array of polygon colors (24-bit values).
	;    OCOLOR=oclr Outline color (all the same, def=black).
	;      If not given no outline will be done.
	;    OTHICK=othk Outline thickness (all the same, def=1).
	;    /CLIP means clip to plot window.
        ;===========================================================
	pro img_aa::multipoly, x, y, px=px, py=py, size=sz, $
	  color=clr0, ocolor=oclr, othick=othk, $
	  device=dev, data=dat, normalized=nrm, error=err, clip=clip
 
	;--------  Deal with x,y  ----------------
	if n_elements(x) eq 0 then begin
	  print,' Error in img_aa::multipoly must give x & y = polygon centers.'
	  err = 1
	  return
	endif
 
	;--------  Deal with color  -------------- 
	self->color, clr0, c1, c2, c3, /multi, error=err
	if err ne 0 then return
	clm = n_elements(c1)-1			; Color array limit.
	if n_elements(oclr) ne 0 then begin	; Outline color.
	  self->color, oclr, c1o, c2o, c3o, error=err
	endif
 
	;-------  Plot parameters  ------------------------
	if n_elements(px) eq 0 then begin
	  px = [-1.,1.,1.,-1.,-1.]
	  py = [-1.,-1.,1.,1.,-1.]
	endif
	if n_elements(sz) eq 0 then sz=1.
	if n_elements(othk) eq 0 then othk=1
	n = n_elements(x)
	px3 = 3*px
	py3 = 3*py
	slm = n_elements(sz)-1			; Size array limit.
 
	;------  Deal with coordinate system  ---------
	flag = 2
	if keyword_set(dev) then flag=1
	if keyword_set(nrm) then flag=3
 
	;---  Convert x,y to device: ix,iy  --------------
	zwindow,xs=self.nx,ys=self.ny	; Z buffer window.
	case flag of
1:	begin	; Device.
	  ix = 3*round(x)
	  iy = 3*round(y)
	end
2:	begin	; Data.
	  t = round(convert_coord(x,y,/data,/to_dev))
	  ix = 3*reform(t(0,*))
	  iy = 3*reform(t(1,*))
	end
3:	begin	; Normal.
	  t = round(convert_coord(x,y,/norm,/to_dev))
	  ix = 3*reform(t(0,*))
	  iy = 3*reform(t(1,*))
	end
	endcase
	zwindow,/close			; Close z buffer window.
 
	;-----  Deal with clipping window  ------
	if keyword_set(clip) then begin
	  t1 = round(!x.window*!d.x_size)	; Always in dev coordinates
	  t2 = round(!y.window*!d.y_size)	; for plotp and polyfill
	  c_win = 3*[t1(0),t2(0),t1(1),t2(1)]	; commands below.
	  extra = {clip:c_win, noclip:0}	; clip=c_win,noclip=0.
	endif else begin
	  extra = {dum:0}			; Ignored.
	endelse
 
	;-----  Get image color components  -----
	r = *self.rr			; Red image component.
	g = *self.gg			; Green image component.
	b = *self.bb			; Blue image component.
 
	zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
 
	;---  Do outline first  -----
	ocnt = 0			; Define.
	if n_elements(oclr) ne 0 then begin
	  for i=0,n-1 do begin		; Loop over polygons.
	    szi = sz(i<slm)		; Size of polygon i.
	    ppx = px3*szi		; Polygon i vertices.
	    ppy = py3*szi
	    polyfill,/dev,ix(i)+ppx,iy(i)+ppy,col=0,_extra=extra ; Erase inside.
	    plots,/dev,ix(i)+ppx,iy(i)+ppy,col=255,_extra=extra	 ; Outline.
	  endfor
	  t = tvrd()			; Read back.
	  ;---  Thicken  ------	
	  if othk lt 2 then t2=3 else t2 = 2*(othk>1)+2
	  thicken,t,255,bold=t2,/quiet	; Thicken plot.
	  w = where(t ne 0, ocnt)	; Find plotted pixels.
	endif else ocnt=0		; No outline.
 
	;---  Do red ---
	tv, r				; Load red.
	for i=0,n-1 do begin		; Loop over polygons.
	  szi = sz(i<slm)
	  ppx = px3*szi
	  ppy = py3*szi
	  polyfill, /dev, ix(i)+ppx, iy(i)+ppy, col=c1(i<clm),_extra=extra
	endfor
	r = tvrd()			; Read back.
	if ocnt gt 0 then r(w)=c1o else print,' No outline in bounds.'
 
	;---  Do green ---
	tv, g				; Load green.
	for i=0,n-1 do begin		; Loop over polygons.
	  szi = sz(i<slm)
	  ppx = px3*szi
	  ppy = py3*szi
	  polyfill, /dev, ix(i)+ppx, iy(i)+ppy, col=c2(i<clm),_extra=extra
	endfor
	g = tvrd()			; Read back.
	if ocnt gt 0 then g(w)=c2o else print,' No outline in bounds.'
 
	;---  Do blue ---
	tv, b				; Load blue.
	for i=0,n-1 do begin		; Loop over polygons.
	  szi = sz(i<slm)
	  ppx = px3*szi
	  ppy = py3*szi
	  polyfill, /dev, ix(i)+ppx, iy(i)+ppy, col=c3(i<clm),_extra=extra
	endfor
	b = tvrd()			; Read back.
	if ocnt gt 0 then b(w)=c3o else print,' No outline in bounds.'
	
	zwindow,/close			; Close z buffer window.
 
	;------  Replace color image components  ----
	(*self.rr)(0,0) = r
	(*self.gg)(0,0) = g
	(*self.bb)(0,0) = b
	self.lstcmd = 'multipoly'
 
	if self.autoshow eq 1 then self->show
 
	end
 
 
        ;===========================================================
	;  PLOT = Plot on image
        ;===========================================================
	pro img_aa::plot, x0, y0, color=clr0, error=err,help=hlp, $
	  device=dev, position=pos0, thick=thk0, charthick=cthk0, $
	  charsize=csz0, xthick=xthick, ythick=ythick,matchpos=matchpos,$
	  psym=psym0, symsize=symsiz0, linestyle=lsty, nodata=nodata, $
	  title=ttl, xtitle=xttl, ytitle=yttl, background=bck, _extra=extra
 
	;--------  Deal with x,y  ----------------
	if n_elements(x0) eq 0 then begin
	  print,' Error in img_aa::plot must give x,y or y to plot.'
	  err = 1
	  return
	endif
	if n_elements(y0) eq 0 then begin
	  y = x0
	  x = indgen(n_elements(y))
	endif else begin
	  x = x0
	  y = y0
	endelse
 
	;--------  Deal with color  -------------- 
	self->color, clr0, c1, c2, c3, error=err
	if err ne 0 then return
 
	;-------  Plot parameters  ------------------------
	csz = !p.charsize
	thk = !p.thick
	cthk = !p.charthick
	symsiz = !p.symsize
	psym = !p.psym
	if n_elements(csz0) ne 0 then csz=csz0
	if n_elements(thk0) ne 0 then thk=thk0
	if n_elements(cthk0) ne 0 then cthk=cthk0
	if n_elements(symsiz0) ne 0 then symsiz=symsiz0
	if n_elements(psym0) ne 0 then psym=psym0
	if csz eq 0 then csz=1.0
 
	;---  Match position to a normal window (needs X windows) ----
	if keyword_set(matchpos) then begin
	  self->get, nx=nx,ny=ny		; Window size.
	  window,/free,xs=nx,ys=ny,/pixmap	; Make a normal window.
	  ;---  Do graphics command  -----
	  plot,x,y,pos=pos,dev=dev,color=255,/nodata,chars=csz, $
	    title=ttl, xtitle=xttl, ytitle=yttl, _extra=extra
	  pos0 = [!x.window[0],!y.window[0],!x.window[1],!y.window[1]]
	  wdelete				; Delete normal window.
	endif
 
	;------  Deal with plot position  ---------
	if n_elements(pos0) ne 0 then begin
	  if keyword_set(dev) then begin
	    pos = pos0*3
	  endif else begin
	    pos = pos0
	  endelse
	endif
 
	;---  Erase to specified backgound color  -----
	if n_elements(bck) ne 0 then self->erase, bck
 
	;---  Do plot  -----------
	zwindow,xs=self.nx3,ys=self.ny3	; Z buffer window (3x bigger).
	;---  Do axes  -----------
	csz = csz*3*0.75
	;---  Axes only  ---------
	plot,x,y,pos=pos,dev=dev,color=255,xtickn=strarr(31)+' ', $
	  ytickn=strarr(31)+' ',/nodata,chars=csz,_extra=extra
	t1 = tvrd()			; Read back plot.
	athk = 1
	if keyword_set(xthick) then athk=xthick
	if keyword_set(ythick) then athk=ythick
	th1 = 3
	if athk ge 2 then th1=2*athk+2
	;---  Axes with tick labels  ---------
	plot,x,y,pos=pos,dev=dev,color=255,/nodata,chars=csz, $
	  title=ttl, xtitle=xttl, ytitle=yttl, _extra=extra
	t2 = tvrd()			; Read back plot.
	t2 = t2-t1			; Tick labels only.
	th2 = 3
	if cthk ge 2 then th2=2*cthk+2
	;----  Do curve  ----------
	if not keyword_set(nodata) then begin
	  erase
	  oplot,x,y,psym=psym,symsize=symsiz*2.4, linestyle=lsty
	  t3 = tvrd()
	  th3 = 3
	  if thk ge 2 then th3=2*thk+2
	endif
	zwindow,/close		; Close z buffer window.
	;-----  Thicken  -----------
	thicken, t1, 255, bold=th1	; Thicken axes.
	thicken, t2, 255, bold=th2	; Thicken tick labels.
	if not keyword_set(nodata) then begin
	  thicken, t3, 255, bold=th3	; Thicken curve.
	  t = t1>t2>t3
	endif else begin
	  t = t1>t2
	endelse
	w = where(t ne 0, cnt)	; Find plotted pixels.
	if cnt eq 0 then return	; Null plot.
 
	;-----  Copy plot to color components  -----
	(*self.rr)(w) = c1
	(*self.gg)(w) = c2
	(*self.bb)(w) = c3
	self.lstcmd = 'plot'
 
	if self.autoshow eq 1 then self->show
 
	end
 
 
        ;***********************************************************
        ;***********************************************************
        ;
        ;  Internal routines
        ;
        ;***********************************************************
        ;***********************************************************
 
        ;===========================================================
        ;  COLOR = Deal with a given color
	;  Give color as single 24-bit color value, a 3 element
	;  array: [r,g,b], or an array of 24-bit values with /multi.
	;  Returns color components of given colors:
	;    c1=red, c2=green, c3=blue.
        ;===========================================================
	pro img_aa::color, clr0, c1, c2, c3, multi=multi, error=err
 
	;-------  Deal with color  --------------
	if n_elements(clr0) eq 0 then clr0 = 16777215	; Default color.
	clr = clr0					; Copy color.
	c2rgb, ulong(clr)<16777215, c1,c2,c3
	clr = [c1,c2,c3]
	if not keyword_set(multi) then begin
	  if n_elements(clr) ne 3 then begin
	    print,' Error in img_aa:color Must give a 3 elements plot color'
	    print,'   array: [r,g,b], or a 24-bit color value.'
	    err = 1
	    return
	  endif
	endif
	mn = min(clr,max=mx)
	if (mn lt 0) or (mx gt 255) then begin
	  print,' Error in img_aa:color Color out of range (0-255).'
	  err = 1
	  return
	endif
	err = 0
 
	end
 
 
        ;===========================================================
        ;  CLEANUP = Cleanup routine for img_aa object
        ;===========================================================
	pro img_aa::cleanup
	ptr_free, self.rr, self.gg, self.bb
	end
 
	;===========================================================
        ;  INIT = set up initial values
	;
	;  Will init to a 640 x 512 window erased to white, or
	;  may give an image to load instead.
        ;===========================================================
        function img_aa::init, img, xsize=nx, ysize=ny, $
	  bgcolor=bclr, true=tr, autoshow=ash
 
	;-------  Load given image  ------------
	if n_elements(img) gt 0 then begin
	  self.iflag = 1
	  img_split, img, rr, gg, bb, true=tr, nx=nx, ny=ny
	  nx3 = 3*nx
	  ny3 = 3*ny
	  self.rr = ptr_new(rebin(rr,nx3,ny3,/samp))
	  self.gg = ptr_new(rebin(gg,nx3,ny3,/samp))
	  self.bb = ptr_new(rebin(bb,nx3,ny3,/samp))
	  self.nx = nx
	  self.ny = ny
	  self.tr = tr
	  self.nx3 = nx3
	  self.ny3 = ny3
	  ;---  Try to set any embedded scaling  ---
	  zwindow,xs=nx3,ys=ny3
	  img0 = img_subimg(img,0,0,200,2)      ; Part of 1st two lines.
	  set_scale, image=img0, /quiet, mag=3  ; Set scale.
	  img_split, img0, r,g,b,nx=nx	        ; Want blue channel.
	  if nx ge 160 then begin
	    info = b(0:159,0)		        ; Grab info if there.
	    map_set_scale,info=info,col=0,mag=3 ; Try to set map scale from b.
	  endif
	  zwindow,/close
	;-------  Set up a window  -------
	endif else begin
	  self.iflag = 0
	  if n_elements(nx) eq 0 then nx=640
	  if n_elements(ny) eq 0 then ny=512
	  if n_elements(bclr) eq 0 then bclr=16777215
	  if n_elements(tr) eq 0 then tr=3
	  nx3 = 3*nx
	  ny3 = 3*ny
	  self.nx = nx
	  self.ny = ny
	  self.tr = tr
	  self.nx3 = nx3
	  self.ny3 = ny3
	  c2rgb,bclr,c1,c2,c3
	  self.rr = ptr_new(bytarr(nx3,ny3)+c1)
	  self.gg = ptr_new(bytarr(nx3,ny3)+c2)
	  self.bb = ptr_new(bytarr(nx3,ny3)+c3)
	endelse
 
	if n_elements(ash) ne 0 then self.autoshow=ash
 
	return, 1
 
	end
 
 
	;========================================================
	;  img_aa object structure
	;========================================================
	pro img_aa__define
 
	tmp = {img_aa,        $
		iflag:0,      $ ; Image flag: 1=image was loaded, 0=not.
		lstcmd:'',    $ ; Last command.
		rr:ptr_new(), $ ; Pointer to 3X red image component.
		gg:ptr_new(), $ ; Pointer to 3X green image component.
		bb:ptr_new(), $ ; Pointer to 3X blue image component.
		nx:0L,        $ ; Original image X size.
		ny:0L,        $ ; Original image Y size.
		tr:0,         $ ; Original image true.
		nx3:0L,       $ ; 3x image X size.
		ny3:0L,       $ ; 3x image Y size.
		autoshow:0,   $ ; Automatically show results? 1=yes.
		dum:0 }
 
	end
