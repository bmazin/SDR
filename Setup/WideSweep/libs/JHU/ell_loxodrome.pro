;-------------------------------------------------------------
;+
; NAME:
;       ELL_LOXODROME
; PURPOSE:
;       Deal with loxodromes on ellipsoidal earth.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_loxodrome, lng1, lat1
; INPUTS:
;       lng1 = Longitude of starting point (P1).   in
;       lat1 = Latitude of starting point (P1).    in
;         This point must be a scalar value.
; KEYWORD PARAMETERS:
;       Keywords:
;         LNG2=lng2  Longitude of ending point (P2).
;         LAT2=lat2  Latitude of ending point.
;         AZI=azi    Azimuth (deg) of loxodrome from P1 to P2.
;         DIST=dist  Distance (m) along loxodrome from P1 to P2.
;         /P2  Compute lng2, lat2 from lng1, lat1, azi, and dist.
;         /AD  Compute azi and dist from P1 and P2.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Algorithms from John Snyder, Map Projections -
;        A Working Manual.
;        The starting point must be a scalar value.  For /P2
;        AZI must be a scalar, DIST may be an array (avoid 0 dist).
;        For /AD P2 (lng2,lat2) may be an array.
;        Be careful, for extreme cases LAT2 may go > 90.
;        Use ellipsoid,set=name to set working ellipsoid
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 09
;       R. Sterner, 2002 Apr 28 --- Cleaned up to allow some array values.
;       R. Sterner, 2002 May 01 --- Now calls ellipsoid.
;       R. Sterner, 2002 Oct 07 --- Fixed negative range when lat1=lat2,
;       found by Rick Chapman when he ported it to the Palm.
;       R. Sterner, 2006 Dec 27 --- Fixed the problem of going the wrong
;       way around the world found by Rick Chapman in Oct 2002.
;       R. Sterner, 2006 Dec 28 --- Cleaned up some lose ends.
;       This routine should be split into two:
;       ell_lox_rb2ll.pro  From range and bearing compute new pt lon, lat.
;       ell_lox_ll2rb.pro  From point 2 lon, lat compute range and bearing.
;       where range and bearing are the loxodromic values.
;       Use same calling syntax as ell_rb2ll, ell_ll2rb.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_loxodrome, lng10, lat1, lng2=lng20, lat2=lat2, $
	  azi=azi, dist=dist, p2=p2, ad=ad, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Deal with loxodromes on ellipsoidal earth.'
	  print,' ell_loxodrome, lng1, lat1'
	  print,'   lng1 = Longitude of starting point (P1).   in'
	  print,'   lat1 = Latitude of starting point (P1).    in'
	  print,'     This point must be a scalar value.'
	  print,' Keywords:'
	  print,'   LNG2=lng2  Longitude of ending point (P2).'
	  print,'   LAT2=lat2  Latitude of ending point.'
	  print,'   AZI=azi    Azimuth (deg) of loxodrome from P1 to P2.'
	  print,'   DIST=dist  Distance (m) along loxodrome from P1 to P2.'
	  print,'   /P2  Compute lng2, lat2 from lng1, lat1, azi, and dist.'
	  print,'   /AD  Compute azi and dist from P1 and P2.'
	  print,' Notes: Algorithms from John Snyder, Map Projections -'
	  print,'  A Working Manual.'
	  print,'  The starting point must be a scalar value.  For /P2'
	  print,'  AZI must be a scalar, DIST may be an array (avoid 0 dist).'
	  print,'  For /AD P2 (lng2,lat2) may be an array.'
	  print,'  Be careful, for extreme cases LAT2 may go > 90.'
	  print,'  Use ellipsoid,set=name to set working ellipsoid'
	  return
	endif
 
	;-------------------------------------------------
	;  Ellipsoid
	;-------------------------------------------------
;	f = 1.D0/298.257223563D0	; Flattening factor.
;	a = 6378137.0D0			; Semimajor axis (m).
	ellipsoid, get=ell		; Get ellipsoid.
	a = ell.a			; Semimajor axis (m).
	f1 = ell.f1			; Reciprocal of flattening factor.
	f = 1.D0/f1			; Flattening factor.
	b = a*(1-f)			; Semiminor axis (m).
	e2 = (a^2-b^2)/a^2		; Eccentricity^2.
	e4 = e2*e2
	e6 = e2*e4
	e = sqrt(e2)			; Eccentricity.
	radeg = 180D0/!dpi		; Must use double for mm accuracy.
	pi2 = !dpi/2.D0
 
	;-----------------------------------------------------------
	;  Compute loxodrome azimuth and distance
	;    Given P1 and P2 (lng1,lat1, lng2,lat2),
	;    Ref: Snyder, P. 46.
	;-----------------------------------------------------------
	if keyword_set(ad) then begin
	  lng1 = lng10				; Don't change original.
	  lng2 = lng20
	  if n_elements(lng2) eq 0 then begin
	    print,' Error in ell_loxodrome: Must give ending point to'
	    print,'   compute azimuth and distance.'
	    return
	  endif
	  if n_elements(lat2) eq 0 then begin
	    print,' Error in ell_loxodrome: Must give ending point to'
	    print,'   compute azimuth and distance.'
	    return
	  endif
	  ;-------------------------------------------------
	  ;  Correct coordinates to avoid going wrong way
	  ;  (caught by Rick Chapman, email 14 Oct 2002).
	  ;  lng2, lat2 may be arrays.
	  ;-------------------------------------------------
	  w = where(abs(lng2-lng1) gt 180, cnt)	; Any problems?
	  if cnt gt 0 then begin		; Adjust problem points.
	    ;---  Cases with lng1 or lng2 LT 0  ---
	    if (lng1 lt 0) then begin		; lng1 needs adjusted.
	      lng1 = lng1 + 360			; Adjust lng1.
	    endif else begin			; lng2 may need adjusted.
	      w2 = where(lng2 lt 0, cnt2)	; Check lng2.
	      if (cnt2 gt 0) then $		; Adjust lng2.
	        lng2(w2) = lng2(w2) + 360
	    endelse
	    w3 =where(abs(lng2-lng1) gt 180,cnt3) ; Any more problems?
	    if cnt3 gt 0 then begin		; Adjust problem points.
	      ;---  Cases with lng1 Gt lng2  ---
	      if (lng1 gt lng2) then begin
	        lng1 = lng1 - 360		; Adjust lng1.
	      endif else begin
	        lng2(w3) = lng2(w3) - 360	; Adjust lng2.
	      endelse
	    endif ; cnt3
	  endif ; cnt
 
	  lt1 = lat1/radeg	; Convert long,lat to radians.
	  ln1 = lng1/radeg
	  lt2 = lat2/radeg	; Convert coordinates to radians.
	  ln2 = lng2/radeg
;--- Next line limit [lat1,lat2]>(-89.999999D0)<89.999999D0 ??? -----
	  ell_merc, [lng1,lng2],[lat1,lat2],x=x,y=y
	  recpol,y(1:*)-y(0),x(1:*)-x(0),r,azir  ; Azi in radians (7-14).
	  azi = azir*radeg	; Azimuth in degrees.
	  dist = double(lat2*0)	; Space for dist.
	  weq = where(lat1 eq lat2, c_eq)  ; Special case for lat2 eq lat1.
	  wne = where(lat1 ne lat2, c_ne)  ; Normal case where lat2 ne lat1.
	  if c_eq gt 0 then begin			; Dist (7-17)
	    dist(weq) = a*abs((ln2(weq)-ln1)*cos(lt1)/sqrt(1D0-e2*sin(lt1)^2))
	  endif
	  if c_ne gt 0 then begin			; (3-21)
	    p = [lt1,lt2(wne)]
	    tt = 1 - e2/4 - 3*e4/64 - 5*e6/256
	    aa = 3*e2/8 + 3*e4/32 + 45*e6/1024
	    bb = 15*e4/256 + 45*e6/1024
	    cc = 35*e6/3072
	    m = a*(tt*p - aa*sin(2*p) + bb*sin(4*p) - cc*sin(6*p))
	    caz = cos(azir)
	    dist(wne) = (m(1:*)-m(0))/caz			; (7-16)
	  endif
	  if n_elements(azi) eq 1 then begin	; Scalar case.
	    azi = azi(0)
	    dist = dist(0)
	  endif
	endif
 
	;-----------------------------------------------------------
	;  Compute loxodrome endpoint
	;    Given starting point, azimuth, and distance.
	;    Ref: Snyder, P. 46-47.
	;-----------------------------------------------------------
	if keyword_set(p2) then begin
	  if n_elements(azi) eq 0 then begin
	    print,' Error in ell_loxodrome: Must give azimuth and distance'
	    print,'   to compute ending point.'
	    return
	  endif
	  if n_elements(dist) eq 0 then begin
	    print,' Error in ell_loxodrome: Must give azimuth and distance'
	    print,'   to compute ending point.'
	    return
	  endif
	  lng1 = lng10			; Don't change original.
	  lt1 = lat1/radeg		; Convert long,lat to radians.
	  ln1 = lng1/radeg
	  if (azi eq 90) or (azi eq 270) then begin	; Due east or west.
	    lat2 = double(dist*0) + lat1
	    if azi eq 90 then s=dist else s=-dist
	    ln2 = ln1 + s*sqrt(1-e2*sin(lt1)^2)/(a*cos(lt1))	; (7-17)
	    lng20 = ln2*radeg
	  endif else begin				; Any other azi.
	    p = lt1
	    tt = 1 - e2/4 - 3*e4/64 - 5*e6/256		; (3-21)
	    aa = 3*e2/8 + 3*e4/32 + 45*e6/1024
	    bb = 15*e4/256 + 45*e6/1024
	    cc = 35*e6/3072
	    m1 = a*(tt*p - aa*sin(2*p) + bb*sin(4*p) - cc*sin(6*p))
	    caz = cos(azi/radeg)
	    m2 = dist*caz + m1				; (7-18)
	    u = m2/(a*(1-e2/4-3*e4/64-5*e6/256))	; (7-19)
	    tmp = sqrt(1-e2)				; (3-24)
	    e1 = (1-tmp)/(1+tmp)
	    e12 = e1*e1					; (3-26)
	    e13 = e1*e12
	    e14 = e1*e13
	    aa = 3*e1/2 - 27*e13/32
	    bb = 21*e12/16 - 55*e14/32
	    cc = 151*e13/96
	    dd = 1097*e14/512
	    lt2 = u + aa*sin(2*u) + bb*sin(4*u) + cc*sin(6*u) + dd*sin(8*u)
	    lat2 = lt2*radeg
	    ell_merc, lng1,lat1,x=x1,y=y1,map_a=smj
	    esin = e*sin(lt2)
	    t1 = ((1-esin)/(1+esin))^(e/2)
	    t2 = tan(!dpi/4 + lt2/2)
	    ln2 = ln1 + tan(azi/radeg)*(alog(t2*t1) - y1/smj)	; (7-20)
	    lng20 = ln2*radeg
	  endelse
	endif
 
	end
