;-------------------------------------------------------------
;+
; NAME:
;       MANDELBROT
; PURPOSE:
;       Compute Mandelbrot images
; CATEGORY:
; CALLING SEQUENCE:
;       Menu driven.
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 May, 1990
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro mandelbrot, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Compute Mandelbrot images'
	  print,'   Menu driven.'
	  return
	endif
 
	device,decomp=0
 
	erase
	wshow, 0, 0
	flag = 0
 
	print,' '
	print,' Mandelbrot set exploration'
	print,' '
	makevlt
	color	  ; Force 255 = white.
 
 
	menu = ['Mandelbrot','  Quit','  Compute initial image','  Zoom in',$
	        '  Recompute current image','  Change image size',$
	        '  Change number of iterations (currently 100)',$
		'  Save image','  Retrieve image','  New random color table',$
		'  Rotate color table (Press any key to stop)',$
		'  Color printout','  Hide this menu (click to unhide)']
 
	in = 2
	mx = 100
 
loop:	wshow, 0
	in = wmenu(menu, title=0, init=in)
	if in lt 0 then begin
	  in = 2
	  goto, loop
	endif
 
	if in eq 1 then return		; Quit.
 
	if in eq 2 then begin		; Compute initial image.
	  print,' Computing initial image . . .'
	  for ix = -1, 1 do begin
	    for iy = -1, 1 do begin
	      xyouts, 5+ix,5+iy,'Computing',/dev,color=0
	    endfor
	  endfor
	  xyouts, 5, 5, 'Computing',/dev
	  r = [-3, 1, 100, -2, 2, 100]
	  mx = 100
	  print,' Magnification = ',4./(r(1)-r(0))
	  mcompute, r, img, last=30
	  tvscl, img
	  flag = 1
	  goto, loop
	endif
 
	if in eq 3 then begin		; Zoom.
	  if flag eq 0 then begin
	    print,' Nothing to zoom.  First compute the initial image.'
	    goto, loop
	  endif
	  mzoom, r, img, r2
	  r = r2
	  for ix = -1, 1 do begin
	    for iy = -1, 1 do begin
	      xyouts, 5+ix,5+iy,'Computing',/dev,color=0
	    endfor
	  endfor
	  xyouts, 5, 5, 'Computing',/dev
	  print,' Magnification = ',4./(r(1)-r(0))
	  mcompute, r, img, /show, last=mx
	  goto, loop
	endif
 
	if in eq 4 then begin		; Recompute.
	  for ix = -1, 1 do begin
	    for iy = -1, 1 do begin
	      xyouts, 5+ix,5+iy,'Computing',/dev,color=0
	    endfor
	  endfor
	  xyouts, 5, 5, 'Computing',/dev
	  print,' Magnification = ',4./(r(1)-r(0))
	  mcompute, r, img, /show, last=mx
	  goto, loop
	endif
 
	if in eq 5 then begin		; Change image size.
	  nx = r(2)
	  ny = r(5)
	  x = 50  & y = 50
	  movbox, x, y, nx, ny, /noerase, xsize=1.
	  r(2) = nx
	  r(5) = ny
	  goto, loop
	endif
 
	if in eq 6 then begin		; Change number of iterations.
	  wshow,0,0
	  print,' Change number of iterations. Currently = '+strtrim(mx,2)
	  txt = ''
	  read,' Enter new number of iterations (def = current): ', txt
	  if txt ne '' then mx = txt + 0
	  menu(6) = '  Change number of iterations (currently '+$
	    strtrim(mx,2)+')'
	  goto, loop
	endif
 
	if in eq 7 then begin		; Save image.
	  wshow, 0, 0
	  txt = ''
	  read,' File name to save image in (no extension): ', txt
	  if txt eq '' then goto, loop
	  tvlct,rr,gg,bb,/get
	  save2,txt+'.mand',img,r,rr,gg,bb
	  print,' Image saved.'
	  goto, loop
	endif
 
	if in eq 8 then begin		; Retrieve image.
	  f = findfile('*.mand')
	  if f(0) eq '' then begin
	    in = wmenu(['No files found.  Click to continue'])
	    goto, loop
	  endif
	  f = ['Select image file to retrieve','  None',f]
	  in = wmenu(f, title=0, init=2)
	  if in lt 2 then goto, loop
	  f = f(in)
	  restore2,f,img,r,rr,gg,bb
	  tvlct,rr,gg,bb
	  tvscl,img
	  flag = 1
	  goto, loop
	endif
 
	if in eq 9 then begin		; New random color table.
	  print,' Press SPACE bar for new table, RETURN when done.'
	  tmp = bytscl(img)
loop9:	  k = get_kbrd(1)
	  k = (byte(k))(0)
	  if (k eq 13) or (k eq 10) then goto, loop
	  makevlt
	  color				  ; Force 255 = white.
	  tv,tmp
	  goto, loop9
	endif
 
	if in eq 10 then begin		; Rotate color table.
	  print,' Press any key to quit.'
	  tvscl,img
	  wait, 0
	  rotvlt
	  goto, loop
	endif
 
	if in eq 11 then begin	; Color printout.
	  nx = r(2)
	  ny = r(5)
	  a = tvrd(0,0,nx,ny)
	  tekcolor, a
	  goto, loop
	endif
 
	if in eq 12 then begin	; Hide menu.
	  cursor, x, y, /dev	; This hides menu and waits for a click.
	  goto, loop
	endif
 
	goto, loop
 
	end
