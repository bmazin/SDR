;-------------------------------------------------------------
;+
; NAME:
;       PLINT
; PURPOSE:
;       Intersection point of a plane and a line.
; CATEGORY:
; CALLING SEQUENCE:
;       plint, lp1, lp2, n, pp, pi, flag
; INPUTS:
;       lp1, lp2 = two points on the line.     in
;         lp1 is the 0 point, + toward lp2.
;       n = normal to plane.                   in
;       pp = any point on the plane.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       pi = intersection point.               out
;       flag = intersection flag:              out
;         0: no intersection,
;        +1: + side of line (also 0),
;        -1: - side of line.
; COMMON BLOCKS:
; NOTES:
;       Notes: all points are 3 element arrays (x,y,z).
; MODIFICATION HISTORY:
;       RES  20 May, 1985 from PLINT.FOR sub.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro plint, lp1, lp2, n, pp, pi, flag, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Intersection point of a plane and a line.'
	  print,' plint, lp1, lp2, n, pp, pi, flag'
	  print,'   lp1, lp2 = two points on the line.     in'
	  print,'     lp1 is the 0 point, + toward lp2.'
	  print,'   n = normal to plane.                   in'
	  print,'   pp = any point on the plane.           in'
	  print,'   pi = intersection point.               out'
	  print,'   flag = intersection flag:              out'
	  print,'     0: no intersection,'
	  print,'    +1: + side of line (also 0),'
	  print,'    -1: - side of line.'
	  print,' Notes: all points are 3 element arrays (x,y,z).'
	  return
	endif
 
	pi = fltarr(3)
	flag = 0
 
	d = lp2 - lp1	   ; compute line directorix.
 
	w = lp1 - pp	   ; weighting factor.
 
	v1 = total(w*n)    ; numerator.
	v2 = total(d*n)    ; denominator.
 
	if v2 eq 0. then return
 
	t = -v1/v2
 
	if t ge 0. then flag = 1
	if t lt 0. then flag = -1
 
	pi = lp1 + t*d
 
	return
 
	end
