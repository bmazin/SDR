;-------------------------------------------------------------
;+
; NAME:
;       YMDS2JS
; PURPOSE:
;       Convert to year, month, day, second to "Julian Second".
; CATEGORY:
; CALLING SEQUENCE:
;       js = ymds2js(y,m,d,s)
; INPUTS:
;       y,m,d = year, month, day numbers.   in
;       s = second into day.                in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js = "Julian Second".               out
; COMMON BLOCKS:
; NOTES:
;       Notes: Julian seconds (not an official unit) serve the
;         same purpose as Julian Days, interval computations.
;         The zero point is 0:00 1 Jan 2000, so js < 0 before then.
;         Julian Seconds are double precision and have a precision
;         better than 1 millisecond over a span of +/- 1000 years.
;       
;       See also js2ymds, dt_tm_fromjs, dt_tm_tojs, jscheck.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ymds2js, y, m, d, s, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert to year, month, day, second to "Julian Second".'
	  print,' js = ymds2js(y,m,d,s)'
	  print,'   y,m,d = year, month, day numbers.   in'
	  print,'   s = second into day.                in'
	  print,'   js = "Julian Second".               out'
	  print,' Notes: Julian seconds (not an official unit) serve the'
	  print,'   same purpose as Julian Days, interval computations.'
	  print,'   The zero point is 0:00 1 Jan 2000, so js < 0 before then.'
	  print,'   Julian Seconds are double precision and have a precision'
	  print,'   better than 1 millisecond over a span of +/- 1000 years.'
	  print,' '
	  print,' See also js2ymds, dt_tm_fromjs, dt_tm_tojs, jscheck.'
	  return, -1
	endif
 
	return, s + (ymd2jd(y,m,d)-2451545)*86400d0
 
	end
