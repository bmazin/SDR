;-------------------------------------------------------------
;+
; NAME:
;       SUN
; PURPOSE:
;       Computes geocentric physical ephemeris of the sun.
; CATEGORY:
; CALLING SEQUENCE:
;       sun, y, m, d, et
; INPUTS:
;       y = year.                      in
;       m = month number.              in
;       d = monthday number.           in
;       et = ephemeris time in hours.  in
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
;         TRUE_RA = true RA (hours).
;         TRUE_DEC = true Dec (deg).
;         APP_RA = apparent RA (hours).
;         APP_DEC = apparent Dec (deg).
;         LAT0 = latitude at center of disk (deg).
;         LONG0 = longitude at center of disk (deg).
;         PA = position angle of rotation axis (deg).
;	  CARRINGTON = Carrington rotation number.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: based on the book Astronomical Formulae
;         for Calculators, by Jean Meeus.
;         If no arguments given will prompt and list values.
; MODIFICATION HISTORY:
;       R. Sterner, 19 Feb, 1991
;	24 July, 1991 --- added Carrington Rotation number
;	  based on an equation from Howard Cohl, Sac Peak.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sun, yr, m, d, et, help=hlp, $
	  dist=dist, true_long=true_long, app_long=app_long, $
	  true_lat=true_lat, app_lat=app_lat, sd=sd, $
	  true_ra=true_ra, app_ra=app_ra, true_dec=true_dec, $
	  app_dec=app_dec, pa=pa, lat0=lat0, long0=long0, list=list, $
	  carrington=carr
 
	np = n_params(0)
 
	if ((np gt 0) and (np lt 4)) or keyword_set(hlp) then begin
	  print,' Computes geocentric physical ephemeris of the sun.'
	  print,' sun, y, m, d, et'
	  print,'   y = year.                      in'
	  print,'   m = month number.              in'
	  print,'   d = monthday number.           in'
	  print,'   et = ephemeris time in hours.  in'
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
	  print,'   TRUE_RA = true RA (hours).'
	  print,'   TRUE_DEC = true Dec (deg).'
	  print,'   APP_RA = apparent RA (hours).'
	  print,'   APP_DEC = apparent Dec (deg).
	  print,'   LAT0 = latitude at center of disk (deg).'
	  print,'   LONG0 = longitude at center of disk (deg).'
	  print,'   PA = position angle of rotation axis (deg).'
	  print,'   CARRINGTON = Carrington rotation number.'
	  print,' Notes: based on the book Astronomical Formulae'
	  print,'   for Calculators, by Jean Meeus.'
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
	  yr = 0
	  m = 0
	  d = 0
	  read,' Year (yyyy): ',yr
	  read,' Month (mm): ',m
	  read,' Month day (dd): ',d
	  read,' Ephermeris time in hours: ',et
	  list = 1
	endif
 
	;---------------------------------------------------;
	;        Radians/degrees conversion (double)        ;
	;---------------------------------------------------;
	radeg = 180.d0/!dpi
 
	;---------------------------------------------------;
	;        Julian Date                                ;
	;---------------------------------------------------;
	jd = double(ymd2jd(yr, m, d)) - 0.5d0 + et/24d0
 
	;---------------------------------------------------;
	;        Julian Centuries from 1900.0               ;
	;---------------------------------------------------;
	t = (jd - 2415020d0)/36525d0
 
	;---------------------------------------------------;
	;	Carrington Rotation Number.                 ;
	;---------------------------------------------------;
	carr = (1./27.2753D0)*(jd-2398167.d0) + 1.d0

	;---------------------------------------------------;
	;        Geometric Mean Longitude (deg)             ;
	;---------------------------------------------------;
	mnl = 279.69668d0 + 36000.76892d0*t + 0.0003025*t^2
	mnl = mnl mod 360d0
 
	;---------------------------------------------------;
	;        Mean anomaly (deg)                         ;
	;---------------------------------------------------;
	mna = 358.47583d0 + 35999.04975d0*t - $
	      0.000150d0*t^2 - 0.0000033d0*t^3
	mna = mna mod 360d0
 
	;---------------------------------------------------;
	;        Eccentricity of orbit                      ;
	;---------------------------------------------------;
	e = 0.01675104d0 - 0.0000418d0*t - 0.000000126d0*t^2
 
	;---------------------------------------------------;
	;        Sun's equation of center (deg)             ;
	;---------------------------------------------------;
	c = (1.919460d0 - 0.004789d0*t - 0.000014d0*t^2)*sin(mna/radeg) $
	    + (0.020094d0 - 0.000100d0*t)*sin(2*mna/radeg) $
	    + 0.000293d0*sin(3*mna/radeg)
 
	;---------------------------------------------------;
	;        Sun's true geometric longitude (deg)       ;
	;        refered to the mean equinox of date.       ;
	;        Should the higher accuracy terms (not      ;
	;        included here) be added to true_long?      ;
	;        (from which app_long is derived).          ;
	;---------------------------------------------------;
	true_long = (mnl + c) mod 360d0
 
	;---------------------------------------------------;
	;        Sun's true anomaly (deg)                   ;
	;---------------------------------------------------;
	ta = (mna + c) mod 360d0
 
	;---------------------------------------------------;
	;        Sun's radius vector (AU)                   ;
	;        There are a set of higher accuracy         ;
	;        terms not included here.  The values       ;
	;        calculated here agree with the example     ;
	;        in the book.                               ;
	;---------------------------------------------------;
	dist = 1.0000002d0*(1.d0 - e^2)/(1.d0 + e*cos(ta/radeg))
 
	;---------------------------------------------------;
	;        Semidiameter (arc sec)                     ;
	;---------------------------------------------------;
	sd = 959.63/dist
 
	;---------------------------------------------------;
	;        Apparent longitude (deg) from true         ;
	;        longitude.                                 ;
	;---------------------------------------------------;
	omega = 259.18d0 - 1934.142d0*t		; Degrees
	app_long = true_long - 0.00569d0 - 0.00479d0*sin(omega/radeg)
 
	;---------------------------------------------------;
	;        Latitudes (deg) for completeness.          ;
	;        Never more than 1.2 arc sec from 0,        ;
	;        always set to 0 here.                      ;
	;---------------------------------------------------;
	true_lat = 0.
	app_lat = 0.
 
	;---------------------------------------------------;
	;        RA, Dec                                    ;
	;---------------------------------------------------;
	;---------------------------------------------------;
	;        True Obliquity of the ecliptic (deg)       ;
	;---------------------------------------------------;
	ob1 = 23.452294d0 - 0.0130125d0*t - 0.00000164d0*t^2 $
	     + 0.000000503d0*t^3
	;---------------------------------------------------;
	;        True RA, Dec (is this correct?)            ;
	;---------------------------------------------------;
	y = cos(ob1/radeg)*sin(true_long/radeg)
	x = cos(true_long/radeg)
	recpol, x, y, r, true_ra, /deg
	true_ra = true_ra mod 360d0
	if true_ra lt 0. then true_ra = true_ra + 360d0
	true_ra = true_ra/15d0
	true_dec = asin(sin(ob1/radeg)*sin(true_long/radeg))*radeg
	;---------------------------------------------------;
	;        Apparent  RA, Dec                          ;
	;        Agrees with example in book.               ;
	;---------------------------------------------------;
	;---------------------------------------------------;
	;        Apparent  Obliquity of the ecliptic        ;
	;---------------------------------------------------;
	ob2 = ob1 + 0.00256d0*cos(omega/radeg)	; Correction.
	y = cos(ob2/radeg)*sin(app_long/radeg)
	x = cos(app_long/radeg)
	recpol, x, y, r, app_ra, /deg
	app_ra = app_ra mod 360d0
	if app_ra lt 0. then app_ra = app_ra + 360d0
	app_ra = app_ra/15d0
	app_dec = asin(sin(ob2/radeg)*sin(app_long/radeg))*radeg
 
	;---------------------------------------------------;
	;        Heliographic coordinates                   ;
	;---------------------------------------------------;
	theta = (jd - 2398220d0)*360d0/25.38d0	; Deg.
	i = 7.25				; Deg.
	k = 74.3646 + 1.395833*t		; Deg.
	lamda = true_long - 0.00569d0
	lamda2 = lamda - 0.00479d0*sin(omega/radeg)
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
	if long0 lt 0 then long0 = long0 + 360d0
 
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
