;-------------------------------------------------------------
;+
; NAME:
;       EXPLORE
; PURPOSE:
;       Image stats in a 16 x 16 box movable with the mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       explore, a, x, y
; INPUTS:
;       a = array which is displayed on screen.   in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x, y = Cursor coordinates.                in, out.
; COMMON BLOCKS:
; NOTES:
;       Notes: Assumes array is loaded with element (0,0) at the
;         lower left corner of the window, and !ORDER = 0
;         Lists array indices of cursor box center,
;         array value at cursor box center,
;         and cursor box min, max, and mean, SD, skew, kurt.
;         Any button exits.
; MODIFICATION HISTORY:
;       R. Sterner 25 July, 1989
;       R. Sterner, 2007 Feb 12 --- Fixed cursor image endian problem.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO EXPLORE, A, X, Y, help=hlp
 
	IF (N_PARAMS(0) LT 1) or keyword_set(hlp) THEN begin
	  print,' Image stats in a 16 x 16 box movable with the mouse.'
	  PRINT,' explore, a, x, y'
	  PRINT,'   a = array which is displayed on screen.   in.'
	  PRINT,'   x, y = Cursor coordinates.                in, out.'
	  PRINT,' Notes: Assumes array is loaded with element (0,0) at the'
	  PRINT,'   lower left corner of the window, and !ORDER = 0'
	  PRINT,'   Lists array indices of cursor box center,'
	  PRINT,'   array value at cursor box center,'
	  PRINT,'   and cursor box min, max, and mean, SD, skew, kurt.'
	  PRINT,'   Any button exits.'
	  return
	endif
 
	if n_elements(x) eq 0 then x = 100
	if n_elements(y) eq 0 then y = 100
 
	SZ = SIZE(A)		  ; Array sizes.
	LX = SZ(1)-1-7		  ; Last allowed index in X.
	LY = SZ(2)-1-7		  ; Last allowed index in Y.
	C = INTARR(16) + 16385	  ; Set up new cursor.  16 elements of bits.
	C(15) = 0		  ; set bit to 1 to display in cursor.
	C([0,14]) = 32767
	C(7) = 16513
	if endian() eq 0 then c=swap_endian(c)
	DEVICE, CURSOR_IMAGE = C, CURSOR_XY = [7,7]	; Set new cursor.
 
LOOP:	CURSOR, X, Y, 2, /DEVICE        ; Read cursor (dev), only if moved.
	X = X>7<LX  & Y = Y>7<LY	; Force indices to be in range.
	T = A((X-7):(X+7), (Y-7):(Y+7))	; Extract 15 x 15 subarray.
	TMIN = MIN(T)		;find stats
	TMAX = MAX(T)
	TMEAN = MEAN(T)
	TSD = STDEV(T)
	tskew = skew(t)
	tk = kurt(t)
	PRINT,' array( ',STRTRIM(X,2),', ',STRTRIM(Y,2),' )= ', $
	  STRTRIM(A(X,Y),2),  $
	  '   min, max: ',STRTRIM(TMIN,2),'  ',STRTRIM(TMAX,2)
	print,'   mean, sd, skew, kurt: ',STRTRIM(TMEAN,2), $
	  '  ',STRTRIM(TSD,2),'  ',$
	  strtrim(tskew,2),'  ',strtrim(tk,2)
	IF (!ERR gt 0) and (!err le 4) THEN BEGIN ; Check if button pressed.
	  DEVICE, /CURSOR_CROSSHAIR	  ; Yes, restore cursor type.
	  RETURN			  ; and return.
	ENDIF
	GOTO, LOOP			; No, keep looping.
 
	END	
