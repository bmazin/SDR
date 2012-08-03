;-------------------------------------------------------------
;+
; NAME:
;       ELL_LLH2XYZ
; PURPOSE:
;       Ellipsoidal Long, Lat, Height, to x, y, z.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_llh2xyz, lng1, lat1, htm, x, y, z
; INPUTS:
;       lng1, lat1 = geodetic longitude, latitude (deg). in
;       htm = height above ellipsoid (m).                in
; KEYWORD PARAMETERS:
;       Keywords:
;         ELLIPSOID=ell_str Give ellipsoid structure instead
;           of using ellipsoid,set=name or taking default.
; OUTPUTS:
;       x,y,z = Geocentric x,y,z (m).                    out.
; COMMON BLOCKS:
; NOTES:
;       Note: Use ellipsoid,set=name to set working ellipsoid
;         or give ellipsoid using ELLIPSOID=ell_str keyword.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 07
;       R. Sterner, 2002 Apr 19 --- Added ELLIPSOID keyword.
;       R. Sterner, 2002 May 01 --- Now calls ellipsoid.
;       R. Sterner, 2002 May 06 --- Added ELLIPSOID keyword back in.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_llh2xyz, lng1, lat1, htm, x, y, z, ellipsoid=in_ell, help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Ellipsoidal Long, Lat, Height, to x, y, z.'
	  print,' ell_llh2xyz, lng1, lat1, htm, x, y, z'
	  print,'   lng1, lat1 = geodetic longitude, latitude (deg). in'
	  print,'   htm = height above ellipsoid (m).                in'
	  print,'   x,y,z = Geocentric x,y,z (m).                    out.'
	  print,' Keywords:'
	  print,'   ELLIPSOID=ell_str Give ellipsoid structure instead'
	  print,'     of using ellipsoid,set=name or taking default.'
	  print,' Note: Use ellipsoid,set=name to set working ellipsoid'
	  print,'   or give ellipsoid using ELLIPSOID=ell_str keyword.'
	  return
	endif
 
	;---------------------------------------------------------
	;  Ellipsoid.  Default = WGS84 constants (www.wgs84.com)
	;---------------------------------------------------------
;	a = 6378137.0D0			; Semimajor axis (m).
;	f1 = 298.257223563D0		; Reciprocal of flattening factor.
	ellipsoid, get=ell		; Get ellipsoid.
	if n_elements(in_ell) then ell=in_ell	; ELLIPSOID keyword used.
	ellname = ell.name		; Name.
	a = ell.a			; Semimajor axis (m).
	f1 = ell.f1			; Reciprocal of flattening factor.
	print,' '+ellname+' ellipsoid Long, Lat, Height, to x, y, z.'
	f = 1.D0/f1			; Flattening factor.
	b = a*(1-f)			; Semiminor axis (m).
	e2 = (a^2-b^2)/a^2
	b2_over_a2 = (b/a)^2
 
	;-----------------------------------------------
	;  Initial values
	;  lng1, lat1 = geodetic.
	;  lng0, lat0 = geocentric. (lng0=lng1).
	;-----------------------------------------------
	dtor = !dpi/180D0		; Degrees to radians.
	lng1r = lng1*dtor		; Convert to radians.
	lat1r = lat1*dtor
	lat0r = atan(b2_over_a2*tan(lat1r))	; Geocentric latitude.
	csx  = cos(lng1r)		; lng0r = lng1r.
	snx  = sin(lng1r)
	csy0 = cos(lat0r)
	sny0 = sin(lat0r)
	csy1 = cos(lat1r)
	sny1 = sin(lat1r)
 
	;--------------------------------------------------
	;  Find x,y,z of surface point
	;  Axis  Long  Lat
	;   X      0     0
	;   Y    +90     0
	;   Z      0   +90
	;--------------------------------------------------
	rp = b/sqrt(1-e2*cos(lat0r)^2)		; Geocentric dist to surface pt.
	xp = rp*csy0*csx
	yp = rp*csy0*snx
	zp = rp*sny0
 
	;--------------------------------------------------
	;  Find local displacement from surface to height.
	;  Up vector depends on local vertical, which
	;  depends on geodetic latitude.
	;--------------------------------------------------
	xh = htm*csy1*csx
	yh = htm*csy1*snx
	zh = htm*sny1
 
	;--------------------------------------------------
	;  Final position.
	;--------------------------------------------------
	x = xp + xh
	y = yp + yh
	z = zp + zh
 
	return
	end
