;-------------------------------------------------------------
;+
; NAME:
;       LL2RBE
; PURPOSE:
;       For two points on WGS84 ellipsoid return range and bearing.
; CATEGORY:
; CALLING SEQUENCE:
;       ll2rbe, lng1, lat1, lng2, lat2, dist, azi1, azi2
; INPUTS:
;       lng1, lat1 = Point 1 geodetic long and lat (deg).  in
;       lng2, lat2 = Point 2 geodetic long and lat (deg).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dist = Distance along surface of ellipsoid (m).    out
;       azi1 = forward geodetic azimuth (pt1 to pt2, deg). out
;       azi1 = reverse geodetic azimuth (pt2 to pt1, deg). out
; COMMON BLOCKS:
; NOTES:
;       Notes: Uses T. Vincenty's method.  Converted to IDL from
;       FORTRAN code at ftp://www.ngs.noaa.gov/pub/pcsoft/for_inv.3d/source/inverse.for
;       Example:
;         lng1, lat1 = 144.42486788D0, -37.95103341D0
;         lng2, lat2 = 143.92649552D0, -37.65282113D0
;       Computed:
;         dist = 54972.271 meters
;         azi1 = 306.86816 deg
;         azi2 = 127.17363 deg
;       
;       The Vicenty formulae should be good over distances from
;       a few cm to nearly 20,000 km with millimeter accuracy.
;       rb2lle is inverse.
;       ll2rb is spherical version.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 04
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ll2rbe, lng1, lat1, lng2, lat2, dist, azi1, azi2, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' For two points on WGS84 ellipsoid return range and bearing.'
	  print,' ll2rbe, lng1, lat1, lng2, lat2, dist, azi1, azi2'
	  print,'   lng1, lat1 = Point 1 geodetic long and lat (deg).  in'
	  print,'   lng2, lat2 = Point 2 geodetic long and lat (deg).  in'
	  print,'   dist = Distance along surface of ellipsoid (m).    out'
	  print,'   azi1 = forward geodetic azimuth (pt1 to pt2, deg). out'
	  print,'   azi1 = reverse geodetic azimuth (pt2 to pt1, deg). out'
	  print," Notes: Uses T. Vincenty's method.  Converted to IDL from"
	  print,' FORTRAN code at ftp://www.ngs.noaa.gov/pub/pcsoft/for_inv.3d/source/inverse.for'
	  print,' Example:'
	  print,'   lng1, lat1 = 144.42486788D0, -37.95103341D0'
	  print,'   lng2, lat2 = 143.92649552D0, -37.65282113D0'
	  print,' Computed:'
	  print,'   dist = 54972.271 meters'
	  print,'   azi1 = 306.86816 deg'
	  print,'   azi2 = 127.17363 deg'
	  print,' '
	  print,' The Vicenty formulae should be good over distances from'
	  print,' a few cm to nearly 20,000 km with millimeter accuracy.'
	  print,' rb2lle is inverse.'
	  print,' ll2rb is spherical version.'
	  return
	endif
 
;--------------  Comments from the FORTRAN code  --------------------
; *** SOLUTION OF THE GEODETIC INVERSE PROBLEM AFTER T.VINCENTY
; *** MODIFIED RAINSFORD'S METHOD WITH HELMERT'S ELLIPTICAL TERMS
; *** EFFECTIVE IN ANY AZIMUTH AND AT ANY DISTANCE SHORT OF ANTIPODAL
; *** STANDPOINT/FOREPOINT MUST NOT BE THE GEOGRAPHIC POLE
;
; *** A IS THE SEMI-MAJOR AXIS OF THE REFERENCE ELLIPSOID
; *** F IS THE FLATTENING (NOT RECIPROCAL) OF THE REFERNECE ELLIPSOID
; *** LATITUDES AND LONGITUDES IN RADIANS POSITIVE NORTH AND EAST
; *** FORWARD AZIMUTHS AT BOTH POINTS RETURNED IN RADIANS FROM NORTH
;
; *** PROGRAMMED FOR CDC-6600 BY LCDR L.PFEIFER NGS ROCKVILLE MD 18FEB75
; *** MODIFIED FOR IBM SYSTEM 360 BY JOHN G GERGEN NGS ROCKVILLE MD 7507
;--------------------------------------------------------------------
 
	;--------  WGS84 constants (www.wgs84.com) --------------
	f = 1.D0/298.257223563D0	; Flattening factor.
	a = 6378137.0D0			; Semimajor axis (m).
 
	;---------  Initial values  --------------------
	dtor = !dpi/180D0		; Degrees to radians.
	eps = 0.5D-13			; Tolerence.
	glon1 = lng1*dtor
	glat1 = lat1*dtor
	glon2 = lng2*dtor
	glat2 = lat2*dtor
 
	r = 1D0 - f
	tu1 = r*sin(glat1)/cos(glat1)
	tu2 = r*sin(glat2)/cos(glat2)
	cu1 = 1/sqrt(1+tu1*tu1)
	su1 = cu1*tu1
	cu2 = 1/sqrt(1+tu2*tu2)
	s = cu1*cu2
	baz = s*tu2
	faz = baz*tu1
	x = glon2 - glon1
 
	;-----  Iterate  ---------------
	repeat begin
	  sx = sin(x)
	  cx = cos(x)
	  tu1 = cu2*sx
	  tu2 = baz - su1*cu2*cx
	  sy = sqrt(tu1*tu1 + tu2*tu2)
	  cy = s*cx + faz
	  y = atan(sy,cy)
	  sa = s*sx/sy
	  c2a = -sa*sa + 1
	  cz = faz + faz
	  if c2a gt 0 then cz=-cz/c2a + cy
	  e = cz*cz*2 - 1
	  c = ((-3*c2a+4)*f+4)*c2a*f/16
	  d = x
	  x = ((e*cy*c + cz)*sy*c + y)*sa
	  x = (1 - c)*x*f + glon2-glon1
	endrep until abs(d-x) le eps
 
	;------  Finish up  ----------------
	faz = atan(tu1,tu2)
	baz = atan(cu1*sx, baz*cx-su1*cu2) + !dpi
	x = sqrt((1/r/r - 1)*c2a + 1) + 1
	x = (x-2)/x
	c = 1 - x
	c = (x*x/4 + 1)/c
	d = (0.375*x*x - 1)*x
	x = e*cy
	s = 1 - e*e
	dist = ((((sy*sy*4 - 3)*s*cz*d/6 - x)*d/4 + cz)*sy*d + y)*c*a*r
 
	azi1 = faz/dtor
	if azi1 lt 0 then azi1 = azi1 + 360
	azi2 = baz/dtor
	if azi2 lt 0 then azi2 = azi2 + 360
 
	end
