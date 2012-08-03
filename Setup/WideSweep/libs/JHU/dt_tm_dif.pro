;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_DIF
; PURPOSE:
;       Find time interval in seconds between two date/time strings.
; CATEGORY:
; CALLING SEQUENCE:
;       sec = dt_tm_dif(t1, t2)
; INPUTS:
;       t1, t2 = date and time strings.        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       sec = Time in seconds from t1 to t2.   out
; COMMON BLOCKS:
; NOTES:
;       Note: date and time strings are strings like 21-Jan-1989 14:43:03
;       The format of the date and time strings is flexable, see date2ymd.
; MODIFICATION HISTORY:
;       R. Sterner. 12 Apr, 1989.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;       R. Sterner, 26 Feb, 1991 --- Renamed from interval_sec.pro
;       R. Sterner, 27 Feb, 1991 --- Renamed from interv_sec.pro
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION dt_tm_dif, T1, T2, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find time interval in seconds between two date/time strings.'
	  print,' sec = dt_tm_dif(t1, t2)'
	  print,'    t1, t2 = date and time strings.        in'
	  print,'    sec = Time in seconds from t1 to t2.   out'
	  print,' Note: date and time strings are strings like'+$
	    ' 21-Jan-1989 14:43:03'
	  print,' The format of the date and time strings is flexable, '+$
	    'see date2ymd.'
	  return, -1
	endif
 
	;-------  T1: First date and time  ----------
	dt_tm_brk, T1, DT, TM		; Break T1 into date and time.
	DATE2YMD, DT, Y, M, D		; Find Y, M, D.
	JD1 = YMD2JD(Y,M,D)		; Find JD.
	SEC1 = DOUBLE(SECSTR(TM))	; Time in sec.
 
	;-------  T2: Second date and time  ----------
	dt_tm_brk, T2, DT, TM		; Break T2 into date and time.
	DATE2YMD, DT, Y, M, D		; Find Y, M, D.
	JD2 = YMD2JD(Y,M,D)		; Find JD.
	DJD2 = JD2 - JD1		; Days after JD1.
	SEC2 = SECSTR(TM)		; Time in sec.
	INT_SEC2 = (DJD2*86400D0 + SEC2) - SEC1	; Sec since T1.
 
	RETURN, INT_SEC2
 
	END
