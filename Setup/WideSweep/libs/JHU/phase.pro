;-------------------------------------------------------------
;+
; NAME:
;       PHASE
; PURPOSE:
;       Return an array filled in to indicate specified moon phase.
; CATEGORY:
; CALLING SEQUENCE:
;       a = phase(sz, ph, [xtr, xed, y])
; INPUTS:
;       sz = Size of array to generate.                     in
;       ph = Phase angle in deg.                            in
;         0=new, 90=first Q, 180=full, 270=last Q.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       tr = Terminator X coordinates.                      out
;       ed = Edge X coordinates.                            out
;       y = Y coordinates for terminator and edge.          out
;       a = returned array.                                 out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 23 Feb, 1988.
;       R. Sterner, 13 Dec 1990 --- updated to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION PHASE, SZ0, PH0, TR, ED, Y, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return an array filled in to indicate specified moon phase.'
	  print,' a = phase(sz, ph, [xtr, xed, y])
	  print,'   sz = Size of array to generate.                     in'
	  print,'   ph = Phase angle in deg.                            in'
	  print,'     0=new, 90=first Q, 180=full, 270=last Q.
	  print,'   tr = Terminator X coordinates.                      out'
	  print,'   ed = Edge X coordinates.                            out'
	  print,'   y = Y coordinates for terminator and edge.          out'
	  print,'   a = returned array.                                 out'
	  return, -1
	endif
 
	SZ = FIX(0.5 + SZ0)
	PH = PH0 MOD 360		; Put phase in the range 0 to 360.
	IF PH LT 0 THEN PH = PH + 360
 
	R = SZ/2.			; Radius is 1/2 array size.
	Y = MAKEX(.5, SZ-.5, 1.)	; Find pixel centers in Y (then -R).
	X2 = SQRT(R^2 - (Y-R)^2)	; Circular X for each Y, + side.
	X1 = -X2			; - side.
	Y = Y - .5			; Returned Y values.
 
	IF PH LE 180. THEN BEGIN	; Bend one side or the other inward.
	  X1 = -COS(PH/!RADEG)*X1
	ENDIF ELSE BEGIN
	  X2 = -COS(PH/!RADEG)*X2
	ENDELSE
 
	X1 = X1 + R
	X2 = X2 + R
	IF PH LE 180. THEN BEGIN	; Return sides.
	  TR = X1
	  ED = X2
	ENDIF ELSE BEGIN
	  TR = X2
	  ED = X1
	ENDELSE
	X1B = FIX(X1+1.)<(sz-1)		; Want nearest X values.
	X2B = FIX(X2)<(sz-1)
 
	A = BYTARR(SZ,SZ)		; Make array of 0s.
 
	FOR I = 0, SZ-1 DO BEGIN	; Fill in 1s.
	  D = X2B(I) - X1B(I)
	  IF D GT 0 THEN A(X1B(I):X2B(I),I) = 1
	ENDFOR
 
	RETURN, A
	END
