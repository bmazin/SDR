;-------------------------------------------------------------
;+
; NAME:
;       ELL_GEO_INT
; PURPOSE:
;       Intersection point of two geodesic segments.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_geo_int, s1, s2, pi
; INPUTS:
;       s1, s2 = Segments 1 and 2.        in
;         s1 = {lon1:lon1, lat1:lat1, lon2:lon2, lat2:lat2}
;               Segment start point,  Segment end point.
;         s2 = Same format.
; KEYWORD PARAMETERS:
;       Keywords:
;         FLAG=flag Status flag.  0=no intersection, 1=intersection.
; OUTPUTS:
;       pi = Returned intersection point. out
;         pi = {loni:loni, lati:lati}
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 25
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_geo_int, s1, s2, pm, flag=flag, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Intersection point of two geodesic segments.'
	  print,' ell_geo_int, s1, s2, pi'
	  print,'   s1, s2 = Segments 1 and 2.        in'
	  print,'     s1 = {lon1:lon1, lat1:lat1, lon2:lon2, lat2:lat2}'
	  print,'           Segment start point,  Segment end point.'
	  print,'     s2 = Same format.'
	  print,'   pi = Returned intersection point. out'
	  print,'     pi = {loni:loni, lati:lati}'
	  print,' Keywords:'
	  print,'   FLAG=flag Status flag.  0=no intersection, 1=intersection.'
	  return
	endif
 
	;----------------------------------------------------------
	;  Check that segment S2 (p3-p4) crosses segment S1 (p1-p2)
	;----------------------------------------------------------
	p1 = {lon:s1.lon1,lat:s1.lat1}	; Seg 1 start pt.
	p2 = {lon:s1.lon2,lat:s1.lat2}	; Seg 1 end pt.
	side3 = ell_geo_side(p1,p2,{lon:s2.lon1,lat:s2.lat1})
	side4 = ell_geo_side(p1,p2,{lon:s2.lon2,lat:s2.lat2})
	if side3*side4 eq 1 then begin	; Test points are on same side of s1.
	  flag=0			; No intersection.
	  return
	endif
 
	;----------------------------------------------------------
	;  Check that segment S1 (p1-p2) crosses segment S2 (p3-p4)
	;----------------------------------------------------------
	p3 = {lon:s2.lon1,lat:s2.lat1}	; Seg 2 start pt.
	p4 = {lon:s2.lon2,lat:s2.lat2}	; Seg 2 end pt.
	side1 = ell_geo_side(p3,p4,{lon:s1.lon1,lat:s1.lat1})
	side2 = ell_geo_side(p3,p4,{lon:s1.lon2,lat:s1.lat2})
	if side1*side2 eq 1 then begin	; Test points are on same side of s2.
	  flag=0			; No intersection.
	  return
	endif
 
	;----------------------------------------------------------
	;  Segments intersect
	;  Do a binary search with a pt on S1, match
	;  azimuth of S2.
	;----------------------------------------------------------
	tol = 0.001				; Tolerance (m).
	flag = 1				; Segments intersect.
	pm = p1					; Init last midpt.
loop:
	pm_last = pm				; Save last midpt.
	pm = ell_geo_mid(p1,p2)			; New midpt.
 
	ell_ll2rb, pm_last.lon, pm_last.lat, pm.lon, pm.lat, r, a1
	if r lt tol then return
 
	sidem = ell_geo_side(p3,p4,pm)		; Side of midpt.
	if sidem eq 0. then return		; Exact match.
	if sidem eq side2 then begin		; Next pm=mid(p1,pm).
	  p2 = pm				; New pt 2.
	  goto, loop
	endif else begin			; Next pm=mid(p2,pm).
	  p1 = pm
	  goto, loop
	endelse
 
	end
