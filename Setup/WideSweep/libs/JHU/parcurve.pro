;-------------------------------------------------------------
;+
; NAME:
;       PARCURVE
; PURPOSE:
;       Return a curve parallel to given curve.
; CATEGORY:
; CALLING SEQUENCE:
;       parcurve, x, y, x2, y2
; INPUTS:
;       x,y = arrays of coordinates along original curve.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         SHIFT=s distance to shift curve (def=1).
;         /POLY means form a closed polygon by shifting
;           the given curve +/- s from the original position.
; OUTPUTS:
;       x2,y2 = coordinates along a parallel curve.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro parcurve, x, y, x2, y2, shift=s, poly=poly, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Return a curve parallel to given curve.'
	  print,' parcurve, x, y, x2, y2'
	  print,'   x,y = arrays of coordinates along original curve.  in'
	  print,'   x2,y2 = coordinates along a parallel curve.        out'
	  print,' Keywords:'
	  print,'   SHIFT=s distance to shift curve (def=1).'
	  print,'   /POLY means form a closed polygon by shifting'
	  print,'     the given curve +/- s from the original position.'
	  return
	endif
 
	if n_elements(s) eq 0 then s = 1.
 
	dx = x(1:*) - x		; Vectors between curve points.
	dy = y(1:*) - y
	m = sqrt(dx^2 + dy^2)	; Vector magnitudes.
	ux = dx/m		; Unit vectors.
	uy = dy/m
	px = uy			; Perpendicular.
	py = -ux
	n = n_elements(px)	; # vectors.
	px = [px,px(n-1)]	; Duplicate last point.
	py = [py,py(n-1)]
	if keyword_set(poly) then begin
	  x2 = [x+s*px, reverse(x-s*px)]	; Polygon.
	  y2 = [y+s*py, reverse(y-s*py)]
	  x2 = [x2,x2(0)]			; Close it.
	  y2 = [y2,y2(0)]
	endif else begin
	  x2 = x + s*px		; Parallel curve.
	  y2 = y + s*py
	endelse
 
	return
	end
