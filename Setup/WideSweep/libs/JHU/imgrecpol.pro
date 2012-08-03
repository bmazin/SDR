;-------------------------------------------------------------
;+
; NAME:
;       IMGRECPOL
; PURPOSE:
;       Map an X/Y image to an angle/radius image.
; CATEGORY:
; CALLING SEQUENCE:
;       ar = imgrecpol(xy, x1, x2, y1, y2, a1, a2, da, r1, r2, dr)
; INPUTS:
;       xy = X/Y image.					in
;       x1, x2 = start and end x in xy.			in
;       y1, y2 = start and end y in xy.			in
;       a1, a2, da = start ang, end ang, ang step (deg).	in
;       r1, r2, dr = start radius, end radius, radius step.	in
; KEYWORD PARAMETERS:
;       Keywords:
;         /BILINEAR does bilinear interpolation,
;           else nearest neighbor is used.
;         /MASK masks values outside image to 0.
; OUTPUTS:
;       ar = returned angle/radius image.			out
;         Angle is in x direction, and radius is in y direction.
; COMMON BLOCKS:
; NOTES:
;       Notes: Angle is 0 along + X axis and increases CCW.
; MODIFICATION HISTORY:
;       R. Sterner.  11 July, 1986.
;       R. Sterner, 4 Sep, 1991 --- converted to IDL vers 2.
;       R. Sterner, 5 Sep, 1991 --- simplified and added bilinear interp.
;       Johns Hopkins Applied Physics Lab.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function imgrecpol, xy, x1, x2, y1, y2, a1, a2, da, $
	  r1, r2, dr, help=hlp, mask=mask, bilinear=bilin
 
	IF (N_PARAMS(0) LT 11) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Map an X/Y image to an angle/radius image.'
	  PRINT,' ar = imgrecpol(xy, x1, x2, y1, y2, a1, a2, da, r1, r2, dr)'
	  PRINT,'   xy = X/Y image.					in'
	  PRINT,'   x1, x2 = start and end x in xy.			in'
	  PRINT,'   y1, y2 = start and end y in xy.			in'
	  PRINT,'   a1, a2, da = start ang, end ang, ang step (deg).	in'
	  PRINT,'   r1, r2, dr = start radius, end radius, radius step.	in'
	  PRINT,'   ar = returned angle/radius image.			out'
	  PRINT,'     Angle is in x direction, and radius is in y direction.'
	  print,' Keywords:'
	  print,'   /BILINEAR does bilinear interpolation,'
	  print,'     else nearest neighbor is used.'
	  print,'   /MASK masks values outside image to 0.'
	  print,' Notes: Angle is 0 along + X axis and increases CCW.'
	  RETURN, -1
	ENDIF
 
	;------  Get input image size and make sure its an image  ------
	S = SIZE(XY)				; Error check.
	IF S(0) NE 2 THEN BEGIN
	  PRINT,' Error in IMGRECPOL: First arg must be a 2-d array.'
	  RETURN, -1
	ENDIF
 
	;-------  Set up angle and radius arrays  -------
	A = MAKEX(A1, A2, DA)/!RADEG		; Generate angle array.
	NA = N_ELEMENTS(A)
	R = transpose(MAKEX(R1, R2, DR))	; Generate radius array.
	NR = N_ELEMENTS(R)
	a = rebin(a, na, nr)
	r = rebin(r, na, nr)
 
	;-------  Compute X and Y from angle and radius  -------
	;-------  One of the longer steps  ------
	X = R*COS(A)				; From AR coordinates find X.
	Y = R*SIN(A)				; From AR coordinates find Y.
 
	;------  Convert X and Y to indices  --------
	NX = S(1)				; Size of XY in x.
	NY = S(2)				; Size of XY in y.
	IX = (X-X1)*(NX-1)/(X2-X1)		; From X find X indices.
	IY = (Y-Y1)*(NY-1)/(Y2-Y1)		; From Y find Y indices.
 
	;------  Interpolate  ------------
	if not keyword_set(bilin) then begin
	  ;------  Nearest Neighbor interpolation  -------
	  ar = XY(fix(.5+IX)<(nx-1),fix(.5+IY)<(ny-1))  ; Pick off values.
	endif else begin
	  ;------  Bilinear interpolation  -------
	  ix0 = floor(ix)	; Indices of the 4 surrounding points.
	  ix1 = (ix0+1)<(nx-1)
	  iy0 = floor(iy)
	  iy1 = (iy0+1)<(ny-1)
	  v00 = xy(ix0,iy0)	; Values of the 4 surrounding points.
	  v01 = xy(ix0,iy1)
	  v10 = xy(ix1,iy0)
	  v11 = xy(ix1,iy1)
	  fx = ix - ix0		; Fractional x distance between points.
	  v0 = v00 + (v10-v00)*fx	; X interp at y0.
	  v1 = v01 + (v11-v01)*fx	; X interp at y1.
	  ar = v0+(v1-v0)*(iy-iy0)	; Y interp at x.
	endelse
 
	;-------  Mask points outside input image to 0  -------
	if keyword_set(mask) then begin
          W = WHERE((IX lt 0) or (IX ge (NX-1)) or $
	            (IY lt 0) or (IY ge (NY-1)), count)
	  if count gt 0 then ar(w) = 0
	endif
 
	;-------  Return result  ---------
	RETURN, AR
 
	END
