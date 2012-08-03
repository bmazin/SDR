;-------------------------------------------------------------
;+
; NAME:
;       XMERGE
; PURPOSE:
;       Widget based routine to merge multiple color images in one.
; CATEGORY:
; CALLING SEQUENCE:
;       xmerge
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DIRECTORY=dir  optional initial directory (def=current).
;         /DEBUG  means add a few debug buttons.
; OUTPUTS:
; COMMON BLOCKS:
;       xmerge_event_com
; NOTES:
;       Notes: Click on HELP button for details.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Mar 14
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
;===================================================================
;	Table of routines
;	Explanation of coordinate systems used.
;	pro xmer_gen = Genrate final combined image.
;	pro xmer_tv = tv command that handles transparent background.
;	pro xmer_bkg = Set overall background color.
;	pro xmer_rdimg = Read an image.
;	pro xmer_add = Add an image to list.
;	pro xmer_restore = Restore an *.mer file.
;	pro xmer_rescale = Rescale a displayed image.
;	pro xmer_maxscale = Compute max scale factor allowed.
;	pro xmer_boxes = Slider bar scaling: outline images.
;	pro xmer_update = Update screen.
;	pro xmer_imageorder = Rearrange image order.
;	function xmer_findi = Find which image was selected by cursor.
;	pro xmer_count = display image count in widget window.
;	pro xmer_image = Interactively position an image.
;	pro xmer_window = Create or recreate a layout window.
;	pro xmerge_event = Event handler for xmerge.
;	pro xmerge.pro = Widget based image merge routine (main).
;===================================================================
 
;===================================================================
;	pro xmer_gen = Generate final combined image.
;	1995 Mar 23
;===================================================================
 
	pro xmer_gen, m
 
	if m.pcnt le 1 then begin
	  bell
	  print,' Nothing to merge.'
	  return
	endif
 
	print,' Generating merged image . . .'
 
	;-------  Find combined image size for scale 1.00  ------------
	widget_control, m.id_siz, get_val=val         ;---  Size.
        t = strupcase(strmid(val,0,1))
	if t eq 'L' then begin
	  bx0 = 2000
	  by0 = 2000
	endif else begin
          t = 'L'                                     ;---  Rotation.
          widget_control, m.id_rot, get_val=val
          if strupcase(strmid(val,0,1)) eq 'P' then t = 'P'
	  if t eq 'L' then begin
	    bx0 = 2000
	    by0 = 1500
	  endif else begin
	    bx0 = 1500
	    by0 = 2000
	  endelse
	endelse
 
	;--------  Find actual scale factor and correct size  -----------
	widget_control, m.id_xytxt, get_val=scale     ;---  Scale.
        scale = scale(0)+0.
;	bx = round(bx0/scale)
;	by = round(by0/scale)
	bx = bx0/scale
	by = by0/scale
 
	;---------  Setup R,G,B component background  -----------
	bigr = bytarr(bx,by) + m.rbk
	bigg = bytarr(bx,by) + m.gbk
	bigb = bytarr(bx,by) + m.bbk
 
	;---------  Loop through images  -------------------------
	for i=0, m.pcnt-1 do begin
	  print,' '+m.pname(i)+': '+strtrim(i+1,2)+' of '+ $
	    strtrim(m.pcnt,2)+' . . .'
	  xmer_rdimg,m.pname(i),m.ptyp(i),a,r,g,b,err=err  ; Read image.
	  if err ne 0 then goto, skip
	  sz=size(a) & nxa=sz(1) & nya=sz(2)		; Image size.
	  ix1=m.px0(i) & iy1=m.py0(i)			; LL image corner.
	  ix2=ix1+nxa-1 & iy2=iy1+nya-1			; UR image corner.
	  ar = r(a)					; Image R,G,B.
	  ag = g(a)
	  ab = b(a)
	  if m.trans(i) ge 0 then begin			; Trans back?
	    wtb = where(a eq m.trans(i), ctr)		; Yes, where?
	    if ctr gt 0 then begin			; Image has some bkg.
	      bk = bigr(ix1:ix2,iy1:iy2)		; Copy red background.
	      ar(wtb) = bk(wtb)
	      bk = bigg(ix1:ix2,iy1:iy2)		; Copy green background.
	      ag(wtb) = bk(wtb)
	      bk = bigb(ix1:ix2,iy1:iy2)		; Copy blue background.
	      ab(wtb) = bk(wtb)
	    endif
	  endif
	  bigr(ix1,iy1) = ar				; Insert image R,G,B
	  bigg(ix1,iy1) = ag				;   components into
	  bigb(ix1,iy1) = ab				;   combined image.
skip:
	endfor
 
	print,' Merging color components . . .'
	img = bytarr(bx,by,3)
	img(0,0,0) = bigr
        img(0,0,1) = bigg
        img(0,0,2) = bigb
	write_jpeg,'temp.jpg',img,true=3,quality=100    ; Save in jpeg file.
	read_jpeg, 'temp.jpg',c,cc,colors=250,/dither,/two_pass
 
	print,' Displaying result . . .'
	if (bx gt 1000) or (by gt 900) then begin
	  swindow, xs=bx, ys=by
	endif else begin
	  window, xs=bx, ys=by
	endelse
	tvlct,cc
	tv,c
 
	m.genwin = !d.window		; Remember generate window.
	widget_control, m.top, set_uval=m
 
	return
	end
 
 
;===================================================================
;	pro xmer_tv = TV comand that handles transparent background.
;	1995 Mar 17
;===================================================================
 
	pro xmer_tv, img, x, y, trans=indx	; indx=array of backgr pixels.
 
	sz = size(img)			; Size of image.
	nx = sz(1)
	ny = sz(2)
	
	if indx(0) ne -1 then begin	; Do transparent background.
	  back = tvrd(x,y,nx,ny)	; Read behind image.
	  img(indx)=back(indx)		; Move backgrnd into img.
	endif
 
	tv,img,x,y			; Now display image.
 
	return
	end
 
;===================================================================
;	pro xmer_bkg = Set overall background color.
;	1995 Mar 16
;===================================================================
 
	pro xmer_bkg, m, rgb=rgb, hsv=hsv
 
	xhelp, /wait, $
	 ['The selected background color may change slightly', $
	  'when the Done button is pressed.  This', $
	  'happens because the closest color in the',$
	  'working directory is used.  The actual',$
	  'color selected will be used for the final',$
	  'combined image.']
 
	tvlct, r, g, b, /get		; Original color table.
	in = m.bk			; Index of background.
 
	;-------  Set background  -----------
	if keyword_set(rgb) then xced1,in,/wait,exit=ex
	if keyword_set(hsv) then xced1,in,/hsv,/wait,exit=ex
 
	if ex eq 1 then return			; No change.
 
	tvlct,r2,g2,b2,/get			; Get new color.
	r2=r2(in) & g2=g2(in) & b2=b2(in)	; Pick off color in.
	m.rbk=r2 & m.gbk=g2 & m.bbk=b2	; Save selected background colors.
 
	;------  Find closest color in working color table  -----
	d = long(r-r2)^2 + long(g-g2)^2 + long(b-b2)^2
	w =where(d eq min(d))
	m.bk = w(0)
 
	widget_control, m.top, set_uval=m	; Save updated map.
 
	xmer_update, m				; Update screen.
 
	return
	end
 
 
;===================================================================
;	pro xmer_rdimg = Read an image.
;	1995 Mar 15
;===================================================================
 
	pro xmer_rdimg, f, typ, a, r, g, b, error=err	; file,typ,img,r,g,b.
 
	err = 0
	f2 = findfile(f, count=cnt)
	if cnt eq 0 then begin
	  bell
	  err = 1
	  print,' Could not read image '+f
	  print,'    Ignoring this image.'
	  return
	endif
 
	case typ of
'TIF':	begin
          a = tiff_read(f,r,g,b,order=order)	; Read image.
          if order eq 1 then a=reverse(a,2)	; Needs reversed.
	  if n_elements(r) eq 0 then begin	; Default to BW.
	    r = indgen(256)
	    g = r
	    b = r
	  endif
	end
'GIF':	read_gif, f, a, r, g, b
'JPG':	begin
	  read_jpeg, f, a, ct, colors=!d.table_size-1, /dither, /two_pass
	  r = ct(*,0)
	  g = ct(*,1)
	  b = ct(*,2)
	end
	endcase
 
	return
	end
 
;===================================================================
;	pro xmer_add = Add an image to list.
;	1994 Sep 20
;===================================================================
 
	pro xmer_add, tin, m, type=typ, trans=tr ; tin=input txt, m=map strct.
 
	f = getwrd(tin)				; Pick off file name.
	if n_elements(tr) eq 0 then tr=getwrd(tin,3)	; Transparent index.
	if n_elements(typ) eq 0 then typ=getwrd(tin,4)	; Image type.
 
	xmer_rdimg, f, typ, a, r, g, b, err=err	; Read in image.
	if err ne 0 then return
 
        widget_control, m.id_xytxt, get_val=sf	; Get slider bar scale.
	mag = sf(0)+0.0				; Mag factor.
        sf = sf(0)*800./2000.			; Overall scale factor.
        sz = size(a)				; Current image size.
        dx = round(sz(1)*sf)			; New image size.
        dy = round(sz(2)*sf)
        a = congrid(a,dx,dy)			; Resize image.
        rr = r(a)
        gg = g(a)
        bb = b(a)
	wtb = -1		; Assume no transparent background.
	if tr ge 0 then wtb=where(a eq tr)	; Find indices of given bkgr.
        c = color_quan(rr,gg,bb,r,g,b,cube=m.cube)
	x0 = getwrd(tin,1)			; Pick off possible position.
	y0 = getwrd(tin,2)
	;---------  This section finds screen position (x,y)  -----
	;---------  Interactive image position  ----------
	if x0 eq '' then begin			; Interactive position.
          m.add_mode = 1
          x = 10
          y = 10
          xmer_image, x, y, dx, dy, m
	;---------  Image position from *.mer file  -------------
	endif else begin			; From mer file.
	  x = round(sf*x0)			; Screen X.
	  y = round(sf*y0)			; Screen Y.
	endelse
	;----------------------------------------------------------
        m.pcnt = m.pcnt + 1   ; Number of images.
        in = m.pcnt-1         ; Index into image table.
        m.px(in) = x          ; Displayed image position.
        m.py(in) = y
        m.px0(in) = fix(x/sf) ; Full page coordinates of image.
        m.py0(in) = fix(y/sf)
        m.pdx(in) = dx        ; Displayed image size.
        m.pdy(in) = dy
        m.pdx0(in) = sz(1)    ; Original image size.
        m.pdy0(in) = sz(2)
        m.pname(in) = f       ; Actual image name.
	m.ptyp(in) = typ      ; Image type (GIF, TIF, JPG).
	m.trans(in) = tr      ; Transparent index.
        name = strtrim(in,2)+'.tmp'
        resopen,name,/write
        resput,'img',c
	resput,'back',wtb	; Save backgr indices.
        resclose
        m.pres(in) = name     ; Displayed image name.
        widget_control, m.top, set_uval=m
        xmer_count, m
        xmer_tv,c,x,y, trans=wtb
        xmer_maxscale, m
 
	return
	end
 
 
;===================================================================
;	pro xmer_restore = Restore an *.mer file.
;	1994 Sep 12
;===================================================================
 
	pro xmer_restore, file, m
 
	;------  Read *.mer file  ------------
	txt = getfile(file)				; Read mer file.
	txt = txt(where(strlen(txt) gt 1))		; Drop null lines.
	txt = txt(where(strmid(txt,0,1) ne '#'))	; Drop comments.
	;------  Initialize key search  -----------
	val = txtgetkey(init=txt, delim=' ')
 
	;-------  Handle printer setup parameters  ---------
	val = txtgetkey('size',delim=' ',/start)               ;--- Size
	if val eq 'S' then begin
	  widget_control, m.id_siz, set_val='Small'
	endif else begin
	  widget_control, m.id_siz, set_val='Large'
	endelse
	val = txtgetkey('rotation',delim=' ',/start)           ;--- Rotation
	if val eq 'L' then begin
	  widget_control, m.id_rot, set_val='Landscape'
	endif else begin
	  widget_control, m.id_rot, set_val='Portrait'
	endelse
	val = txtgetkey('scale',delim=' ',/start)              ;--- Scale
	widget_control, m.id_xytxt, set_val=val
	sxy = float(val)>m.mag1<m.mag2
	widget_control, m.id_xytxt, set_val=string(sxy,form='(F4.2)')
	x = 560*(sxy-m.mag1)/(m.mag2-m.mag1)
	widget_control, m.id_xy, set_val=x
        val = txtgetkey('back_rgb',delim=' ',/start)            ;--- Backgr.
	r2 = getwrd(val,0)+0		; R
	g2 = getwrd(val,1)+0		; G
	b2 = getwrd(val,2)+0		; B
	m.rbk=r2 & m.gbk=g2 & m.bbk=b2	; Save actual background color.
	;------  Find closest color in working color table  -----
	tvlct,r,g,b,/get		; Get working color table.
	d = long(r-r2)^2 + long(g-g2)^2 + long(b-b2)^2
	w =where(d eq min(d))
	m.bk = w(0)
 
	;------  Clear window  ---------
	m.pcnt = 0			; Clear out all images.
	xmer_window, m			; Create and update new window.
	xmess,' Restoring '+file+' . . .',wid=wid,/nowait
 
	;-------  Page layout (images)  ----------
	repeat begin
	  val = txtgetkey('image',delim=' ')
	  if val ne '' then xmer_add, val, m
	endrep until val eq ''
 
	widget_control, wid, /dest
	return
	end
 
;===================================================================
;	pro xmer_rescale = Rescale a displayed image.
;	1994 Sep 6
;===================================================================
 
	pro  xmer_rescale, m, sf, i
 
	;-------------------------------------
	;	m = Map structure
	;	sf = New scale factor
	;	i = image index
	;-------------------------------------
	f = m.pname(i)
	tr = m.trans(i)
	xmer_rdimg, f, m.ptyp(i), a, r, g, b	; Read image.
	sz = size(a)
	dx = round(sz(1)*sf)		; New image size.
	dy = round(sz(2)*sf)
	a = congrid(a,dx,dy)		; Resize image.
	rr = r(a)			; Convert to standard color tbl.
	gg = g(a)
	bb = b(a)
	wtb = -1		; Assume no transparent background.
	if tr ge 0 then wtb=where(a eq tr) ; Find indices of given bkgr.
	c = color_quan(rr,gg,bb,r,g,b,cube=m.cube)
	resopen,m.pres(i),/write	; Save in display file.
	resput,'img',c
	resput,'back',wtb	; Save backgr indices.
	resclose
	m.pdx(i) = dx			; New displayed image size.
	m.pdy(i) = dy
 
	return
	end
 
;===================================================================
;	pro xmer_maxscale = Compute max scale factor allowed.
;	1994 Sep 6
;===================================================================
 
	pro xmer_maxscale, m
 
	;--------  Find max allowed mag factor  -------
	if m.pcnt eq 0 then begin	; No images.
	  ms = 4.0
	endif else begin
	  mx = 2.56*!d.x_size/m.pdx0(0:m.pcnt-1)
	  my = 2.56*!d.y_size/m.pdy0(0:m.pcnt-1)
	  ms = min([mx,my])<4.0
	  ms = fix(ms*100)/100.		; Truncate to 2 decimal places.
	endelse
	m.mag2 = ms				; Set max slider scale.
	widget_control, m.top, set_uval=m	; Save.
	txt = 'Scale Factor (0.5 to '+string(ms,form='(f5.3)')+')'
	widget_control, m.id_scran, set_val=txt
	;-------  Update scale factor slider bar position  ----------
	widget_control, m.id_xytxt, get_val=sxy
	sxy = float(sxy(0))>m.mag1<m.mag2
	widget_control, m.id_xytxt, set_val=string(sxy,form='(F4.2)')
	x = 560*(sxy-m.mag1)/(m.mag2-m.mag1)
	widget_control, m.id_xy, set_val=x
 
	return
	end
 
;===================================================================
;	pro xmer_boxes = Slider bar scaling: outline images.
;	1994 Sep 6
;===================================================================
 
	pro xmer_boxes, m
 
	pres = m.pres
	widget_control, m.id_xytxt, get_val=scale
	scale = scale(0)+0.
	if m.last_scale eq scale then return
	nx = !d.x_size		; Screen size.
	ny = !d.y_size
	n = m.pcnt		; Number of images.
	sf = scale*800./2000.	; Current scale factor.
	dx = fix(m.pdx0*sf)	; New displayed image size.
	dy = fix(m.pdy0*sf)
	m.pdx = dx		; Save new sizes.
	m.pdy = dy
	erase, m.bk
	for i=0, n-1 do begin
	  xx0 = sf*m.px0(i)	; New display position.
	  yy0 = sf*m.py0(i)
	  xx = xx0>0<(nx-dx(i)-1)   ; Keep in bounds. (-1 added 95/11/14 RES)
	  yy = yy0>0<(ny-dy(i)-1)
	  if (xx ne xx0) or (yy ne yy0) then begin
	    print,' Shifting image '+strtrim(i,2)+' to fit on page.'
	  endif
	  m.px(i) = xx		; Save new display positions.
	  m.py(i) = yy
	  plots,/dev,xx+[0,dx(i),dx(i),0,0],yy+[0,0,dy(i),dy(i),0],col=0
	endfor
	widget_control, m.top, set_uval=m	; Update sizes and positions.
 
	return
	end
 
 
;===================================================================
;	pro xmer_update = Update screen.
;	1994 Sep 2
;===================================================================
 
	pro xmer_update, m
 
	nx = !d.x_size		; Screen size.
	ny = !d.y_size
	n = m.pcnt		; Number of images.
	widget_control, m.id_xytxt, get_val=scale
	scale = scale(0)+0.
	sf = 800./2000.*scale			; Overall scale factor.
	;--------  Rescale image sizes and positions before display  ------
	if m.last_scale ne scale then begin
	  xmess,'Rescaling images . . .',wid=wid,/nowait
	  for i=0, n-1 do begin
	    xmer_rescale, m, sf, i
	  endfor
	  widget_control, wid, /dest		; Drop Rescale message.
	  m.last_scale = scale			; Scaling OK.
	endif
	;-----------  End rescale  --------------
	;---------  Display images  ----------------
	erase, m.bk			; Erase display.
	for i=0, n-1 do begin		; Loop through all images.
	  resopen,m.pres(i)		; Read image i.
	  resget,'img',img
	  resget,'back',wtb
	  resclose
          xx0 = sf*m.px0(i)     ; New display position.
          yy0 = sf*m.py0(i)
          xx = xx0>0<(nx-m.pdx(i)) ; Keep in bounds.
          yy = yy0>0<(ny-m.pdy(i))
	  if (xx ne xx0) or (yy ne yy0) then begin
	    print,' Shifting image '+strtrim(i,2)+' to fit on page.'
	  endif
	  m.px(i) = xx			; Store position in case new.
	  m.py(i) = yy
	  xmer_tv,img,xx,yy,trans=wtb	; Display.
	endfor
	widget_control, m.top, set_uval=m	; Update positions.
 
	return
	end
 
;===================================================================
;	pro xmer_imageorder = Rearrange image order.
;	1994 Sep 1
;===================================================================
 
	pro xmer_imageorder, in, m
 
	if in(0) lt 0 then begin
	  m.pcnt = 0
	endif else begin  
	  j = indgen(n_elements(in))	; Subscripts to modify.
	  m.px(j) = m.px(in)
	  m.py(j) = m.py(in)
	  m.pdx(j) = m.pdx(in)
	  m.pdy(j) = m.pdy(in)
	  m.px0(j) = m.px0(in)
	  m.py0(j) = m.py0(in)
	  m.pdx0(j) = m.pdx0(in)
	  m.pdy0(j) = m.pdy0(in)
	  m.pname(j) = m.pname(in)
	  m.pres(j) = m.pres(in)
	  m.ptyp(j) = m.ptyp(in)
	  m.trans(j) = m.trans(in)
	  m.pcnt = n_elements(in)
	endelse
	widget_control, m.top, set_uval=m
 
	return
	end
 
;===================================================================
;	function xmer_findi = Find which image was selected by cursor.
;	1994 Sep 1
;===================================================================
 
	function xmer_findi, x, y, m
 
	if m.pcnt eq 0 then return,-1		; No boxes.
 
	;---------  Find which box(es) given point is inside  --------
	x1 = m.px(0:m.pcnt-1)
	y1 = m.py(0:m.pcnt-1)
	dx = m.pdx(0:m.pcnt-1)
	dy = m.pdy(0:m.pcnt-1)
	x2 = x1 + dx
	y2 = y1 + dy
	w = where((x ge x1) and (x le x2) and $
	          (y ge y1) and (y le y2), cnt)
	if cnt eq 0 then return, -1		; Outside all boxes.
	if cnt eq 1 then return, w(0)		; Inside just 1 box.
 
	;------  Inside multiple boxes, Find closest box center  ----------
	in = (indgen(m.pcnt))(w)
        pxc = x1(w) + dx(w)/2              ; Image centers.
        pyc = y1(w) + dy(w)/2
        d = float(pxc-x)^2 + float(pyc-y)^2   ; Find closest center.
        i = (where(d eq min(d)))(0)
	return, in(i)
	end
 
;===================================================================
;	pro xmer_count = display image count in widget window.
;	1994 Sep 1
;===================================================================
 
	pro xmer_count, m
 
	n = m.pcnt
	txt = ' images'
	if n eq 1 then txt = ' image'
	n = strtrim(n,2)
	widget_control, m.id_cnt, set_val=n+txt+'  '
 
	return
	end
 
;===================================================================
;	pro xmer_image = Interactively position an image.
;	1994 Aug 31
;===================================================================
 
	pro xmer_image, x, y, dx, dy, m
 
	wset, m.win
	dx2 = dx/2.
	dy2 = dy/2.
	xmn = dx2
	ymn = dy2
	xmx = m.sc_x - dx2
	ymx = m.sc_y - dy2
	xc = (x+dx2)<xmx>xmn
	yc = (y+dy2)<ymx>ymn
	tvcrs, xc, yc
	tvbox, xc-dx2, yc-dy2, dx, dy, -2, /noerase
	repeat begin
	  tvbox, xc-dx2, yc-dy2, dx, dy, -2
	  cursor, /dev, xc, yc, /change
	  xc = xc<xmx>xmn
	  yc = yc<ymx>ymn
	  txt = string(xc,yc,form='(2I5)')
	  widget_control, m.id_crs,set_val=txt
	endrep until !mouse.button ne 0
	x = round(xc - dx2)
	y = round(yc - dy2)
	tvbox, x, y, dx, dy, -1
;	polyfill, /dev, color=72+m.pcnt, [x,x+dx,x+dx,x],[y,y,y+dy,y+dy]
	widget_control, m.id_crs,set_val=' '
	widget_control, m.id_crs2,set_val='(Last: '+txt+')'
	return
	end
 
;===================================================================
;	pro xmer_window = Create or recreate a layout window.
;	R. Sterner, 1994 Aug 31
;===================================================================
 
	pro xmer_window, m
 
	;---------  Set up standard color table  ----------
	if !d.table_size ge 216 then cube=6 else cube=5
	t = bytarr(5,5)
	c = color_quan(t,t,t,r,g,b,cube=cube)
	tvlct,r,g,b
	topc = cube*cube*cube
	m.topc = topc		; Save standard color table info.
	m.cube = cube
	m.bk = !d.table_size-1
	m.rsc = r
	m.gsc = g
	m.bsc = b
	tvlct,m.rbk,m.gbk,m.bbk,m.bk
 
	;--------  Determine window size and shape  -----------
	dx = 800	; Assume large window.
	dy = 800
	wsz = '11" x 11"'
	tt = 'Color Image Merge Layout.   '
	widget_control, m.id_siz, get_val=sz
	if sz eq 'Small' then begin
	  widget_control, m.id_rot, get_val=rot
	  if rot eq 'Landscape' then begin
	    dy = 600
	    wsz = '11" x 8.5"'
	  endif else begin
	    dx = 600
	    wsz = '8.5" x 11"'
	  endelse
	endif
	tclr = '   '+strtrim(m.topc,2)+' color approximation.'
 
	;---------  Detroy any old window  --------------
	if m.winb ne 0 then widget_control, m.winb, /dest
 
	;----------  Create new window  -----------------
	winb = widget_base(title=tt+wsz+tclr)
	id_draw = widget_draw(winb, xsize=dx, ysize=dy, /button, $
	  uval='MOVE', retain=2)
	widget_control, winb, /real
	m.winb = winb				; Draw widget base ID.
	m.win = !d.window			; Draw widget window number.
	m.id_draw = id_draw			; Draw widget ID.
	m.sc_x = dx-1				; Last screen x.
	m.sc_y = dy-1				; Last screen y.
	widget_control, m.top, set_uval=m	; Save window info.
 
	erase, m.bk				; Erase to selected background.
 
	;--------  Register draw widget  ------------
	xmanager, 'xmer_window', winb, event_handler='xmerge_event', /just_reg
 
	;--------  Bring control panel to front  ---------
	widget_control, m.top, /show
 
	;--------  Update screen  -----------
	xmer_update, m
	xmer_maxscale, m
	widget_control, winb, set_uval=m	; Save map in base.
 
	return
	end
 
;===================================================================
;	pro xmerge_event = Event handler for xmerge.
;	R. Sterner, 1994 Aug 30
;===================================================================
 
	pro xmerge_event, ev
 
	common xmerge_event_com, seed
 
	widget_control, ev.id, get_uval=uval
	cmd = getwrd(uval)
	widget_control, ev.top, get_uval=m	; Uval from event top.
	widget_control, m.top, get_uval=m	; Uval from original top.
 
	if cmd eq 'QUIT' then begin
	  widget_control, m.winb,/ dest
	  widget_control, ev.top,/ dest
	  xmess,'Please remove the *.tmp files generated by xmerge',/wait
	  return
	endif
 
        if cmd eq 'BACKRGB' then begin
	  xmer_bkg, m, /rgb
          return
        endif
 
        if cmd eq 'BACKHSV' then begin
	  xmer_bkg, m, /hsv
          return
        endif
 
	if cmd eq 'MOVE' then begin
	  if m.add_mode eq 1 then begin
	    m.add_mode = 0
	    widget_control, m.top, set_uval=m
	    wait,.2
	    return
	  endif
	  if ev.release eq 1 then return	; Ignore button release.
	  i = xmer_findi(ev.x, ev.y, m)
	  if i lt 0 then return
	  widget_control, m.id_img, set_val=m.pname(i)	; Image name.
	  x = m.px(i)			; Closest image.
	  y = m.py(i)
	  dx = m.pdx(i)
	  dy = m.pdy(i)
          dx2 = dx/2			; 1/2 box size.
          dy2 = dy/2
          xmn = dx2			; Box center lower limits.
          ymn = dy2
          xmx = m.sc_x - dx2		; Box center upper limits.
          ymx = m.sc_y - dy2
          xc = (x+dx2)<xmx>xmn		; Box center.
          yc = (y+dy2)<ymx>ymn
	  tvbox,xc-dx2,yc-dy2,dx,dy,-2,/noerase	  ; Outline box.
          tvcrs, xc, yc			; Jump to center.
	  polyfill, /dev, color=255, [x,x+dx,x+dx,x],[y,y,y+dy,y+dy] ; Erase it.
	  repeat begin			; Move image box.
	    cursor, /dev, xc, yc, /nowait
	    wait,.05
	    xc = xc<xmx>xmn
	    yc = yc<ymx>ymn
	    txt = string(xc,yc,form='(2I5)')
	    widget_control, m.id_crs,set_val=txt
	    tvbox,xc-dx2,yc-dy2,dx,dy,-2	; Outline box.
	  endrep until !mouse.button eq 0
	  tvbox,xc-dx2,yc-dy2,dx,dy,-1		; Erase box.
	  x = xc-dx2
	  y = yc-dy2
	  m.px(i) = x				; Put new box in map structure.
	  m.py(i) = y
	  widget_control, m.id_xytxt, get_val=scale  ; Get slider bar scale.
	  scale = scale(0)+0.
	  sf = scale*800./2000.		; Overall scale factor.
	  if scale ne m.last_scale then begin
	    xmer_rescale, m, sf, i
	  endif
	  m.px0(i) = (x+1)/sf-1		; Update full page coordinates.
	  m.py0(i) = (y+1)/sf-1
	  widget_control, m.top, set_uval=m	; Save updated structure.
	  resopen,m.pres(i)
	  resget,'img',img
	  resget,'back',wtb
	  resclose
	  xmer_tv, img, x, y, trans=wtb
	  if m.pcnt gt 1 then begin	; If more than 1 image
            in = intarr(m.pcnt)		; Bring active one to top.
            in(i) = 1
            in = where(in eq 0)
            xmer_imageorder, [in,i], m
	  endif
	  widget_control, m.id_crs,set_val=''
	  widget_control, m.id_crs2,set_val='(Last: '+txt+')'
	  wait,.1
	  widget_control, m.id_img, set_val=''
	  return
	endif
 
	if cmd eq 'DROP' then begin
	  if m.pcnt eq 0 then begin
	    xmess, 'There are no images to drop', /wait
	    widget_control, ev.id, /input_focus
	    return
	  endif
	  xmess, 'Click on image to drop', wid=wid, /nowait
	  wset, m.win
	  x = m.sc_x/2
	  y = m.sc_y/2
	  tvcrs, x, y
	  cursor,/dev,x,y,/up
	  i = xmer_findi(x, y, m)
	  widget_control, wid, /dest
	  if i lt 0 then begin
	    widget_control, ev.id, /input_focus
	    return
	  endif
	  x = m.px(i)
	  y = m.py(i)
	  dx = m.pdx(i)
	  dy = m.pdy(i)
	  tvbox,x,y,dx,dy,-2,/noerase
	  if xoption(["Drop","Don't drop"],def=0) eq 0 then begin
	    polyfill, /dev, color=255, [x,x+dx,x+dx,x],[y,y,y+dy,y+dy]
	    in = intarr(m.pcnt)
	    in(i) = 1
	    in = where(in eq 0)
	    xmer_imageorder, in, m
	    xmer_count, m
	    xmer_update, m
	    xmer_maxscale, m
	  endif else begin
	    tvbox,x,y,dx,dy,-1
	  endelse
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'LIST' then begin
	  if m.pcnt eq 0 then begin
	    xmess,'There are no images to list',/wait
	  endif else begin
	    tmp = m.pname(0:m.pcnt-1)
	    n = max(strlen(tmp)) + 3
	    txt = tmp + spc(n, tmp) + $
	          'Size: '+strtrim(m.pdx0(0:m.pcnt-1),2)+ ' x ' + $
	          strtrim(m.pdy0(0:m.pcnt-1),2)
	    txt = ['Images listed in display order:',' ',txt]
	    xhelp,txt,/wait
	  endelse
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'UPDATE' then begin
	  xmer_update, m
	  return
	endif
 
	if cmd eq 'ADDTIF' then begin
	  path = m.path
	  f=pickfile(filt='*.tif', path=path, get_path=path2)	; Pick a file
	  if f eq '' then return
	  m.path = path2
	  xtxtin,t,titl='Enter index of transparent color (none=-1)',$
	    /wait,def='-1',menu=['0',strtrim(!d.table_size-1,2)]
	  xmer_add, f, m, type='TIF', trans=t
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'ADDGIF' then begin
	  path = m.path
	  f=pickfile(filt='*.gif', path=path, get_path=path2)	; Pick a file
	  if f eq '' then return
	  m.path = path2
	  xtxtin,t,titl='Enter index of transparent color (none=-1)',$
	    /wait,def='-1',menu=['0',strtrim(!d.table_size-1,2)]
	  xmer_add, f, m, type='GIF', trans=t
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'ADDJPG' then begin
	  path = m.path
	  f=pickfile(filt='*.jpg', path=path, get_path=path2)	; Pick a file
	  if f eq '' then return
	  m.path = path2
	  xtxtin,t,titl='Enter index of transparent color (none=-1)',$
	    /wait,def='-1',menu=['0',strtrim(!d.table_size-1,2)]
	  xmer_add, f, m, type='JPG', trans=t
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'SIZE' then begin
	  widget_control, ev.id, get_val=val
	  if val eq 'Small' then val = 'Large' else $
	    val = 'Small'
	  widget_control, ev.id, set_val=val
	  if val eq 'Large' then widget_control, m.id_rot, set_val='Landscape'
	  if val eq 'Large' then widget_control, m.id_rot, map=0 else $
	    widget_control, m.id_rot, map=1
	  xmer_window, m
	  return
	endif
 
	if cmd eq 'ROT' then begin
	  widget_control, ev.id, get_val=val
	  if val eq 'Landscape' then val = 'Portrait' else $
	    val = 'Landscape'
	  widget_control, ev.id, set_val=val
	  xmer_window, m
	  return
	endif
 
	if cmd eq 'XY' then begin
	  widget_control, m.id_xy, get_val=sxy
	  sxy = m.mag1 + (m.mag2-m.mag1)*(sxy/560.)
	  widget_control, m.id_xytxt, set_val=string(sxy,form='(F4.2)')
	  if m.pcnt eq 0 then begin
	    m.last_scale = sxy
	    widget_control, m.top, set_uval=m
	  endif
	  xmer_boxes, m
	  return
	endif
 
	if cmd eq 'XYTXT' then begin
	  widget_control, m.id_xytxt, get_val=sxy
	  sxy = float(sxy(0))>m.mag1<m.mag2
	  widget_control, m.id_xytxt, set_val=string(sxy,form='(F4.2)')
	  x = 561*(sxy-m.mag1)/(m.mag2-m.mag1)
	  widget_control, m.id_xy, set_val=x
	  if m.pcnt eq 0 then begin
	    m.last_scale = sxy
	    widget_control, m.top, set_uval=m
	  endif
	  xmer_update, m
	  return
	endif
 
	if cmd eq 'TEXT' then begin
	  if m.txt_instr eq 0 then begin
	    xhelp,['Instructions for text box',' ',$
		'These instructions will appear only once.',' ',$
		'Use box to position text to display.',$
		'Left mouse button cycles through 3 modes:',' ',$
		'MOVE mode: position box',$
		'SIZE mode: change box size',$
		'FREE CURSOR mode: cursor is detached from box.',$
		'  The box is exited in free cursor mode by',$
		'  clicking below its center.  Click above', $
		'  box center to re-enter MOVE mode.', ' ', $
		'If mouse is moved when clicked then click may',$
		'not take effect.  Just click again.']
	    m.txt_instr = 1
	    widget_control, m.top, set_uval=m
	  endif
	  box1, x,y,dx,dy,/nostat,col=-2, exitcode=ex
	  if ex eq 1 then return
          widget_control, m.id_xytxt, get_val=sf  ; Get slider bar scale.
	  scale = sf(0)+0.
          sf = sf(0)*800./2000.                   ; Overall scale factor.
	  nx = dx/sf
	  ny = dy/sf
	  xtextimg, xs=nx, ys=ny, /wait, out=out
	  if out ne '' then begin
	    x0 = fix(x/sf)
	    y0 = fix(y/sf)
	    tin = out+' '+strtrim(x0,2)+' '+strtrim(y0,2)+' -1 TIF'
	    xmer_add, tin, m
	  endif
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'CENT' then begin
	  widget_control, m.id_xytxt, get_val=scale
	  scale = scale(0)+0.
	  xmess,'Click mouse on desired page center',wid=wid,/nowait
	  sx = (m.sc_x+1)*1.28		; Full page center.
	  sy = (m.sc_y+1)*1.28
	  xc = m.sc_x/2			; Screen window center.
	  yc = m.sc_y/2
	  tvcrs, xc, yc			; Put cursor in screen center.
	  cursor,xc,yc,/dev		; Select new center.
	  widget_control, wid, /dest
	  sf = 800./2000.		; Screen scale factor.
	  xc = xc/sf			; Convert from screen to page
	  yc = yc/sf			;   coordinates.
	  dx = (sx - xc)/scale		; Shift in page coordinates.
	  dy = (sy - yc)/scale
	  print,' Shifting images by ',dx,dy
	  m.px0 = m.px0 + dx		; New page coordinates.
	  m.py0 = m.py0 + dy
	  m.px = m.px0*sf		; New screen coordinates.
	  m.py = m.py0*sf
	  widget_control, m.top, set_uval=m	; Save new values.
	  xmer_update, m		; Update display.
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'GEN' then begin
	  xmer_gen, m
	  return
	endif
 
	if cmd eq 'DROPGEN' then begin
	  if m.genwin ge 32 then swdelete, m.genwin else wdelete, m.genwin
	  tvlct, m.rsc, m.gsc, m.bsc
	  tvlct,m.rbk,m.gbk,m.bbk,m.bk
	  return
	endif
 
	if cmd eq 'HELP_OV' then begin
	  xhelp,$
		['Overview of xmerge',$
		' ','The xmerge routine is used combine mulitple color',$
		'images into a single image.  GIF, TIFF or JPEG are',$
		"supported.  Each image may have it's own color table.",$
		'the combined image size may be adjusted as needed within',$
		'limits.  The combined image is referred to as a page.', ' ',$
		'The xmerge routine is controlled by a widget which has',$
		'three main divisions:',$
		'  Top row buttons: basic commands such as Quit,',$
		'    Help, Update, and so on.',$
		'  Page Setup: size, orientation, and background color,',$
		'    of the final merged image.',$
		'  Page Layout: commands dealing with positioning the',$
		'    images.']
	  return
	endif
 
	if cmd eq 'HELP_TOP' then begin
	  xhelp,$
		['Top row buttons', ' ',$
		'Quit: Quit the xmerge routine.',$
		'Help: Display help text.',$
		'Update Screen: refresh the screen display.  This',$
		'   should be used after a scale change since it rescales',$
		'   all the display images at once.  Moving or clicking',$
		'   on an image outline after a slider bar scale change',$
		'   will rescale just that image each time until the',$
		'   Update Screen option is executed.',$
		'Cursor: gives a cross hair cursor, might be useful',$
		'   in positioning images.', $
		'New Page: Clears the page for a new layout.',$
		'Generate: Creates a new image with all the subimages',$
		'   combined into one.',$
		'Drop GenWin: Deletes the combined image window created',$
		'   by the Generate command.', $
		'Xview: calls up the xview routine.  Use this to save result.']
	  return
	endif
 
	if cmd eq 'HELP_PS' then begin
	  xhelp,$
		['Page Setup',' ',$
		'Page size:  Toggle between small (8.5" x 11") and',$
		'   large (11" x 11").  For scale 1.00 small is 1500x2000.',$
		'Page orientation button:  Toggle between portrait and',$
		'   landscape orientation.  For small page only.',$
		'Scale factor text window:  Enter desired scale factor.',$
		'   Applies to all images together.  Press the Enter key',$
		'   on the keyboard to redisplay images.  The actual size',$
		'   of each image is not changed, only the final size of the',$
		'   merged image.  Bigger scales give smaller final images:',$
		'   scale=1 gives 1500x2000 (small, portrait),',$
		'   scale=2 gives  750x1000, and so on.',$
		'Scale factor slider bar: Displays outlines of images as',$
		'   bar is moved.  Use the Update Screen button to redisplay',$
		'   images after using the slider bar.',' ',$
		'Note on scale factors','One scale factor applies to all',$
		'the images.  The scale factor range allowed',$
		'is from 0.5 to 4.0, but the maximum scale factor depends on',$
		'the size of the images, an image may not be magnified',$
		'beyond the edges of the page.  Also, as the scale factor is',$
		'increased images that would extend off the page are shifted',$
		'to stay on the page.  This may result in image overlap.']
	  return
	endif
 
	if cmd eq 'HELP_PL' then begin
	  xhelp,$
		['Page Layout',' ',$
		'The page layout controls are used select and position',$ 
		'images, save and retrieve layout files, and make',$
		'an image containing text.',' ',$
		'Add image button:',$
		'   Allows selection of GIF, TIFF, or JPEG images.',$
		'   After an image has been selected any color in it',$
		'   may be designated as transparent, default is none.', ' ',$
		'   More details on the file selection widget: The',$
		'   default Path is displayed in the top text field.  It',$
		"   may be modified to point to a desired directory.  It's",$
		'   initial value may be set using the DIRECTORY=dir',$
		'   keyword on the call to xmerge:',$
		"   xmerge,dir='/users/images/ers' for example.",$
		'   The Filter text field may also be changed but is',$
		'   set depending on what image type was selected.', $
		'   Two larger text windows display the current',$
		'   files (that match the filter) on the right, and the',$
		'   subdirectories on the left.  The subdirectory window',$
		'   also displays ../ which means the parent directory.',$
		'   Clicking on a subdirectory or the parent directory',$
		'   moves to that directory, so it is not necessary to',$
		'   enter a directory in the Path field.  A file is',$
		'   selected by clicking on its name in the file window,',$
		'   it is copied to the Selection window and may be',$
		'   chosen by clicking on the Ok button.',$
		'Moving an image: A displayed image may be moved by dragging',$
		'   it with the mouse.',$
		'Dropping image button: Click on the Drop Image button, then',$
		'   click on the image to drop.',$
		'List images button: Lists the displayed images and their',$
		'   sizes.',$
		'Save current layout button: Save the current layout in',$
		'   a text file of the form *.mer.',$
		'Retrieve a layout button: Retrieves a previously saved',$
		'   layout file (*.mer file).',$
		'Set new page center button: allows a new page center to be',$
		'   selected.',$
		'Text button: Deals with text labels.']
	  return
	endif
 
	if cmd eq 'DEBUG' then begin
	  cat=dog
	  return
	endif
 
	if cmd eq 'CURSOR' then begin
	  crossi,/dev,col=0,/mag
	  return
	endif
 
	if cmd eq 'DLIST' then begin
	  txt = ['   i      px     pdx     px0    pdx0'+$
	    '      py     pdy     py0    pdy0']
	  for i=0,m.pcnt-1 do begin
	    txt = [txt,string(i,m.px(i),m.pdx(i),m.px0(i),m.pdx0(i),$
		m.py(i),m.pdy(i),m.py0(i),m.pdy0(i),$
		form='(i4,8f8.1)')]
	  endfor
	    xhelp,txt
	  return
	endif
 
	if cmd eq 'SAVE' then begin	; Save current layout in *.mer file.
	  xtxtin, ifile, title='Enter name of *.mer file', $
	    def=m.ifile, /wait
	  if ifile eq '' then return
	  xmess,'Saving . . .',wid=wid,/nowait
	  ;-----  Build up mer file contents  ----------
	  ;---  Header  ---
	  txt = ['#   Created on '+systime()]
	  user = getenv('USER')
	  if user eq '' then user = 'Unknown user'
	  user = strupcase(strmid(user,0,1))+strmid(user,1,99)
	  txt = [txt,'#   by '+user]
	  t = 'L'				        ;---  Rotation.
	  widget_control, m.id_rot, get_val=val
	  if strupcase(strmid(val,0,1)) eq 'P' then t = 'P'
	  txt = [txt,'rotation  '+t]
	  widget_control, m.id_siz, get_val=val		;---  Size.
	  t = strupcase(strmid(val,0,1))
	  txt = [txt,'size  '+t]
	  widget_control, m.id_xytxt, get_val=scale	;---  Scale.
	  scale = scale(0)+0.
	  t = string(scale,form='(f5.3)')
	  txt = [txt,'scale  '+t]
	  t = string(m.rbk,m.gbk,m.bbk,form='(3I4)')
	  txt = [txt,'back_rgb  '+t]
	  ;-------  Page layout  ----------
	  x0 = strtrim(fix(m.px0),2)
	  y0 = strtrim(fix(m.py0),2)
	  tr = strtrim(m.trans,2)
	  ty = strtrim(m.ptyp,2)
	  for i=0, m.pcnt-1 do begin
	    t = 'image '+m.pname(i)+' '+x0(i)+' '+y0(i)+' '+tr(i)+' '+ty(i)
	    txt = [txt,t]
	  endfor
	  putfile, ifile, txt
	  wait,1
	  m.ifile = ifile
	  widget_control, m.top, set_uval=m
	  widget_control, wid, /dest
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'REST' then begin	; Restore layout from *.mer file.
	  path = m.ipath
	  f=pickfile(filt='*.mer', path=path, get_path=path2)	; Pick a file
	  if f eq '' then begin
	    widget_control, ev.id, /input_focus
	    return
	  endif
	  m.ipath=path2				; Update *.mer file path.
	  widget_control, m.top, set_uval=m
	  f = findfile(f, count=cnt)
	  if cnt eq 0 then begin
	    xmess,['*.mer file not found:',f],/wait
	    widget_control, ev.id, /input_focus
	    return
	  endif
	  xmer_restore, f(0), m
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if cmd eq 'NEW' then begin
	  opt = xoption(['OK','Cancel'],title='Current layout will be lost', $
	    def=0)
	  if opt eq 1 then return
	  m.pcnt = 0
	  widget_control, m.top, set_uval=m
	  xmer_window, m
          xmer_count, m
	  widget_control, m.id_xytxt, set_val='1.00'
          xmer_maxscale, m
	  widget_control, m.id_add, /input_focus
	  return
	endif
 
	if cmd eq 'XVIEW' then begin
	  xview
	  return
	endif
 
	return
	end
 
;===================================================================
;	pro xmerge.pro = Widget based routine to merge multiple color images.
;	R. Sterner, 1994 Aug 30
;===================================================================
 
	pro xmerge, directory=path, debug=debug, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Widget based routine to merge multiple color images in one.'
	  print,' xmerge'
	  print,'   No args'
	  print,' Keywords:'
	  print,'   DIRECTORY=dir  optional initial directory (def=current).'
	  print,'   /DEBUG  means add a few debug buttons.'
	  print,' Notes: Click on HELP button for details.'
	  return
	endif
 
	;-----------  Check number of colors  ----------------
	window,colors=256,/free,/pixmap,xs=50,ys=50
	win = !d.window
	erase
	wdelete,win
	nc = !d.table_size
	if nc ne 256 then begin
	  bell
	  print,' Warning: only '+strtrim(nc,2)+' colors available.'
	  print,'   Should have 256 for best results.'
	  print,'   If it matters exit IDL and get back in.'
	endif
	
	;-----------  Widget layout  -------------------------
	top = widget_base(/column, title='Merge multiple color images')
 
	;---------  Top row buttons  ---------------
	b = widget_base(top,/row,/frame)
	id = widget_button(b, value='Quit',uval='QUIT')
	id_hlp = widget_button(b, value='Help',menu=2)
	id = widget_button(id_hlp, value='Overview of xmerge',uval='HELP_OV')
	id = widget_button(id_hlp, value='Top row commands',uval='HELP_TOP')
	id = widget_button(id_hlp, value='Printer Setup Commands',$
	  uval='HELP_PS')
	id = widget_button(id_hlp, value='Page Layout Commands',$
	  uval='HELP_PL')
	id = widget_button(b, val='Update Screen',uval='UPDATE')
	if keyword_set(debug) then begin
	  id = widget_button(b, val='Debug Stop',uval='DEBUG')
	  id = widget_button(b, val='Debug List images',uval='DLIST')
	endif
	id = widget_button(b, val='cursor',uval='CURSOR')
	id = widget_button(b, val='New Page',uval='NEW')
	id_gen = widget_button(b, value='Generate',uval='GEN')
	id = widget_button(b, value='Drop GenWin',uval='DROPGEN')
	id = widget_button(b, value='Xview',uval='XVIEW')
 
	;--------  Page setup  ------------
	bb = widget_base(top,/column,/frame)
	b = widget_base(bb,/row)
	id = widget_label(b, val='Page Setup')
	id_siz = widget_button(b, value='Small',uval='SIZE')
	bs = widget_base(b,/row)
	id_rot = widget_button(bs, value='Landscape',uval='ROT')
	id_bk = widget_button(b, value='Background color',menu=2)
	  id = widget_button(id_bk, value='HSV',uval='BACKHSV')
	  id = widget_button(id_bk, value='RGB',uval='BACKRGB')
 
	b = widget_base(bb,/row)
	id_scran = widget_label(b, val='Scale Factor (0.5 to 4.0)')
	mag1 = 0.5
	mag2 = 4.0
	b = widget_base(bb,/row)
	id_xytxt = widget_text(b,val='1.00', /edit, xsize=8, uval='XYTXT')
	id_xy = widget_slider(b,val=80,xsize=561,uval='XY',/drag,/suppress, $
	  min=0, max=560)
 
	;--------  Page Layout  ------------
	bb = widget_base(top,/column,/frame)
	b = widget_base(bb,/row)
	id = widget_label(b, val='Page Layout.     ')
	id_cnt = widget_label(b, val='0 images')
	id_img = widget_label(b, val='')
	b = widget_base(bb,/row)
	id_add = widget_button(b, value='Add image',menu=2)
	  id = widget_button(id_add, value='GIF', uval='ADDGIF')
	  id = widget_button(id_add, value='TIFF', uval='ADDTIF')
	  id = widget_button(id_add, value='JPEG', uval='ADDJPG')
	id_drop = widget_button(b, value='Drop Image',uval='DROP')
	id = widget_button(b, value='List Images',uval='LIST')
	id_save = widget_button(b, value='Save current layout',uval='SAVE')
	id_rest = widget_button(b, value='Restore a layout',uval='REST')
	b = widget_base(bb,/row)
	id_cent = widget_button(b, value='Set new page center',uval='CENT')
	id_text = widget_button(b, value='Text',uval='TEXT')
	id_crs = widget_label(b,value='  ')
	id_crs2 = widget_label(b,value='  ')
;	id_gen = widget_button(b, value='Generate',uval='GEN')
;	id = widget_button(b, value='Drop GenWin',uval='DROPGEN')
;	id = widget_button(b, value='Xview',uval='XVIEW')
 
	;--------  Set up widget map  ----------------
	if n_elements(path) eq 0 then cd, curr=path
	cd, curr=ipath		; Path for *.mer files.
	map = {top:top, genwin:0, $
	  rsc:bytarr(256), gsc:bytarr(256), bsc:bytarr(256),$
	  id_siz:id_siz, id_rot:id_rot, id_xy:id_xy, $
	  id_xytxt:id_xytxt, winb:0L, win:0L, id_draw:0L, add_mode:0, $
	  sc_x:0, sc_y:0, id_crs:id_crs, id_crs2:id_crs2, trans:intarr(20), $
	  px:fltarr(20), py:fltarr(20), pdx:intarr(20), pdy:intarr(20), $
	  px0:fltarr(20), py0:fltarr(20), pdx0:intarr(20), pdy0:intarr(20), $
	  pname:strarr(20), pres:strarr(20), pcnt:0, id_cnt:id_cnt, topc:0, $
	  ptyp:strarr(20), rbk:255, gbk:255, bbk:255, bk:!d.table_size-1, $
	  cube:0, path:path, ipath:ipath, last_scale:1.0, id_img:id_img, $
	  mag1:mag1, mag2:mag2, id_scran:id_scran, $
	  ifile:'tmp.mer', txt_instr:0, id_add:id_add}
 
	;--------  Activate widget  -----------------------
	widget_control, top, /real
 
	;---------  Make window  ---------------------
;	window,5,xs=10,ys=10,/pixmap
;	erase
;	wdelete,5
;	if !d.table_size ge 216 then cube=6 else cube=5
;	t = bytarr(5,5)
;	c = color_quan(t,t,t,r,g,b,cube=cube)
;	tvlct,r,g,b
;	topc = cube*cube*cube
;	map.topc = topc
;	map.cube = cube
;	map.bk = !d.table_size-1
	xmer_window, map
 
	;---------  Register widget  -----------------
	widget_control, top, set_uval=map
	xmanager, 'xmerge', top
 
	return
	end
