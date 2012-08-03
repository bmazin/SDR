;-------------------------------------------------------------
;+
; NAME:
;       IMG_DISP
; PURPOSE:
;       Display a given image.
; CATEGORY:
; CALLING SEQUENCE:
;       img_disp, img
; INPUTS:
;       img = Input image.  in
;         2-d array, 3-d array, or file name.
; KEYWORD PARAMETERS:
;       Keywords:
;         /SCALE Bytescl image for display.
;         MAG=mag  Mag factor (def=1).
;         SMAG=smag  Like MAG but smooth image first if smag<1.
;         TITLE=ttl Image window title.  Defaults to name and size.
;           Can change later: if current window do:
;           widget_control,swinfo(/base),base_set_title=newtitle
;         /ADDSIZE means image size to end of title text.
;         /CURRENT Use current window if correct size.
;           May also say CURRENT=n to look back n windows for
;           a size match.
;         /ORDER display the image reversed in Y.
;         XPOS=x, YPOS=y  Optional window position.
;         X_SCR=x_scr X size of scrolling region.
;         Y_SCR=y_scr Y size of scrolling region.
;           Def = up to 90% of screen size.
;         /PIXMAP means use a pixmap.
;        GROUP_LEADER=grp  specified group leader.  When the
;          group leader widget is destroyed this widget is also.
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
;           3=file not read.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Normally used for byte images but may also be
;         be used for INT and UINT images. These will scale
;         -32768 to 32677 and 0 to 65536 to 0 to 255 for display.
;         Displays in an swindow (scrolling window widget).
;         Can delete using swdelete.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 03
;       R. Sterner, 2002 Jun 11 --- Allowed INT and UINT images.
;       R. Sterner, 2003 Mar 13 --- Added XPOS, YPOS, X_SCR, Y_SCR keywords.
;       R. Sterner, 2003 Mar 21 --- Added GROUP_LEADER.
;       R. Sterner, 2003 Apr 02 --- Always use swindow (allows title change).
;       R. Sterner, 2003 Apr 21 --- Allowed CURRENT=n to match last n windows.
;       R. Sterner, 2003 Apr 21 --- Can add image size to title.
;       R. Sterner, 2004 May 20 --- Added window index to default title.
;       R. Sterner, 2005 Jan 17 --- Added /pixmap.
;       R. Sterner, 2006 Jan 25 --- Added /quiet to swindow call.
;       R. Sterner, 2006 Jan 25 --- Allowed x and y mag factors.
;       R. Sterner, 2006 Mar 16 --- Fixed bug in trying to set title for a
;       normal window (not swindow).
;       R. Sterner, 2007 May 08 --- Added /SCALE.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_disp, imag, title=ttl0, current=curr, xpos=xpos, ypos=ypos, $
	  order=order, mag=mag, smag=smag, error=err, addsize=addsize, $
	  x_scr=x_scr, y_scr=y_scr, pixmap=pixmap0, group_leader=grp, $
	  scale=scale, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a given image.'
	  print,' img_disp, img'
	  print,'   img = Input image.  in'
	  print,'     2-d array, 3-d array, or file name.'
	  print,' Keywords:'
	  print,'   /SCALE Bytescl image for display.'
	  print,'   MAG=mag  Mag factor (def=1).'
	  print,'   SMAG=smag  Like MAG but smooth image first if smag<1.'
	  print,'   TITLE=ttl Image window title.  Defaults to name and size.'
	  print,'     Can change later: if current window do:'
	  print,'     widget_control,swinfo(/base),base_set_title=newtitle' 
	  print,'   /ADDSIZE means image size to end of title text.'
	  print,'   /CURRENT Use current window if correct size.'
	  print,'     May also say CURRENT=n to look back n windows for'
	  print,'     a size match.'
	  print,'   /ORDER display the image reversed in Y.'
	  print,'   XPOS=x, YPOS=y  Optional window position.'
	  print,'   X_SCR=x_scr X size of scrolling region.'
	  print,'   Y_SCR=y_scr Y size of scrolling region.'
	  print,'     Def = up to 90% of screen size.'
	  print,'   /PIXMAP means use a pixmap.'
	  print,'  GROUP_LEADER=grp  specified group leader.  When the'
	  print,'    group leader widget is destroyed this widget is also.'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,'     3=file not read.'
	  print,' Note: Normally used for byte images but may also be'
	  print,'   be used for INT and UINT images. These will scale'
	  print,'   -32768 to 32677 and 0 to 65536 to 0 to 255 for display.'
	  print,'   Displays in an swindow (scrolling window widget).'
	  print,'   Can delete using swdelete.'
	  return
	endif
 
	if datatype(imag) eq 'STR' then begin
	  ;----  Try to read image  -----------
	  img = read_image(imag, r, g, b)
	  ;----  Image not read?  -------------
	  if n_elements(img) eq 1 then begin
	    print,' Error in img_disp: Image not read: '+img
	    err = 3
	    return
	  endif
	  ;----  Deal with IDL PNG bug  --------
	  filebreak, imag, ext=ext
	  if strlowcase(ext) eq 'png' then begin  ; Handle IDL 5.3 png bug.
	    if !version.release lt 5.4 then img=img_rotate(img,7)
	  endif
	  ;----  Deal with palette image  ----------
	  if n_elements(r) gt 0 then begin	; 8-bit palette image.
	    if n_elements(smag) ne 0 then begin	; Requested smoothing.
	      rr = r(img)			; Must smooth RGB components.
	      gg = g(img)			; so get components and
	      bb = b(img)			; merge.
	      img = img_merge(rr,gg,bb)
	    endif
	  endif
	endif else begin
	  img = imag
	  if keyword_set(scale) then img=bytscl(img)
	endelse
 
	;-------  Allow images of type INT and UINT  --------
	;---  Translate to byte: min->0, max->255  ----------
	typ = datatype(img)
	if (typ eq 'INT') or (typ eq 'UIN') then begin
	  tb = byte(round(maken(0.,255.,65336)))
	  if typ eq 'INT' then add=32768L else add=0
	  img = tb(img+add) 
	endif
 
	;--------  Mag factor  -----------------
	if n_elements(mag) ne 0 then begin
;	  if mag ne 1 then img = img_resize(img, mag=mag)
	  if min(mag eq 1) eq 0 then img=img_resize(img, mag=mag)
	endif
 
	;--------  SMag factor  -----------------
	if n_elements(smag) ne 0 then begin
	  if min(smag) le 0 then return
	  sm = round(1./min(smag))
	  img = img_smooth(img,sm)
;	  if smag ne 1 then img = img_resize(img, mag=smag)
	  if min(smag eq 1) eq 0 then img=img_resize(img, mag=smag)
	endif
 
	;----  Get size limits  --------
	device,get_screen_size=sz0
	sz = 0.90*sz0
	xmx = round(sz(0))
	ymx = round(sz(1))
	img_shape, img, nx=xs, ny=ys, true=tr, err=err; Image shape.
	if err ne 0 then return
	if n_elements(x_scr) eq 0 then x_scr=0 else x_scr=xs<xmx<x_scr
	if n_elements(y_scr) eq 0 then y_scr=0 else y_scr=ys<ymx<y_scr
	if n_elements(xpos) eq 0 then xpos=50
	if n_elements(ypos) eq 0 then ypos=50
	;---  Get scroll size that would be used, no window made  ----
	swindow, xs=xs,ys=ys, x_scr=x_scr, y_scr=y_scr, get_scroll=scr
	xoff = xpos
	yoff = sz0(1)-(scr(1)+ypos)
 
	;----  Pixmap?  -----------------------------------
	pixmap = keyword_set(pixmap0)
 
	;--------  Set window title  ----------------------
	sztxt = '  '+strtrim(xs,2)+' x '+strtrim(ys,2)	; Image size text.
	if n_elements(ttl0) eq 0 then begin		; Window title.
	  if datatype(imag) eq 'STR' then begin
	    filebreak, imag, nvfile=nam
	    ttl = nam + ':'
	  endif else ttl=''
	  ttl = ttl+sztxt
	endif else begin
	  ttl = ttl0
	  if keyword_set(addsize) then ttl=ttl+sztxt
	endelse
 
	;--------  Display window  ----------------------
	if n_elements(curr) ne 0 then begin		; Use current.
	  winlist,size=[xs,ys],win=win,/quiet,look=curr	; Look for win match.
	  if win eq -1 then begin			; Need new.
	    swindow, xs=xs,ys=ys, pixmap=pixmap, $
	      xoff=xoff, yoff=yoff, x_scr=x_scr, y_scr=y_scr,/quiet
	  endif else begin
	    wset, win					; Set to matched window.
	    wshow					; Force to front.
	  endelse
	endif else swindow, xs=xs,ys=ys, $		; Use new.
	            pixmap=pixmap,xoff=xoff,yoff=yoff, $
		    x_scr=x_scr,y_scr=y_scr, /quiet
 
	;--------  Add title --------------------------
	if n_elements(ttl0) eq 0 then begin		; Default title:
	  ttl = ttl + '  ' + strtrim(!d.window,2)	; Update with win index.
	endif else begin				; Title given.
	  if keyword_set(addsize) then $		; /ADDSIZE: also win.
	    ttl=ttl+'  '+strtrim(!d.window,2)
	endelse
	if pixmap eq 0 then begin
	  win_base = swinfo(/base)
	  if win_base ge 0 then $
	    widget_control,win_base,base_set_title=ttl ; Set window title.
	endif
 
	;--------  2-D image  --------------------------
	if tr eq 0 then begin
	  if n_elements(r) gt 0 then begin	; 2-D 8-bit palette image.
	    device, get_decomp=decomp
	    device,decomp=0
	    tvlct,r,g,b
	    tv,img,order=order
	    device,decomp=decomp
	  endif else begin			; 2-D gray scale image.
	    tv,img,order=order
	  endelse
	  return
	endif
 
	;--------  3-D image  --------------------------
	tv, img, true=tr,order=order
 
	end
