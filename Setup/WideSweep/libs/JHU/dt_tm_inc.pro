;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_INC
; PURPOSE:
;       Increment a date/time by a given number of seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       dt_tm_inc, t, s
; INPUTS:
;       s = Time in seconds to add.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  Allows output date to be customized.
;         The default format string is 'y$ n$ d$ h$:m$:s$'
;            The following substitutions take place in the format string:
;         Y$ = 4 digit year.
;         y$ = 2 digit year.
;         N$ = full month name.
;         n$ = 3 letter month name.
;         d$ = day of month number.
;         W$ = full weekday name.
;         w$ = 3 letter week day name.
;         h$ = hour.
;         m$ = minute.
;         s$ = second.
;         @  = Carriage Return.
;         !  = Line feed.
;         Some examples: 'h$:m$:s$' -> 09:12:04,
;         'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ...
; OUTPUTS:
;       t = date and time string.        in, out
;         date/time strings are strings like 21-Jan-1989 14:43:03
;         The format of the date and time strings is flexible, see date2ymd.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Apr, 1989.
;       RES 25 Oct, 1991 --- renamed and rewrote from incsec_datetime.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro dt_tm_inc, date_time, incsec, format=frmt, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Increment a date/time by a given number of seconds.'
	  print,' dt_tm_inc, t, s'
	  print,'   t = date and time string.        in, out'
          print,'     date/time strings are strings like'+$
                      ' 21-Jan-1989 14:43:03'
          print,'     The format of the date and time strings is flexible, '+$
                      'see date2ymd.'
	  print,'   s = Time in seconds to add.      in'
          print,' Keywords:'
          print,'   FORMAT = format string.  Allows output date to be '+$
            'customized.'
          print,"   The default format string is 'y$-n$-d$ h$:m$:s$'"
          print,'      The following substitutions take place in the '+$
            'format string:'
          print,'   Y$ = 4 digit year.'
          print,'   y$ = 2 digit year.'
          print,'   N$ = full month name.'
          print,'   n$ = 3 letter month name.'
          print,'   d$ = day of month number.'
          print,'   W$ = full weekday name.'
          print,'   w$ = 3 letter week day name.'
          print,'   h$ = hour.'
          print,'   m$ = minute.'
          print,'   s$ = second.'
          PRINT,'   @  = Carriage Return.'
          PRINT,'   !  = Line feed.'
          print,"   Some examples: 'h$:m$:s$' -> 09:12:04,"
          print,"   'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ..."
	  return
	endif
 
	;----------  Break apart date_time string  ---------------
	dt_tm_brk, DATE_TIME, DATE, TIME
	DATE2YMD, DATE, Y, M, D
	SEC = SECSTR(TIME)
 
	;----------  Process increment  ---------
	INCDAYS = LONG(INCSEC/86400.D0)
	INCSEC = INCSEC - 86400D0*INCDAYS
 
	;-------  Add increment  --------
	JD = YMD2JD(Y, M, D)		; Date as Julian Day.
	JD = JD + INCDAYS		; Add days to JD,
	SEC = SEC + INCSEC		; and sec to time.
 
	IF SEC LT 0 THEN BEGIN		; Borrow.
	  SEC = SEC + 86400
	  JD = JD - 1
	ENDIF
	IF SEC GT 86400 THEN BEGIN	; Carry.
	  SEC = SEC - 86400
	  JD = JD + 1
	ENDIF
 
        ;-----  format string  ------
        fmt = 'Y$-n$-d$ h$:m$:s$'               ; Default format.
        if keyword_set(frmt) then fmt = frmt    ; Use given format.
 
	;-------  Put date time string back together  -------
	date_time = dt_tm_mak(jd, sec, format=fmt)
 
	RETURN
	END
