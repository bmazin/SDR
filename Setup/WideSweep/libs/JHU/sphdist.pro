;-------------------------------------------------------------
;+
; NAME:
;       SPHDIST
; PURPOSE:
;       Angular distance between points on a sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       d = sphdist(long1, lat1, long2, lat2)
; INPUTS:
;       long1 = longitude of point 1.         in
;       lat1 = latitude of point 1.           in
;       long2 = longitude of point 2.         in
;       lat2 = latitude of point 2.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       d = angular distance between points.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: points 1 and 2 may be arrays.
; MODIFICATION HISTORY:
;       R. Sterner, 5 Feb, 1991
;       R. Sterner, 26 Feb, 1991 --- Renamed from sphere_dist.pro
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function sphdist, long1, lat1, long2, lat2, $
	  help=hlp, degrees=degrees
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Angular distance between points on a sphere.'
	  print,' d = sphdist(long1, lat1, long2, lat2)'
	  print,'   long1 = longitude of point 1.         in'
	  print,'   lat1 = latitude of point 1.           in'
	  print,'   long2 = longitude of point 2.         in'
	  print,'   lat2 = latitude of point 2.           in'
	  print,'   d = angular distance between points.  out'
	  print,' Keywords:'
	  print,'   /DEGREES means angles are in degrees, else radians.'
	  print,' Notes: points 1 and 2 may be arrays.'
	  return, -1
	endif
 
	cf = 1.0
	if keyword_set(degrees) then cf = !radeg
 
	;--- Convert both points to rectangular coordinates. ---
	polrec, 1.0, lat1/cf, rxy, z1
	polrec, rxy, long1/cf, x1, y1
	polrec, 1.0, lat2/cf, rxy, z2
	polrec, rxy, long2/cf, x2, y2
 
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
