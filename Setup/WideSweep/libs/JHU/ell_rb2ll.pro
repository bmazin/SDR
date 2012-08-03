;-------------------------------------------------------------
;+
; NAME:
;       ELL_RB2LL
; PURPOSE:
;       From range and bearing on an ellipsoid compute a point.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_rb2ll, lng1, lat1, dist, azi1, lng2, lat2, azi2
; INPUTS:
;       lng1,lat1 = Starting point geodetic long and lat (deg). in
;       dist = Distance along surface of ellipsoid (m).         in
;       azi1 = Geodetic azimuth from starting point.            in
;         Inputs may be arrays.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       lng2,lat2 = End point geodetic long and lat (deg).      out
;       azi2 = Reverse geodetic azimuth from end to start (deg).out
; COMMON BLOCKS:
; NOTES:
;       Notes: Use ellipsoid,set=name to set working ellipsoid.
;       Uses T. Vincenty's method. Converted to IDL from FORTRAN code
;       at ftp://www.ngs.noaa.gov/pub/pcsoft/for_inv.3d/source/forward.for
;       
;       Reference: Direct and Inverse Solutions of Geodesics on the
;       Ellipsoid with Applications of Nested Equations.
;       T. Vincenty, Survey Review XXII, 176, April 1975. p 88-93.
;       
;       The Vicenty formulae should be good over distances from
;       a few cm to nearly 20,000 km with millimeter accuracy.
;       ell_ll2rb is inverse.
;       rb2ll is spherical version.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 04
;       R. Sterner, 2002 May 01 --- Generalized ellipsoid.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_rb2ll, lng1, lat1, dist, azi1, lng2, lat2, azi2, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' From range and bearing on an ellipsoid compute a point.'
	  print,' ell_rb2ll, lng1, lat1, dist, azi1, lng2, lat2, azi2'
	  print,'   lng1,lat1 = Starting point geodetic long and lat (deg). in'
	  print,'   dist = Distance along surface of ellipsoid (m).         in'
	  print,'   azi1 = Geodetic azimuth from starting point.            in'
	  print,'     Inputs may be arrays.'
	  print,'   lng2,lat2 = End point geodetic long and lat (deg).      out'
	  print,'   azi2 = Reverse geodetic azimuth from end to start (deg).out'
	  print,' Notes: Use ellipsoid,set=name to set working ellipsoid.'
	  print," Uses T. Vincenty's method. Converted to IDL from FORTRAN code"
	  print,' at ftp://www.ngs.noaa.gov/pub/pcsoft/for_inv.3d/source/forward.for'
	  print,' '
	  print,' Reference: Direct and Inverse Solutions of Geodesics on the'
	  print,' Ellipsoid with Applications of Nested Equations.'
	  print,' T. Vincenty, Survey Review XXII, 176, April 1975. p 88-93.'
	  print,' '
	  print,' The Vicenty formulae should be good over distances from'
	  print,' a few cm to nearly 20,000 km with millimeter accuracy.'
	  print,' ell_ll2rb is inverse.'
	  print,' rb2ll is spherical version.'
	  return
	endif
 
;--------------  Comments from the FORTRAN code  --------------------
; *** SOLUTION OF THE GEODETIC DIRECT PROBLEM AFTER T.VINCENTY
; *** MODIFIED RAINSFORD'S METHOD WITH HELMERT'S ELLIPTICAL TERMS
; *** EFFECTIVE IN ANY AZIMUTH AND AT ANY DISTANCE SHORT OF ANTIPODAL
;
; *** A IS THE SEMI-MAJOR AXIS OF THE REFERENCE ELLIPSOID
; *** F IS THE FLATTENING OF THE REFERENCE ELLIPSOID
; *** LATITUDES AND LONGITUDES IN RADIANS POSITIVE NORTH AND EAST
; *** AZIMUTHS IN RADIANS CLOCKWISE FROM NORTH
; *** GEODESIC DISTANCE S ASSUMED IN UNITS OF SEMI-MAJOR AXIS A
;
; *** PROGRAMMED FOR CDC-6600 BY LCDR L.PFEIFER NGS ROCKVILLE MD 20FEB75
; *** MODIFIED FOR SYSTEM 360 BY JOHN G GERGEN NGS ROCKVILLE MD 750608
;--------------------------------------------------------------------
 
	;--------  WGS84 constants (www.wgs84.com)  -------------
;	f = 1.D0/298.257223563D0	; Flattening factor.
;	a = 6378137.0D0
	ellipsoid, get=ell		; Get working ellipsoid.
	a = ell.a			; Semimajor axis (m).
	f = 1.D0/ell.f1			; Flattening factor.
 
	;---------  Initial values  --------------------
	dtor = !dpi/180D0		; Degrees to radians.
	eps = 0.5D-13			; Tolerence.
	glon1 = lng1*dtor
	glat1 = lat1*dtor
	faz = azi1*dtor
 
	r = 1D0 - f
	tu = r*sin(glat1)/cos(glat1)
	sf = sin(faz)
	cf = cos(faz)
	baz = 0.D0*faz		; Want as many baz az faz.
;	if cf ne 0 then baz=atan(tu,cf)*2
	w = where(cf ne 0D0, cnt)
	if cnt gt 0 then baz(w)=atan(tu(w),cf(w))*2
	cu = 1/sqrt(tu*tu + 1)
	su = tu*cu
	sa = cu*sf
	c2a = -sa*sa + 1
	x = sqrt((1/r/r - 1)*c2a + 1) + 1
	x = (x - 2)/x
	c = 1 - x
	c = (x*x/4 + 1)/c
	d = (0.375D0*x*x - 1)*x
	tu = dist/r/a/c
	y = tu
 
	;------  Iterate  --------------
	repeat begin
	  sy = sin(y)
	  cy = cos(y)
	  cz = cos(baz + y)
	  e = cz*cz*2 - 1
	  c = y
	  x = e*cy
	  y = e + e - 1
	  y = (((sy*sy*4 - 3)*y*cz*d/6 + x)*d/4 - cz)*sy*d + tu
	endrep until max(abs(y-c)) le eps
 
	;-------  Finish up  -----------
	baz = cu*cy*cf - su*sy
	c = r*sqrt(sa*sa + baz*baz)
	d = su*cy + cu*sy*cf
	glat2 = atan(d,c)
	c = cu*cy - su*sy*cf
	x = atan(sy*sf, c)
	c = ((-3*c2a + 4)*f + 4)*c2a*f/16
	d = ((e*cy*c + cz)*sy*c + y)*sa
	glon2 = glon1 + x - (1-c)*d*f
	baz = atan(sa,baz) + !dpi
 
	lng2 = glon2/dtor
	lat2 = glat2/dtor
	azi2 = baz/dtor
 
	end
