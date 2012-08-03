;-------------------------------------------------------------
;+
; NAME:
;       WEEKDAY
; PURPOSE:
;       Compute weekday given year, month, day.
; CATEGORY:
; CALLING SEQUENCE:
;       wd = weekday(y,m,d,[nwd])
; INPUTS:
;       y, m, d = Year, month, day (Like 1988, 10, 31).      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       wd = Returned name of weekday.                       out
;       nwd = optional Weekday number.                       out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 31 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION WEEKDAY, Y, M, D, NWD, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Compute weekday given year, month, day.'
	  PRINT,' wd = weekday(y,m,d,[nwd])'
	  PRINT,'   y, m, d = Year, month, day (Like 1988, 10, 31).      in'
	  PRINT,'   wd = Returned name of weekday.                       out'
	  PRINT,'   nwd = optional Weekday number.                       out'
	  RETURN, -1
	ENDIF
 
	NAMES = ['','Sunday','Monday','Tuesday',$
		 'Wednesday','Thursday','Friday','Saturday']
 
	NWD = ((YMD2JD(Y,M,D) + 1) MOD 7) + 1
	RETURN, NAMES(NWD)
 
	END
