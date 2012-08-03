;-------------------------------------------------------------
;+
; NAME:
;       ELL_GEO_MID
; PURPOSE:
;       Find midpoint between two points along a geodesic.
; CATEGORY:
; CALLING SEQUENCE:
;       pm = ell_geo_mid(p1, p2)
; INPUTS:
;       p1 = Point 1 on geodesic {lon:lon, lat:lat}. in
;       p2 = Point 2 on geodesic {lon:lon, lat:lat}. in
; KEYWORD PARAMETERS:
;       Keywords:
;         AZI1=a1 Returned azimuth from p1 to pm.
;         AZI2=a2 Returned azimuth from pm to p1.
; OUTPUTS:
;       pm = Returned midpoint {lon:lon, lat:lat}.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Mar 09
;       R. Sterner, 2006 Sep 25 --- Switched to function using structures.
;       R. Sterner, 2007 Aug 05 --- Added new keyword AZIMUTH.
;       R. Sterner, 2007 Aug 20 --- Changed the returned azimuth
;       to azi1=a1, azi2=a2.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ell_geo_mid, p1, p2, azi1=a1, azi2=a2, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find midpoint between two points along a geodesic.'
	  print,' pm = ell_geo_mid(p1, p2)'
	  print,'   p1 = Point 1 on geodesic {lon:lon, lat:lat}. in'
	  print,'   p2 = Point 2 on geodesic {lon:lon, lat:lat}. in'
	  print,'   pm = Returned midpoint {lon:lon, lat:lat}.   out'
	  print,' Keywords:'
	  print,'   AZI1=a1 Returned azimuth from p1 to pm.'
	  print,'   AZI2=a2 Returned azimuth from pm to p1.'
          return,''
        endif
 
	ell_ll2rb, p1.lon,p1.lat, p2.lon,p2.lat,d,a1,a2	; Dist and dir 1 to 2.
	ell_rb2ll, p1.lon,p1.lat, d/2D0, a1, lonm, latm, a2  ; Go halfway.
	return, {lon:lonm, lat:latm}
 
	end
