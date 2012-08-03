;-------------------------------------------------------------
;+
; NAME:
;       ELL_CYL_EQ_AREA
; PURPOSE:
;       Compute area of given lng/lat polygon on an earth ellipsoid.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_cyl_eq_area, lng, lat, area
; INPUTS:
;       lng, lat = Long and lat (deg).    in
; KEYWORD PARAMETERS:
;       Keywords:
;         LONG0=lng0  Central longitude (deg). Def=0.
;         /KM  return value in km^2 instead of m^2.
;         /QUIET do not list area.
;         NAME=name Name of area, list km^2 (over-rides /QUIET).
;         /POLYGON list # pts in polygon used when listing name.
;         OUT=txt Return message instead of printing it.
;         /SIGNED Return signed area (no abs(area)).
; OUTPUTS:
;       area = area in m^2 (-1 if error). out
; COMMON BLOCKS:
; NOTES:
;       Notes: intended for area not near a pole and not
;         including a pole.
;         To set the ellipsoid do ellipsoid,set=name
;         Default = last set or WGS 84 if none set.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 May 06
;       R. Sterner, 2002 May 07 --- Added new keyword KM.
;       R. Sterner, 2006 Feb 13 --- Added NAME=name, /POLYGON.
;       R. Sterner, 2006 Feb 13 --- Added OUT=txt.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_cyl_eq_area, lng, lat, area, help=hlp, long0=lng0, $
	   quiet=quiet, km=km, name=name, polygon=polygon, out=txt0, $
	   signed=signed
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Compute area of given lng/lat polygon on an earth ellipsoid.'
	  print,' ell_cyl_eq_area, lng, lat, area'
	  print,'   lng, lat = Long and lat (deg).    in'
	  print,'   area = area in m^2 (-1 if error). out'
	  print,' Keywords:'
	  print,'   LONG0=lng0  Central longitude (deg). Def=0.'
	  print,'   /KM  return value in km^2 instead of m^2.'
	  print,'   /QUIET do not list area.'
	  print,'   NAME=name Name of area, list km^2 (over-rides /QUIET).'
	  print,'   /POLYGON list # pts in polygon used when listing name.'
	  print,'   OUT=txt Return message instead of printing it.'
	  print,'   /SIGNED Return signed area (no abs(area)).'
	  print,' Notes: intended for area not near a pole and not'
	  print,'   including a pole.' 
	  print,'   To set the ellipsoid do ellipsoid,set=name'
	  print,'   Default = last set or WGS 84 if none set.'
	  return
	endif
 
	if n_elements(lng0) eq 0 then lng0=0.D0
 
	;-----  Ellipsoid values  -------------------
	ellipsoid, get=ell
	a = ell.a		; Semimajor axis (m).
	f1 = ell.f1		; Reciprocal of flattening factor.
	f = 1.D0/f1		; Flattening factor.
	b = a*(1-f)		; Semiminor axis (m).
	e2 = (a^2-b^2)/a^2	; Eccentricity^2.
	e = sqrt(e2)		; Eccentricity
	radeg = 180D0/!dpi	; Must use double for mm accuracy.
 
	;----  List ellipsoid  -----------
	n = n_elements(lng)
	if n lt 3 then begin
	  print,' Error in ell_cyl_eq_area: must give at least 3 points.'
	  area = -1
	  return
	endif
	if not keyword_set(quiet) then begin
	  print,' Computing area of a '+strtrim(n,2)+' point polygon '+$
	    'on a '+ell.name+' ellipsoid.'
	endif
 
	;--------  Convert to radians  --------------
	dlngr = (lng-lng0)/radeg	; Convert long diff to radians.
	latr = lat/radeg		; Convert lat to radians.
 
	;-----  Values depending on latitude  ------------
	sn = sin(latr)
	esn = e*sn
	e2sn2 = esn^2
	q = (1D0-e2)*(sn/(1D0-e2sn2) - (1D0/(2D0*e))*alog((1D0-esn)/(1D0+esn)))
 
	;------  x,y coordinates  ----------------
	x = a*dlngr
	y = a*q/2D0
 
	;-----  Compute area  ------------
	polystat,x,y,s, signed=signed
	area = s(1)
 
	;------  List area  ---------------
	if n_elements(name) ne 0 then begin
	  txt = ''
	  if keyword_set(polygon) then begin
	    txt = ' using a '+strtrim(n,2)+' point polygon.'
	  endif
	  txt = ' '+name+': '+strtrim(area/1E6,2)+' km^2'+txt
	  if not arg_present(txt0) then print,txt
	  txt0 = txt
	endif else begin
	  if not keyword_set(quiet) then print,' Area = '+strtrim(area,2)+$
	    ' m^2 ('+strtrim(area/1E6,2)+' km^2)'
	endelse
 
	;-------- km^2  --------------------
	if keyword_set(km) then area=area/1D6
 
	end
