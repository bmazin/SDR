;-------------------------------------------------------------
;+
; NAME:
;       RECPOL3D
; PURPOSE:
;       Convert vector(s) from rectangular to spherical polar form.
; CATEGORY:
; CALLING SEQUENCE:
;       recpol3d, x, y, z, r, az, ax
; INPUTS:
;       x = X component.          in
;       y = Y component.          in
;       z = Z component.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       r = Radius.               out
;       az = angle from Z axis.   out
;       ax = angle from X axis.   out
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
 
 
	pro recpol3d, x, y, z, r, az, ax, help=hlp, degrees=degrees
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Convert vector(s) from rectangular to spherical polar form.
	  print,' recpol3d, x, y, z, r, az, ax
	  print,'   x = X component.          in
	  print,'   y = Y component.          in
	  print,'   z = Z component.          in
	  print,'   r = Radius.               out
	  print,'   az = angle from Z axis.   out
	  print,'   ax = angle from X axis.   out
          print,' Keywords:'
          print,'   /DEGREES means angles are in degrees, else radians.'
	  return
	endif
 
	recpol, x, y, rxy, ax, degrees=degrees
	recpol, z, rxy, r, az, degrees=degrees
 
	return
	end
