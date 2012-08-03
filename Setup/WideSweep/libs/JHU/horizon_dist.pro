;-------------------------------------------------------------
;+
; NAME:
;       HORIZON_DIST
; PURPOSE:
;       Compute distance to horizon given observer height.
; CATEGORY:
; CALLING SEQUENCE:
;       d = horizon_dist(ht)
; INPUTS:
;       h = Observer height.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /GEOM return geometric horizon, else refracted.
;           Perhaps better for large heights.
;         /FEET  Observer height is in feet, else meters.
;         /NMILES Distance is in nautical miles, else km.
;         RADIUS=rad Enter Earth radius to use (km, def=6371).
;         REFCON=rc  Refraction constant (def=7/6).
; OUTPUTS:
;       d = Distance to horizon. out
; COMMON BLOCKS:
; NOTES:
;       Notes: Distance is from the observer to the horizon,
;         not along the surface.  Refraction is approximated
;         by using an earth radius of 7/6 times the actual
;         earth radius.  Refraction is variable but this is
;         a typical value and commonly used.
;         Ref: http://mintaka.sdsu.edu/GF/explain/atmos_refr/horizon.html
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 19
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function horizon_dist, h0, geom=geom, radius=rad, help=hlp, $
	  feet=feet, nmiles=nmiles, refcon=refcon
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute distance to horizon given observer height.'
	  print,' d = horizon_dist(ht)'
	  print,'   h = Observer height.     in'
	  print,'   d = Distance to horizon. out'
	  print,' Keywords:'
	  print,'   /GEOM return geometric horizon, else refracted.'
	  print,'     Perhaps better for large heights.'
	  print,'   /FEET  Observer height is in feet, else meters.'
	  print,'   /NMILES Distance is in nautical miles, else km.'
	  print,'   RADIUS=rad Enter Earth radius to use (km, def=6371).'
	  print,'   REFCON=rc  Refraction constant (def=7/6).'
	  print,' Notes: Distance is from the observer to the horizon,'
	  print,'   not along the surface.  Refraction is approximated'
	  print,'   by using an earth radius of 7/6 times the actual'
	  print,'   earth radius.  Refraction is variable but this is'
	  print,'   a typical value and commonly used.'
	  print,'   Ref: http://mintaka.sdsu.edu/GF/explain/atmos_refr/horizon.html'
	  return,''
	endif
 
	h = h0
	if keyword_set(feet) then h=h*0.3048	; Feet -> meters.
 
	r = 6371D0				; Earth radius (km).
	if n_elements(rad) ne 0 then r=rad	; New radius (km).
	r = r*1000D0				; Radius in m.
 
	rc = 7./6.				; Refraction constant.
	if n_elements(refcon) ne 0 then rc=refcon
 
	if not keyword_set(geom) then r=r*rc	; Refraction correction.
 
	d = sqrt(2*r*h + h^2)/1000.		; Horizon distance (km).
	if keyword_set(nmiles) then d=d/1.852	; in nmiles.
 
	return, d
 
	end
