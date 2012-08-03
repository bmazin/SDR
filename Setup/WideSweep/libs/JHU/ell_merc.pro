;-------------------------------------------------------------
;+
; NAME:
;       ELL_MERC
; PURPOSE:
;       Mercator projection on an ellipsoid, forward and inverse.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_merc, p1, p2
; INPUTS:
;       p1,p2 = Values to be converted.    in
;         Either lng,lat or x,y.
; KEYWORD PARAMETERS:
;       Keywords:
;         X=x,Y=y  Convert given lng,lat to x,y and return.
;         LNG=lng,LAT=lat Convert given x,y to lng,lat and return.
;         SCALE=sc  Map scale (def=1:1).
;         CLNG=lng0 Central longitude (def=0).
;         MAP_A=smj  Returned value for the semimajor axis
;           of the map.  Includes scale.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Algorithms from John Snyder,
;       Map Projections - A Working Manual.
;       Use ellipsoid,set=name to set working ellipsoid.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 08
;       R. Sterner, 2002 May 01 --- Generalized the ellipsoid.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_merc, p1, p2, x=x, y=y, lng=lng, lat=lat, $
	  scale=scale, clng=lng0, err=err, map_a=smj, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Mercator projection on an ellipsoid, forward and inverse.'
	  print,' ell_merc, p1, p2'
	  print,'   p1,p2 = Values to be converted.    in'
	  print,'     Either lng,lat or x,y.'
	  print,' Keywords:'
	  print,'   X=x,Y=y  Convert given lng,lat to x,y and return.'
	  print,'   LNG=lng,LAT=lat Convert given x,y to lng,lat and return.'
	  print,'   SCALE=sc  Map scale (def=1:1).'
	  print,'   CLNG=lng0 Central longitude (def=0).'
	  print,'   MAP_A=smj  Returned value for the semimajor axis'
	  print,'     of the map.  Includes scale.'
	  print,' Notes: Algorithms from John Snyder,'
	  print,' Map Projections - A Working Manual.'
	  print,' Use ellipsoid,set=name to set working ellipsoid.'
	  return
	endif
 
	;-------------------------------------------------
	;  Ellipsoid
	;-------------------------------------------------
;	f = 1.D0/298.257223563D0	; Flattening factor.
;	a = 6378137.0D0			; Semimajor axis (m).
	ellipsoid, get=ell		; Get ellipsoid.
	a = ell.a			; Semimajor axis (m).
	f1 = ell.f1			; Reciprocal of flattening factor.
	f = 1.D0/f1			; Flattening factor.
	b = a*(1-f)			; Semiminor axis (m).
	e2 = (a^2-b^2)/a^2		; Eccentricity^2.
	e = sqrt(e2)			; Eccentricity.
	radeg = 180D0/!dpi		; Must use double for mm accuracy.
	pi2 = !dpi/2.D0
 
	;-------------------------------------------------
	;  Defaults
	;-------------------------------------------------
	if n_elements(scale) eq 0 then scale=1D0
	if n_elements(lng0) eq 0 then lng0=0.D0
	smj = a*scale
 
 
	err = 1
 
	;-------------------------------------------------
	;  Forward: Long,Lat ==> x,y
	;-------------------------------------------------
	if arg_present(x) then begin
	  if not arg_present(y) then begin
	    print,' Error in ell_merc: must give both x=x, y=y'
	    return
	  endif
;	  print,' Transforming Long, Lat to x,y ...'
	  x = smj*(p1-lng0)/radeg
	  snlat = sin(p2/radeg)
	  t1 = (1D0+snlat)/(1D0-snlat)
	  t2 = (1D0-e*snlat)/(1D0+e*snlat)
	  y = (smj/2.D0)*alog(t1*t2^e)
	  return 
	endif
 
	;-------------------------------------------------
	;  Inverse: x,y ==> Long,Lat
	;-------------------------------------------------
	if arg_present(lng) then begin
	  if not arg_present(lat) then begin
	    print,' Error in ell_merc: must give both lng=lng, lat=lat'
	    return
	  endif
;	  print,' Transforming x,y to Long, Lat ...'
	  lng = (p1/smj)*radeg + lng0	; Longitude.
	  t = exp(-p2/smj)
	  pstart = pi2 - 2D0*atan(t)	; First guess lat (radians).
	  p = pstart			; Initial arrays.
	  pnew = p
	  tol = 1D-11			; Tolerance for mm accuracy.
	  w = lindgen(n_elements(t))	; Index to all elements.
loop:	  
	  tmp = (1D0-e*sin(p(w)))/(1D0+e*sin(p(w)))
	  pnew(w) = pi2 - 2D0*atan(t(w)*tmp^(e/2D0))
	  w = where(abs(p-pnew) gt tol, cnt)
	  if cnt gt 0 then begin
	    print,cnt
	    p(w) = pnew(w)
	    goto, loop
	  endif
	  lat = pnew*radeg
	endif
 
	end
