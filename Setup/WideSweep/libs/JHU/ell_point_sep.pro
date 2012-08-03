;-------------------------------------------------------------
;+
; NAME:
;       ELL_POINT_SEP
; PURPOSE:
;       Distance in meters between two points given as structures.
; CATEGORY:
; CALLING SEQUENCE:
;       sep = ell_point_sep(p1, p2)
; INPUTS:
;       p1, p2 = Two given points.                     in
;         Points are structures: {lon:lon, lat:lat}.
; KEYWORD PARAMETERS:
;       Keywords:
;         AZI=azi  Two element array with azimuths [a1,a2]
;           where a1 is azimuth from p1 to p2, and a2 is azimuth
;           from p2 to p1.
; OUTPUTS:
;       sep = Distance between the points in meters.   out
;         Distance is the ellipsoidal geodesic distance.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Aug 24
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ell_point_sep, p1, p2, azi=azi, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Distance in meters between two points given as structures.'
	  print,' sep = ell_point_sep(p1, p2)'
	  print,'   p1, p2 = Two given points.                     in'
	  print,'     Points are structures: {lon:lon, lat:lat}.'
	  print,'   sep = Distance between the points in meters.   out'
	  print,'     Distance is the ellipsoidal geodesic distance.'
	  print,' Keywords:'
	  print,'   AZI=azi  Two element array with azimuths [a1,a2]'
	  print,'     where a1 is azimuth from p1 to p2, and a2 is azimuth'
	  print,'     from p2 to p1.'
	  return,''
	endif
 
	ell_ll2rb, p1.lon,p1.lat,p2.lon,p2.lat,d,a1,a2
	azi = [a1,a2]
	return, d
 
	end
