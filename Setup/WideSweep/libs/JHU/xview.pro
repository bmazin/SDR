;-------------------------------------------------------------
;+
; NAME:
;       XVIEW
; PURPOSE:
;       View and/or convert images (GIF, TIFF, ...).
; CATEGORY:
; CALLING SEQUENCE:
;       xview
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SCROLL_SIZE=[mx,my]  Max size before scrolling sets in.
;         DIRECTORY=dir        Set initial directory.
;         HOTLIST=hfile        Name of directory hotlist file.
;           File has list of directories of interest.  For file
;           format do xhotlist, /help.  Default is the file named.
;           xview_dir.txt in local directory first, then $HOME.
;         TYPE=typ  Initial image type:
;           GIF=def,JPEG,TIFF,XWD,BMP,XBM,PICT,SRF
;         WILD=wild Initial wildcard (def depends on TYPE).
;         MAG=mag Initial magnification (def=1.0).
;         ICTXT=txt Text string to execute after each image load.
;           Intended to set data coordinates for data cursor.
;           Image name is available in the variable called NAME at
;           the point where this text is executed.  If a file name
;           contains coordinate info a routine which extracts that
;           info may be called.  Ex: for file N40W120.gif the
;           routine could pick off the 40 and 120 and use that to
;           set the scaling. Something like ICTXT="set_scale,name"
;         READ_CUSTOM=rc  Name of an optional custom image
;           read routine.  May also include default wild card
;           as 2nd element of a string array. Routine syntax:
;           img = rdcust(filename, r, g, b) where r,g,b may
;           be set to scalar 0 for no new color table.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 11 Oct, 1993
;       R. Sterner, 1994 Dec 13 --- Added JPEG.  Also allowed initial
;       mag factor to be given.  Added more mag factors to pulldown menu.
;       R. Sterner, 1994 Dec 30 --- Added XBM.
;       R. Sterner, 1995 May 5 --- Added PRINT.
;       R. Sterner, 1995 May 18 --- Added TRANSPARENCY.
;       R. Sterner, 1995 Nov 9 --- Added SRF.
;       R. Sterner, 1997 Feb 27 --- Added vivid color print option.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 1999 Sep 28 --- Switched to read_tiff (from tiff_read).
;       R. Sterner, 2001 Jul 19 --- Fixed to save JPEG correctly.
;       R. Sterner, 2001 Jul 26 --- Fixed image resize, also called img_shape.
;       R. Sterner, 2003 Apr 23 --- Added PNG images.
;       R. Sterner, 2004 Apr 29 --- Changed call to xtxtin.
;       R. Sterner, 2004 May 19 --- Fixed set_scale call to work.
;       R. Sterner, 2004 Jun 02 --- Fixed B&W PNG (no color table).
;       R. Sterner, 2006 Mar 16 --- Fixed dir list to be opsys dependent.  Switched to
;       file_search.  Dropped double wildcards.
;       R. Sterner, 2007 Mar 19 --- Added cubic=-0.5 on magnify option.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;========================================================
;	xview_print = Make a color print of current image.
;	R. Sterner, 1995 May 5.
;========================================================
 
	pro xview_print, fname, trans=trans, printer=pr
 
	txt = 'print'
	if keyword_set(trans) then txt = 'transparency'
 
	subset = 0
	sub2set = 0
	opt = xoption(title='Make a color '+txt,['OK','Cancel'],$
	  def=0, subopt=['Single Page','Two Pages','Four Pages'],$
	  subset=subset, /exclusive, sub2opt=['Display color',$
	  'Vivid color'],sub2set=sub2set,/ex2)
	if opt ne 0 then return
 
	if n_elements(pr) eq 0 then begin
	  pr = 'Paper Color'
	  if keyword_set(trans) then pr = 'Transparency Color'
	endif
	two = 0
	four = 0
	if subset eq 1 then two=1
	if subset eq 2 then four=1
	vivid = ''
	if sub2set eq 1 then vivid=' vivid'
 
	prwindow, pr+vivid, comment=fname, two=two, four=four
 
	return
	end
 
;========================================================
;	udlist = Update image list.
;========================================================
 
	pro udlist, up,  noload=noload
 
	widget_control, /hour
	widget_control, up.dir, get_value=dir    ; Get current directory.
	dir = dir(0)
	widget_control, up.file, get_value=wild  ; Get current file or wild.
	wild = wild(0)
	widget_control, up.mag, get_val=mag	 ; Get current mag.
	mag = mag(0)
	mag = getwrd(mag,2)+0.0
	smax = up.smax				 ; Max scroll window.
 
	tmpdir = dir				 ; To avoid ls arg list too
	cd,curr=tmp2dir				 ;   big error
	if tmp2dir eq dir then tmpdir=''	 ;   use null for local.
	fname = filename(tmpdir,wild,/nosym)	 ; Add path to file.
;	f = findfile(fname,count=cnt)		 ; Look for files.
	f = file_search(fname,count=cnt,/fold_case)		 ; Look for files.
	if cnt eq 0 then begin			 ; No files.
	  widget_control, up.list, set_value=['No files found']
	  widget_control, up.left, set_uval=['']
	endif else begin			 ; Found some.
	  tmp = filename('x','y',del=del)
	  for i = 0, n_elements(f)-1 do f(i)=getwrd(f(i),/last,delim='/')
	  for i = 0, n_elements(f)-1 do f(i)=getwrd(f(i),/last,delim=del)
	  widget_control, up.list, set_val=f
	  widget_control, up.left, set_uval=f
	  if keyword_set(noload) then return	 ; Don't load.
	  if cnt eq 1 then begin		 ; Found one.  Load it.
	    tvimg, fname, smax=smax, mag=mag, cinit=up.ictxt, imgsz=up.imgsz, $
	      type=up.type, custom=up.custread, rot=up.rot
          endif
	endelse
 
	return
	end
 
;========================================================
;	tvimg = image loader
;	R. Sterner, 11 Oct, 1993
;	R. Sterner, 2000 Sep 26 --- Upgraded for 24-bit color.
;	R. Sterner, 2003 Apr 23 --- Added PNG.
;
;	tvimg, name, smax=smax
;	  name = image file name.                        in
;	  smax = optional max scroll window size [mx,my]  in
;	  mag=mag = optional image mag factor.           in
;========================================================
 
	pro tvimg, name, smax=smax, mag=mag, custom=cust, type=id_type, $
	  cinit=ictxt, rot=rot, imgsz=imgsz
 
	;---------  Get file type from widget  ---------------
	widget_control, id_type, get_val=txt
	type = strupcase(getwrd(txt,/last))
	tt = getwrd(name,/last,delim='/')	; Window title = file name.
 
	;---------  Read image  ----------
	iflag = -1	; Indexed color?  1=yes, 0=no.
	order = 0
	case type of
'PNG':	begin
	  read_png, name, img, r, g, b
	  img_shape, img, true=tr
	  if tr eq 0 then iflag=1 else iflag=0
	  if n_elements(r) eq 0 then begin	; No color table.
	    r = bindgen(256)			; Use B&W.
	    g = r
	    b = r
	  endif
	end
'GIF':	begin
	  read_gif, name, img, r, g, b
	  iflag = 1
	end
'SRF':	begin
	  read_srf, name, img, r, g, b
	  iflag = 1
	end
'JPG':	begin
	  read_jpeg, name, img
	  if (size(img))(0) eq 1 then begin	; Gray scale.
	    r = c
	    g = c
	    b = c
	    iflag = 1
	  endif else begin			; Color.
	    iflag = 0
	  endelse
	end
'XWD':	begin
	  img = read_xwd(name, r, g, b)
	end
'TIF':	begin
	  img = read_tiff(name, order=order)
	  if order gt 1 then order=1	; A bug?  order comes back 16437.
	  iflag = 0
	end
'BMP':	begin
	  img = read_bmp(name, r, g, b)
	  iflag = 1
	end
'XBM':	begin
	  read_x11_bitmap, name, img, /expand_to_bytes
	  img = reverse(img,2)
	  r = bindgen(256)
	  g = r
	  b = r
	  iflag = 1
	end
'PICT':	begin
	  read_pict, name, img, r, g, b
	  iflag = 1
	end
'CUSTOM': begin
	    img = call_function(cust, name, r, g, b)
	    iflag = 1
	  end
else:	begin
	  print,' Unkown image type: ',type
	  return
	end
	endcase
 
	;-----------  Rotate image  --------------
	img = img_rotate(img,rot)
	;-----------  Size image  ----------------
	mx = smax(0)
	my = smax(1)
	img_shape, img, true=tr, nx=nx,ny=ny
	ttsz = ' ('+strtrim(nx,2)+', '+strtrim(ny,2)+')'
	tt = tt + ttsz
	widget_control, imgsz, set_val='Image size:'+ttsz
	if n_elements(mag) eq 0 then mag = 1
	if mag ne 1 then begin
;	  img = img_resize(img,mag=mag)
	  img = img_resize(img,mag=mag,cubic=-0.5)
	  img_shape, img, nx=nx,ny=ny
	endif
	sx = nx<mx
	sy = ny<my
 
	;------------  Create display window  ---------------
	swdelete			; Delete last window if any.
	if !d.window ge 0 then wdelete
	if (sx ne nx) or (sy ne ny) or (sx lt 50) then begin
	  swindow, xs=nx, ys=ny, x_scr=sx+2, y_scr=sy+2, $
	    title=tt, index=tmp
	  win = tmp(0)
	endif else begin
	  window, xs=nx, ys=ny, colors=256, title=tt
	  win = !d.window
	endelse
 
	;-----------  Display type  -------------------------------
	dflag = 8
	if !d.n_colors gt 256 then dflag=24
	if (dflag eq 8) and (iflag eq 0) then begin
	  c = color_quan(img,tr,r,g,b)
	  img = c
	  iflag = 1
	endif
 
	;-----------  Display color table and image  -------------
	if iflag eq 0 then begin
	  tr=(where((size(img))(1:3) eq 3))(0)+1
	  tv, img, true=tr, order=order
	endif else begin
	  if dflag eq 24 then device, decomp=0
	  tvlct,r,g,b
	  tv, img, order=order
	  if dflag eq 24 then device, decomp=1
	endelse
 
	;-------  Execute cursor initialization text string  --------
	set_scale, image=img, /quiet	; Default init routine.
;	set_scale, /quiet	; Default init routine.
	map_set_scale		; Secondary default (for maps).
	if ictxt ne '' then err = execute(ictxt)
 
	return
	end
 
 
;========================================================
;	Event handler routine
;	R. Sterner, 11 Oct, 1993
;========================================================
 
	pro xview_event, ev
 
	widget_control, ev.id, get_uval=name
	widget_control, ev.top, get_uval=uval
 
	if nwrds(name) gt 1 then begin
	  name2 = getwrd(name,1,99)
	  name = getwrd(name)
	endif
 
	if name eq 'LIST' then begin
	  widget_control, uval.left, get_uval=f	; image list from uval.
	  widget_control,uval.dir,get_val=dir		; Image directory.
	  dir = dir(0)
	  ictxt = uval.ictxt
	  smax = uval.smax				; Max scroll window.
	  id_mag = uval.mag				; Image mag.
	  widget_control, id_mag, get_val=mag
	  mag = getwrd(mag(0),2) + 0.0
	  name=f(ev.index)				; Selected image.
	  xmess,wid=wid,/nowait,'Loading image '+name+' . . .'
	  fname = filename(dir,name,/nosym)		; Total name.
	  tvimg, fname, smax=smax, mag=mag, cinit=ictxt, imgsz=uval.imgsz, $
	    type=uval.type, custom=uval.custread, rot=uval.rot
	  widget_control, wid, /dest
	  widget_control, uval.id_curr, set_val=name	; Update current name.
	  return
	endif
 
	if name eq 'DIR' then begin		; New directory.
	  widget_control, ev.id, get_val=dir	; Get entered directory.
	  dir = dir(0)
	  uval.curr = dir
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'HOT' then begin
	  widget_control, uval.dir, get_val=dir	; Get entered directory.
	  dir = dir(0)
	  xhotlist, file=uval.hot, out=new, val=dir, desc=dir, browse=bfile
	  ;-----  No browse file selected, maybe a directory  --------
	  if bfile eq '' then begin
	    if new eq '' then return			; No directory, done.
	    widget_control, uval.dir, set_val=new	; Set new dir.
	    udlist,uval, /noload			; Display contents.
	    return
	  endif
	  ;-----  Returned a browse file, deal with it  ---------------
	  ;-----  Find type and check if known image type  ----------
	  filebreak,bfile,nvfile=bnam,ext=btyp
	  allowed = ['png','gif','srf','jpg','xwd','tif','bmp','xbm','pict']
	  allowed2 = ['PNG','GIF','SRF','JPEG','XWD','TIFF','BMP','XBM','PICT']
	  w = (where(strlowcase(btyp) eq allowed, cnt))(0)
	  if cnt eq 0 then begin
	    xmess,'Unkown image type: '+btyp
	    return
	  endif
	  ;-----  Known image type, set widget fields and load it  -------
	  widget_control, uval.type, set_val='Image type: '+strupcase(btyp)
	  widget_control, uval.file, set_val='*.'+allowed(w)
	  widget_control, uval.known, set_val='Known '+allowed2(w)+' images'
	  widget_control, uval.dir, set_val=new	; Set new dir.
	  udlist,uval, /noload			; Display contents.
	  ictxt = uval.ictxt
	  smax = uval.smax				; Max scroll window.
	  id_mag = uval.mag				; Image mag.
	  widget_control, id_mag, get_val=mag
	  mag = getwrd(mag(0),2) + 0.0
	  xmess,wid=wid,/nowait,'Loading image '+bnam+' . . .'
	  tvimg, bfile, smax=smax, mag=mag, cinit=ictxt, imgsz=uval.imgsz, $
	    type=uval.type, custom=uval.custread, rot=uval.rot
	  widget_control, wid, /dest
	  widget_control, uval.id_curr, set_val=bnam	; Update current name.
	  return
	endif
 
	if name eq 'FILE' then begin		; New file.
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'ZOOM' then begin
	  in = !d.window
	  if in lt 0 then return
	  print,' '
	  print,' Use mouse to zoom and pan'
	  print,'   Zoom out:  Left button'
	  print,'   Zoom in:   Middle button'
	  print,'   Quit zoom: Right button'
	  wshow,in
	  zpan, in=in, out=1, size=300
	  wdelete, 1
	  return
	endif
	
	if name eq 'PAN' then begin
	  in = !d.window
	  if in lt 0 then return
	  wshow,in
	  crossi,/dev,/mag,/pix
	  return
	endif
	
	if name eq 'XLOAD' then begin
	  in = !d.window
	  if in lt 0 then return
	  xloadct
	  return
	endif
	
	if name eq 'THRESH' then begin
	  in = !d.window
	  if in lt 0 then return
	  imgmask
	  return
	endif
	
	if name eq 'ICURS' then begin
	  txt = ['Enter text to be used to initialize',$
	         'the data coordinate system after each',$
		 'image load.  A null string means no',$
		 'initialization.  A procedure may be',$
		 'called with the current image file name',$
		 'which is stored in the variable called',$
		 'name.  Ex: cur_init, name',$
		 'will call a procedure named cur_init',$
		 'and pass in the current image name.',$
		 'Applies to images loaded AFTER, not current.']
	  xtxtin, ictxt,def=uval.ictxt,title=txt,$; Get cursor init text.
	    group=ev.top
	  uval.ictxt = ictxt			  ; Put in uval.
	  widget_control, ev.top, set_uval=uval   ; Save uval.
	  return
	endif
	
	if name eq 'ROT' then begin
	  ttl = ['Select transformation to apply to each      ',$
	         'image before it is displayed.  Images may   ',$
		 'be transposed and rotated.  A transpose     ',$
		 'is done before a rotation.  Rotations       ',$
		 'are counter-clockwise.                      ', $
		 'Applies to images loaded AFTER, not current.']
	  txt = ['0   No change',$
		 '1   Rotate  90 deg',$
		 '2   Rotate 180 deg',$
		 '3   Rotate 270 deg',$
		 '4   Transpose',$
		 '5   Transpose, then Rotate  90 deg: reverse in X',$
		 '6   Transpose, then Rotate 180 deg',$
		 '7   Transpose, then Rotate 270 deg: reverse in Y']
	  rot = xlist(txt,/wait,title=ttl)	  ; Get rotation code.
	  uval.rot = getwrd(rot,0)+0		  ; Put in uval.
	  widget_control, ev.top, set_uval=uval   ; Save uval.
	  return
	endif
	
	if name eq 'CURS' then begin
	  in = !d.window
	  if in lt 0 then return
	  wshow,in
	  crossi,/data,/mag
	  return
	endif
	
;	if name eq 'DVCURS' then begin
;	  in = !d.window
;	  if in lt 0 then return
;	  crossi,/dev,/mag
;	  return
;	endif
	
	if name eq 'MAG' then begin
	  widget_control, ev.id, get_val=value
	  id_mag = uval.mag
	  widget_control, id_mag, set_val='Image mag: '+value+'     '
	  return
	endif
	
	if name eq 'PNG' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.png'
	  widget_control, uval.known, set_val='Known PNG images'
	  udlist, uval, /noload
	  return
	endif
	
	if name eq 'GIF' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.gif'
	  widget_control, uval.known, set_val='Known GIF images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'SRF' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.srf'
	  widget_control, uval.known, set_val='Known SRF images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'JPG' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.jpg'
	  widget_control, uval.known, set_val='Known JPEG images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'XWD' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.dmp'
	  widget_control, uval.known, set_val='Known XWD images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'TIF' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.tif'
	  widget_control, uval.known, set_val='Known TIFF images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'BMP' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.bmp'
	  widget_control, uval.known, set_val='Known BMP images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'XBM' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.xbm'
	  widget_control, uval.known, set_val='Known XBM images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'PICT' then begin
	  widget_control, uval.type, set_val='Image type: '+name
	  widget_control, uval.file, set_val='*.pict'
	  widget_control, uval.known, set_val='Known PICT images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'CUSTOM' then begin
          widget_control, uval.type, set_val='Image type: '+name
          widget_control, uval.file, set_val=uval.custwild
	  widget_control, uval.known, set_val='Known CUSTOM images'
	  udlist, uval, /noload
	  return
	endif
 
	if name eq 'SGIF' then begin
	  tt = 'Enter name of output GIF file in selection box'
	  out = pickfile(titl=tt,file='temp.gif',get_path=dir)
	  if out eq '' then return
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving GIF image in '+out+' . . .',/nowait,wid=wid
;	  out = dir+out	; <===<<< Full path is returned above.
 	  t = tvrd()
	  tvlct,r,g,b,/get
	  write_gif, out, t,r,g,b
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'SSRF' then begin
	  tt = 'Enter name of output SRF file in selection box'
	  out = pickfile(titl=tt,file='temp.srf',get_path=dir)
	  if out eq '' then return
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving SRF image in '+out+' . . .',/nowait,wid=wid
;	  out = dir+out
 	  t = tvrd()
	  tvlct,r,g,b,/get
	  write_srf, out, t,r,g,b
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'SJPG' then begin
	  tt = 'Enter name of output JPEG file in selection box'
	  out = pickfile(titl=tt,file='temp.jpg',get_path=dir)
	  if out eq '' then return
	  xtxtin,title=['Enter JPEG quality factor','100 = best',$
	    '0 = worst','75 = default'],def='75', group=ev.top, qf
	  qf = qf+0
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving JPEG image in '+out+' . . .',/nowait,wid=wid
	  jpegscreen, out, quality=qf
;	  out = dir+out
; 	  t = tvrd()
;	  tvlct,r,g,b,/get
;	  rr = r(t)
;	  gg = g(t)
;	  bb = b(t)
;	  cc=[[[rr]],[[gg]],[[bb]]]
;	  write_jpeg,out,cc,true=3,quality=qf
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'STIFF' then begin
	  tt = 'Enter name of output TIFF file in selection box'
	  out = pickfile(titl=tt,file='temp.tif',get_path=dir)
	  if out eq '' then return
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving TIFF image in '+out+' . . .',/nowait,wid=wid
;	  out = dir+out
 	  t = tvrd()
	  tvlct,r,g,b,/get
	  tiff_write, out, reverse(t,2),1,red=r,green=g,blue=b
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'SBMP' then begin
	  tt = 'Enter name of output BMP file in selection box'
	  out = pickfile(titl=tt,file='temp.bmp',get_path=dir)
	  if out eq '' then return
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving BMP image in '+out+' . . .',/nowait,wid=wid
;	  out = dir+out
 	  t = tvrd()
	  tvlct,r,g,b,/get
	  write_bmp, out, t, r, g, b
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'SPICT' then begin
	  tt = 'Enter name of output PICT file in selection box'
	  out = pickfile(titl=tt,file='temp.pict',get_path=dir)
	  if out eq '' then return
	  setwin, err=err
	  if err ne 0 then return
	  xmess,'Saving PICK image in '+out+' . . .',/nowait,wid=wid
;	  out = dir+out
 	  t = tvrd()
	  tvlct,r,g,b,/get
	  write_pict, out, t, r, g, b
	  wait,1
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'QUIT' then begin
	  widget_control, /dest, ev.top
	  return
	endif
 
	if name eq 'CROP' then begin
	  wshow
	  subimg
	  return
	endif
 
	if name eq 'PRINT' then begin
          setwin, err=err
          if err ne 0 then return
	  widget_control, uval.id_curr, get_val=name	; Get current name.
	  widget_control, uval.dir, get_val=dir		; Get directory.
	  fname = filename(dir(0),name(0),/nosym)	; Complete file name.
	  xview_print, fname
	  return
	endif
 
	if name eq 'TRANS' then begin
          setwin, err=err
          if err ne 0 then return
	  widget_control, uval.id_curr, get_val=name	; Get current name.
	  widget_control, uval.dir, get_val=dir		; Get directory.
	  fname = filename(dir(0),name(0),/nosym)	; Complete file name.
	  xview_print, fname, /trans
	  return
	endif
 
	if name eq 'CPRINT' then begin
          setwin, err=err
          if err ne 0 then return
	  widget_control, uval.id_curr, get_val=name	; Get current name.
	  widget_control, uval.dir, get_val=dir		; Get directory.
	  fname = filename(dir(0),name(0),/nosym)	; Complete file name.
	  xview_print, fname, printer=name2
;############
	  return
	endif
 
	if name eq 'CPROC' then begin
          if !d.window lt 0 then return
	  err = execute(name2)
;############
	  return
	endif
 
	if name eq 'PAINT' then begin
	  paint
	  return
	endif
 
	if name eq 'CTOOL' then begin
	  ctool
	  return
	endif
 
	if name eq 'HSV' then begin
	  xhsbc
	  return
	endif
 
	if name eq 'ADJ' then begin
	  imgscale
	  return
	endif
 
	if name eq 'SHRP' then begin
	  xmess,'Sharpening image . . .',wid=wid,/nowait
	  tvsharp
	  widget_control, wid,/dest
	  return
	endif
 
	if name eq 'BW' then begin
	  xmess,wid=wid,/nowait,'Converting image to black and white . . .'
          tvlct,r,g,b,/get
          lum = bytscl((.3*r)+(.59*g)+(.11*b),top=!d.table_size-1)
          t = tvrd()
          z = lum(t)
          loadct,0
          tv,z
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'COLOR' then begin
	  xmess,wid=wid,/nowait,'Converting image to standard color . . .'
          tvlct,r,g,b,/get
          t = tvrd()
          rr = r(t)
          gg = g(t)
          bb = b(t)
          c = color_quan(rr,gg,bb,rc,gc,bc,cube=6)
          tvlct,rc,gc,bc
          tv,c
	  widget_control, wid, /dest
	  return
	endif
 
	if name eq 'DELETE' then begin
	  print,' DELETE'
	  return
	endif
 
	if name eq 'HELP' then begin
	  print,' HELP '+name2
	  whoami, hdir
	  hfile = filename(hdir,name2,/nosym)
	  t = getfile(hfile,err=err,/quiet)
	  if err ne 0 then begin
	    xmess,'Could not open help file '+hfile
	    return
	  endif
	  xhelp,t
	  return
	endif
 
	if name eq 'ERASE' then begin
	  swdelete
	  if !d.window ge 0 then wdelete
	  widget_control, uval.id_curr, set_val=' '
	  return
	endif
 
	return
	end
 
 
;=======================================================
;	Main program
;	R. Sterner, 1 Jun, 1993
;
;	Comments:
;	  Values that are needed globally (or at least by
;	several widgets) are stored in the uval of the top
;	since this is easy to access having the widget event
;	structure.  This allows various labels to be updated
;	or read.  A unique code is stored as the uval of each
;	widget that calls for an action.  This makes it easy
;	to determine which widget was activated.  Needed values
;	may then be read back, such as a directory name from
;	the directory text widget.  List widgets are a problem
;	because their value may not be read back so the list
;	displayed by them must be stored elsewhere.  That is
;	handled here by storing this list in an unused base
;	uval (here the left side base uval is used).  The
;	address of this base is saved with the global values in
;	the top uval structure.
;=======================================================
 
	pro xview, scroll_size=smax, directory=dir0, hotlist=hot, $
	  read_custom=rdcust, write_custom=wrcust, $
	  type=type, wild=wild, ictxt=ictxt, mag=mag, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' View and/or convert images (GIF, TIFF, ...).'
	  print,' xview'
	  print,'   Widget based inputs.'
	  print,' Keywords:'
	  print,'   SCROLL_SIZE=[mx,my]  Max size before scrolling sets in.'
	  print,'   DIRECTORY=dir        Set initial directory.'
	  print,'   HOTLIST=hfile        Name of directory hotlist file.'
	  print,'     File has list of directories of interest.  For file'
	  print,'     format do xhotlist, /help.  Default is the file named.'
	  print,'     xview_dir.txt in local directory first, then $HOME.'
	  print,'   TYPE=typ  Initial image type:'
	  print,'     GIF=def,JPEG,TIFF,XWD,BMP,XBM,PICT,SRF'
	  print,'   WILD=wild Initial wildcard (def depends on TYPE).'
	  print,'   MAG=mag Initial magnification (def=1.0).'
	  print,'   ICTXT=txt Text string to execute after each image load.'
	  print,'     Intended to set data coordinates for data cursor.'
	  print,'     Image name is available in the variable called NAME at'
	  print,'     the point where this text is executed.  If a file name'
	  print,'     contains coordinate info a routine which extracts that'
	  print,'     info may be called.  Ex: for file N40W120.gif the'
	  print,'     routine could pick off the 40 and 120 and use that to'
	  print,'     set the scaling. Something like ICTXT="set_scale,name"'
	  print,'   READ_CUSTOM=rc  Name of an optional custom image'
	  print,'     read routine.  May also include default wild card'
	  print,'     as 2nd element of a string array. Routine syntax:'
	  print,'     img = rdcust(filename, r, g, b) where r,g,b may'
	  print,'     be set to scalar 0 for no new color table.'
	  return
	endif
 
	;----------  Check for 256 color mode  -----------
        if !d.table_size ne 256 then begin
	  bell
	  print,' Warning: not in 256 color mode.  May have problems'
	  print,' viewing some images.'
          print,' Exit IDL and get back in xview for 256 colors.'
        endif else begin
	  window,colors=256,/free
	  wdelete
	endelse
 
	;-------  Handle custom file read  ---------
	custread = ''
	custwild = ''
	if n_elements(rdcust) ne 0 then begin
	  tmp = [rdcust,'*']		; Make sure a default wild card exists.
	  custread = rdcust(0)		; Read routine name.
	  custwild = rdcust(1)		; Default wild card.
	endif
 
	;-------  Hotlist  ---------------------
	cd, curr=curr
	if n_elements(hot) eq 0 then begin
	  hot = 'xview_dir.txt'
	  f = findfile(hot,count=cnt)
	  if cnt eq 0 then begin
	    home = getenv('HOME')
	    hot = filename(home,'xview_dir.txt',/nosym)
	    f = findfile(hot,count=cnt)
	    if cnt eq 0 then begin
	      txt = [' Default xview hotlist created by '+getenv('USER'),$
		' on '+systime(),curr,curr]
	      hot = 'xview_dir.txt'
	      putfile,hot,txt
	      print,' Created default hotlist in local directory.'
	    endif
	  endif
	endif else begin
	  f = findfile(hot,count=cnt)
	  if cnt eq 0 then begin
	    print,' Error in xview: specified hotlist file not found: ',hot
	    return
	  endif
	endelse
 
	;-------  Max scroll size  -------------
	device,get_screen_size=ssz
;print,round(0.9*ssz)
;	if n_elements(smax) eq 0 then smax = [1100,950]
	if n_elements(smax) eq 0 then smax = round([0.9,0.85]*ssz)
 
	;-------  Data coordinates initialization  ---------
	if n_elements(ictxt) eq 0 then ictxt = ''
 
	;-------  Allowed types: PNG, GIF, JPEG, TIFF, PICT, BMP, XBM, XWD, CUSTOM.
	if n_elements(type) eq 0 then type = 'PNG'
	type = strupcase(type)
	if n_elements(wild) eq 0 then begin
	  case strmid(type,0,3) of
'PNG':	    wild = '*.png'
'GIF':	    wild = '*.gif'
'JPG':	    wild = '*.jpg'
'TIF':	    wild = '*.tif'
'PIC':	    wild = '*.pict'
'BMP':	    wild = '*.bmp'
'XBM':	    wild = '*.xbm'
'XWD':	    wild = '*.dmp'
'SRF':	    wild = '*.srf'
else:	    wild = '*'
	  endcase
	endif
	;-------  Allowed mags: 1/5, 1/2, 1, 2, 5
	if n_elements(mag) eq 0 then mag = '1.0'
	mag = strtrim(mag,2)
	;-------  Initial directory  ---------------
	if n_elements(dir0) eq 0 then cd, curr=dir0
 
	;-------  Left side  ----------
	root = widget_base(title='Image Viewer',/row)
	left = widget_base(root,/column)
	bdir = widget_base(left,/row)
	w = widget_label(bdir,value='Directory          ')
	id = widget_button(bdir,value='Directory Hotlist', uval='HOT')
	pdh = widget_button(bdir,value='Help',menu=2)
	  id = widget_button(pdh, value='Overview',$
	    uval='HELP xview_overview.txt')
	  id = widget_button(pdh, value='Text fields',$
	    uval='HELP xview_text_fields.txt')
	  pdh2 = widget_button(pdh, value='Buttons',menu=2)
	    id = widget_button(pdh2, value='Brief descriptions',$
	      uval='HELP xview_buttons_brief.txt')
	    id = widget_button(pdh2, value='User defined buttons',$
	      uval='HELP xview_buttons_user.txt')
	w = widget_button(bdir,value='Quit',uval='QUIT')
	w = widget_button(bdir,value='Erase',uval='ERASE')
	id_dir = widget_text(left,xsize=40,ysize=1,/edit,val=dir0,uval='DIR')
	btmp = widget_base(left,/row)
	w = widget_label(btmp,value='File name')
	id_file = widget_text(left,xsize=40,val=wild,/edit,uval='FILE')
	btmp = widget_base(left,/row)
	id_known = widget_label(btmp,value='Known '+type+' images',/dynamic)
	id_list = widget_list(left,val=['No files'], ysize=8,uval='LIST')
	id_curr = widget_text(left,xsize=40,val=' ')
 
	;-------  Right side  ----------
	right = widget_base(root,/column)
	;-----  Change type pull down menu  --------
	id_type = widget_label(right,value='Image type: '+type,/dynamic)
	pd1 = widget_button(right, value='        Change Type ...    ', menu=2)
	  pdt = widget_button(pd1, value='PNG',uval='PNG')
	  pdt = widget_button(pd1, value='GIF',uval='GIF')
	  pdt = widget_button(pd1, value='JPEG',uval='JPG')
	  pdt = widget_button(pd1, value='TIFF',uval='TIF')
	  pdt = widget_button(pd1, value='XWD',uval='XWD')
	  pdt = widget_button(pd1, value='BMP',uval='BMP')
	  pdt = widget_button(pd1, value='XBM',uval='XBM')
	  pdt = widget_button(pd1, value='PICT',uval='PICT')
	  pdt = widget_button(pd1, value='SRF',uval='SRF')
	if n_elements(rdcust) ne 0 then begin
	  pdcust = widget_button(pd1, value='CUSTOM',uval='CUSTOM')
	endif
	;-----  Image mag pull down menu  --------
	id_mag = widget_text(right,/edit,value='Image mag: '+mag,uval='MAG0')
	pd2 = widget_button(right, value='  Image Magnification ... ', menu=2)
	  w=widget_button(pd2,value='0.2',uval='MAG')
	  w=widget_button(pd2,value='0.25',uval='MAG')
	  w=widget_button(pd2,value='0.5',uval='MAG')
	  w=widget_button(pd2,value='.75',uval='MAG')
	  w = widget_button(pd2,value='1.0',uval='MAG')
	  w = widget_button(pd2,value='1.5',uval='MAG')
	  w = widget_button(pd2,value='2.0',uval='MAG')
	  w = widget_button(pd2,value='2.5',uval='MAG')
	  w = widget_button(pd2,value='5.0',uval='MAG')
	img_sz = widget_label(right,value=' ',/dynamic)
	;------  Tools pull down menu  --------
	pd1 = widget_button(right,value='Tools and functions ...',menu=2)
	  id = widget_button(pd1,value='Zoom and pan',uval='ZOOM')
	  id = widget_button(pd1,value='Device and Pixel Cursor',uval='PAN')
;	  id = widget_button(pd1,value='Device Cursor',uval='DVCURS')
	  id = widget_button(pd1,value='Data Cursor',uval='CURS')
	  id = widget_button(pd1,value='Initialize Data Coordinates ...',$
	    uval='ICURS')
	  id = widget_button(pd1,value='Rotate, transpose, ...',uval='ROT')
	  id = widget_button(pd1,value='Crop image',uval='CROP')
	  id = widget_button(pd1,value='Paint Pixels',uval='PAINT')
	  id = widget_button(pd1,value='Edit Color Table',uval='CTOOL')
	  id = widget_button(pd1,value='Load New Color Table',uval='XLOAD')
	  id = widget_button(pd1,value='Threshhold Image',uval='THRESH')
	  id = widget_button(pd1,value='Adjust overall image hue/sat/value',$
	    uval='HSV')
	  id = widget_button(pd1,value='Convert to BW',uval='BW')
	  id = widget_button(pd1,value='Sharpen (BW only)',uval='SHRP')
	  id = widget_button(pd1,value='Adjust contrast (BW only)',uval='ADJ')
	  id = widget_button(pd1,value='Convert to Color',uval='COLOR')
	  id = widget_button(pd1,value='Delete',uval='DELETE')
	;------  Save pull down menu  -------------
	pd3 = widget_button(right, value='  Save image as ... ', menu=2)
	  id = widget_button(pd3,value='GIF',uval='SGIF')
	  id = widget_button(pd3,value='JPEG',uval='SJPG')
	  id = widget_button(pd3,value='TIFF',uval='STIFF')
	  id = widget_button(pd3,value='BMP',uval='SBMP')
	  id = widget_button(pd3,value='PICT',uval='SPICT')
	  id = widget_button(pd3,value='SRF',uval='SSRF')
	;------  Check for user defined buttons  --------
	;  If xview.txt exists in home directory read it.  It
	;  defines custom buttons using the following format:
	;  print: button_label / printer_number
	;  process: button_label / procedure_name
	;  . . .
	;  You can have any number of print: and process: lines.
	;  Null lines and lines with * as first char are ignored.
	;  Ex:
	;  print: Phaser 340 paper / 5
	;  print: Phaser 340 trans / 6
	;  process: Negative / imgneg
	;-----------------------------------------------------
	a = getfile(filename(getenv('HOME'),'xview.txt',/nosym), err=err,/q)
	if err ne 0 then begin
	  ;-----  Print Button  ---------------------
	  id = widget_button(right, value='Color Print', uval='PRINT')
	  id = widget_button(right, value='Color Transparency', uval='TRANS')
	  cpri = 0
	  cpro = 0
	endif else begin
	  a = drop_comments(a)
	  one = strupcase(strmid(a,0,3))
	  wpri = where(one eq 'PRI',cpri)	; Print buttons.
	  wpro = where(one eq 'PRO',cpro)	; Process buttons.
	endelse
	if cpri gt 0 then begin
	  pdp = widget_button(right, value='  PRINT ', menu=2)
	  for i=0,cpri-1 do begin
	    t = a(wpri(i))
	    v = getwrd(getwrd(t,del='/'),1,del=':')	; Label.
	    n = getwrd(t,/last,del='/')			; Printer #.
	    id = widget_button(pdp,value=v,uval='CPRINT '+n)
	  endfor
	endif
	if cpro gt 0 then begin
	  pdp = widget_button(right, value='  PROCESS ', menu=2)
	  for i=0,cpro-1 do begin
	    t = a(wpro(i))
	    v = getwrd(getwrd(t,del='/'),1,del=':')	; Label.
	    n = getwrd(t,/last,del='/')			; Command.
	    id = widget_button(pdp,value=v,uval='CPROC '+n)
	  endfor
	endif
 
	;-----------  Set selected user values  -----------
	data = {top:root, dir:id_dir, file:id_file, list:id_list, $
	 left:left,  mag:id_mag, type:id_type, smax:smax, curr:curr, $
	 hot:hot, custread:custread, custwild:custwild, known:id_known, $
	 ictxt:ictxt, rot:0, imgsz:img_sz, id_curr:id_curr}
	widget_control, root, set_uval=data
 
	;-------  Display  ----------
	widget_control,root,/real
	udlist, data, /noload
	xmanager, 'xview', root
 
	return
	end
