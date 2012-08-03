;-------------------------------------------------------------
;+
; NAME:
;       WORLD_SUNZD
; PURPOSE:
;       Compute Sun zenith distance for an array of world points.
; CATEGORY:
; CALLING SEQUENCE:
;       zd = world_sunzd(time, res)
; INPUTS:
;       time = time string (null string = current time).   in
;         May also give time in Julian Seconds.
;       res = resolution in degrees for both lat and long. in
; KEYWORD PARAMETERS:
;       Keywords:
;         ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.
;         SUNLNG=sunlng  Returned subsolar longitude.
;         SUNLAT=sunlat  Returned subsolar latitude.
; OUTPUTS:
;       zd = Returned zenith distance array in degrees.    out
;         zd covers longitudes -180 to (+180-res) and
;                   latitudes   -90 to (+90-res).
; COMMON BLOCKS:
; NOTES:
;       Notes: To display result, do device,decomp=0 (if 24-bit),
;         Use sun_colors to load sun color table, then display
;         zd (tv, not tvscl).  Can remap using map_image.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Oct 14
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function world_sunzd, time0, res, zone=hrs, $
	  sunlng=sunlng, sunlat=sunlat, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Compute Sun zenith distance for an array of world points.'
	  print,' zd = world_sunzd(time, res)'
	  print,'  time = time string (null string = current time).   in'
	  print,'    May also give time in Julian Seconds.'
	  print,'  res = resolution in degrees for both lat and long. in'
	  print,'  zd = Returned zenith distance array in degrees.    out'
	  print,'    zd covers longitudes -180 to (+180-res) and'
	  print,'              latitudes   -90 to (+90-res).'
	  print,' Keywords:'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.'
	  print,'   SUNLNG=sunlng  Returned subsolar longitude.'
	  print,'   SUNLAT=sunlat  Returned subsolar latitude.'
	  print,' Notes: To display result, do device,decomp=0 (if 24-bit),'
	  print,'   Use sun_colors to load sun color table, then display'
	  print,'   zd (tv, not tvscl).  Can remap using map_image.'
	  return,''
	endif
 
	;--------  Deal with arguments  -----------------------------
	if n_elements(time0) eq 0 then time0=''	; Force time defined.
	time = time0				; Copy time.
	if time eq '' then begin
	  time=systime()			; If null use current.
	endif
	if n_elements(hrs) eq 0 then hrs=-gmt_offsec()/3600.	; Def=local.
	if n_elements(res) eq 0 then res=1	; Default res = 1 deg.
 
	;--------  Set up lat, long, and world array  ---------------
	lng=makex(-180,180,res) & nx=n_elements(lng)
	lat=makex(-90,90,res)   & ny=n_elements(lat)
	lat = transpose(lat)	  ; Want latitude to be a column.
        vx = cos(lat/!radeg)	  ; Find X and Z components for Long=0 (Y=0).
        vz = sin(lat/!radeg)
	a = bytarr(nx,ny)	  ; Output zenith distances in degrees (byte).
 
	;--------  Get sun position  --------------------------------
	sunaltazi, time, sublng=sunlng, sublat=sunlat, zone=hrs
 
	;---  Loop through longitudes, find sun/world pt long diff  ---
	for i=0, nx-1 do begin
	  polrec3d,1.,90.-sunlat,lng(i)-sunlng,/deg,sx,sy,sz	; New sun vect.
	  cs = vx*sx + vz*sz                            ; Lat vector dot sun v.
	  a(i,0) = round(acos(cs)*!radeg)               ; Zenith Dist.
	endfor
 
	return, a
 
	end
