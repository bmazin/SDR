;-------------------------------------------------------------
;+
; NAME:
;       RADEC2ALTAZI
; PURPOSE:
;       Convert from ra,dec,time to alt,azi.
; CATEGORY:
; CALLING SEQUENCE:
;       radec2altazi, ra, dec, js_ut, lng, lat, alt2, azi2
; INPUTS:
;       ra,dec = R.A., Dec in deg.           in
;       js_ut = UT Time in JS.               in
;       lng, lat = Observer long,lat in deg. in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       alt, azi = Alt, Azi in deg.          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jan 17
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro radec2altazi, ra, dec, js_ut, lng, lat, alt2, azi2, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
          print,' Convert from ra,dec,time to alt,azi.'
	  print,' radec2altazi, ra, dec, js_ut, lng, lat, alt2, azi2'
	  print,'   ra,dec = R.A., Dec in deg.           in'
	  print,'   js_ut = UT Time in JS.               in'
	  print,'   lng, lat = Observer long,lat in deg. in'
	  print,'   alt, azi = Alt, Azi in deg.          out'
	  return
	endif
 
	;--------  RA of meridian in deg  -------------
	gra = js2gra(js_ut)*!radeg	; RA (deg) of Greenwich meridan.
	lra = gra + lng			; RA (deg) of Local meridan.
 
	;--------  RA, Dec to X,Y,Z  ---------------------
	ax1 = ra - lra - 90.D0
	az1 = 90.D0 - dec
	polrec3d, /deg, 1.D0, az1, ax1, x1, y1, z1
	;--------  Rotate about X axis by CoLat  -------
	colat = 90.D0-lat
	rot_3d, 1D0, x1,y1,z1, colat, /deg, x2, y2, z2
	;--------  Convert X2,Y2,Z2 to Azi, Alt  -------
	recpol3d, /deg,x2,y2,z2,r,az2,ax2
	alt2 = 90D0-az2
	azi2 = pmod(90d0-ax2,360)
 
	return
 
	end
