;-------------------------------------------------------------
;+
; NAME:
;       MAPRECT
; PURPOSE:
;       Plot a rectangle on a map and list its parameters.
; CATEGORY:
; CALLING SEQUENCE:
;       maprect, lng, lat, dx, dy
; INPUTS:
;       lng = longitude (degrees) of rectangle center.  in
;       lat = latitude (degrees) of rectangle center.   in
;       dx = halfwidth of rectangle in EW direction.    in
;          May also be two valued [west, east].
;       dy = halfwidth of rectangle in NS direction.    in
;          May also be two valued [south, north].
;       UNITS=unt  Units of distance:
;         'kms'     Default.
;         'miles'   Statute miles.
;         'nmiles'  Nautical miles.
;         'feet'    Feet.
;         'yards'   Yards.
;         'degrees' Degrees (great circle).
;         'radians' Radians (great circle).
;       /NOPLOT  do not plot rectangle.
;       /NOLIST  do not list parameters of rectangle.
;       COLOR=clr  Plot color (def=!p.color).
;       THICKNESS=thk Plot thickness (def=!p.thick).
;       LINESTYLE=sty Plot linestyle (def=!p.linestyle).
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 5
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro maprect, lng,lat,dx,dy,noplot=noplot,nolist=nolist, $
	  units=units,color=clr,thickness=thk,linestyle=sty,help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Plot a rectangle on a map and list its parameters.'
	  print,' maprect, lng, lat, dx, dy'
	  print,'   lng = longitude (degrees) of rectangle center.  in'
	  print,'   lat = latitude (degrees) of rectangle center.   in'
	  print,'   dx = halfwidth of rectangle in EW direction.    in'
	  print,'      May also be two valued [west, east].'
	  print,'   dy = halfwidth of rectangle in NS direction.    in'
	  print,'      May also be two valued [south, north].'
	  print,'   UNITS=unt  Units of distance:'
	  print,"     'kms'     Default."
	  print,"     'miles'   Statute miles."
	  print,"     'nmiles'  Nautical miles."
	  print,"     'feet'    Feet."
	  print,"     'yards'   Yards."
	  print,"     'degrees' Degrees (great circle)."
	  print,"     'radians' Radians (great circle)."
	  print,'   /NOPLOT  do not plot rectangle.'
	  print,'   /NOLIST  do not list parameters of rectangle.'
	  print,'   COLOR=clr  Plot color (def=!p.color).'
	  print,'   THICKNESS=thk Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Plot linestyle (def=!p.linestyle).'
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
	  print,' Error in maprect: Unknown units: '+units
	  print,'   Aborting.'
	  return
	end
	endcase
 
	;-------  Find rectangle points in lat/long  ----------
	dxx=dx & if n_elements(dxx) eq 1 then dxx=[dx,dx]  ; W and E.
	dyy=dy & if n_elements(dyy) eq 1 then dyy=[dy,dy]  ; S and N.
	dxx=dxx*cf & dyy=dyy*cf				   ; Apply con factor.
	rb2ll,lng,lat,dxx(0),270,xw,yw			   ; Mid west side.
	rb2ll,lng,lat,dxx(1),90,xe,ye			   ; Mid east side.
	ll2rb,xw,yw,lng,lat,r,bw			   ; Backazi from west.
	ll2rb,xe,ye,lng,lat,r,be			   ; Backazi from ast.
	;------  4 corners  -----------
	rb2ll,xw,yw,dyy(0),bw+90,xsw,ysw		   ; SW point.
	rb2ll,xw,yw,dyy(1),bw-90,xnw,ynw		   ; NW point.
	rb2ll,xe,ye,dyy(0),be-90,xse,yse		   ; SE point.
	rb2ll,xe,ye,dyy(1),be+90,xne,yne		   ; NE point.
	;-------  Step around rectangle from SW corner  -------
	ll2rb,xsw,ysw,xse,yse,r,b
	rb2ll,xsw,ysw,maken(0,r,10),b,x,y		   ; South side.
	xx=x & yy=y
	ll2rb,xse,yse,xne,yne,r,b
	rb2ll,xse,yse,maken(0,r,10),b,x,y		   ; East side.
	xx=[xx,x] & yy=[yy,y]
	ll2rb,xne,yne,xnw,ynw,r,b
	rb2ll,xne,yne,maken(0,r,10),b,x,y		   ; North side.
	xx=[xx,x] & yy=[yy,y]
	ll2rb,xnw,ynw,xsw,ysw,r,b
	rb2ll,xnw,ynw,maken(0,r,10),b,x,y		   ; West side.
	xx=[xx,x] & yy=[yy,y]
 
	;---------  Put longitude in standard range  ----------
	if min(xx) gt 180 then xx=xx-360
	a = convert_coord(xx,yy,/data,/to_dev)	; Convert lng/lat to ix/iy.
	ix=a(0,*) & iy=a(1,*)
	eflg = 0				; Clear error flag.
	if (max(ix) eq 1e12) or (max(iy) eq 1e12) then eflg=1	; Off map.
 
	;-------  List rectangle parameters  ------------------
	if eflg then begin
	  print,' Part of rectangle is beyond edge of map, no listing.'
	endif else if not keyword_set(nolist) then begin
	  idx = max(ix)-min(ix)
	  idy = max(iy)-min(iy)
	  r = polyfillv(ix-min(ix),iy-min(iy),ceil(idx),ceil(idy))
	  print,' '
	  print,' Parameters for a rectangle of size '+$
	    strtrim(dxx(0),2)+' '+utxt+' W '+strtrim(dxx(1),2)+' '+utxt+' E '
	  print,strtrim(dyy(0),2)+' '+utxt+' S '+strtrim(dyy(1),2)+' '+utxt+' N'
	  print,'   from longitude '+strtrim(lng,2)+' and  latitude '+$
	    strtrim(lat,2)+':'
	  print,' Shape: DY/DX = '+strtrim(idy/idx,2)
	  print,' Area = '+strtrim(n_elements(r),2)+' pixels'
	  print,' '
	endif
 
	;--------  Plot rectangle  ----------------------------
        if eflg then begin
          print,' Part of rectangle is beyond edge of map, no plot.'
        endif else if not keyword_set(noplot) then begin
	  ;---------  Make sure plot parameters defined  --------
	  if n_elements(clr) eq 0 then clr = !p.color
	  if n_elements(thk) eq 0 then thk = !p.thick
	  if n_elements(sty) eq 0 then sty = !p.linestyle
	  ;---------  Clip to map window  ------------
	  c = [transpose(!x.window*!d.x_size),transpose(!y.window*!d.y_size)]
	  c = c(0:*)
	  plots,ix,iy,color=clr,thick=thk,linestyle=sty,clip=c,noclip=0,/dev
	endif
 
	return
	end
