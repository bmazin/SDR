;-------------------------------------------------------------
;+
; NAME:
;       JD2DATE
; PURPOSE:
;       Convert a Julian Day number to a date string.
; CATEGORY:
; CALLING SEQUENCE:
;       date = jd2date(jd)
; INPUTS:
;       jd = Julian Day number.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  Allows output date to be customized.
;            The following substitutions take place in the format string:
;         Y$ = 4 digit year.
;         y$ = 2 digit year.
;         N$ = full month name.
;         n$ = 3 letter month name.
;         d$ = day of month number.
;         W$ = full weekday name.
;         w$ = 3 letter week day name.
; OUTPUTS:
;       date = returned date string.  out
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         The default format string is 'd$-n$-Y$' giving 24-Sep-1989
;         Example: FORMAT='w$ N$ d$, Y$' would give 'Mon 
; MODIFICATION HISTORY:
;       R. Sterner, 27 Feb, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function jd2date, jd, form=frm, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a Julian Day number to a date string.'
	  print,' date = jd2date(jd)'
	  print,'   jd = Julian Day number.       in'
	  print,'   date = returned date string.  out'
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
          print,'   W$ = full weekday name.'
          print,'   w$ = 3 letter week day name.'
          print,' Notes:'
          print,"   The default format string is 'd$-n$-Y$' giving 24-Sep-1989"
          print,"   Example: FORMAT='w$ N$ d$, Y$' would give 'Mon "+$
            "September 18, 1989'"
          RETURN, -1
	endif
 
	if n_elements(frm) eq 0 then frm='d$-n$-Y$'
 
	jd2ymd, jd, y, m, d
	return, ymd2date(y,m,d,form=frm)
	end
