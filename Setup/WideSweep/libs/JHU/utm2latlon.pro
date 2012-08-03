;-------------------------------------------------------------
;+
; NAME:
;       UTM2LATLON
; PURPOSE:
;       Convert UTM coordinates to lat,lon.
; CATEGORY:
; CALLING SEQUENCE:
;       utm2latlon, x, y, lat, lon
; INPUTS:
;       x,y = UTM coordinates.                   in
; KEYWORD PARAMETERS:
;       Keywords:
;         ELLIPSOID=ell Give ellipsoid to use (def=WGS 84).
;           ell={a:a, f1:f1, name:name} where a=semimajor axis in m,
;           f1=1/flattening_factor, name=ellipsoid name.  Ex:
;           ell={a:6378137.0D0,f1:298.25722D0,name:'WGS 84'}.
; OUTPUTS:
;       lat,lon = Latitude and longitude (deg).  out
; COMMON BLOCKS:
; NOTES:
;       Note: f1 may be computed from a and b: f1=1/(1-b/a)
;       ZONE=zone UTM zone number (1 to 60).
;       LON0=lon0 Longitude of central meridian (deg).
;         Use one of ZONE or LON0.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Jun 04
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro utm2latlon, x0, y0, lat, lon, $
	  ellipsoid=ell, zone=zone, lon0=lon0, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert UTM coordinates to lat,lon.'
	  print,' utm2latlon, x, y, lat, lon'
	  print,'   x,y = UTM coordinates.                   in'
	  print,'   lat,lon = Latitude and longitude (deg).  out'
	  print,' Keywords:'
	  print,'   ELLIPSOID=ell Give ellipsoid to use (def=WGS 84).'
	  print,'     ell={a:a, f1:f1, name:name} where a=semimajor axis in m,'
	  print,'     f1=1/flattening_factor, name=ellipsoid name.  Ex:'
	  print,"     ell={a:6378137.0D0,f1:298.25722D0,name:'WGS 84'}."
	  print,'     Note: f1 may be computed from a and b: f1=1/(1-b/a)'
	  print,'   ZONE=zone UTM zone number (1 to 60).'
	  print,'   LON0=lon0 Longitude of central meridian (deg).'
	  print,'     Use one of ZONE or LON0.'
	  return
	endif
	
	k0 = 0.9996		; Central meridian scale factor for UTM.	
	x = x0 - 500000D0	; Correct false easting to easting.
	y = y0 + 0D0
	
	;-------------------------------------------------------------------
	;  Deal with central longitude
	;-------------------------------------------------------------------
	if n_elements(lon0) eq 0 then begin
	  if n_elements(zone) eq 0 then begin
	    print,' Must give central longitude (LON0) or UTM zone (ZONE).'
	    return
	  endif
	  lon0 = zone*6 - 183
	endif
 
	;-------------------------------------------------------------------
	;  Ellipsoid and related values
	;-------------------------------------------------------------------
	if n_elements(ell) eq 0 then ellipsoid,set='wgs 84',get=ell
	a = ell.a
	b = ell.a*(1-1/ell.f1)
	a2 = a*a
	b2 = b*b
	e2 = 1D0 - b2/a2
	e4 = e2*e2
	e6 = e2*e4
 
	;-------------------------------------------------------------------
	;  Computed values
	;-------------------------------------------------------------------
	m = y/k0
	mu = m/(a*(1  -e2/4 - 3*e4/64 - 5*e6/256))
	t = sqrt(1-e2)
	e11 = (1-t)/(1+t)
	e12 = e11*e11
	e13 = e11*e12
	e14 = e11*e13
	j1 =    3*e11/2  - 27*e13/32
	j2 =   21*e12/16 - 55*e14/32
	j3 =  151*e13/96
	j4 = 1097*e14/512
	fp = mu + j1*sin(2*mu) + j2*sin(4*mu) + j3*sin(6*mu) + j4*sin(8*mu)
	
	ep2 = e2/(1-e2)
	cosfp = cos(fp)
	tanfp = tan(fp)
	sinfp2 = sin(fp)^2
	c1 = ep2*cosfp^2
	c12 = c1*c1
	t1 = tanfp^2
	t12 = t1*t1
	r1 = a*(1-e2)/sqrt((1-e2*sinfp2)^3)
	n1 = a/sqrt(1-e2*sinfp2)
	d = x/(n1*k0)
	d2= d*d
	d3 = d*d2
	d4 = d*d3
	d5 = d*d4
	d6 = d*d5
 
	;-------------------------------------------------------------------
	;  Compute lat and lon
	;-------------------------------------------------------------------
	q1 = n1*tanfp/r1
	q2 = d2/2
	q3 = (5 + 3*t1 + 10*c1 - 4*c12 - 9*ep2)*d4/24
	q4 = (61 + 90*t1 + 298*c1 +45*t12 - 3*c12 - 252*ep2)*d6/720
	lat = fp - q1*(q2 - q3 + q4)		; Radians.
	lat = lat*!radeg
 
	q5 = d
	q6 = (1 + 2*t1 + c1)*d3/6
	q7 = (5 - 2*c1 + 28*t1 - 3*c12 + 8*ep2 + 24*t12)*d5/120
	lon = (q5 - q6 +q7)/cosfp		; Radians.
	lon = lon0 + lon*!radeg
 
	end
