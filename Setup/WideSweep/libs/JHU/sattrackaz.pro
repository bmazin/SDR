;-------------------------------------------------------------
;+
; NAME:
;       SATTRACKAZ
; PURPOSE:
;       Return the azimuth of a satellite track given inc and lat.
; CATEGORY:
; CALLING SEQUENCE:
;       taz = sattrackaz(inc, lat)
; INPUTS:
;       inc = Inclination of satellite orbit (degrees).     in
;       lat = Latitude of subsatellite point (degrees).     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ASCENDING  Means satellite is in the ascending part
;           of it's orbit (moving northward).
;         /DESCENDING  Means satellite is in the descending part
;           of it's orbit (moving southward).
; OUTPUTS:
;       taz = Azimuth of forward satellite track (degrees). out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jan 17
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function sattrackaz, inc, lat, ascending=asc, descending=des, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return the azimuth of a satellite track given inc and lat.'
	  print,' taz = sattrackaz(inc, lat)'
	  print,'   inc = Inclination of satellite orbit (degrees).     in'
	  print,'   lat = Latitude of subsatellite point (degrees).     in'
	  print,'   taz = Azimuth of forward satellite track (degrees). out'
	  print,' Keywords:'
	  print,'   /ASCENDING  Means satellite is in the ascending part'
	  print,"     of it's orbit (moving northward)."
	  print,'   /DESCENDING  Means satellite is in the descending part'
	  print,"     of it's orbit (moving southward)."
	  return,''
	endif
 
	;------  Error checking  ------------
	dflag = 0				; Direction flag.
	if keyword_Set(asc) then dflag=1	; Ascending.
	if keyword_Set(des) then dflag=2	; Descending.
 
	if dflag eq 0 then begin
	  print,' Error in sattrackaz: Must use a keyword to specify'
	  print,'   Ascending or Descending part of orbit.'
	  return,-1
	endif
 
	w = where(abs(lat) gt abs(inc), cnt)
	if cnt gt 0 then begin
          print,' Error in sattrackaz: Given latitude is invalid.'
          print,'   Subsatellite latitude cannot be greater than the.'
	  print,'   orbital inclination.'
          return,-1
        endif
 
	if abs(inc) gt 90 then begin
	  w = where(abs(lat) gt 180-abs(inc), cnt)
	  if cnt then begin
            print,' Error in sattrackaz: Given latitude is invalid.'
            print,'   Subsatellite latitude cannot be greater than the.'
	    print,'   180-(orbital inclination).'
            return,-1
          endif
	endif
 
	;------  Compute track azimuth  ------------
	cinc = cos(inc/!radeg)
	clat = cos(lat/!radeg)
	ta = !radeg*asin(cinc/clat)		; Ascending.
	if dflag eq 2 then ta=180-ta		; Descending.
	w = where(ta lt 0, cnt)			; Keep azimuth in standard
	if cnt gt 0 then ta(w)=360+ta(w)	;    range (0-360).
 
	return, ta
 
	end
