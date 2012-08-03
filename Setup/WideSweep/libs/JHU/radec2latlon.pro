;-------------------------------------------------------------
;+
; NAME:
;       RADEC2LATLON
; PURPOSE:
;       RA, Dec, time to Latitude, Longitude (substar point).
; CATEGORY:
; CALLING SEQUENCE:
;       radec2latlon, ra, dec, js_ut, lat, lon
; INPUTS:
;       ra,dec = R.A., Dec of an object (deg).         in
;       js_ut = UT Time in JS.                         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       lat, lon = position of sub-object point (deg). out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Oct 29
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro radec2latlon, ra, dec, js_ut, lat, lon, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' RA, Dec, time to Latitude, Longitude (substar point).'
	  print,' radec2latlon, ra, dec, js_ut, lat, lon'
	  print,' ra,dec = R.A., Dec of an object (deg).         in'
	  print,' js_ut = UT Time in JS.                         in'
	  print,' lat, lon = position of sub-object point (deg). out'
	  return
	endif
 
	gra = js2gra(js_ut)*!radeg	; GMST in degrees.
	lon = ra - gra			; Longitude under RA.
	w1 = where(lon lt -180, c1)	; Correct to -180 to +180 deg.
	w2 = where(lon gt  180, c2)
	if c1 gt 0 then lon(w1)=lon(w1)+360
	if c2 gt 0 then lon(w2)=lon(w2)-360
	lat = dec			; Latitude under Dec.
 
	end
