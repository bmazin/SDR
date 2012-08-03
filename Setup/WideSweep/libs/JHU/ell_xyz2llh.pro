;-------------------------------------------------------------
;+
; NAME:
;       ELL_XYZ2LLH
; PURPOSE:
;       x, y, z to ellipsoidal Long, Lat, Height.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_xyz2llh, x, y, z, lng1, lat1, htm
; INPUTS:
;       x,y,z = Geocentric x,y,z (m).                    in
; KEYWORD PARAMETERS:
;       Keywords:
;         ELLIPSOID=ell_str Give ellipsoid structure instead
;           of using ellipsoid,set=name or taking default.
;         /QUIET means inhibit message.
; OUTPUTS:
;       lng1, lat1 = geodetic longitude, latitude (deg). out
;       htm = height above ellipsoid (m).                out
; COMMON BLOCKS:
; NOTES:
;       Note: Use ellipsoid,set=name to set working ellipsoid
;         or give ellipsoid using ELLIPSOID=ell_str keyword.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 07
;       R. Sterner, 2002 Apr 19 --- Added ELLIPSOID keyword.
;       R. Sterner, 2002 May 01 --- Now calls ellipsoid.
;       R. Sterner, 2002 May 06 --- Added ELLIPSOID keyword back in.
;       R. Sterner, 2004 Apr 01 --- Added /QUIET.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_xyz2llh, x, y, z, lng1, lat1, htm, ellipsoid=in_ell, $
	  quiet=quiet, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' x, y, z to ellipsoidal Long, Lat, Height.'
	  print,' ell_xyz2llh, x, y, z, lng1, lat1, htm'
	  print,'   x,y,z = Geocentric x,y,z (m).                    in'
	  print,'   lng1, lat1 = geodetic longitude, latitude (deg). out'
	  print,'   htm = height above ellipsoid (m).                out'
	  print,' Keywords:'
	  print,'   ELLIPSOID=ell_str Give ellipsoid structure instead'
	  print,'     of using ellipsoid,set=name or taking default.'
	  print,'   /QUIET means inhibit message.'
	  print,' Note: Use ellipsoid,set=name to set working ellipsoid'
	  print,'   or give ellipsoid using ELLIPSOID=ell_str keyword.'
	  return
	endif
 
	;-------------------------------------------------
	;  Ellipsoid.
	;-------------------------------------------------
;	ellname = 'WGS 84'
;	a = 6378137.0D0			; Semimajor axis (m).
;	f1 = 298.257223563D0		; Reciprocal of flattening factor.
	ellipsoid, get=ell		; Get ellipsoid.
	if n_elements(in_ell) then ell=in_ell	; ELLIPSOID keyword used.
	ellname = ell.name		; Name.
	a = ell.a			; Semimajor axis (m).
	f1 = ell.f1			; Reciprocal of flattening factor.
	if not keyword_set(quiet) then print,' x, y, z to '+ $
	  ellname+' ellipsoid Long, Lat, Height.'
	f = 1.D0/f1			; Flattening factor.
	b = a*(1-f)			; Semiminor axis (m).
	a2 = a^2
	a4 = a^4
	b2 = b^2
	b4 = b^4
	a2b2 = a2*b2
	a2_over_b2 = a2/b2
 
	;-------------------------------------------------
	;  Convert problem from 3-D to 2-D
	;-------------------------------------------------
	x0 = sqrt(x^2 + y^2)
	y0 = z
	x02 = x0^2
	y02 = y0^2
	n = n_elements(x0)>n_elements(y0)	; # elements if arrays.
 
	;-------------------------------------------------
	;  Coefficients
	;-------------------------------------------------
	c0 = a2b2*(b2*x02 + a2*y02 - a2b2)
	c1 = 2*a2b2*(x02 + y02 - a2 - b2)
	c2 = a2*(x02-4*b2) + b2*y02 - a4 - b4
	c3 = -2*(a2 + b2)
	c4 = -1D0
 
	;--------------------------------------------------
	;  Loop through all points
	;--------------------------------------------------
	t = dblarr(n)
	for i=0,n-1 do begin
	  t0 = c0([i])
	  t1 = c1([i])
	  t2 = c2([i])
	  t3 = c3([i])
	  t4 = c4([i])
	  c = [t0,t1,t2,t3,t4]
	  roots = fz_roots(c)	; Find roots of 4th deg polynomial.
	  t(i) = double(roots(3))	; Nearest = nadir point.
	endfor
 
	xe = a2*x0/(a2+t)	; Ellipse X,Y at nadir pt.
	ye = b2*y0/(b2+t)
	htm = sign(t)*sqrt((x0-xe)^2+(y0-ye)^2)	; Height in m.
	lat0r = atan(ye,xe)			; Geocentric latitude (radians).
	lat1r = atan(a2_over_b2*tan(lat0r))	; Geodetic latitude (radians).
	lng1r = atan(y,x)			; Longitude (radians).
	rtod = 180D0/!dpi			; Radians to degrees.
	lat1 = lat1r*rtod			; Lat in deg.
	lng1 = lng1r*rtod			; Long in deg.
 
	if n_elements(lng1) eq 1 then lng1=lng1(0)
	if n_elements(lat1) eq 1 then lat1=lat1(0)
	if n_elements(htm) eq 1 then htm=htm(0)
	
	end
