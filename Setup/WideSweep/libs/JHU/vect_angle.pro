;-------------------------------------------------------------
;+
; NAME:
;       VECT_ANGLE
; PURPOSE:
;       Angular distance between vectors.
; CATEGORY:
; CALLING SEQUENCE:
;       ang = vect_angle(x1,y1,z1, x2,y2,z2)
; INPUTS:
;       x1,y1,z1 = coordinates of point 1.      in
;       x2,y2,z2 = coordinates of point 2.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       a = angular distance between points.    out
; COMMON BLOCKS:
; NOTES:
;       Notes: points 1 and 2 may be arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Feb, 1991
;       R. Sterner, 26 Feb, 1991 --- Renamed from vector_angle.pro
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function vect_angle, x1,y1,z1, x2,y2,z2, $
	  help=hlp, degrees=degrees
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Angular distance between vectors.'
	  print,' ang = vect_angle(x1,y1,z1, x2,y2,z2)'
	  print,'   x1,y1,z1 = coordinates of point 1.      in'
	  print,'   x2,y2,z2 = coordinates of point 2.      in'
	  print,'   a = angular distance between points.    out'
	  print,' Keywords:'
	  print,'   /DEGREES means angles are in degrees, else radians.'
	  print,' Notes: points 1 and 2 may be arrays.'
	  return, -1
	endif
 
	cf = 1.0
	if keyword_set(degrees) then cf = !radeg
 
	;--- Compute vector dot product for both points. ---
	cs = x1*x2 + y1*y2 + z1*z2
 
	;--- Compute the vector cross product for both points. ---
	xc = y1*z2 - z1*y2
	yc = z1*x2 - x1*z2
	zc = x1*y2 - y1*x2
	sn = sqrt(xc*xc + yc*yc + zc*zc)
 
	;--- Convert to polar.  ------
	recpol, cs, sn, r, a
	return, cf*a
 
	end
