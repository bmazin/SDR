;-------------------------------------------------------------
;+
; NAME:
;       DATUM_NAD27_TO_WGS84
; PURPOSE:
;       Datum shift from NAD27 to WGS84, CONUS only.
; CATEGORY:
; CALLING SEQUENCE:
;       datum_nad27_to_wgs84, lng, lat, ht
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
	;  Make sure to set to the original datum's
	;  ellipsoid first.
	;-----------------------------------------------
	ellipsoid,set='Clark 1866'	; NAD 27 ellipsoid.
	dx = -8d0			; NAD 27 to WGS 84
	dy = 160d0			;   ellipsoid center shift (m).
	dz = 176d0
 
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
 
	end
