;-------------------------------------------------------------
;+
; NAME:
;       SCREENGIF
; PURPOSE:
;       Display a GIF image in a screen window.
; CATEGORY:
; CALLING SEQUENCE:
;       screengif, [file]
; INPUTS:
;       file = name of GIF file.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         WINDOW=win  Returned index of display window.
;            -2 means Z buffer.
;         ERROR=err   Returned error flag: 0=ok, 1=not displayed.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Prompts for file if called with no args.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 1.
;       R. Sterner, 2000 May 22 --- Fixed to work with Z buffer, set_scale.
;       R. Sterner, 2000 Dec 26 --- Added image array return.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro screengif, file, window=outwin, error=err, image=img, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Display a GIF image in a screen window.'
	  print,' screengif, [file]'
	  print,'   file = name of GIF file.   in'
	  print,' Keywords:'
	  print,'   WINDOW=win  Returned index of display window.'
	  print,'      -2 means Z buffer.'
	  print,'   ERROR=err   Returned error flag: 0=ok, 1=not displayed.'
	  print,' Notes: Prompts for file if called with no args.'
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' '
	  print,' Display a gif image in a screen window.'
	  file = ''
	  read,' Enter name of GIF file: ',file
	  if file eq '' then return
	endif
 
	;---------  Handle file name  -------------
	filebreak,file,dir=dir,name=name,ext=ext
	if ext eq '' then begin
	  print,' Adding .gif as the file extension.'
	  ext = 'gif'
	endif
	if ext ne 'gif' then begin
	  print,' Warning: non-standard extension: '+ext
	  print,' Standard extension is gif.'
	endif
	name = name + '.' + ext
	fname = filename(dir,name,/nosym)
 
	;--------  Read GIF file  -------------
	f = findfile(fname,count=c)
	if c eq 0 then begin
	  print,' GIF image not found: '+fname
	  err=1
	  return
	endif
	print,' Reading '+fname
	read_gif,fname,img,r,g,b
 
	;---------  Display  --------------------
	if !d.name eq 'X' then begin
	  device,get_decomp=decomp
	  device,decomp=0
	endif
 
	sz=size(img) & nx=sz(1) & ny=sz(2)
	tt = fname+'  ('+strtrim(nx,2)+','+strtrim(ny,2)+')'
 
	if !d.name eq 'Z' then begin
	  device,set_res=[nx,ny]
	  outwin = '-2'
	endif else begin
	  if (nx gt 1200) or (ny gt 900) then begin
	    swindow,xs=nx,ys=ny,x_scr=nx<1200,y_scr=ny<900,titl=tt
	  endif else begin
	    window,/free,xs=nx,ys=ny,titl=tt
	  endelse
	  outwin = !d.window
	endelse
 
	tvlct,r,g,b
	tv, img
 
	set_scale, image=img, /quiet
	map_set_scale, image=img
 
	if !d.name eq 'X' then device,decomp=decomp
	err = 0
	return
 
	end
