;-------------------------------------------------------------
;+
; NAME:
;       MONTHDAYS
; PURPOSE:
;       Given a year and month returns number of days in that month.
; CATEGORY:
; CALLING SEQUENCE:
;       days = monthdays(yr,mon)
; INPUTS:
;       yr = year (like 1988).                     in
;       mon = month number (like 11 = Nov).        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       days = number of days in month (like 30).  out
; COMMON BLOCKS:
; NOTES:
;       Notes: If mon is 0 then return array of
;       month days for entire year.
; MODIFICATION HISTORY:
;       R. Sterner,  14 Aug, 1985.
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
 
	FUNCTION MONTHDAYS,YR,M, help=hlp
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Given a year and month returns number of days in that month.'
	  PRINT,' days = monthdays(yr,mon)'
	  PRINT,'   yr = year (like 1988).                     in'
	  PRINT,'   mon = month number (like 11 = Nov).        in'
	  PRINT,'   days = number of days in month (like 30).  out'
	  PRINT,' Notes: If mon is 0 then return array of'
	  PRINT,' month days for entire year.'
	  RETURN, -1
	ENDIF
 
	DYS = [0,31,28,31,30,31,30,31,31,30,31,30,31]
 
	; Correct DYS for leap-year.
	IF (((YR MOD 4) EQ 0) AND ((YR MOD 100) NE 0)) $
            OR ((YR MOD 400) EQ 0) THEN DYS(2) = 29
 
	IF M EQ 0 THEN RETURN, DYS
	RETURN, DYS(M)
 
	END
