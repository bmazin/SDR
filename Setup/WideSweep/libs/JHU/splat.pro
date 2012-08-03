;-------------------------------------------------------------
;+
; NAME:
;       SPLAT
; PURPOSE:
;       Generate points on a splat curve.
; CATEGORY:
; CALLING SEQUENCE:
;       splat, n, r1, r2, x, y
; INPUTS:
;       n = number of points on curve.                        in
;       r1, r2 = min and max distance of points from center.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         SMOOTH=s smoothing window size (def = 5% of n).
; OUTPUTS:
;       x, y = splat curve points.                            out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       RES  7 Feb, 1986.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO SPLAT, N, R1, R2, X, Y, help=hlp, smooth=smth
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Generate points on a splat curve.'
	  print,' splat, n, r1, r2, x, y'
	  print,'   n = number of points on curve.                        in'
	  print,'   r1, r2 = min and max distance of points from center.  in'
	  print,'   x, y = splat curve points.                            out'
	  print,' Keywords:'
	  print,'   SMOOTH=s smoothing window size (def = 5% of n).'
	  return
	endif
 
	if n_elements(smth) eq 0 then smth = (.05*n)
	w = smth>5
 
	R = makey(n,w,/per)
	r = scalearray(r, min(r),max(r), r1, r2)
	A = MAKEN(0.,6.2831853,N+1)
	A = A(1:*)
	X = COS(A)*R
	Y = SIN(A)*R
	RETURN
	END
