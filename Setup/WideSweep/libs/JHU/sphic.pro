;-------------------------------------------------------------
;+
; NAME:
;       SPHIC
; PURPOSE:
;       Compute intersection points of two circles on a unit sphere.
; CATEGORY:
; CALLING SEQUENCE:
;       sphic, ln1,lt1,r1, ln2,lt2,r2, lnp1,ltp1, lnp2,ltp2, flag
; INPUTS:
;       ln1 = longitude of circle 1 center.      in
;       lt1 = latitude of circle 1 center.       in
;       r1 = radius of circle 1.                 in
;            Angle along sphere surface.
;       ln2 = longitude of circle 2 center.      in
;       lt2 = latitude of circle 2 center.       in
;       r2 = radius of circle 2.                 in
;            Angle along sphere surface.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means all angles are in degrees, else radians.
; OUTPUTS:
;       lnp1 = longitude of intersection 1.      out
;       ltp1 = latitude of intersection 1.       out
;       lnp2 = longitude of intersection 2.      out
;       ltp2 = latitude of intersection 2.       out
;       flag = -2: circles are the same, all points on both.
;              -1: parallel circles, different radii, no int.
;               0: non-parallel circles, no intersection.
;               1: tangent circles, one intersection.
;               2: circles intersect in two points.
; COMMON BLOCKS:
; NOTES:
;       Notes: if flag < 1 then returned intersection points
;         are meaningless and may be undefined.
;         If flag = 1 then both points are the same.
; MODIFICATION HISTORY:
;       R. Sterner. 13 Apr, 1988.
;       R. Sterner. 14 Feb, 1991 --- to IDL V2 & slight changes.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro sphic, ln1, lt1, r1, ln2, lt2, r2, lnp1, ltp1, lnp2, ltp2, flag, $
	  degrees=degrees, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Compute intersection points of two circles on a unit sphere.'
	  print,' sphic, ln1,lt1,r1, ln2,lt2,r2, lnp1,ltp1, lnp2,ltp2, flag'
	  print,'   ln1 = longitude of circle 1 center.      in'
	  print,'   lt1 = latitude of circle 1 center.       in'
	  print,'   r1 = radius of circle 1.                 in'
	  print,'        Angle along sphere surface.'
	  print,'   ln2 = longitude of circle 2 center.      in'
	  print,'   lt2 = latitude of circle 2 center.       in'
	  print,'   r2 = radius of circle 2.                 in'
	  print,'        Angle along sphere surface.'
	  print,'   lnp1 = longitude of intersection 1.      out'
	  print,'   ltp1 = latitude of intersection 1.       out'
	  print,'   lnp2 = longitude of intersection 2.      out'
	  print,'   ltp2 = latitude of intersection 2.       out'
	  print,'   flag = -2: circles are the same, all points on both.'
	  print,'          -1: parallel circles, different radii, no int.'
	  print,'           0: non-parallel circles, no intersection.'
	  print,'           1: tangent circles, one intersection.'
	  print,'           2: circles intersect in two points.'
	  print,' Keywords:'
	  print,'   /DEGREES means all angles are in degrees, else radians.'
	  print,' Notes: if flag < 1 then returned intersection points'
	  print,'   are meaningless and may be undefined.'
	  print,'   If flag = 1 then both points are the same.'
	  return
	endif
 
	;--------  Convert from lat, long to unit vector  ------
	if keyword_set(degrees) then begin
	  cl1 = 90.-lt1
	  cl2 = 90.-lt2
	endif else begin
	  cl1 = 90./!radeg-lt1
	  cl2 = 90./!radeg-lt2
	endelse
	polrec3d, 1., cl1, ln1, px, py, pz, degrees=degrees
	polrec3d, 1., cl2, ln2, qx, qy, qz, degrees=degrees
	p = [px,py,pz]
	q = [qx,qy,qz]
	;--------  Offsets from sphere center to circle planes  ------
	if keyword_set(degrees) then begin
	  v = cos(r1/!radeg)
	  w = cos(r2/!radeg)
	endif else begin
	  v = cos(r1)
	  w = cos(r2)
	endelse
 
	c = total(p*q)			     ; Cosine of angle between vectors.
	if c eq 1.0 then begin		     ; Parallel circles. No int.
	  if v eq w then flag = -2	     ; Coincident circles.
	  if v ne w then flag = -1	     ; Parallel circles.
	  return
	endif
 
	t = ((v-c*w)*p + (w-c*v)*q)/(1-c^2)  ; Vector to midpoint of int. pts.
	t2 = total(t*t)			     ; T dot T = length squared.
 
	if t2 gt 1.0 then begin
	  flag = 0			     ; Non-parallel, no intersection.
	  return
	endif
 
	flag = 2			     ; Assume 2 intersections.
	if t2 eq 1.0 then flag = 1	     ; No, only one.
	h = sqrt(1-t2)			     ; Dist. midpt to int. pt.
	r = unit(crossp(p,q))		     ; Unit vector toward int. pts.
	i1 = t + h*r			     ; Int. pts.
	i2 = t - h*r
 
	;--------  Convert points back to lat, long  ----------
	recpol3d, i1(0), i1(1), i1(2), r, clp1, lnp1, degrees=degrees
	recpol3d, i2(0), i2(1), i2(2), r, clp2, lnp2, degrees=degrees
	if keyword_set(degrees) then begin
	  ltp1 = 90.-clp1
	  ltp2 = 90.-clp2
	endif else begin
	  ltp1 = 90./!radeg-clp1
	  ltp2 = 90./!radeg-clp2
	endelse
 
	return
	end
 
