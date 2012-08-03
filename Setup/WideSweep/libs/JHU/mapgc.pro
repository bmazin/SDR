;-------------------------------------------------------------
;+
; NAME:
;       MAPGC
; PURPOSE:
;       Plot a great route circle on a map.
; CATEGORY:
; CALLING SEQUENCE:
;       mapgc, lng1, lat2, lng2, lat2
; INPUTS:
;       lng1 = longitude (degrees) of point p1.    in
;       lat1 = latitude (degrees) of point p1.     in
;       lng2 = longitude (degrees) of point p2.    in
;       lat2 = latitude (degrees) of point p2.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBER=n   Number of points between p1 and p2.
;         STEPSIZE=d Step size between points from p1 to p2.
;         UNITS=unt  Units of stepsize:
;           'kms'     Default.
;           'miles'   Statute miles.
;           'nmiles'  Nautical miles.
;           'feet'    Feet.
;           'yards'   Yards.
;           'degrees' Degrees (great circle).
;           'radians' Radians (great circle).
;         /NOPLOT  do not plot great circle.
;         XOUT=lng  Returned longitudes of points along great circle.
;         YOUT=lng  Returned latitudes of points along great circle.
;         RANGE=ran Returned Distance between points (UNITS).
;         AZIMUTH=azi  Azimuth of p2 from p1 (deg).
;         COLOR=clr  Plot color (def=!p.color).
;         THICKNESS=thk Plot thickness (def=!p.thick).
;         LINESTYLE=sty Plot linestyle (def=!p.linestyle).
;         PSYM=psym  Plot symbol (def=!p.psym).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Use only one of NUMBER or STEPSIZE.  STEPSIZE
;         typically also needs UNITS unless they are km.
;         NUMBER gives specified number of points including ends.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 4
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mapgc, x1,y1,x2,y2,xout=x3,yout=y3, stepsize=step, number=num, $
	  units=units,color=clr,thickness=thk,linestyle=sty, psym=psym, $
	  noplot=noplot,range=ran, azimuth=azi, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Plot a great route circle on a map.'
	  print,' mapgc, lng1, lat2, lng2, lat2'
	  print,'   lng1 = longitude (degrees) of point p1.    in'
	  print,'   lat1 = latitude (degrees) of point p1.     in'
	  print,'   lng2 = longitude (degrees) of point p2.    in'
	  print,'   lat2 = latitude (degrees) of point p2.     in'
	  print,' Keywords:'
	  print,'   NUMBER=n   Number of points between p1 and p2.'
	  print,'   STEPSIZE=d Step size between points from p1 to p2.'
	  print,'   UNITS=unt  Units of stepsize:'
	  print,"     'kms'     Default."
	  print,"     'miles'   Statute miles."
	  print,"     'nmiles'  Nautical miles."
	  print,"     'feet'    Feet."
	  print,"     'yards'   Yards."
	  print,"     'degrees' Degrees (great circle)."
	  print,"     'radians' Radians (great circle)."
	  print,'   /NOPLOT  do not plot great circle.'
	  print,'   XOUT=lng  Returned longitudes of points along great circle.'
	  print,'   YOUT=lng  Returned latitudes of points along great circle.'
	  print,'   RANGE=ran Returned Distance between points (UNITS).'
	  print,'   AZIMUTH=azi  Azimuth of p2 from p1 (deg).'
	  print,'   COLOR=clr  Plot color (def=!p.color).'
	  print,'   THICKNESS=thk Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Plot linestyle (def=!p.linestyle).'
	  print,'   PSYM=psym  Plot symbol (def=!p.psym).'
	  print,' Notes: Use only one of NUMBER or STEPSIZE.  STEPSIZE'
	  print,'   typically also needs UNITS unless they are km.'
	  print,'   NUMBER gives specified number of points including ends.'
	  return
	endif
 
	if (n_elements(num) eq 0) and (n_elements(step) eq 0) then begin
	  print,' Error in mapgc: must give either NUMBER or STEPSIZE.'
 	  stop
	endif
	if (n_elements(num) ne 0) and (n_elements(step) ne 0) then begin
	  print,' Error in mapgc: must give only one of NUMBER or STEPSIZE.'
 	  stop
	endif
 
	;---------  Deal with units  ---------------
	if n_elements(units) eq 0 then units='kms'
	un = strlowcase(strmid(units,0,2))
	case un of	; Convert distance on earth's surface to radians.
'km':	begin
	  cf = 1.56956e-04	; Km/radian.
	  utxt = 'kms'
	end
'mi':	begin
	  cf = 2.52595e-04	; Miles/radian.
	  utxt = 'miles'
	end
'nm':	begin
	  cf = 2.90682e-04	; Nautical mile/radian.
	  utxt = 'nautical miles'
	end
'fe':	begin
	  cf = 4.78401e-08	; Feet/radian.
	  utxt = 'feet'
	end
'ya':	begin
	  cf = 1.43520e-07	; Yards/radian.
	  utxt = 'yards'
	end
'de':	begin
	  cf = 0.0174532925	; Degrees/radian.
	  utxt = 'degrees'
	end
'ra':	begin
	  cf = 1.0		; Radians/radian.
	  utxt = 'radians'
	end
else:	begin
	  print,' Error in mapcirc: Unknown units: '+units
	  print,'   Aborting.'
	  return
	end
	endcase
 
	;-------  Find range and bearing  --------------
	ll2rb,x1,y1,x2,y2,ran,azi
	if n_elements(step) eq 0 then begin
	  r = maken(0,ran,num)		; Range points along GC.
	endif else begin
	  r = makex(0,ran,step*cf)	; Range points along GC.
	endelse
	ran = ran/cf
	;--------  Back to lat/lng  ----------------------
	rb2ll,x1,y1,r,azi,x3,y3
	;---------  Put longitude in standard range  ----------
	if min(x3) gt 180 then x3=x3-360
 
	if keyword_set(noplot) then return
	;--------  Plot points  ----------------------------
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(thk) eq 0 then thk = !p.thick
	if n_elements(sty) eq 0 then sty = !p.linestyle
	if n_elements(psym) eq 0 then psym = !p.psym
	oplot,x3,y3,color=clr,thick=thk,linestyle=sty,psym=psym
 
	return
	end
