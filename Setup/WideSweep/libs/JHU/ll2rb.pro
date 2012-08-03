;-------------------------------------------------------------
;+
; NAME:
;       LL2RB
; PURPOSE:
;       From latitude, longitude compute range, bearing.
; CATEGORY:
; CALLING SEQUENCE:
;       ll2rb, lng0, lat0, lng1, lat1, dist, azi
; INPUTS:
;       lng0, lat0 = long, lat of reference point (deg).    in
;       lng1, lat1 = long, lat of point of interest (deg).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means range is in degrees instead of radians.
; OUTPUTS:
;       dist = range to point point of interest (radians).  out
;       azi = azimuth to point of interest (degrees).       out
; COMMON BLOCKS:
; NOTES:
;       Notes: A unit sphere is assumed, thus dist is in radians
;         so to get actual distance multiply dist by radius.
;         Useful constants:
;         Radius of Earth (mean) = 6371.23 km = 3958.899 miles.
;         (Must first convert to radians if using /DEGREES).
;         rb2ll is inverse.
;         ll2rbe is WGS84 ellipsoidal version.
; MODIFICATION HISTORY:
;       R. Sterner, 13 Feb,1991
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro ll2rb, lng1, lat1, lng2, lat2, dist, azi, degrees=deg, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' From latitude, longitude compute range, bearing.'
	  print,' ll2rb, lng0, lat0, lng1, lat1, dist, azi'
	  print,'   lng0, lat0 = long, lat of reference point (deg).    in'
	  print,'   lng1, lat1 = long, lat of point of interest (deg).  in'
	  print,'   dist = range to point point of interest (radians).  out'
	  print,'   azi = azimuth to point of interest (degrees).       out'
	  print,' Keywords:'
	  print,'   /DEGREES means range is in degrees instead of radians.'
	  print,' Notes: A unit sphere is assumed, thus dist is in radians'
	  print,'   so to get actual distance multiply dist by radius.'
	  print,'   Useful constants:'
	  print,'   Radius of Earth (mean) = 6371.23 km = 3958.899 miles.'
	  print,'   (Must first convert to radians if using /DEGREES).'
	  print,'   rb2ll is inverse.'
	  print,'   ll2rbe is WGS84 ellipsoidal version.'
	  return
	endif
 
	polrec3d, 1., (90.-lat2)/!radeg, lng2/!radeg, x1, y1, z1
	rot_3d, 3, x1, y1, z1, -(180.-lng1)/!radeg, x2, y2, z2
	rot_3d, 2, x2, y2, z2, -(90.-lat1)/!radeg, x3, y3, z3
	recpol3d, x3, y3, z3, r, dist, ax
	azi = (360. - ax*!radeg) mod 360.
	if keyword_set(deg) then dist=dist*!radeg
 
	return
	end
