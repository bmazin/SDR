;-------------------------------------------------------------
;+
; NAME:
;       TOPO
; PURPOSE:
;       Make a monochrome shaded relief view of a surface.
; CATEGORY:
; CALLING SEQUENCE:
;       t = topo(z, az, ax)
; INPUTS:
;       z = array of elevations to shade.                       in
;       az = light source angle from zenith in deg (def = 45).  in
;       ax = light source angle from x axis in deg (def = 45).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         DELTA=d  Set a range of slopes in degrees to map to 0 to 1.
;           Delta is relative to sun angle. Try small value, 5 or 10.
;         ZERO=v  Value (0 to 1) to map zero slope (flat surface) to.
;           May be used with DELTA (DELTA=10 if not given with ZERO).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: there are no true shadows.  DELTA and ZERO give better
;         control over brightness and avoid low sun angles returning
;         low brightness results.  The operation of DELTA and ZERO
;         are roughly: ZERO is brightness, DELTA is contrast.
;         Best values depend on the data but ZERO=.5 and DELTA
;         around 5 to 15 might be reasonable.
; MODIFICATION HISTORY:
;       R. Sterner. 19 Nov, 1987.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner, 1994 Jun 6 --- Made a minor memory savings.
;       R. Sterner, 1994 Jun 28 --- Added DELTA and ZERO keywords.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function topo, s0, az, ax, delta=delta, zero=zero, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a monochrome shaded relief view of a surface.'
	  print,' t = topo(z, az, ax)'
	  print,'   z = array of elevations to shade.                       in'
	  print,'   az = light source angle from zenith in deg (def = 45).  in'
	  print,'   ax = light source angle from x axis in deg (def = 45).  in'
	  print,' Keywords:'
	  print,'   DELTA=d  Set a range of slopes in degrees to map to 0 to 1.'
	  print,'     Delta is relative to sun angle. Try small value, 5 or 10.'
	  print,'   ZERO=v  Value (0 to 1) to map zero slope (flat surface) to.'
	  print,'     May be used with DELTA (DELTA=10 if not given with ZERO).'
	  print,' Note: there are no true shadows.  DELTA and ZERO give better'
	  print,'   control over brightness and avoid low sun angles returning'
	  print,'   low brightness results.  The operation of DELTA and ZERO'
	  print,'   are roughly: ZERO is brightness, DELTA is contrast.'
	  print,'   Best values depend on the data but ZERO=.5 and DELTA'
	  print,'   around 5 to 15 might be reasonable.'
	  return, -1
	endif
 
	np = n_params(0)
	if np lt 3 then ax = 45.
	if np lt 2 then az = 45.
 
	s = float(s0)	
 
	;---------  Surface normals  ------------
	nx = shift(s, 1, 0) - s		; X and Y components.
	ny = shift(s, 0, 1) - s
	s = 0				; Drop s (no longer needed).
	nx(0,0) = nx(1,*)		; Copy adjacent values to
	nx(0,0) = nx(*,1)		; avoid edge effects.
	ny(0,0) = ny(1,*)
	ny(0,0) = ny(*,1)
	nz = nx*0. + 1.			; Z component.
	;--------  Unit normal  --------------
	r = sqrt(nx^2 + ny^2 + nz^2)	; Surface normal length.
	nx = nx/r
	ny = ny/r
	nz = nz/r
	r = 0				; Drop r (no longer needed).
 
	;-------  Dot with light vector  --------
	polrec3d, 1, az/!radeg, ax/!radeg, lx, ly, lz	; light vector.
	r = nx*lx + ny*ly + nz*lz	; dot product.
	w = where(r lt 0.0)
	if w(0) ne -1 then r(w) = 0
 
	;-------  Do adaptive scaling  ----------
	if n_elements(zero) ne 0 then if n_elements(delta) eq 0 then delta=10.
	if n_elements(delta) eq 0 then return, r
 
	hi = cos((az-delta)/!radeg)<1
	lo = cos((az+delta)/!radeg)>0
 
	if n_elements(zero) eq 0 then begin	; Case 1.
	  r = scalearray(r,lo,hi,0,1)>0<1
	endif else begin
	  mid = cos(az/!radeg)
	  if zero ge .5 then r = scalearray(r,mid,hi,zero,1)>0<1   ; Case 2A.
	  if zero lt .5 then r = scalearray(r,lo,mid,0,zero)>0<1   ; Case 2B.
	endelse
	
	return, r
	end
