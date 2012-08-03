;-------------------------------------------------------------
;+
; NAME:
;       DATUM_SA1956_TO_WGS84
; PURPOSE:
;       Datum shift from SA1956 to WGS84, CONUS only.
; CATEGORY:
; CALLING SEQUENCE:
;       datum_sa1956_to_wgs84, lng, lat, ht
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Longitude and latitude are input in the NAD 27
;       datum and output in the WGS 84 datum.  This datum
;       is only for the continental US (conus) an is an
;       average. This routine shows how to do a 3
;       parameter datum shift when delta x,y,z are known.
;       Use this code as an example for datum shifting.
;       Will need to know the datum ellipsoid and
;       ellipsoid center shift values.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jul 15
;       R. Sterner, 2006 Mar 15 --- Renamed correctly and fixed help.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro datum_nad27_to_wgs84, lng, lat, ht, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Datum shift from NAD27 to WGS84, CONUS only.'
	  print,' datum_nad27_to_wgs84, lng, lat, ht'
	  print,'   lng, lat = Longitude and latitude.  in,out'
	  print,'   ht = height above ellipsoid (m).    in,out'
	  print,' Note: Longitude and latitude are input in the NAD 27'
	  print,' datum and output in the WGS 84 datum.  This datum'
	  print,' is only for the continental US (conus) an is an'
	  print,' average. This routine shows how to do a 3'
	  print,' parameter datum shift when delta x,y,z are known.'
	  print,' Use this code as an example for datum shifting.'
	  print,' Will need to know the datum ellipsoid and'
	  print,' ellipsoid center shift values.'
	  return
	endif
 
	;-----------------------------------------------
	;  Save incoming
	;-----------------------------------------------
	ell = 'International'
	datum0 = 'Provisional S. American 1956 - Guyana'
	lng0 = lng
	lat0 = lat
	ht0 = ht
 
	;-----------------------------------------------
	;  Make sure to set to the original datum's
	;  ellipsoid first.
	;  Datum is Provisional S. American 1956 - Guyana
	;-----------------------------------------------
	ellipsoid,set=ell		; Ellipsoid used.
	dx = -298d0			; Old Datum to WGS 84
	dy = 159d0			;   ellipsoid center shift (m).
	dz = -369d0
 
	;-----------------------------------------------
	;  Find earth centered x,y,z.
	;-----------------------------------------------
	ell_llh2xyz,lng,lat,ht,x,y,z	; lng, lat, ht to x,y,z.
 
	;-----------------------------------------------
	;  Set to the target datum's ellipsoid.
	;-----------------------------------------------
	ellipsoid,set='wgs 84'		; WGS 84 ellipsoid.
 
	;-----------------------------------------------
	;  Shift ellipsoid center and convert back to
	;  geographic coordinates.
	;-----------------------------------------------
	ell_xyz2llh,x+dx,y+dy,z+dz,lng,lat,ht	; x,y,z to lng, lat, ht.
 
	;-----------------------------------------------
	;  List shift.
	;-----------------------------------------------
	ell_ll2rb, lng0,lat0, lng, lat, r, a1, a2
	print,' The point:'
	print,'   long: '+strtrim(lng0,2)
	print,'    lat: '+strtrim(lat0,2)
	print,'  datum: '+datum0
	print,'    Ell: '+ell
	print,' When converted to WGS84 shifts to:'
	print,'   long: '+strtrim(lng,2)
	print,'    lat: '+strtrim(lat,2)
	print,' The height changes'
	print,'   from: '+strtrim(ht0,2)
	print,'     to: '+strtrim(ht,2)
	print,'   Range (m): '+strtrim(r,2)
	print,'   Azi (deg): '+strtrim(a1,2)
	print,' '
	print,' DX = '+strtrim(dx,2)
	print,' DY = '+strtrim(dy,2)
	print,' DZ = '+strtrim(dz,2)
 
 
	end
