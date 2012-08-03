;-------------------------------------------------------------
;+
; NAME:
;       FLAT2SPH
; PURPOSE:
;       Map a flat map onto a sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       flat2sph, flat, lng1, lng2, lat1, lat2, $
; INPUTS:
;       flat = array containing flat map.                    in
;         Longitude in X, Latitude in Y.
;       lng1, lng2 = start and end longitude in flat (deg).  in
;       lat1, lat2 = start and end latitude in flat (deg).   in
;       lng0, lat0 = Long. and Lat. of sphere center (deg).  in
;       r = radius of sphere in pixels.                      in
;           r may also be an array: [r,pa,ncx,ncy] where
;           r = radius in pixels,
;           pa = axis position angle in degrees,
;           ncx, ncy = center in normalized coordinates.
;       nx, ny = size of sphere image in pixels.             in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       sphere = output image of sphere.                     out
; COMMON BLOCKS:
; NOTES:
;       Note: flat may contain only a partial map.
; MODIFICATION HISTORY:
;       R. Sterner,  6 Nov, 1989.
;       R. Sterner, 26 Feb, 1991 --- Renamed from flat2sphere.pro
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro flat2sph, flat, lng1, lng2, lat1, lat2, out, lng0, lat0, $
	  rr, ny, nz, help=hlp
 
	if (n_params(0) lt 11) or keyword_set(hlp) then begin
	  print,' Map a flat map onto a sphere.' 
	  print,' flat2sph, flat, lng1, lng2, lat1, lat2, $'
	  print,'              sphere, lng0, lat0, r, nx, ny'
	  print,'   flat = array containing flat map.                    in'
	  print,'     Longitude in X, Latitude in Y.
	  print,'   lng1, lng2 = start and end longitude in flat (deg).  in'
	  print,'   lat1, lat2 = start and end latitude in flat (deg).   in'
	  print,'   sphere = output image of sphere.                     out'
	  print,'   lng0, lat0 = Long. and Lat. of sphere center (deg).  in'
	  print,'   r = radius of sphere in pixels.                      in'
	  print,'       r may also be an array: [r,pa,ncx,ncy] where'
	  print,'       r = radius in pixels,'
	  print,'       pa = axis position angle in degrees,'
	  print,'       ncx, ncy = center in normalized coordinates.'
	  print,'   nx, ny = size of sphere image in pixels.             in'
	  print,' Note: flat may contain only a partial map.'
	  return
	endif
 
	;-----  pick apart rr  ----------
	rra = rr
	ner = n_elements(rra)
	if ner ge 1 then r = rra(0)			; Radius in pixels.
	if ner ge 2 then pa = rra(1) else pa = 0.	; Axis angle (deg).
	if ner ge 3 then ncx = rra(2) else ncx = 0.5	; Sphere center x.
	if ner ge 4 then ncy = rra(3) else ncy = 0.5	; Sphere center y.
	
	sz = size(flat)					; Find size of flat.
	nxf = sz(1)					; Size in X.
	nyf = sz(2)					; Size in Y.
 
	cy = (ny-1.)*ncx				; Output sphere center.
	cz = (nz-1.)*ncy
	makexy, 0, ny-1, 1, 0, nz-1, 1, yy, zz		; Output x & y coord.
	yy = (yy-cy)/r					; Make unit sphere.
	zz = (zz-cz)/r
	m = yy^2 + zz^2					; Dist^2 from center.
 
	wi = where(m le 1., counti)			; pts inside sphere.
	wo = where(m gt 1., counto)			; pts outside sphere.
 
	xx = fltarr(ny,nz)				; Sphere point x value.
	xx(wi) = sqrt(1. - (yy(wi)^2 + zz(wi)^2)) 	; equat view X pts.
	if counto gt 0 then begin
	  yy(wo) = 0.					; Zero pts outsde sphr.
	  zz(wo) = 0.
	endif
 
	rot_3d, 2,xx,yy,zz,lat0/!radeg,xx2,yy2,zz2	; Y rot by Lat0.
	rot_3d, 1,xx2,yy2,zz2,-pa/!radeg,xx3,yy3,zz3	; X rot by -pa deg.
	recpol3d, xx3, yy3, zz3, rr, az, ax		; to sph polar coord.
	lat = 90. - az*!radeg				; Lat & long.
	lng = ax*!radeg + lng0
	l1 = 0.						; Shift long.
	l2 = lng2 - lng1
	lng = lng - lng1
	w = where(lng gt 360., count)			; Long. to 0-360 deg.
	if count gt 0 then lng(w) = lng(w) - 360.	; correct lng > 360.
	w = where(lng lt 0., count)
	if count gt 0 then lng(w) = lng(w) + 360.	; correct lng < 0.
	if counto gt 0 then begin
	  lng(wo) = -999.				; invalid pt flg value.
	  lat(wo) = -100.
	endif
 
	lngindx = scalearray(lng,l1,l2,0.,nxf-1.)	; find long. indices.
	latindx = scalearray(lat,lat1,lat2,0.,nyf-1.)	; Find lat indices.
	;---  Restrict to region covered by flat map ---
	wf = where((latindx ge 0.) and (latindx le nyf-1.) and $  
	           (lngindx ge 0.) and (lngindx le nxf-1.), count)
	if count gt 0 then begin
	  latindx = latindx(wf)
	  lngindx = lngindx(wf)
	endif
 
	out = bytarr(ny,nz)				; 0 outside sph.
	out(wi) = 1					; 1 inside sph.
	if count gt 0 then begin
	  ix = fix(.5+lngindx)				; NN interp.
	  iy = fix(.5+latindx)
	  out(wf) = flat(ix,iy)				; Move flat to sph.
	endif
 
	return
	end
