;-------------------------------------------------------------
;+
; NAME:
;       TVPOS
; PURPOSE:
;       Gives screen position used by tv, tvscl.
; CATEGORY:
; CALLING SEQUENCE:
;       tvpos, img, n, x0, y0
; INPUTS:
;       img = Image of desired size (for size only).    in.
;         img may be an array, [nx,ny] giving
;         dimensions of desired image instead of
;         image itself (saves space).
;       n = Position number.                            in.
; KEYWORD PARAMETERS:
;       Keywords:
;         RESOLUTION=[rx,ry] Specify bounding array size instead
;           of using current screen size.  Allows tvpos to work
;           with an array with no reference to the screen.
; OUTPUTS:
;       x0, y0 = screen coordinates of lower left       out.
;          corner of tv position.
; COMMON BLOCKS:
; NOTES:
;       Note: On error x0 and y0 are -1.
; MODIFICATION HISTORY:
;       R. Sterner.  15 July, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 11 Dec, 1989 --- converted to SUN.
;       R. Sterner, 1995 Nov 21 --- Added RESOLUTION keyword.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro tvpos, img, pos, x0, y0, resolution=res, help=hlp
 
	if (n_params(0) LT 4) or keyword_set(hlp) then begin
	  print,' Gives screen position used by tv, tvscl.'
	  print,' tvpos, img, n, x0, y0
	  print,'   img = Image of desired size (for size only).    in.
	  print,'     img may be an array, [nx,ny] giving'
	  print,'     dimensions of desired image instead of'
	  print,'     image itself (saves space).'
	  print,'   n = Position number.                            in.
	  print,'   x0, y0 = screen coordinates of lower left       out.
	  print,'      corner of tv position.'
	  print,' Keywords:'
	  print,'   RESOLUTION=[rx,ry] Specify bounding array size instead'
	  print,'     of using current screen size.  Allows tvpos to work'
	  print,'     with an array with no reference to the screen.'
	  print,' Note: On error x0 and y0 are -1.
	  return
	endif
 
	s = size(img)
	if n_elements(img) eq 2 then s = [2,img]
 
	if s(0) ne 2 then begin
	  print,' Error in tvpos: first arg must be a 2-d array.'
	  x0 = -1
	  y0 = -1
	  return
	endif
 
	sx = s(1)		; size of array in X.
	sy = s(2)		; size of array in Y.
	xres = !d.x_size
	yres = !d.y_size
	if n_elements(res) ge 2 then begin
	  xres = res(0)
	  yres = res(1)
	endif
	xorig = 0		; POS number 0 coordinates.
	yorig = yres - 1 - sy
 
	nx = fix(xres/sx)	; Number of positions in X.
	ny = fix(yres/sy)	; number of positions in Y.
	if (pos lt 0) or (pos ge nx*ny) then begin
	  print,' Error in tvpos: Position number out of range.'
	  print,' Must be in range: 0 <= pos < '+strtrim(nx*ny,2)
	  x0 = -1
	  y0 = -1
	  return
	endif
 
	iy = fix(pos/nx)	; 2-d position indices.
	ix = pos - iy*nx
 
	x0 = xorig + ix*sx	; corner coordinates.
	y0 = yorig - iy*sy + 1
 
	return
	end
