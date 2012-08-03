;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_FROMJS
; PURPOSE:
;       Convert "Julian Seconds" to a date/time string.
; CATEGORY:
; CALLING SEQUENCE:
;       dt = dt_tm_fromjs(js)
; INPUTS:
;       js = "Julian Seconds".      in
; KEYWORD PARAMETERS:
;       Keywords: 
;         FORMAT=fmt format for dt (see dt_tm_mak).
;           Def = "Y$ n$ d$ h$:m$:s$ w$"
;         /FRACTION displays fraction of second in default format.
;         DECIMAL=dp  Number of decimal places to use for fraction of
;           second (def=3) for f$ in format.  f4 will include dec pt.
;         DENOMINATOR=den If given then fraction is listed as nnn/ddd
;           ddd is given by den.  Over-rides DECIMAL keyword.  Ex:
;           DENOM=1000 might give 087/1000 for f$ in format.
;         DDECIMAL=ddp  Number of decimal places to use in day
;           of year (if doy$ included in format, def=none).
;         YEAR=yy returns extracted year.
;         MONTH=mm returns extracted month.
;         DAY=dd returns extracted day.
;         SECOND=ss returns extracted seconds after midnight.
;         JD=jd  returns extracted Julian Day of date.
;         NUMBERS=st Returned structure with numeric values.
; OUTPUTS:
;       dt = date/time string.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Julian seconds (not an official unit) serve the
;         same purpose as Julian Days, interval computations.
;         The zero point is 0:00 1 Jan 2000, so js < 0 before then.
;         Julian Seconds are double precision and have a precision
;         better than 1 millisecond over a span of +/- 1000 years.
;       
;       See also dt_tm_tojs, ymds2js, js2ymds, jscheck.
; MODIFICATION HISTORY:
;       R. Sterner, 3 Sep, 1992
;       R. Sterner, 18 Aug, 1993 --- Added JD keyword.
;       R. Sterner, 2 Dec, 1993 --- Changed default format.
;       R. Sterner, 1998 Apr 15 --- Returned NUMBERS structure.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function dt_tm_fromjs, js, format=form, help=hlp, $
	  year=year, month=mm, day=dd, second=ss, jd=jd, $
	  ddecimal=ddec, decimal=dec, denominator=den, fraction=fr, $
	  numbers=st
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert "Julian Seconds" to a date/time string.'
	  print,' dt = dt_tm_fromjs(js)'
	  print,'   js = "Julian Seconds".      in'
	  print,'   dt = date/time string.      out'
	  print,' Keywords: '
	  print,'   FORMAT=fmt format for dt (see dt_tm_mak).'
	  print,'     Def = "Y$ n$ d$ h$:m$:s$ w$"'
	  print,'   /FRACTION displays fraction of second in default format.'
	  print,'   DECIMAL=dp  Number of decimal places to use for fraction of'
	  print,'     second (def=3) for f$ in format.  f4 will include dec pt.'
	  print,'   DENOMINATOR=den If given then fraction is listed as nnn/ddd'
	  print,'     ddd is given by den.  Over-rides DECIMAL keyword.  Ex:'
	  print,'     DENOM=1000 might give 087/1000 for f$ in format.'
	  print,'   DDECIMAL=ddp  Number of decimal places to use in day'
	  print,'     of year (if doy$ included in format, def=none).'
	  print,'   YEAR=yy returns extracted year.'
	  print,'   MONTH=mm returns extracted month.'
	  print,'   DAY=dd returns extracted day.'
	  print,'   SECOND=ss returns extracted seconds after midnight.'
	  print,'   JD=jd  returns extracted Julian Day of date.'
	  print,'   NUMBERS=st Returned structure with numeric values.'
          print,' Notes: Julian seconds (not an official unit) serve the'
          print,'   same purpose as Julian Days, interval computations.'
          print,'   The zero point is 0:00 1 Jan 2000, so js < 0 before then.'
          print,'   Julian Seconds are double precision and have a precision'
          print,'   better than 1 millisecond over a span of +/- 1000 years.'
	  print,' '
	  print,' See also dt_tm_tojs, ymds2js, js2ymds, jscheck.'
	  return, -1
	endif
 
	js2ymds, js, year, mm, dd, ss
	jd = ymd2jd(year,mm,dd)
	fm = "Y$ n$ d$ h$:m$:s$ w$"
	if keyword_set(fr) then begin
	  fm = "Y$ n$ d$ h$:m$:s$f$ w$"
	  if keyword_set(den) then fm = "Y$ n$ d$ h$:m$:s$ f$ w$"
	endif
	if n_elements(form) ne 0 then fm = form
	out = dt_tm_mak(jd, ss, form=fm,dec=dec,den=den,ddec=ddec, numbers=st)
	return, out
 
	end
