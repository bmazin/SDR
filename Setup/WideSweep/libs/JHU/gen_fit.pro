;-------------------------------------------------------------
;+
; NAME:
;       GEN_FIT
; PURPOSE:
;       Fitted Y array for given X array from given fit parameters.
; CATEGORY:
; CALLING SEQUENCE:
;       y = gen_fit(x, cur)
; INPUTS:
;       x = array of desired x values. May be a scalar.       in
;       cur = array describing the fitted curve.              in
;         Has following format:
;         cur = [ftype, xoff, yoff, ndeg, c0, c1, ..., cn]
;               for polynomial,
;         cur = [ftype, xoff, yoff, a, b]
;               for exponential and power.
;         ftype = 0, 1, 2 for Polynomial, Exponential, Power Law.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = fitted y values. May be a scalar.                 out
; COMMON BLOCKS:
; NOTES:
;       Note: CUR may be obtained from the routine FIT.
;       
; MODIFICATION HISTORY:
;       R. Sterner.  14 Oct, 1986.
;       RES 9 Oct, 1989 --- converted to SUN.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION GEN_FIT, XP, CUR, help=hlp
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Fitted Y array for given X array from given fit parameters.'
	  PRINT,' y = gen_fit(x, cur)'
	  PRINT,'   x = array of desired x values. May be a scalar.       in'
	  PRINT,'   cur = array describing the fitted curve.              in'
	  print,'     Has following format:'
	  PRINT,'     cur = [ftype, xoff, yoff, ndeg, c0, c1, ..., cn]'
	  print,'           for polynomial,'
	  PRINT,'     cur = [ftype, xoff, yoff, a, b]'
	  print,'           for exponential and power.'
	  PRINT,'     ftype = 0, 1, 2 for Polynomial, Exponential, Power Law.'
	  PRINT,'   y = fitted y values. May be a scalar.                 out'
	  print,' Note: CUR may be obtained from the routine FIT.
	  PRINT,' '
	  RETURN, -1
	ENDIF
 
	FTYPE = FIX(CUR(0))
	XOFF = CUR(1)
	YOFF = CUR(2)
 
	IF FTYPE EQ 0 THEN BEGIN
	  NDEG = CUR(3)
	  COEFF = CUR(4:*)
	  YP = FLTARR(N_ELEMENTS(XP)) + COEFF(0) + YOFF
	  FOR I = 1, NDEG DO YP = YP + COEFF(I)*(XP+XOFF)^I
	ENDIF
	IF FTYPE EQ 1 THEN BEGIN
	  A = CUR(3)
	  B = CUR(4)
	  YP = A*EXP(B*(XP+XOFF)) + YOFF
	ENDIF
	IF FTYPE EQ 2 THEN BEGIN
	  A = CUR(3)
	  B = CUR(4)
	  YP = A*(XP+XOFF)^B + YOFF
	ENDIF
 
	RETURN, YP
	END
