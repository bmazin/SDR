;-------------------------------------------------------------
;+
; NAME:
;       DOT
; PURPOSE:
;       Used by SUN_SHADE for dot prod. of surf. normal & sun vect.
; CATEGORY:
; CALLING SEQUENCE:
;       r = dot(s,[azi,alt])
; INPUTS:
;       s = Surface array to be shaded.                    in
;       azi = Light azimuth (deg, def = 135).              in
;       alt = Light altitude (deg, def = 60).              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r = dot products: surface normals and sun vector.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 8 Mar, 1989.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       Slightly modified version of routine by J. Culbertson.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION DOT, S0, AZI, ALT, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP EQ 0) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Used by SUN_SHADE for dot prod. of surf. normal & sun vect.'
	  PRINT,' r = dot(s,[azi,alt])'
	  PRINT,'   s = Surface array to be shaded.                    in'
	  PRINT,'   azi = Light azimuth (deg, def = 135).              in'
	  PRINT,'   alt = Light altitude (deg, def = 60).              in'
	  PRINT,'   r = dot products: surface normals and sun vector.  out'
	  RETURN, -1
	ENDIF
 
	IF NP LT 3 THEN ALT = 60.
	IF NP LT 2 THEN AZI = 135.
 
	S = FLOAT(S0)	
	NX = SHIFT(S, 1, 0) - S		; Surface normals.
	NY = SHIFT(S, 0, 1) - S
	NX(0,0) = NX(1,*)		; fix edge effect.
	NY(0,0) = NY(*,1)
	SZ = SIZE(NX)
	NZ = FLTARR(SZ(1),SZ(2)) + 1.
	NL = SQRT(NX^2 + NY^2 + NZ^2)	; normal length.
	NX = NX/NL			; unit normal.
	NY = NY/NL
	NZ = NZ/NL
 
	LX = SIN(AZI/!RADEG)*COS(ALT/!RADEG)
	LY = COS(AZI/!RADEG)*COS(ALT/!RADEG)
	LZ = SIN(ALT/!RADEG)
 
	R = NX*LX + NY*LY + NZ*LZ	; dot product.
	W = WHERE(R LT 0.0)
	if w(0) ne -1 then R(W) = 0
 
	RETURN, R
	END
