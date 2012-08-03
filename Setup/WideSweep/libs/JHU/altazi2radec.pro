;-------------------------------------------------------------
;+
; NAME:
;       ALTAZI2RADEC
; PURPOSE:
;       Convert from alt,azi,time to ra,dec.
; CATEGORY:
; CALLING SEQUENCE:
;       altazi2radec, alt, azi, js_ut, lng, lat, ra, dec
; INPUTS:
;       alt, azi = Object altitude and azimuth in deg. in
;       js_ut = UT Time in JS.                         in
;       lng, lat = Observer long,lat in deg.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ra,dec = R.A., Dec in deg.                     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jan 11
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro altazi2radec, alt, azi, js_ut, lng, lat, ra, dec, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Convert from alt,azi,time to ra,dec.'
	  print,' altazi2radec, alt, azi, js_ut, lng, lat, ra, dec'
	  print,'   alt, azi = Object altitude and azimuth in deg. in'
	  print,'   js_ut = UT Time in JS.                         in'
	  print,'   lng, lat = Observer long,lat in deg.           in'
	  print,'   ra,dec = R.A., Dec in deg.                     out'
	  return
	endif
 
	;--------  Convert Azi, Alt to X,Y,Z  --------
	ax1 = 90.D0-azi	; Deg from +X.
	az1 = 90.D0-alt	; Deg from +Z.
	polrec3d, /deg, 1.D0, az1, ax1, x1, y1, z1
	;--------  Rotate about X axis by CoLat  -------
	colat = 90.D0-lat
	rot_3d, 1, x1,y1,z1, -colat, /deg, x2, y2, z2
	;--------  Convert X2,Y2,Z2 to HA, Dec  ------
	recpol3d, /deg,x2,y2,z2,r,az2,ax2
	ha = -90.D0 - ax2
	dec = 90.D0 - az2
 
	;--------  RA of meridian in deg  -------------
	gra = js2gra(js_ut)*!radeg	; RA (deg) of Greenwich meridan.
	lra = gra + lng			; RA (deg) of Local meridan.
 
	;---------  HA to RA  --------------
	ra = pmod(lra-ha,360)			; R.A. in deg.
 
	return
 
	end
