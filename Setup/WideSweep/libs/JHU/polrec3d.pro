;-------------------------------------------------------------
;+
; NAME:
;       POLREC3D
; PURPOSE:
;       Convert vector(s) from spherical polar to rectangular form.
; CATEGORY:
; CALLING SEQUENCE:
;       polrec3d, r, az, ax, x, y, z
; INPUTS:
;       r = Radius.              in
;       az = angle from Z axis.  in
;       ax = angle from X axis.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       x = x component.         out
;       y = y component.         out
;       z = z component.         out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;       RES 13 Feb, 1991 --- added /degrees.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro polrec3d, r, az, ax, x, y, z, help=hlp, degrees=degrees
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Convert vector(s) from spherical polar to rectangular form.
	  print,' polrec3d, r, az, ax, x, y, z
	  print,'   r = Radius.              in
	  print,'   az = angle from Z axis.  in
	  print,'   ax = angle from X axis.  in
	  print,'   x = x component.         out
	  print,'   y = y component.         out
	  print,'   z = z component.         out
          print,' Keywords:'
          print,'   /DEGREES means angles are in degrees, else radians.'
	  return
	endif
 
	polrec, r, az, z, rxy, degrees=degrees
	polrec, rxy, ax, x, y, degrees=degrees
 
	return
	end
