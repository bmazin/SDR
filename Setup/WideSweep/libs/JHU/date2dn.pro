;-------------------------------------------------------------
;+
; NAME:
;       DATE2DN
; PURPOSE:
;       Find day of year number from date.
; CATEGORY:
; CALLING SEQUENCE:
;       dn = date2dn(date)
; INPUTS:
;       date = date string (like 6 Jul, 1995).    in
;         Default date is current date and time.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dn = day number in year (like 187).        out
; COMMON BLOCKS:
; NOTES:
;       Notes: The format of the date is flexible except that the
;         month must be month name.
;         Dashes, commas, periods, or slashes are allowed.
;         Some examples: 23 sep, 1985     sep 23 1985   1985 Sep 23
;         23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.
;         Doesn't check if month day is valid. Doesn't
;         change year number (like 86 does not change to 1986).
;         Dates may have only 2 numeric values, year and day. If
;         both year & day values are < 31 then day is assumed first.
;         systime() can be handled: dn=date2dn(systime()).
;         Day number is returned as a string.
;         For invalid dates dn is set to a null string.
;         Times are allowed.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Jul 6
;       R. Sterner, 2004 Sep 16 --- Made default be current date/time.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function date2dn, date0, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Find day of year number from date.'
	  print,' dn = date2dn(date)'
	  print,' date = date string (like 6 Jul, 1995).    in'
	  print,'   Default date is current date and time.'
	  print,' dn = day number in year (like 187).        out'
          print,' Notes: The format of the date is flexible except that the'
          print,'   month must be month name.'
          print,'   Dashes, commas, periods, or slashes are allowed.'
          print,'   Some examples: 23 sep, 1985     sep 23 1985   1985 Sep 23'
          print,'   23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.'
          print,"   Doesn't check if month day is valid. Doesn't"
          print,'   change year number (like 86 does not change to 1986).'
          print,'   Dates may have only 2 numeric values, year and day. If'
          print,'   both year & day values are < 31 then day is assumed first.'
          print,'   systime() can be handled: dn=date2dn(systime()).'
	  print,'   Day number is returned as a string.'
          print,'   For invalid dates dn is set to a null string.'
	  print,'   Times are allowed.'
          return, ''
        endif
 
	if n_elements(date0) eq 0 then date0=systime()	; Default is NOW.
	dt_tm_brk,date0,date,tm
	date2ymd,date,y,m,d		; Find year, month, day from date.
	if y lt 0 then return,''	; Invalid date, return a null string.
	dn = strtrim(ymd2dn(y,m,d),2)	; Day number.
	if tm eq '' then return, dn	; No fraction.
	frac = secstr(tm)/86400.	; Fraction of day.
	return, strtrim(dn+frac,2)
 
	end
