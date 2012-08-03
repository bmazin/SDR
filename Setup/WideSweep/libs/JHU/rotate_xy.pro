;-------------------------------------------------------------
;+
; NAME:
;       ROTATE_XY
; PURPOSE:
;       Rotate a set of X,Y points about a given point.
; CATEGORY:
; CALLING SEQUENCE:
;       rotate_xy, x1, y1, ang, x0, y0, x2, y2
; INPUTS:
;       x1, y1 = original points to rotate.          in
;          Arrays or scalars.
;       ang = angle to rotate by in radians (CCW).   in
;       x0, y0 = center to rotate about.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       x2, y2 = rotated points.                     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 22 Oct, 1986.
;       R. Sterner, 22 Jan, 1990 --- converted to SUN.
;       RES 13 Feb, 1991 --- added /degrees.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO ROTATE_XY, X1, Y1, ANG, X0, Y0, X2, Y2, help=hlp, degrees=degrees
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Rotate a set of X,Y points about a given point.'
	  print,' rotate_xy, x1, y1, ang, x0, y0, x2, y2'
	  print,'   x1, y1 = original points to rotate.          in'
	  print,'      Arrays or scalars.'
	  print,'   ang = angle to rotate by in radians (CCW).   in'
	  print,'   x0, y0 = center to rotate about.             in'
	  print,'   x2, y2 = rotated points.                     out'
	  print,' Keywords:'
          print,'   /DEGREES means angle is in degrees, else radians.'
          return
        endif
 
	if keyword_set(degrees) then begin
	  CS = COS(ANG/!radeg)
	  SN = SIN(ANG/!radeg)
	endif else begin
	  CS = COS(ANG)
	  SN = SIN(ANG)
	endelse
 
	X11 = X1 - X0
	Y11 = Y1 - Y0
	X2 = X11*CS - Y11*SN + X0
	Y2 = X11*SN + Y11*CS + Y0
 
	RETURN
	END
