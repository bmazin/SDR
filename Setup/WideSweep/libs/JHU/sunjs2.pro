;-------------------------------------------------------------
;+
; NAME:
;       SUNJS2
; PURPOSE:
;       Computes geocentric physical ephemeris of the sun.
; CATEGORY:
; CALLING SEQUENCE:
;       sunjs2, js
; INPUTS:
;       js = ephemeris time as Julian Seconds.  in
;         Delta T = ET - UT which is not completely
;         predictable but is about 1 minute now.
;         This difference is noticable slightly.
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST displays values on screen.
;         DIST = distance in AU.
;         SD = semidiameter of disk in arc seconds.
;         TRUE_LONG = true longitude (deg).
;         TRUE_LAT = 0 always.
;         APP_LONG = apparent longitude (deg).
;         APP_LAT = 0 always.
;         J2000_LONG = J2000.0 longitude (deg).
;         J2000_LAT = 0 always.
;         TRUE_RA = true RA (hours).
;         TRUE_DEC = true Dec (deg).
;         APP_RA = apparent RA (hours).
;         APP_DEC = apparent Dec (deg).
;         LAT0 = latitude at center of disk (deg).
;         LONG0 = longitude at center of disk (deg).
;         PA = position angle of rotation axis (deg).
;         CARRINGTON = Carrington rotation number.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: based on the book Astronomical Algorithms
;         Chapter 24, by Jean Meeus. Good to about 0.01 degree.
;         Coefficients based on above reference.
;         If no arguments given will prompt and list values.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Feb 05
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sunjs2, js, help=hlp, $
	  dist=dist, true_long=true_long, app_long=app_long, $
	  true_lat=true_lat, app_lat=app_lat, sd=sd, $
	  true_ra=true_ra, app_ra=app_ra, true_dec=true_dec, $
	  app_dec=app_dec, pa=pa, lat0=lat0, long0=long0, list=list, $
	  carrington=carr, j2000_long=j2000_long, j2000_lat=j2000_lat
 
	np = n_params(0)
 
	if keyword_set(hlp) then begin
	  print,' Computes geocentric physical ephemeris of the sun.'
	  print,' sunjs2, js'
	  print,'   js = ephemeris time as Julian Seconds.  in'
	  print,'     Delta T = ET - UT which is not completely'
	  print,'     predictable but is about 1 minute now.'
	  print,'     This difference is noticable slightly.'
	  print,' Keywords:'
	  print,'   /LIST displays values on screen.'
	  print,'   DIST = distance in AU.'
	  print,'   SD = semidiameter of disk in arc seconds.'
	  print,'   TRUE_LONG = true longitude (deg).'
	  print,'   TRUE_LAT = 0 always.'
	  print,'   APP_LONG = apparent longitude (deg).'
	  print,'   APP_LAT = 0 always.'
	  print,'   J2000_LONG = J2000.0 longitude (deg).'
	  print,'   J2000_LAT = 0 always.'
	  print,'   TRUE_RA = true RA (hours).'
	  print,'   TRUE_DEC = true Dec (deg).'
	  print,'   APP_RA = apparent RA (hours).'
	  print,'   APP_DEC = apparent Dec (deg).'
	  print,'   LAT0 = latitude at center of disk (deg).'
	  print,'   LONG0 = longitude at center of disk (deg).'
	  print,'   PA = position angle of rotation axis (deg).'
	  print,'   CARRINGTON = Carrington rotation number.'
	  print,' Notes: based on the book Astronomical Algorithms'
	  print,'   Chapter 24, by Jean Meeus. Good to about 0.01 degree.'
	  print,'   Coefficients based on above reference.'
	  print,'   If no arguments given will prompt and list values.'
	  return
	endif
 
 
	;---------------------------------------------------;
	;        Interactive mode                           ;
	;---------------------------------------------------;
	if np eq 0 then begin
	  print,' '
	  print,' Compute Sun parameters'
	  print,' '
	  txt = ''
	  read,' Ephermeris date and time: ',txt
	  if txt eq '' then return
	  js = dt_tm_tojs(txt)
	  list = 1
	endif
 
	;---------------------------------------------------;
        ;        Convert js to y,m,d,et                     ;
        ;---------------------------------------------------;
	js2ymds,js,yr,m,d,s
	et = s/3600.
 
	;---------------------------------------------------;
	;        Radians/degrees conversion (double)        ;
	;---------------------------------------------------;
	radeg = 180.d0/!dpi
 
	;---------------------------------------------------;
	;        Julian Date                                ;
	;---------------------------------------------------;
	jd = double(ymd2jd(yr, m, d)) - 0.5d0 + et/24d0
 
	;---------------------------------------------------;
	;        Julian Centuries from 2000.0       Eq 24.1 ;
	;---------------------------------------------------;
	t = (jd - 2451545d0)/36525d0
 
	;---------------------------------------------------;
	;	Carrington Rotation Number.                 ;
	;---------------------------------------------------;
; >>>===> Check this
	carr = dt_tm_tocr(dt_tm_fromjs(js))
 
	;---------------------------------------------------;
	;        Geometric Mean Longitude (deg)     Eq 24.2 ;
	;---------------------------------------------------;
	mnl = 280.46645d0 + 36000.76983d0*t + 0.0003032*t^2
	mnl = mnl mod 360d0
 
	;---------------------------------------------------;
	;        Mean anomaly (deg)                 Eq 24.3 ;
	;---------------------------------------------------;
	mna = 357.52910d0 + 35999.05030d0*t - $
	      0.0001559d0*t^2 - 0.00000048d0*t^3
	mna = mna mod 360d0
 
	;---------------------------------------------------;
	;        Eccentricity of orbit              Eq 24.4 ;
	;---------------------------------------------------;
	e = 0.016708617d0 - 0.000042037d0*t - 0.0000001236d0*t^2
 
	;---------------------------------------------------;
	;        Sun's equation of center (deg)      P. 152 ;
	;---------------------------------------------------;
	c = (1.914600d0 - 0.004817d0*t - 0.000014d0*t^2)*sin(mna/radeg) $
	    + (0.019993d0 - 0.000101d0*t)*sin(2*mna/radeg) $
	    + 0.000290d0*sin(3*mna/radeg)
 
	;---------------------------------------------------;
	;        Sun's true geometric longitude (deg)       ;
	;        refered to the mean equinox of date.       ;
	;        Should the higher accuracy terms (not      ;
	;        included here) be added to true_long?      ;
	;        (from which app_long is derived).   P. 152 ;
	;---------------------------------------------------;
	true_long = (mnl + c) mod 360d0
 
	;---------------------------------------------------;
	;        Sun's true anomaly (deg)            P. 152 ;
	;---------------------------------------------------;
	ta = (mna + c) mod 360d0
 
	;---------------------------------------------------;
	;        Sun's radius vector (AU)           Eq 24.4 ;
	;        There are a set of higher accuracy         ;
	;        terms not included here.  The values       ;
	;        calculated here agree with the example     ;
	;        in the book.                               ;
	;---------------------------------------------------;
	dist = 1.000001018d0*(1.d0 - e^2)/(1.d0 + e*cos(ta/radeg))
 
	;---------------------------------------------------;
	;        Semidiameter (arc sec)              P. 359 ;
	;---------------------------------------------------;
	sd = 959.63/dist
 
	;---------------------------------------------------;
	;        Apparent longitude (deg) from true         ;
	;        longitude.                          P. 152 ;
	;---------------------------------------------------;
	omega = 125.04d0 - 1934.136d0*t		; Degrees
	app_long = true_long - 0.00569d0 - 0.00478d0*sin(omega/radeg)
 
	;---------------------------------------------------;
	;        J2000.0 longitude (deg) from true          ;
	;        longitude.                          P. 152 ;
	;---------------------------------------------------;
	dyr = (jd - 2451545d0)/365.25d0
	j2000_long = true_long - 0.01397D0*dyr
 
	;---------------------------------------------------;
	;        Latitudes (deg) for completeness.          ;
	;        Never more than 1.2 arc sec from 0,        ;
	;        always set to 0 here.                      ;
	;---------------------------------------------------;
	true_lat = 0.
	app_lat = 0.
	j2000_lat = 0.
 
	;---------------------------------------------------;
	;        RA, Dec                                    ;
	;---------------------------------------------------;
	;---------------------------------------------------;
	;      True Obliquity of the ecliptic (deg) Eq 21.2 ;
	;---------------------------------------------------;
	ob1 = 23.439291d0 - 0.013004167d0*t - 1.63889d-07*t^2 $
	     + 5.03611d-07*t^3
	;---------------------------------------------------;
	;        True RA, Dec (is this correct?)            ;
	;---------------------------------------------------;
	y = cos(ob1/radeg)*sin(true_long/radeg)
	x = cos(true_long/radeg)
	recpol, x, y, r, true_ra, /deg
	true_ra = true_ra mod 360d0
;	if true_ra lt 0. then true_ra = true_ra + 360d0
	w = where(true_ra lt 0.,c) & if c gt 0 then true_ra(w)=true_ra(w)+360d0
	true_ra = true_ra/15d0
	true_dec = asin(sin(ob1/radeg)*sin(true_long/radeg))*radeg
	;---------------------------------------------------;
	;        Apparent  RA, Dec                          ;
	;        Agrees with example in book.               ;
	;---------------------------------------------------;
	;---------------------------------------------------;
	;       Apparent Obliquity of the ecliptic  Eq 24.8 ;
	;---------------------------------------------------;
	ob2 = ob1 + 0.00256d0*cos(omega/radeg)	; Correction.
	y = cos(ob2/radeg)*sin(app_long/radeg)
	x = cos(app_long/radeg)
	recpol, x, y, r, app_ra, /deg
	app_ra = app_ra mod 360d0
	w = where(app_ra lt 0.,c) & if c gt 0 then app_ra(w)=app_ra(w) + 360d0
	app_ra = app_ra/15d0
	app_dec = asin(sin(ob2/radeg)*sin(app_long/radeg))*radeg
 
	;---------------------------------------------------;
	;        Heliographic coordinates            P. 178 ;
	;---------------------------------------------------;
	theta = (jd - 2398220d0)*360d0/25.38d0		 ; Deg.
	i = 7.25					 ; Deg.
	k = 73.6667D0 + 1.3958333D0*(jd-2396758)/36525D0 ; Deg.
	; lambda = true_long corrected for abberation only.
	; 0.00569 deg is 20.4840" = constant of abberation.
	; lambda2 is also corrected for nutation.  P. 152.
	lamda = true_long - 0.00569d0
	lamda2 = lamda - 0.00478d0*sin(omega/radeg)
	diff = (lamda - k)/radeg
	x = atan(-cos(lamda2/radeg)*tan(ob1/radeg))*radeg
	y = atan(-cos(diff)*tan(i/radeg))*radeg
	;---------------------------------------------------;
	;        Position of north pole (deg)               ;
	;---------------------------------------------------;
	pa = x + y
	;---------------------------------------------------;
	;        Latitude at center of disk (deg)           ;
	;---------------------------------------------------;
	lat0 = asin(sin(diff)*sin(i/radeg))*radeg
	;---------------------------------------------------;
	;        Longitude at center of disk (deg)          ;
	;---------------------------------------------------;
	y = -sin(diff)*cos(i/radeg)
	x = -cos(diff)
	recpol, x, y, r, eta, /deg
	long0 = (eta - theta) mod 360d0
;	if long0 lt 0 then long0 = long0 + 360d0
	w = where(long0 lt 0,c) & if c gt 0 then long0(w)=long0(w) + 360d0
 
	;---------------------------------------------------;
	;        List values                                ;
	;---------------------------------------------------;
	if not keyword_set(list) then return
	print,' '
	print,' Sun for '+strtrim(d,2)+' '+(monthnames())(m)+$
          ' '+strtrim(yr,2)+' at ET '+strsec(et*3600d0)
	print,' '
	print,' Distance (AU) = '+strtrim(dist,2)
	print,' Semidiameter (arc sec) = '+strtrim(sd,2)
	print,' True (long, lat) in degrees = ('+$
	  strtrim(true_long,2)+', '+strtrim(true_lat,2)+')'
	print,' Apparent (long, lat) in degrees = ('+$
	  strtrim(app_long,2)+', '+strtrim(app_lat,2)+')'
	print,' J2000.0 (long, lat) in degrees = ('+$
	  strtrim(j2000_long,2)+', '+strtrim(j2000_lat,2)+')'
	print,' True (RA, Dec) in hrs, deg = ('+$
	  strtrim(true_ra,2)+', '+strtrim(true_dec,2)+')'
	print,' Apparent (RA, Dec) in hrs, deg = ('+$
	  strtrim(app_ra,2)+', '+strtrim(app_dec,2)+')'
	print,' Heliographic long. and lat. of disk center in deg = ('+$
	  strtrim(long0,2)+', '+strtrim(lat0,2)+')'
	print,' Position angle of north pole in deg = '+$
	  strtrim(pa,2)
	print,' The Carrington Rotation Number = '+$
	  strtrim(carr,2)
	print,' '
 
	return
	end
