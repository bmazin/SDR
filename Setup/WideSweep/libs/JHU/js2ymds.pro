;-------------------------------------------------------------
;+
; NAME:
;       JS2YMDS
; PURPOSE:
;       Convert from "Julian Second" to year, month, day, second.
; CATEGORY:
; CALLING SEQUENCE:
;       js2ymds, js, y, m, d, s or js2ymds, js, y, m, d, h, mn, s
; INPUTS:
;       js = "Julian Second".                       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y,m,d = year, month, day numbers.           out
;       h, mn, s = hour, minute, second into day.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Julian seconds (not an official unit) serve the
;         same purpose as Julian Days, interval computations.
;         The zero point is 0:00 1 Jan 2000, so js < 0 before then.
;         Julian Seconds are double precision and have a precision
;         better than 1 millisecond over a span of +/- 1000 years.
;         A precision warning may point to a call to dt_tm_fromjs.
;       
;       See also ymds2js, dt_tm_tojs, dt_tm_fromjs, jscheck.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Sep, 1992
;       R. Sterner, 13 Dec, 1992 --- added data type check.
;       R. Sterner, 2001 Oct 15 --- Now allows h, m, s.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro js2ymds, js, y, m, d, s, t2, t3, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from "Julian Second" to year, month, day, second.'
	  print,' js2ymds, js, y, m, d, s or js2ymds, js, y, m, d, h, mn, s'
	  print,'   js = "Julian Second".                       in'
	  print,'   y,m,d = year, month, day numbers.           out'
	  print,'   h, mn, s = hour, minute, second into day.   out'
	  print,' Notes: Julian seconds (not an official unit) serve the'
	  print,'   same purpose as Julian Days, interval computations.'
	  print,'   The zero point is 0:00 1 Jan 2000, so js < 0 before then.'
	  print,'   Julian Seconds are double precision and have a precision'
	  print,'   better than 1 millisecond over a span of +/- 1000 years.'
	  print,'   A precision warning may point to a call to dt_tm_fromjs.'
	  print,' '
	  print,' See also ymds2js, dt_tm_tojs, dt_tm_fromjs, jscheck.'
	  return
	endif
 
	sz = size(js)
	if sz(sz(0)+1) ne 5 then begin
	  print,' Warning in js2ymds: Julian Seconds should be passed in'
	  print,'   as double precision.  Precision degraded.'
	endif
	days = floor(js/86400)
	t = js - 86400D0*days
	jd2ymd, days+2451545, y, m, d
 
	if n_params(0) eq 7 then begin
	  sechms, t, s, t2, t3		; Resolve seconds into day into h,m,s.
	endif else begin
	  s = t				; Seconds into day.
	endelse
	
	return
	end
