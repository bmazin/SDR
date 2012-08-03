;-------------------------------------------------------------
;+
; NAME:
;       MAP_LATLNG_RECT
; PURPOSE:
;       Plot a rectangular area of lat/long on a map.
; CATEGORY:
; CALLING SEQUENCE:
;       map_latlng_rect, lng1, lng2, lat2, lat2
; INPUTS:
;       lng1, lng2 = longitudes (degrees) of sides.   in
;       lat1, lat2 = latitudes (degrees) of sides.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBER=n   Number of points on each side (def=100).
;         COLOR=clr  Plot color (def=!p.color).
;         THICKNESS=thk Plot thickness (def=!p.thick).
;         LINESTYLE=sty Plot linestyle (def=!p.linestyle).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Jun 29
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_latlng_rect, x1,x2,y1,y2, $
	  number=num, color=clr,thickness=thk,linestyle=sty, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Plot a rectangular area of lat/long on a map.'
	  print,' map_latlng_rect, lng1, lng2, lat2, lat2'
	  print,'   lng1, lng2 = longitudes (degrees) of sides.   in'
	  print,'   lat1, lat2 = latitudes (degrees) of sides.    in'
	  print,' Keywords:'
	  print,'   NUMBER=n   Number of points on each side (def=100).'
	  print,'   COLOR=clr  Plot color (def=!p.color).'
	  print,'   THICKNESS=thk Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Plot linestyle (def=!p.linestyle).'
	  return
	endif
 
	;--------  Defaults  ----------------------------
	if n_elements(num) eq 0 then num = 100
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(thk) eq 0 then thk = !p.thick
	if n_elements(sty) eq 0 then sty = !p.linestyle
 
	;--------  Find and plot points  -----------------
	x = maken(x1,x2,num)	; South.
	y = maken(y1,y1,num)
	oplot,x,y,color=clr,thick=thk,linestyle=sty
	x = maken(x2,x2,num)	; East.
	y = maken(y1,y2,num)
	oplot,x,y,color=clr,thick=thk,linestyle=sty
	x = maken(x1,x2,num)	; North.
	y = maken(y2,y2,num)
	oplot,x,y,color=clr,thick=thk,linestyle=sty
	x = maken(x1,x1,num)	; West.
	y = maken(y1,y2,num)
	oplot,x,y,color=clr,thick=thk,linestyle=sty
 
	return
	end
