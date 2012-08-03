;-------------------------------------------------------------
;+
; NAME:
;       VASE
; PURPOSE:
;       Draw rotationally symetric shapes.
; CATEGORY:
; CALLING SEQUENCE:
;       vase
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: This program allows you to enter a profile,
;       then rotates this profile about the Y-axis and allows the
;       shape to be displayed at any angle. There are two modes:
;       Draw mode, and Display mode. Draw mode allows the profile
;       to be drawn with the mouse.  Use button 1 to add new points,
;       and button 2 to delete points.  Button 3 puts you in display
;       mode. Display mode allows the rotated shape to be drawn at
;       any angle. The mouse position determines the angle of the
;       shape, the direction of the cursor from the window center
;       determines the angle of the shape axis and the distance of
;       the cursor from the center determines the angle of the shape
;       toward or away from you
; MODIFICATION HISTORY:
;       R. Sterner,  19 Jan, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro vase, q, bw=bw, color=colr, stereo=ster, help=hlp
 
	if keyword_set(hlp) or 1 then begin
	  print,' Draw rotationally symetric shapes.'
	  print,' vase'
	  print,' Notes: This program allows you to enter a profile,'
	  print,' then rotates this profile about the Y-axis and allows the'
	  print,' shape to be displayed at any angle. There are two modes:'
	  print,' Draw mode, and Display mode. Draw mode allows the profile'
	  print,' to be drawn with the mouse.  Use button 1 to add new points,'
	  print,' and button 2 to delete points.  Button 3 puts you in display'
	  print,' mode. Display mode allows the rotated shape to be drawn at'
	  print,' any angle. The mouse position determines the angle of the'
	  print,' shape, the direction of the cursor from the window center'
	  print,' determines the angle of the shape axis and the distance of'
	  print,' the cursor from the center determines the angle of the shape'
	  print,' toward or away from you'
	  if keyword_set(hlp) then return
	endif
 
	txt = ''
	print,' '
	read,' Press RETURN to continue', txt
	set_isoxy, -100, 100, -100, 100
	erase
	wshow
	xx = intarr(1)
	yy = intarr(1)
	print,' '
	print,' Draw mode:'
	print,' Use cursor to draw outline to rotate about the Y axis.'
	print,' Button 1 = new point, button 2 = delete point, '+$
	  'Button 3 = draw shape.'
	ver, 0
loop:	cursor, x, y, /data			; Get cursor point and command.
	wait,.2
	if !err eq 1 then c='BUTTON_1'
	if !err eq 2 then c='BUTTON_2'
	if !err eq 4 then c='BUTTON_3'
	!err = 0
	if c eq 'BUTTON_3' then goto, next	; Draw shape.
	if c eq 'BUTTON_1' then begin		; Add new point.
	  xx = [xx,x]
	  yy = [yy,y]
	  if n_elements(xx) eq 2 then begin
	    oplot,[xx(1),xx(1)],[yy(1),yy(1)]
	  endif else begin
	    oplot, xx(1:*), yy(1:*)
	  endelse
	  goto, loop
	endif
	if c eq 'BUTTON_2' then begin		; Delete last point.
	  n = n_elements(xx)
	  if n ge 2 then begin
	    xx = xx(0:n-2)
	    yy = yy(0:n-2)
	    erase
	    ver, 0
	    oplot, xx(1:*), yy(1:*)
	  endif
	  goto, loop
	endif
 
next:	if n_elements(xx) eq 1 then return	; Make volume.
	xx = transpose(xx(1:*))
	yy = transpose(yy(1:*))
	zz = xx*0
	n = n_elements(xx)
	vx = fltarr(36, n)  & vy = vx  & vz = vx
	for i = 0, 35 do begin
	  rot_3d, 2, xx, yy, zz, (i*10.)/!radeg, tx, ty, tz
	  vx(i,0) = tx  & vy(i,0) = ty  & vz(i,0) = tz
	endfor
 
	if (not keyword_set(bw)) and (not keyword_set(ster)) then colr=1
 
	set_isoxy, -120, 120, -120, 120
	print,' '
	print,' Display mode:'
	print,' mouse cursor position from window center orients shape.'
	print,' Button 1 = draw shape,  button 3 = done.'
	x0 = .5  & y0 = .58333
	erase
	goto, first
rloop:	cursor, x0, y0, /norm			; Get cursor point and command.
	wait,.2
	if !err eq 1 then c='BUTTON_1'
	if !err eq 2 then c='BUTTON_2'
	if !err eq 4 then c='BUTTON_3'
	!err = 0
	if c eq 'BUTTON_3' then return
 
first:	x = x0 - .5
	y = y0 - .5
	az = -atan(y,x)-90./!radeg
	ax = -(sqrt(x^2+y^2)*720.+90.)/!radeg
	print,' Rotate about x axis by '+strtrim(ax*!radeg,2)+' deg'
	print,' Rotate about z axis by '+strtrim(az*!radeg,2)+' deg'
 
	if keyword_set(colr) then begin
	  rot_3d, 1, vx, vy, vz, ax, tx1, ty1, tz1
	  rot_3d, 3, tx1, ty1, tz1, az, tx, ty, tz
	  erase
	  clr = maken(1,253,36)
	  for i = 0,35 do oplot, tx(i,*), ty(i,*), color=clr(i)
	  clr = maken(1,253,n)
	  for i = 0, n-1 do oplot, [tx(*,i),tx(0,i)], $
	    [ty(*,i),ty(0,i)], color=clr(i)
	endif
 
	if keyword_set(bw) then begin
	  rot_3d, 1, vx, vy, vz, ax, tx1, ty1, tz1
	  rot_3d, 3, tx1, ty1, tz1, az, tx, ty, tz
	  erase
	  for i = 0,35 do oplot, tx(i,*), ty(i,*)
	  for i = 0, n-1 do oplot, [tx(*,i),tx(0,i)], [ty(*,i),ty(0,i)]
	endif
 
	if keyword_set(ster) then begin
	  rot_3d, 1, vx, vy, vz, ax, tx1, ty1, tz1
	  rot_3d, 3, tx1, ty1, tz1, az, tx, ty, tz
	  stereo, /ct
	  device, set_graphics=3
	  erase
	  device, set_graphics=7
	  rot_3d, 2, tx, ty, tz, 4./!radeg, txg, tyg, tzg
	  for i = 0,35 do oplot, txg(i,*), tyg(i,*), color=2
	  for i = 0, n-1 do oplot, [txg(*,i),txg(0,i)], $
	    [tyg(*,i),tyg(0,i)], color=2
	  for i = 0,35 do oplot, tx(i,*), ty(i,*), color=1
	  for i = 0, n-1 do oplot, [tx(*,i),tx(0,i)], $
	    [ty(*,i),ty(0,i)], color=1
	  device, set_graphics=3
	endif
 
	goto, rloop
 
	return
	end
