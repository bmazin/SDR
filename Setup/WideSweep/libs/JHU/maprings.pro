;-------------------------------------------------------------
;+
; NAME:
;       MAPRINGS
; PURPOSE:
;       Plot rings (circles) on a map.
; CATEGORY:
; CALLING SEQUENCE:
;       maprings, dist
; INPUTS:
;       dist = radius of ring.   in
;         May be an array of distances.
; KEYWORD PARAMETERS:
;       Keywords:
;         UNITS=units Units of dist (def=km).
;           Available units (use 2 letters min):
;           'radians' Radians.
;           'degrees' Degrees.
;           'nmiles'  Nautical miles.
;           'miles'   Statute miles.
;           'kms'     Kilometers (default).
;           'meters'  Meters.
;           'yards'   Yards.
;           'feet'    Feet.
;         LNG=lng, LAT=lat Center of ring.
;           If not given will be interactive.
;           lng and lat may be arrays.
;         COLOR=clr  Color of ring.
;         THICKNESS=thk Thickness of ring.
;         LINESTYLE=sty Linestyle of ring.
;           Last 3 items may have a value for each value in dist.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R.Sterner, 2003 May 22
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro maprings, dist, units=units, lng=lng,lat=lat, $
	  color=clr, thickness=thk, linestyle=sty, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot rings (circles) on a map.'
	  print,' maprings, dist'
	  print,'   dist = radius of ring.   in'
	  print,'     May be an array of distances.'
	  print,' Keywords:'
	  print,'   UNITS=units Units of dist (def=km).'
	  print,'     Available units (use 2 letters min):'
	  print,"     'radians' Radians."
	  print,"     'degrees' Degrees."
	  print,"     'nmiles'  Nautical miles."
	  print,"     'miles'   Statute miles."
	  print,"     'kms'     Kilometers (default)."
	  print,"     'meters'  Meters."
	  print,"     'yards'   Yards."
	  print,"     'feet'    Feet."
	  print,'   LNG=lng, LAT=lat Center of ring.'
	  print,'     If not given will be interactive.'
	  print,'     lng and lat may be arrays.'
	  print,'   COLOR=clr  Color of ring.'
	  print,'   THICKNESS=thk Thickness of ring.'
	  print,'   LINESTYLE=sty Linestyle of ring.'
	  print,'     Last 3 items may have a value for each value in dist.'
	  return
	endif
 
	;-------  defaults  ---------------
	if n_elements(units) eq 0 then units='kms'
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(sty) eq 0 then sty=!p.linestyle
	lst_c = n_elements(clr)-1
	lst_t = n_elements(thk)-1
	lst_s = n_elements(sty)-1
 
	imode = 0				; Interactive mode?
	if n_elements(lat) eq 0 then imode=1	; Yes.
	if n_elements(lng) eq 0 then imode=1
 
	erad = earthrad(units)			; Earth radius.
	wshow
 
	;-------  Non-interactive mode  ---------
	if imode eq 0 then begin
	  n = n_elements(lng)
	  for i=0,n-1 do begin
	    for j=0,n_elements(dist)-1 do begin
	      rb2ll, lng(i), lat(i), dist(j)/erad, makex(0.,360.,1.), x, y
	      if abs(mean(x)-lng(i)) gt 5 then x=x-360.
	      plots, x, y, color=clr(j<lst_c), thick=thk(j<lst_t), $
	        linestyle=sty(j<lst_s)
	    endfor
	  endfor
	  return
	endif
 
	;------  Interactive mode  ------------
	xmess,['Left click on center of ring.', $
		'Any other mouse button exits.'], $
		/nowait, wid=wid,yoffset=100
loop:	xcursor, lng, lat
	wait,.1
	if !mouse.button ne 1 then begin
	  widget_control, wid,/dest
	  return
	endif
	for j=0,n_elements(dist)-1 do begin
	  rb2ll, lng, lat, dist(j)/erad, makex(0.,360.,1.), x, y
	  if abs(mean(x)-lng) gt 5 then x=x-360.
	  plots, x, y, color=clr(j<lst_c), thick=thk(j<lst_t), $
	        linestyle=sty(j<lst_s)
	endfor
	goto, loop
 
	end
