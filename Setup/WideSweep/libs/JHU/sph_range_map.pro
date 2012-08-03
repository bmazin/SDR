;-------------------------------------------------------------
;+
; NAME:
;       SPH_RANGE_MAP
; PURPOSE:
;       Compute an array of ranges from a point on a sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       r = sph_range_map(lng0, lat0, res)
; INPUTS:
;       lng0 = Longitude of starting point (deg).         in
;       lat0 = Latitude of starting point (deg).          in
;       res = resolution in degrees for lat and long.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         NX=nx, NY=ny Number of elements in X and Y dimensions.
;           Supercedes res.
; OUTPUTS:
;       r = Returned distance array in degrees.           out
;         r covers longitudes -180 to (+180-res) and
;                   latitudes   -90 to (+90-res).
; COMMON BLOCKS:
; NOTES:
;       Note: lng0,lat0 is the point at 0 range.  For example,
;         if this is the subsolar point then ranges will be
;         sun zenith distance in degrees.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Dec 01
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function sph_range_map, lng0, lat0, res, nx=nx, ny=ny, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Compute an array of ranges from a point on a sphere.'
	  print,' r = sph_range_map(lng0, lat0, res)'
	  print,'  lng0 = Longitude of starting point (deg).         in'
	  print,'  lat0 = Latitude of starting point (deg).          in'
	  print,'  res = resolution in degrees for lat and long.     in'
	  print,'  r = Returned distance array in degrees.           out'
	  print,'    r covers longitudes -180 to (+180-res) and'
	  print,'              latitudes   -90 to (+90-res).'
	  print,' Keywords:'
	  print,'   NX=nx, NY=ny Number of elements in X and Y dimensions.'
	  print,'     Supercedes res.'
	  print,' Note: lng0,lat0 is the point at 0 range.  For example,'
	  print,'   if this is the subsolar point then ranges will be'
	  print,'   sun zenith distance in degrees.'
	  return,''
	endif
 
	;--------  Deal with arguments  -----------------------------
	if n_elements(res) eq 0 then res=1	; Default res = 1 deg.
 
	;--------  Set up lat, long, and world array  ---------------
	if n_elements(nx) gt 0 then begin
	  lng = maken(-180,180,nx)
	endif else begin
	  lng = makex(-180,180,res)
	  nx = n_elements(lng)
	endelse
	if n_elements(ny) gt 0 then begin
	  lat = maken(-90,90,ny)
	endif else begin
	  lat = makex(-90,90,res)
	  ny = n_elements(lat)
	endelse
 
	lat = transpose(lat)	  ; Want latitude to be a column.
        vx = cos(lat/!radeg)	  ; Find X and Z components for Long=0 (Y=0).
        vz = sin(lat/!radeg)
	r = fltarr(nx,ny)	  ; Output distances in degrees.
 
	;---  Loop through longitudes, find sun/world pt long diff  ---
	for i=0, nx-1 do begin
	  polrec3d,1.,90.-lat0,lng(i)-lng0,/deg,sx,sy,sz  ; New pt vect.
	  cs = vx*sx + vz*sz                            ; Lat vector dot pt v.
	  r(i,0) = acos(cs)*!radeg			; Range..
	endfor
 
	return, r
 
	end
