;-------------------------------------------------------------
;+
; NAME:
;       YMD2DATE
; PURPOSE:
;       Convert from year, month, day numbers to date string.
; CATEGORY:
; CALLING SEQUENCE:
;       date = ymd2date(Y,M,D)
; INPUTS:
;       y = year number (like 1986).                         in
;       m = month number (1 - 12).                           in
;       d = day of month number (1 - 31).                    in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  Allows output date to be customized.
;            The following substitutions take place in the format string:
;         Y$ = 4 digit year.
;         y$ = 2 digit year.
;         N$ = full month name.
;         n$ = 3 letter month name.
;         d$ = day of month number.
;         0d$ = day of month number with leading 0 if < 10.
;         W$ = full weekday name.
;         w$ = 3 letter week day name.
; OUTPUTS:
;       date = returned date string (like 24-May-1986).      out
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         The default format string is 'd$-n$-Y$' giving 24-Sep-1989
;         Example: FORMAT='w$ N$ d$, Y$' would give 'Mon 
; MODIFICATION HISTORY:
;       R. Sterner.  16 Jul, 1986.
;       RES 18 Sep, 1989 --- converted to SUN
;       R. Sterner, 28 Feb, 1991 --- modified format.
;       R. Sterner, 16 Dec, 1991 --- added space to 1 digit day.
;       R. Sterner, 1996 Jan 5 --- Added leading 0 to day of month.
;       R. Sterner, 1999 Aug 04 --- Improved the Y2K fix.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ymd2date, y, m, d, help=hlp, format=frmt
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Convert from year, month, day numbers to date string.'
	  print,' date = ymd2date(Y,M,D)'
	  print,'   y = year number (like 1986).                         in'
	  print,'   m = month number (1 - 12).                           in'
	  print,'   d = day of month number (1 - 31).                    in'
	  print,'   date = returned date string (like 24-May-1986).      out'
	  print,' Keywords:'
	  print,'   FORMAT = format string.  Allows output date to be '+$
	    'customized.'
	  print,'      The following substitutions take place in the '+$
	    'format string:'
	  print,'   Y$ = 4 digit year.'
	  print,'   y$ = 2 digit year.'
	  print,'   N$ = full month name.'
	  print,'   n$ = 3 letter month name.'
	  print,'   d$ = day of month number.'
	  print,'   0d$ = day of month number with leading 0 if < 10.'
	  print,'   W$ = full weekday name.'
	  print,'   w$ = 3 letter week day name.'
	  print,' Notes:'
	  print,"   The default format string is 'd$-n$-Y$' giving 24-Sep-1989"
	  print,"   Example: FORMAT='w$ N$ d$, Y$' would give 'Mon "+$
	    "September 18, 1989'"
	  return, -1
	endif
 
	;---- error check -----
	w = where(y lt 0, cnt)
	if cnt gt 0 then begin
	  print,'Error in ymd2date: invalid year: ',y(w)
	  return, -1
	endif
	;-----  Handle 2 digit years  ------
	y = yy2yyyy(y)				; Fix 2 digit years.
	w = where((m lt 1) or (m gt 12),cnt)
	if cnt gt 0 then begin
	  print,'Error in ymd2date: invalid month: ',m(w)
	  return, -1
	endif
	w = where((d lt 1) or (d gt 31), cnt)
	if cnt gt 0 then begin
	  print,'Error in ymd2date: invalid month day: ', d(w)
	  return, -1
	endif
 
	;-----  format string  ------
	if n_elements(frmt) eq 0 then frmt='d$-n$-Y$' ; Default format.
 
	l_y = n_elements(y)-1		; Last element of each array.
	l_m = n_elements(m)-1
	l_d = n_elements(d)-1
	l_dates = l_y>l_m>l_d		; number of dates.
	date_arr = strarr(l_dates+1)
 
	;-----  Loop through all dates  ---------
	for i = 0, l_dates do begin
	  js0 = ymds2js(y(i<l_y),m(i<l_m),d(i<l_d),0)	; Julian Sec at 0:00.
	  date_arr(i) = dt_tm_fromjs(js0,form=frmt)	; Date string.
	endfor
 
	if l_dates eq 0 then date_arr=date_arr(0)  ; Return scalars as scalars.
 
	return, date_arr
 
	end
