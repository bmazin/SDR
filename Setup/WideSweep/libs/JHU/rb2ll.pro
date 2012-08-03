;-------------------------------------------------------------
;+
; NAME:
;       RB2LL
; PURPOSE:
;       From range, bearing compute latitude, longitude .
; CATEGORY:
; CALLING SEQUENCE:
;       rb2ll, lng0, lat0, dist, azi, lng1, lat1
; INPUTS:
;       lng0, lat0 = long, lat of starting point (deg).     in
;       dist = range to point of interest in RADIANS.       in
;       azi = azimuth to point of interest (degrees).       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means distance is in degrees instead of radians.
; OUTPUTS:
;       lng1, lat1 = long, lat of point of interest (deg).  out
; COMMON BLOCKS:
; NOTES:
;       Notes: A unit sphere is assumed, thus dist is in radians.
;         Useful constants:
;         Radius of Earth (mean) = 6371.23 km = 3958.899 miles.
;         Distance to horizon from height H above surface:
;           For small H: dist = sqrt(2*H/R) in Radians
;           For large H: dist = acos(R/(R+H)) in Radians
;         To plot horizon from lat0, lng0, H:
;           rb2ll,lng0,lat0,dist,makex(0,360,1),plng,plat
;           plots,plng-360.,plat,psym=3
;         ll2rb is inverse.
;         rb2lle is WGS84 ellipsoidal version.
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
 
	pro rb2ll, lng1, lat1, dist, azi, lng2, lat2, degrees=deg, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' From range, bearing compute latitude, longitude .'
	  print,' rb2ll, lng0, lat0, dist, azi, lng1, lat1'
	  print,'   lng0, lat0 = long, lat of starting point (deg).     in'
	  print,'   dist = range to point of interest in RADIANS.       in'
	  print,'   azi = azimuth to point of interest (degrees).       in'
	  print,'   lng1, lat1 = long, lat of point of interest (deg).  out'
	  print,' Keywords:'
	  print,'   /DEGREES means distance is in degrees instead of radians.'
	  print,' Notes: A unit sphere is assumed, thus dist is in radians.'
          print,'   Useful constants:'
          print,'   Radius of Earth (mean) = 6371.23 km = 3958.899 miles.'
	  print,'   Distance to horizon from height H above surface:'
	  print,'     For small H: dist = sqrt(2*H/R) in Radians'
	  print,'     For large H: dist = acos(R/(R+H)) in Radians'
	  print,'   To plot horizon from lat0, lng0, H:'
	  print,'     rb2ll,lng0,lat0,dist,makex(0,360,1),plng,plat
	  print,'     plots,plng-360.,plat,psym=3'
	  print,'   ll2rb is inverse.'
	  print,'   rb2lle is WGS84 ellipsoidal version.'
	  return
	endif
 
	ax = (360. - azi)/!radeg
	d = dist
	if keyword_set(deg) then d=dist/!radeg
	polrec3d, 1., d, ax, x3, y3, z3
	rot_3d, 2, x3, y3, z3, (90.-lat1)/!radeg, x2, y2, z2
	rot_3d, 3, x2, y2, z2, (180.-lng1)/!radeg, x1, y1, z1
	recpol3d, x1, y1, z1, r, az, ax
	lng2 = ax*!radeg
	lat2 = 90. - az*!radeg
 
	return
	end
