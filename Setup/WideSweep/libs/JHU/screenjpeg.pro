;-------------------------------------------------------------
;+
; NAME:
;       SCREENJPEG
; PURPOSE:
;       Display a jpeg image in a screen window.
; CATEGORY:
; CALLING SEQUENCE:
;       screenjpeg, [file]
; INPUTS:
;       file = name of JPEG file.   in
;       MAG=mag     Magnification factor (def=1).
;         May be a 2 element array: [magx,magy].
;       /PIXMAP use a pixmap window.  convert_coord needs actual
;         window size to handle conversions to/from /dev.
;       WINDOW=win  Returned index of display window.
;       ERROR=err   Returned error flag: 0=ok, 1=not displayed.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Prompts for file if called with no args.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jan 17
;       R. Sterner, 2000 Jun 29 --- Modified for 24 bit color.
;       R. Sterner, 2002 Apr 11 --- /PIXEMAP, ERROR=err, and MAG=mag.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro screenjpeg, file, mag=mag, pixmap=pixmap, error=err, $
	  window=outwin, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Display a jpeg image in a screen window.'
	  print,' screenjpeg, [file]'
	  print,'   file = name of JPEG file.   in'
	  print,'   MAG=mag     Magnification factor (def=1).'
	  print,'     May be a 2 element array: [magx,magy].'
	  print,'   /PIXMAP use a pixmap window.  convert_coord needs actual'
	  print,'     window size to handle conversions to/from /dev.'
	  print,'   WINDOW=win  Returned index of display window.'
	  print,'   ERROR=err   Returned error flag: 0=ok, 1=not displayed.'
	  print,' Notes: Prompts for file if called with no args.'
	  return
	endif
 
	if n_elements(mag) eq 0 then mag=1.
 
	if n_elements(file) eq 0 then begin
	  print,' '
	  print,' Display a jpeg image in a screen window.'
	  file = ''
	  read,' Enter name of JPEG file: ',file
	  if file eq '' then return
	endif
 
	;---------  Handle file name  -------------
	filebreak,file,dir=dir,name=name,ext=ext
	if ext eq '' then begin
	  print,' Adding .jpg as the file extension.'
	  ext = 'jpg'
	endif
	if ext ne 'jpg' then begin
	  print,' Warning: non-standard extension: '+ext
	  print,' Standard extension is jpg.'
	endif
	name = name + '.' + ext
	fname = filename(dir,name,/nosym)
 
	;-------  Determine if true or pseudo color  ------
	device, get_visual_name=vis	; Get visual type.
	vflag = vis ne 'PseudoColor'	; 0 if PseudoColor.
 
	;--------  Read JPEG file  -------------
	if vflag eq 0 then begin	; 8 bit image.
	  print,' Reading '+fname
	  read_jpeg,fname,img,rgb,/dither,/two_pass,colors=256
	endif else begin
	  img = read_image(fname)
	endelse
 
	;---------  Resize  ---------------------
	img = img_resize(img, mag=mag)
 
	;---------  Display  --------------------
	img_shape, img, nx=nx, ny=ny, true=tr
	tt = fname+'  ('+strtrim(nx,2)+','+strtrim(ny,2)+')'
 
	;---------  Pixmap window  -----------------------
	if keyword_set(pixmap) then begin
	  window,xs=nx,ys=ny,/pixmap,/free
	;---------  Visible window  ----------------------
	endif else begin
	  if (nx gt 1200) or (ny gt 900) then begin
	    swindow,xs=nx,ys=ny,x_scr=nx<1200,y_scr=ny<900,titl=tt
	  endif else begin		; 24 bit image.
	    window,xs=nx,ys=ny,titl=tt
	  endelse
	endelse
 
	outwin = !d.window
 
	if vflag eq 0 then begin	; 8 bit image.
	  tv, img
	  tvlct,rgb
	endif else begin		; 24 bit image.
	  tv,img,true=1
	endelse
 
	return
 
	end
