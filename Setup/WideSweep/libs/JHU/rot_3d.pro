;-------------------------------------------------------------
;+
; NAME:
;       ROT_3D
; PURPOSE:
;       Rotate 3-d coordinate system.
; CATEGORY:
; CALLING SEQUENCE:
;       rot_3d, axis, x1, y1, z1, ang, x2, y2, z2
; INPUTS:
;       axis=Axis number to rotate about: 1=X, 2=Y, 3=Z.     in
;       x1, y1, z1 = arrays of original x,y,z vector comp.   in
;       ang = rotation angle in radians.                     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       x2, y2, z2 = arrays of new x,y,z vector components.  out
; COMMON BLOCKS:
; NOTES:
;       Note: Right-hand rule is used: Point thumb along +axis.
;         Fingers curl in vector rotation direction (for +ang).
;         This is for coordinate system rotation.  To rotate the
;         vectors in a fixed coord. system use the left hand rule.
; MODIFICATION HISTORY:
;       R. Sterner.  28 Jan, 1987.
;       6 May, 1988 --- modified to work with any shape arrays.
;       R. Sterner, 6 Nov, 1989 --- converted to SUN.
;       RES 13 Feb, 1991 --- added /degrees.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro rot_3d, axis, x1, y1, z1, ang, x2, y2, z2, help=hlp, $
	  degrees=degrees
 
	if (n_params(0) ne 8) or keyword_set(hlp) then begin
	  print,' Rotate 3-d coordinate system.'
	  print,' rot_3d, axis, x1, y1, z1, ang, x2, y2, z2'
	  print,'   axis=Axis number to rotate about: 1=X, 2=Y, 3=Z.     in'
	  print,'   x1, y1, z1 = arrays of original x,y,z vector comp.   in'
	  print,'   ang = rotation angle in radians.                     in'
	  print,'   x2, y2, z2 = arrays of new x,y,z vector components.  out'
	  print,' Keywords:'
          print,'   /DEGREES means angle is in degrees, else radians.'
	  print,' Note: Right-hand rule is used: Point thumb along +axis.'
	  print,'   Fingers curl in vector rotation direction (for +ang).'
	  print,'   This is for coordinate system rotation.  To rotate the'
	  print,'   vectors in a fixed coord. system use the left hand rule.'
	  return
	endif
 
        if keyword_set(degrees) then begin
          c = cos(ang/!radeg)
          s = sin(ang/!radeg)
        endif else begin
          c = cos(ang)
          s = sin(ang)
        endelse
 
	case axis of			; depending on axis.
1:	begin
	  x2 =  x1
	  y2 =  c*y1 + s*z1
	  z2 = -s*y1 + c*z1
	end
2:	begin
	  x2 = c*x1 - s*z1
	  y2 = y1
	  z2 = s*x1 + c*z1
	end
3:	begin
	  x2 =  c*x1 + s*y1
	  y2 = -s*x1 + c*y1
	  z2 = z1
	end
else:	begin
	  print,'Invalid axis number: must be 1 for X, 2 for Y, 3 for Z.'
	  return
	end
	endcase
 
	return
	end
