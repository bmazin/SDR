;-------------------------------------------------------------
;+
; NAME:
;       ELL_POLYGON
; PURPOSE:
;       Fill sides of a polygon on an ellipsoid with small steps.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_polygon, lng, lat, flag
; INPUTS:
;       lng, lat = Array of lng and lat of polygon vertices.  in
;         Last point assumed to connect to first point.
;       flag=flg  Connection to next point.  String array.    in
;          'G' = geodesic (default), 'L' = loxodrome.
; KEYWORD PARAMETERS:
;       Keywords:
;         LNG2=lng2  Returned array of longitudes.
;         LAT2=lat2  Returned array of latitudes.
;         STEP=step  Step size along polygon side.  In km unless
;            /M is set.  This is a max step size, actual will
;            be this or smaller.  Default values is 1.
;         /M means step size given in meters, else km.
;         /LIST list the ellipsoid being used.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: use ellipsoid, set=name to specify ellipsoid to use.
;       Mainly intended for area calculations.  Can send resulting
;       points to ell_cyl_eq_area to get area if pole not included.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 May 08
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_polygon, lng,lat,flag, step=step,m=m, lng2=px,lat2=py, $
	  list=list, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Fill sides of a polygon on an ellipsoid with small steps.'
	  print,' ell_polygon, lng, lat, flag'
	  print,'   lng, lat = Array of lng and lat of polygon vertices.  in'
	  print,'     Last point assumed to connect to first point.'
	  print,'   flag=flg  Connection to next point.  String array.    in'
	  print,"      'G' = geodesic (default), 'L' = loxodrome."
	  print,' Keywords:'
	  print,'   LNG2=lng2  Returned array of longitudes.'
	  print,'   LAT2=lat2  Returned array of latitudes.'
	  print,'   STEP=step  Step size along polygon side.  In km unless'
	  print,'      /M is set.  This is a max step size, actual will'
	  print,'      be this or smaller.  Default values is 1.'
	  print,'   /M means step size given in meters, else km.'
	  print,'   /LIST list the ellipsoid being used.'
	  print,' Note: use ellipsoid, set=name to specify ellipsoid to use.'
	  print,' Mainly intended for area calculations.  Can send resulting'
	  print,' points to ell_cyl_eq_area to get area if pole not included.'
	  return
	endif
 
	;---------  List ellipsoid  ---------------
	if keyword_set(list) then begin
	  print,' '
	  print,' Ellipsiodal polygon.'
	  ellipsoid,/curr
	  print,' '
	endif
	
	;---------  Defaults  ---------------------
	n = n_elements(lng)					; # of points.
	if n_elements(flag) eq 0 then flag=strarr(n)+'G'	; Def=Geodesic.
	if n_elements(step) eq 0 then step=1D0			; Step size.
	if keyword_set(m) then stp=step else stp=1000D0*step	; stp is in m.
 
	;---------  Initialize  --------------------
	px = [0D0]	; Starting array of lng.
	py = [0D0]	; Starting array of lat.
 
	;---------  Loop through polygon sides  ----------
	for i1=0, n-1 do begin
 
	  ;---------  Get side endpoints  ----------------
	  i2 = (i1+1) mod n		; Next point with wrap-around.
	  lng1 = lng(i1)		; P1 = First point on side.
	  lat1 = lat(i1)
	  lng2 = lng(i2)		; P2 = Second point on side.
	  lat2 = lat(i2)
	  typ = strupcase(flag(i1))	; TYP = Side type.
 
	  case typ of
	  ;--------------------------------------------------------
	  ;  Geodesic side
	  ;  Find Geodesic dist (gdist) and azi from P1 to P2.
	  ;  Find needed step size along geodesic.
	  ;  Make array of steps.
	  ;  Find points along geodesic.
	  ;--------------------------------------------------------
'G':	  begin
	    ell_ll2rb, lng1,lat1,lng2,lat2,d,azi	; gdist, azi P1 to P2.
	    if d le stp then begin	; Short side, don't subdivide.
	      px = [px,lng1,lng2]
	      py = [py,lat1,lat2]
	    endif else begin				; Long side, subdivide.
	      num = ceil(d/stp)				; Keep step sz LE step.
	      dd = maken(0D0,d,100)			; Distances.
	      ell_rb2ll, lng1,lat1, dd, azi, px1, py1	; Points on geodesic.
	      px = [px,px1]
	      py = [py,py1]
	    endelse
	  end
	  ;-----------  Loxodromic side  -----------------
	  ;--------------------------------------------------------
	  ;  Loxodromic side
	  ;  Find loxodromic dist (ldist) and azi from P1 to P2.
	  ;  Find needed step size along loxodromic.
	  ;  Make array of steps.
	  ;  Find points along loxodromic.
	  ;--------------------------------------------------------
'L':	  begin
	    ; ldist, azi P1 to P2:
	    ell_loxodrome,lng1,lat1,lng2=lng2,lat2=lat2,azi=azi,dist=d,/ad
	    if d le stp then begin	; Short side, don't subdivide.
	      px = [px,lng1,lng2]
	      py = [py,lat1,lat2]
	    endif else begin				; Long side, subdivide.
	      num = ceil(d/stp)				; Keep step sz LE step.
	      dd = maken(0D0,d,100)			; Distances.
	      ; Points on loxodrome:
	      ell_loxodrome,lng1,lat1,azi=azi,dist=dd,lng2=px1,lat2=py1,/p2
	      px = [px,px1]
	      py = [py,py1]
	    endelse
	  end
else:	  begin
	    print,' Error in ell_polygon: Unknown side type for side '+$
	      strtrim(i1,2)+': '+typ
	    print,' Aborting.'
	    return
	  end
	  endcase
 
	;-------  Drop array start values  ---------------
	px = px(1:*)
	py = py(1:*)
 
	endfor ; i1
 
	end
