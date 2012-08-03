;-------------------------------------------------------------
;+
; NAME:
;       SUNPOS
; PURPOSE:
;       Compute sun position from date/time and long/lat.
; CATEGORY:
; CALLING SEQUENCE:
;       sunpos, time, lng, lat, azi, alt
; INPUTS:
;       time=t  Date and time string or double               in
;          precision Julian Seconds.
;       lng, lat = Longitude and latitude.  May be arrays.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.
;         SUBLNG=lng  Subsolar point longitude (deg).
;         SUBLAT=lat  Subsolar point latitude (deg).
; OUTPUTS:
;       azi, alt = corresponding solar azimuth and altitude  out
;          at given points.  Altitude is refracted, not actual.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Dec 13
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro sunpos, time, lng, lat, azi, alt, zone=zone, $
	  sublng=sunlng, sublat=sunlat, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute sun position from date/time and long/lat.'
	  print,' sunpos, time, lng, lat, azi, alt'
	  print,'   time=t  Date and time string or double               in'
	  print,'      precision Julian Seconds.'
	  print,'   lng, lat = Longitude and latitude.  May be arrays.   in'
	  print,'   azi, alt = corresponding solar azimuth and altitude  out'
	  print,'      at given points.  Altitude is refracted, not actual.'
	  print,' Keywords:'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.'
	  print,'   SUBLNG=lng  Subsolar point longitude (deg).'
	  print,'   SUBLAT=lat  Subsolar point latitude (deg).'
	  return
	endif
 
	;--------  Check if date/time string  -------------
	if dt_tm_chk(time) eq 0 then begin
	  if datatype(time) ne 'DOU' then begin
	    print,' Error in sunpos: time must be either a date/time string'
	    print,'      (both date and time),'
	    print,'   or Julian Seconds in double precision.'
	    return
	  endif
	  js = time
	endif else js=dt_tm_tojs(time)
 
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
	alt = refract(90-rr*!radeg)
 
	return
	end
