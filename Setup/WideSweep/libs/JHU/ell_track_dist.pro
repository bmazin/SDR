;-------------------------------------------------------------
;+
; NAME:
;       ELL_TRACK_DIST
; PURPOSE:
;       Return distance in meters along given track.
; CATEGORY:
; CALLING SEQUENCE:
;       d = ell_track_dist(lon,lat)
; INPUTS:
;       lon, lat = Arrays of track longitudes and latitudes.   in
;          These are arrays along a track.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       d = Distances in meters along track for each point.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Dec 07
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ell_track_dist, lon, lat, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return distance in meters along given track.'
	  print,' d = ell_track_dist(lon,lat)'
	  print,'   lon, lat = Arrays of track longitudes and latitudes.   in'
	  print,'      These are arrays along a track.'
	  print,'   d = Distances in meters along track for each point.    out'
	  return,''
	endif
 
	ell_geo_pt_sep, lon, lat, sep
	d = cumulate([0,sep])
	return, d
 
	end
