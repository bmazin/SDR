;-------------------------------------------------------------
;+
; NAME:
;       ELL_GEO_PTS
; PURPOSE:
;       Return an array of points along a geodesic.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_geo_pts,p1,p2,lng3,lat3
; INPUTS:
;       lng1,lat1 = starting point.            in
;       lng2,lat2 = ending point.              in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAX=m  Maximum separation in meters (def=1000).
;         N=n    Number of points along geodesic.
;           Use only one of the above, if none defaults to
;           points spaced LE 1000 m.
; OUTPUTS:
;       lng3,lat3 = returned array of points.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Feb 09
;       R. Sterner, 2007 Aug 05 --- Corrected N=n option.
;       R. Sterner, 2007 Aug 29 --- Allow optional structures.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_geo_pts,arg1,arg2,arg3,arg4,arg5,arg6,max=mx,n=n,help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
help:	  print,' Return an array of points along a geodesic.'
	  print,' ell_geo_pts,p1,p2,lng3,lat3'
	  print,'     or'
	  print,' ell_geo_pts,lng1,lat1,lng2,lat2,lng3,lat3'
	  print,'   p1,p2 each a structure {lon:lon,lat:lat}.'
	  print,'     or'
	  print,'   lng1,lat1 = starting point.            in'
	  print,'   lng2,lat2 = ending point.              in'
	  print,'   lng3,lat3 = returned array of points.  out'
	  print,' Keywords:'
	  print,'   MAX=m  Maximum separation in meters (def=1000).'
	  print,'   N=n    Number of points along geodesic.'
	  print,'     Use only one of the above, if none defaults to'
	  print,'     points spaced LE 1000 m.'
	  return
	endif
 
	;-------------------------------------------
	;  Sort out arguments
	;-------------------------------------------
	if (n_params(0) eq 6) then begin
	  lng1 = arg1
	  lat1 = arg2
	  lng2 = arg3
	  lat2 = arg4
	endif
	if (n_params(0) eq 4) then begin
	  lng1 = arg1.lon
	  lat1 = arg1.lat
	  lng2 = arg2.lon
	  lat2 = arg2.lat
	endif
	if n_elements(lat2) eq 0 then goto, help
 
	;-------------------------------------------
	; Total distance
	;-------------------------------------------
	ell_ll2rb, lng1,lat1, lng2,lat2, d,a1,a2
 
	;-------------------------------------------
	;  Requested N points
	;-------------------------------------------
	if n_elements(n) ne 0 then begin
	  ell_rb2ll, lng1,lat1, maken(0,d,n), a1, lng3,lat3
	  goto, done
	endif
 
	;-------------------------------------------
	;  Requested max separation
	;-------------------------------------------
	if n_elements(mx) eq 0 then mx=1000.	; Def separation (m).
	num = ceil(d/mx) + 1
	ell_rb2ll, lng1,lat1, maken(0,d,num), a1, lng3,lat3
 
	;-------------------------------------------
	;  Sort out results
	;-------------------------------------------
done:	if (n_params(0) eq 6) then begin
	  arg5 = lng3
	  arg6 = lat3
	endif
	if (n_params(0) eq 4) then begin
	  arg3 = lng3
	  arg4 = lat3
	endif
 
	end
