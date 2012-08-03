;-------------------------------------------------------------
;+
; NAME:
;       SATLATLNG2ALTAZI
; PURPOSE:
;       From Lat, Long find Altitude, Azimuth for a satellite.
; CATEGORY:
; CALLING SEQUENCE:
;       sataltazi2latlng, lat, lng, h, lat0, lng0, alt, azi
; INPUTS:
;       lat = Subsatellite point latitude.              in
;       lng = Subsatellite point longitude.             in
;       h = Satellite height above surface (km).        in
;       lat0 = Latitude of observation point.           in
;       lng0 = Longitude of observation point.          in
;         (West < 0).
; KEYWORD PARAMETERS:
; OUTPUTS:
;       alt = Altitude as view from lat0,lng0 (deg).    out
;       azi = Azimuth as view from lat0,lng0 (deg).     out
; COMMON BLOCKS:
; NOTES:
;       Notes: For a spherical earth.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Apr 11
;       R. Sterner, 2006 Aug 15 --- Moved from IDLNOAA and added comments.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro satlatlng2altazi, lat, lng, h, lat0, lng0, alt, azi, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' From Lat, Long find Altitude, Azimuth for a satellite.'
	  print,' sataltazi2latlng, lat, lng, h, lat0, lng0, alt, azi'
	  print,'   lat = Subsatellite point latitude.              in'
	  print,'   lng = Subsatellite point longitude.             in'
	  print,'   h = Satellite height above surface (km).        in'
	  print,'   lat0 = Latitude of observation point.           in'
	  print,'   lng0 = Longitude of observation point.          in'
	  print,'     (West < 0).'
	  print,'   alt = Altitude as view from lat0,lng0 (deg).    out'
	  print,'   azi = Azimuth as view from lat0,lng0 (deg).     out'
	  print,' Notes: For a spherical earth.'
	  return
	endif
 
	;---------------------------------------------------------------------
	;  Method: First use ll2rb to find the range and bearing
	;  from the observation point to the subsatellite point.
	;  The bearing is the azimuth of the satellite.
	;  The range in radians, C (for central angle), is the angle
	;  at the earth's center between the observation point and
	;  the subsatellite point.  Finding the satellite's altitude
	;  above the horizon is now a 2-d problem.  A diagram may be
	;  made with a circle of radius Re at the origin.  Let the
	;  subsatellite point be where the circle crosses the Y axis.
	;  Call the origin point E, the earth center.  Call the
	;  satellite point S and the observation point G.  The segment
	;  ES is along the Y axis.  Segment EG is at angle C from the
	;  Y axis.  Form a right triangle with hypotenus EG with length Re,
	;  vertical side length Re*Cos(C) from point E, and horizontal side
	;  length Re*Sin(C) from point G.  The length of segment ES is
	;  Re + h.  Form another right triangle with hypotenus GS, horizontal
	;  side length Re*Sin(C) from point G (a shared side in first
	;  triangle), and vertical side length (Re + h) - Re*Cos(C).
	;  Call the point on the Y axis where the shared side crosses S'.
	;  The two triangles are ES'G and GS'S.  From the two sides of
	;  the second triangle compute angle A = Ang S'GS.  The satellite
	;  altitude is then A-C.
	;---------------------------------------------------------------------
	re = 6371.23				; Mean earth radius in km.
	ll2rb, lng0, lat0, lng, lat, c, azi	; Range, C, and bearing, azi.
	recpol,re*sin(c),re+h-re*cos(c),t,a	; Find angle A.
	alt = (a-c)*!radeg
 
	return
	end
