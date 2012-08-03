;-------------------------------------------------------------
;+
; NAME:
;       TOPO2
; PURPOSE:
;       Make a shading array for a given data array.
; CATEGORY:
; CALLING SEQUENCE:
;       sh = topo2(z, az, ax)
; INPUTS:
;       z = array of elevations to shade.                       in
; KEYWORD PARAMETERS:
;       Keywords:
;         /SCALE means scale min and max shading to 0 and 1.
;         MIN=mn Scale min shading to mn instead of 0.
;         MAX=mx Scale max shading to mx instead of 1.
;         AZ=az  light source angle from zenith in deg (def = 45).
;         AX=ax  light source angle from x axis in deg (def = 45).
; OUTPUTS:
;       sh = Returned shading array (0 to 1).                   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Jun 29
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function topo2, s0, az=az, ax=ax, scale=scale, min=mn, max=mx, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a shading array for a given data array.'
	  print,' sh = topo2(z, az, ax)'
	  print,'   z = array of elevations to shade.                       in'
	  print,'   sh = Returned shading array (0 to 1).                   out'
	  print,' Keywords:'
	  print,'   /SCALE means scale min and max shading to 0 and 1.'
	  print,'   MIN=mn Scale min shading to mn instead of 0.'
	  print,'   MAX=mx Scale max shading to mx instead of 1.'
	  print,'   AZ=az  light source angle from zenith in deg (def = 45).'
	  print,'   AX=ax  light source angle from x axis in deg (def = 45).'
	  return, ''
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
 
	;-------  Clip to 0  -----
	r = r>0.
 
	;-------  Scale result  -----------------
	if keyword_set(scale) then begin
	  if n_elements(mn) eq 0 then mn=0.	; Min output.
	  if n_elements(mx) eq 0 then mx=1.	; Max output.
	  r = scalearray(r,min(r),max(r),mn,mx)>mn<mx
	endif
	
	return, r
	end
