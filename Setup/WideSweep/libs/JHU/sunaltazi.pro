;-------------------------------------------------------------
;+
; NAME:
;       SUNALTAZI
; PURPOSE:
;       Compute sun position from date/time and long/lat.
; CATEGORY:
; CALLING SEQUENCE:
;       sunaltazi, time, lng, lat, azi, alt
; INPUTS:
;       time=t  Date and time string or double               in
;          precision Julian Seconds.
;       lng, lat = Longitude and latitude.  May be arrays.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.
;         SUBLNG=lng  Subsolar point longitude (deg).
;         SUBLAT=lat  Subsolar point latitude (deg).
;         /NOREFRACT  Means return true altitude, not refracted.
;         ERROR=err   Time error flag (0=ok).
; OUTPUTS:
;       azi, alt = corresponding solar azimuth and altitude  out
;          at given points.  Altitude is refracted, not actual.
; COMMON BLOCKS:
; NOTES:
;       Note: true alt returned unrefracted if it is < -1 deg.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Dec 13
;       R. Sterner, 1998 Jan 19 --- Renamed from sunpos to avoid conflict
;       with a routine of the same name in the IDLASTRO library from GSFC.
;       R. Sterner, 2001 Jan 24 --- Added /NOREFRACT.
;       R. Sterner, 2004 Jan 07 --- Fixed a bug for multiple times.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sunaltazi, time, lng, lat, azi, alt, zone=zone, help=hlp, $
	  sublng=sunlng, sublat=sunlat, error=err, norefract=norefract
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute sun position from date/time and long/lat.'
	  print,' sunaltazi, time, lng, lat, azi, alt'
	  print,'   time=t  Date and time string or double               in'
	  print,'      precision Julian Seconds.'
	  print,'   lng, lat = Longitude and latitude.  May be arrays.   in'
	  print,'   azi, alt = corresponding solar azimuth and altitude  out'
	  print,'      at given points.  Altitude is refracted, not actual.'
	  print,' Keywords:'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.'
	  print,'   SUBLNG=lng  Subsolar point longitude (deg).'
	  print,'   SUBLAT=lat  Subsolar point latitude (deg).'
	  print,'   /NOREFRACT  Means return true altitude, not refracted.'
	  print,'   ERROR=err   Time error flag (0=ok).'
	  print,' Note: true alt returned unrefracted if it is < -1 deg.'
	  return
	endif
 
	;--------  Check if date/time string  -------------
	if datatype(time) eq 'DOU' then begin
	  js = time
	  err = 0
	endif else begin
	  js = dt_tm_tojs(time, err=err)
	  if err ne 0 then return
	endelse
 
	;-------  Correct given time to UT  ----------
	if n_elements(zone) eq 0 then zone=0
	js_et = js - zone*3600.		; Want UT (almost ET).
 
	;-------  Need Julian Day and hours  --------
	js2ymds, js_et, y, m, d, s	; Split JS into components.
	jd = ymd2jd(y,m,d)              ; Find Julian Day number.
	ut = s/86400.			; UT in days.
 
	;-------  Find solar RA/Dec  ------------
	sunjs, js_et, app_ra=ra, app_dec=dec
 
        ;--------  GMST (Greenwich Mean Sidereal Time)  -----
        st = lmst(jd,ut,0)*24
 
	;------  Subsolar point  ------------
        sunlat = dec
        sunlng = 15.0*(ra-st)
 
	;------  Compute sun azimuth and altitude from given pt(s)  -----
	if n_elements(lng) eq 0 then return
	ll2rb,lng,lat,sunlng,sunlat,rr,azi
	alt = 90-rr*!radeg
	if keyword_set(norefract) then return	; No refract.
	w = where(alt gt -1., cnt)
	if cnt gt 0 then alt(w)=refract(alt(w))	; Refract if not too low.
 
	return
	end
