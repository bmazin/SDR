;-------------------------------------------------------------
;+
; NAME:
;       MAKEXY
; PURPOSE:
;       Make 2-d X & Y coord. arrays, useful for functions of x,y.
; CATEGORY:
; CALLING SEQUENCE:
;       MAKEXY, x1, x2, dx, y1, y2, dy, xarray, yarray
; INPUTS:
;       x1 = min x coordinate in output rectangular array.  in
;       x2 = max x coordinate in output rectangular array.  in
;       dx = step size in x.                                in
;       y1 = min y coordinate in output rectangular array.  in
;       y2 = max y coordinate in output rectangular array.  in
;       dy = step size in y.                                in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xarray, yarray = resulting rectangular arrays.      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  15 May, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 30 Aug 89 --- converted to SUN.
;	R. Sterner, 27 Mar, 1992 --- switched from CONGRID to REBIN.
;	  On VAX improved speed by about 5 times.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO MAKEXY, X1, X2, DX, Y1, Y2, DY, XA, YA, help=hlp
 
	IF (N_PARAMS(0) lt 8) or keyword_set(hlp) THEN BEGIN
	  print,' Make 2-d X & Y coord. arrays, useful for functions of x,y.'
	  PRINT,' MAKEXY, x1, x2, dx, y1, y2, dy, xarray, yarray
	  PRINT,'   x1 = min x coordinate in output rectangular array.  in'
	  PRINT,'   x2 = max x coordinate in output rectangular array.  in'
	  PRINT,'   dx = step size in x.                                in'
	  PRINT,'   y1 = min y coordinate in output rectangular array.  in'
	  PRINT,'   y2 = max y coordinate in output rectangular array.  in'
	  PRINT,'   dy = step size in y.                                in'
	  PRINT,'   xarray, yarray = resulting rectangular arrays.      out'
	  RETURN
	ENDIF
 
	X = MAKEX(X1, X2, DX)			; generate X array.
	NX = N_ELEMENTS(X)
	Y = transpose(MAKEX(Y1, Y2, DY))	; generate Y array.
	NY = N_ELEMENTS(Y)
	XA = rebin(X, NX, NY)
	YA = rebin(Y, NX, NY)
 
	RETURN
 
	END
