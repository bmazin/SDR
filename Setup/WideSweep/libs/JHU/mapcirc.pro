;-------------------------------------------------------------
;+
; NAME:
;       MAPCIRC
; PURPOSE:
;       Plot a circle on a map and list its parameters.
; CATEGORY:
; CALLING SEQUENCE:
;       mapcirc, lng, lat, rad
; INPUTS:
;       lng = longitude (degrees) of circle center.  in
;       lat = latitude (degrees) of circle center.   in
;       rad = radius of circle.                      in
;       UNITS=unt  Units of radius:
;         'kms'     Default.
;         'miles'   Statute miles.
;         'nmiles'  Nautical miles.
;         'feet'    Feet.
;         'yards'   Yards.
;         'degrees' Degrees (great circle).
;         'radians' Radians (great circle).
;       /NOPLOT  do not plot circle.
;       /NOLIST  do not list parameters of circle.
;       COLOR=clr  Plot color (def=!p.color).
;       THICKNESS=thk Plot thickness (def=!p.thick).
;       LINESTYLE=sty Plot linestyle (def=!p.linestyle).
;       AREA=area  Returned area of circle in pixels.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Besides plotting circles this routine is
;         Useful for determining how well shape is preserved
;         in various regions of the map or between various maps.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 4
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mapcirc, lng,lat,rad,noplot=noplot,nolist=nolist, $
	  units=units,color=clr,thickness=thk,linestyle=sty, $
	  area=area, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Plot a circle on a map and list its parameters.'
	  print,' mapcirc, lng, lat, rad'
	  print,'   lng = longitude (degrees) of circle center.  in'
	  print,'   lat = latitude (degrees) of circle center.   in'
	  print,'   rad = radius of circle.                      in'
	  print,'   UNITS=unt  Units of radius:'
	  print,"     'kms'     Default."
	  print,"     'miles'   Statute miles."
	  print,"     'nmiles'  Nautical miles."
	  print,"     'feet'    Feet."
	  print,"     'yards'   Yards."
	  print,"     'degrees' Degrees (great circle)."
	  print,"     'radians' Radians (great circle)."
	  print,'   /NOPLOT  do not plot circle.'
	  print,'   /NOLIST  do not list parameters of circle.'
	  print,'   COLOR=clr  Plot color (def=!p.color).'
	  print,'   THICKNESS=thk Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Plot linestyle (def=!p.linestyle).'
	  print,'   AREA=area  Returned area of circle in pixels.'
	  print,' Notes: Besides plotting circles this routine is'
	  print,'   Useful for determining how well shape is preserved'
	  print,'   in various regions of the map or between various maps.'
	  return
	endif
 
	;---------  Deal with units  ---------------
	if n_elements(units) eq 0 then units='kms'
	un = strlowcase(strmid(units,0,2))
	case un of	; Convert distance on earth's surface to radians.
'km':	begin
	  cf = 1.56956e-04	; Km/radian.
	  utxt = 'kms'
	end
'mi':	begin
	  cf = 2.52595e-04	; Miles/radian.
	  utxt = 'miles'
	end
'nm':	begin
	  cf = 2.90682e-04	; Nautical mile/radian.
	  utxt = 'nautical miles'
	end
'fe':	begin
	  cf = 4.78401e-08	; Feet/radian.
	  utxt = 'feet'
	end
'ya':	begin
	  cf = 1.43520e-07	; Yards/radian.
	  utxt = 'yards'
	end
'de':	begin
	  cf = 0.0174532925	; Degrees/radian.
	  utxt = 'degrees'
	end
'ra':	begin
	  cf = 1.0		; Radians/radian.
	  utxt = 'radians'
	end
else:	begin
	  print,' Error in mapcirc: Unknown units: '+units
	  print,'   Aborting.'
	  return
	end
	endcase
 
	;-------  Find circle points in lat/long  ----------
	rb2ll,lng,lat,cf*rad,maken(0,360,181),x,y
	;---------  Put longitude in standard range  ----------
	if min(x) gt 180 then x=x-360
	a = convert_coord(x,y,/data,/to_dev)	; Convert lng/lat to ix/iy.
	ix=a(0,*) & iy=a(1,*)
	eflg = 0				; Clear error flag.
	if (max(ix) eq 1e12) or (max(iy) eq 1e12) then eflg=1	; Off map.
 
	;-------  List circle parameters  ------------------
	if eflg then begin
	  print,' Part of circle is beyond edge of map, no listing.'
	endif else if not keyword_set(nolist) then begin
	  idx = max(ix)-min(ix)
	  idy = max(iy)-min(iy)
	  r = polyfillv(ix-min(ix),iy-min(iy),ceil(idx),ceil(idy))
	  print,' '
	  print,' Parameters for a circle of radius '+strtrim(rad,2)+' '+$
	    utxt
	  print,'   centered at longitude '+strtrim(lng,2)+', latitude '+$
	    strtrim(lat,2)+':'
	  print,' Y diameter/X diameter = '+strtrim(idy/idx,2)
	  print,'   (Flattening = '+strtrim(100*(idx-idy)/idx,2)+' %)'
	  area = n_elements(r)
	  print,' Area = '+strtrim(area,2)+' pixels'
	  print,' '
	endif
 
	;--------  Plot circle  ----------------------------
        if eflg then begin
          print,' Part of circle is beyond edge of map, no plot.'
        endif else if not keyword_set(noplot) then begin
	  ;---------  Make sure plot parameters defined  --------
	  if n_elements(clr) eq 0 then clr = !p.color
	  if n_elements(thk) eq 0 then thk = !p.thick
	  if n_elements(sty) eq 0 then sty = !p.linestyle
	  ;---------  Clip to map window  ------------
	  c = [transpose(!x.window*!d.x_size),transpose(!y.window*!d.y_size)]
	  if total(abs(c)) eq 0 then c=[transpose([1,!d.x_size]-1),$
	    transpose([1,!d.y_size]-1)]
	  c = c(0:*)
	  plots,ix,iy,color=clr,thick=thk,linestyle=sty,clip=c,noclip=0,/dev
	endif
 
	return
	end
