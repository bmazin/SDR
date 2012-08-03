;-------------------------------------------------------------
;+
; NAME:
;       SUN_ZD
; PURPOSE:
;       Return solar zenith distances for given position.
; CATEGORY:
; CALLING SEQUENCE:
;       zd = sun_zd(lng, lat, t1, t2)
; INPUTS:
;       lng = Longitude of position (west<0).               in
;       lat = Latitude of position.                         in
;       t1 = start time.                                    in
;       t2 = end time (def=t1+1 day).                       in
;         Times may be Julian Seconds or Date/Time string.
; KEYWORD PARAMETERS:
;       Keywords:
;         ZONE=hrs  Hours ahead of GMT (def=0). Ex: zone=-4 for EDT.
;         NUMBER=n  Specified number of output values (def=25).
;         TIME=t    Returned time (JS) for each ZD.
;         AZIMUTH=azi  Returned azimuths for each time.
; OUTPUTS:
;       zd = returned solar zenith distances in degrees.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 15
;       R. Sterner, 1998 Jan 19 --- Renamed sunpos to sunaltazi.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function sun_zd, lng, lat, t1, t2, number=num, time=tm, $
	  azimuth=azi, zone=zone, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Return solar zenith distances for given position.'
	  print,' zd = sun_zd(lng, lat, t1, t2)'
	  print,'   lng = Longitude of position (west<0).               in'
	  print,'   lat = Latitude of position.                         in'
	  print,'   t1 = start time.                                    in'
	  print,'   t2 = end time (def=t1+1 day).                       in'
	  print,'     Times may be Julian Seconds or Date/Time string.'
	  print,'   zd = returned solar zenith distances in degrees.    out'
	  print,' Keywords:'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0). Ex: zone=-4 for EDT.'
	  print,'   NUMBER=n  Specified number of output values (def=25).'
	  print,'   TIME=t    Returned time (JS) for each ZD.'
	  print,'   AZIMUTH=azi  Returned azimuths for each time.'
	  return, ''
	endif
 
	j1 = t1
	if datatype(j1) ne 'DOU' then j1=dt_tm_tojs(t1)
	if n_elements(t2) eq 0 then begin
	  j2 = j1+86400d0
	endif else begin
	  j2 = t2
	  if datatype(j2) ne 'DOU' then j2=dt_tm_tojs(t2)
	endelse
	if n_elements(num) eq 0 then num = round((j2-j1)/3600.+1)
 
	tm = maken(j1,j2,num)
	zd = fltarr(num)
	azi = fltarr(num)
 
	for i=0,num-1 do begin
	  sunaltazi, tm(i), lng, lat, az, alt, zone=zone
	  azi(i) = az
	  zd(i) = 90.-alt
	endfor
 
	return, reform(zd,num,1)
	end
