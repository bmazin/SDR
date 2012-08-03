;-------------------------------------------------------------
;+
; NAME:
;       WGS_84
; PURPOSE:
;       Return a structure with some WGS 84 Ellipsoid values.
; CATEGORY:
; CALLING SEQUENCE:
;       s = wgs_84()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         LAT=lat  Specified latitude in degrees (def=0).
;         /GEODETIC means given latitude is geodetic (def)).
;         /GEOCENTRIC means given latitude is geocentric.
; OUTPUTS:
;       s = returned structure:              out
;         s.a = semi-major axis (m).
;         s.b = semi-minor axis (thru N-S pole) (m).
;         s.f1 = Reciprocal of flattening.
;         s.lat0 = Geocentric latitude for returned radius (deg).
;         s.lat1 = Geodetic latitude for returned radius (deg).
;         s.r = Radius from center at given latitude (m).
;         s.r_axis = Radius from rotation axis at given latitude (m).
;         s.d2m_lat = Meters/deg of lat at given lat (m).
;         s.d2m_lon = Meters/deg of lon at given lat (m).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Nov 2
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function wgs_84, help=hlp, lat=lat, geocentric=geocen, geodetic=geodet
 
	if keyword_set(hlp) then begin
	  print,' Return a structure with some WGS 84 Ellipsoid values.'
	  print,' s = wgs_84()'
	  print,'   s = returned structure:              out'
	  print,'     s.a = semi-major axis (m).'
	  print,'     s.b = semi-minor axis (thru N-S pole) (m).'
	  print,'     s.f1 = Reciprocal of flattening.'
	  print,'     s.lat0 = Geocentric latitude for returned radius (deg).'
	  print,'     s.lat1 = Geodetic latitude for returned radius (deg).'
	  print,'     s.r = Radius from center at given latitude (m).'
	  print,'     s.r_axis = Radius from rotation axis at given latitude (m).'
	  print,'     s.d2m_lat = Meters/deg of lat at given lat (m).'
	  print,'     s.d2m_lon = Meters/deg of lon at given lat (m).'
	  print,' Keywords:'
	  print,'   LAT=lat  Specified latitude in degrees (def=0).'
	  print,'   /GEODETIC means given latitude is geodetic (def)).'
	  print,'   /GEOCENTRIC means given latitude is geocentric.'
	endif
 
	;--------  WGS84 constants  -----------------------
	a = 6378137.0000D0	; semi-major axis (m).
	f1 = 298.257223563D0	; Reciprocal flattening.
	f = 1D0/f1		; Actual flattening value.
	b = a*(1D0-f)		; semi-minor axis (thru N-S pole) (m).
	a2 = a^2
	b2 = b^2
 
	;--------  Latitude  --------------------------------
	degrad = !dpi/180D0			; Radians/degree.
	flag = 0	; Unkown latitude type flag.
	;----  Given geocentric latitude, find geodetic latitude  ------
	if keyword_set(geocen) then begin
	  lat0 = double(lat)
	  lat1 = atan((a2/b2)*tan(lat0*degrad))/degrad
	  flag = 1
	endif
	;----  Given geodetic latitude, find geocentric latitude  ------
	if keyword_set(geodet) then begin
	  lat1 = double(lat)
	  lat0 = atan((b2/a2)*tan(lat1*degrad))/degrad
	  flag = 1
	endif
	;-----  Assume geodetic latitude, def=0  ------------
	if flag eq 0 then begin
	  if n_elements(lat) eq 0 then lat=0D0
	  lat1 = double(lat)
	  lat0 = atan((b2/a2)*tan(lat1*degrad))/degrad
	endif
 
	s = sin(lat0*degrad)
	c = cos(lat0*degrad)
 
	r = sqrt((a2*b2)/(a2*s^2+b2*c^2))	; Earth radius at lat (m).
 
	r_ax = r*c				; Radius from rotation axis.
	d2m_lat = r*degrad			; meters per deg of lat at lat.
	d2m_lon = r*c*degrad			; meters per deg of lon at lat.
 
	st = {a:a, b:b, f1:f1, lat0:lat0, lat1:lat1, $
	      r:r, r_axis:r_ax, d2m_lat:d2m_lat, d2m_lon:d2m_lon}
 
	return, st
 
	end
