;-------------------------------------------------------------
;+
; NAME:
;       YDN2MD
; PURPOSE:
;       Convert from year and day number of year to month and day of month.
; CATEGORY:
; CALLING SEQUENCE:
;       ydn2md,yr,dy,m,d
; INPUTS:
;       yr = year (like 1988).               in
;       dy = day number in year (like 310).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = month number (like 11 = Nov).    out
;       d = day of month (like 5).           out
; COMMON BLOCKS:
; NOTES:
;       Note: On error returns m = d = -1.
; MODIFICATION HISTORY:
;       R. Sterner 20 June, 1985 (for budget workspace).
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO YDN2MD,YR,DY,M,D, help=hlp
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert from year and day number of year to month '+$
	    'and day of month.'
	  PRINT,' ydn2md,yr,dy,m,d'
	  PRINT,'   yr = year (like 1988).               in'
	  PRINT,'   dy = day number in year (like 310).  in'
	  PRINT,'   m = month number (like 11 = Nov).    out'
	  PRINT,'   d = day of month (like 5).           out'
	  PRINT,' Note: On error returns m = d = -1.'
	  RETURN
	ENDIF
 
	; Days before start of each month.
	YDAYS = [0,31,59,90,120,151,181,212,243,273,304,334,366]
 
	; Correct YDAYS for leap-year.
	IF (((YR MOD 4) EQ 0) AND ((YR MOD 100) NE 0)) $
            OR ((YR MOD 400) EQ 0) THEN YDAYS(2) = YDAYS(2:*) + 1
 
	FOR I = 1, 12 DO BEGIN
	  IF DY LE YDAYS(I) THEN GOTO, NEXT
	ENDFOR
 
	PRINT,' ydn2md: error in day number.'
	M = -1
	D = -1
	RETURN
 
NEXT:	M = I
	D = DY - YDAYS(M-1)
	RETURN
 
	END
