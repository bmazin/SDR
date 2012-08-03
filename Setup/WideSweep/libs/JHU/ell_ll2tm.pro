;-------------------------------------------------------------
;+
; NAME:
;       ELL_LL2TM
; PURPOSE:
;       Lon,lat to transverse mercator on an ellipsoid.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_ll2tm, lon, lat, x, y
; INPUTS:
;       lon, lat = Geographic longitude and latitude (deg).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /FALSE  Add false easting and northing.
;         LON0=lon0 Longitude of central meridian.
;           Default is mean of given longitudes.
; OUTPUTS:
;       x,y = Easting and northing (meters).                 out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Aug 21
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_ll2tm, lon, lat, x, y, false=false, $
	  lon0=lon0 ,help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Lon,lat to transverse mercator on an ellipsoid.'
	  print,' ell_ll2tm, lon, lat, x, y'
	  print,'   lon, lat = Geographic longitude and latitude (deg).  in'
	  print,'   x,y = Easting and northing (meters).                 out'
	  print,' Keywords:'
	  print,'   /FALSE  Add false easting and northing.'
	  print,'   LON0=lon0 Longitude of central meridian.'
	  print,'     Default is mean of given longitudes.'
	  return
	endif
 
        ;-------------------------------------------------
        ;  Ellipsoid
        ;-------------------------------------------------
        ellipsoid, get=ell              ; Get ellipsoid.
        a = ell.a                       ; Semimajor axis (m).
        f1 = ell.f1                     ; Reciprocal of flattening factor.
        f = 1.D0/f1                     ; Flattening factor.
        b = a*(1-f)                     ; Semiminor axis (m).
        e2 = (a^2-b^2)/a^2              ; Eccentricity^2.
        radeg = 180D0/!dpi              ; Must use double for mm accuracy.
        pi2 = !dpi/2.D0
 
        ;-------------------------------------------------
	;  Initialize
	;  See Snyder page 61.
        ;-------------------------------------------------
	lonrad = lon/radeg		; Convert to radians.
	latrad = lat/radeg
	if n_elements(lon0) eq 0 then lon0=mean(lon)
	lon0rad = lon0/radeg
	e4 = e2*e2
	e6 = e4*e2
	sin_lat2 = sin(latrad)^2
	cos_lat = cos(latrad)
	cos_lat2 = cos_lat^2
	tan_lat = tan(latrad)
	tan_lat2 = tan_lat^2
	sin_2lat = sin(2*latrad)
	sin_4lat = sin(4*latrad)
	sin_6lat = sin(6*latrad)
 
	ep2 = e2/(1D0-e2)					; (8-12)
	N = a/sqrt(1D0-e2*sin_lat2)				; (4-20)
	T  = tan_lat2						; (8-13)
	C = ep2*cos_lat2					; (8-14)
	A1 = (lonrad-lon0rad)*cos_lat				; (8-15)
	M = a*((1 - e2/4 - 3*e4/64 - 5*e6/256)*latrad - $	; (3-21)
	       (3*e2/8 + 3*e4/32 + 45*e6/1024)*sin_2lat + $
	       (15*e4/256 + 45*e6/1024)*sin_4lat - $
	       (35*e6/3072)*sin_6lat)
	M0 = 0D0	; For origin at equator.
	k0 = 0.9996D0	; For UTM.
 
	T2 = T*T
	C2 = C*C
	A2 = A1*A1
	A3 = A2*A1
	A4 = A3*A1
	A5 = A4*A1
	A6 = A5*A1
 
        ;-------------------------------------------------
	;  Convert coordinates
        ;-------------------------------------------------
	x = k0*N*(A1 + (1-T+C)*A3/6 + (5-18*T+T2+72*C-58*ep2)*A5/120)
	y = k0*(M-M0+N*tan_lat*(A2/2+(5-T+9*C+4*C2)*A4/24 $
	    +(61-58*T+T2+600*C-330*ep2)*A6/720))
 
	if keyword_set(false) then begin
	  x = x + 500000D0				; 500,000 m.
	  w = where(lat lt 0., cnt)
	  if cnt gt 0 then y[w] = y[w] + 10000000D0	; 10,000,000 m if South.
	endif
 
	end
