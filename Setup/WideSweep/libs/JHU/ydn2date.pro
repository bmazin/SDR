;-------------------------------------------------------------
;+
; NAME:
;       YDN2DATE
; PURPOSE:
;       Convert year and day of the year to a date string.
; CATEGORY:
; CALLING SEQUENCE:
;       date = ydn2date(Year, dn)
; INPUTS:
;       Year = year.                      in
;       dn = day of the year.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  (see dt_tm_mak(/help)).
; OUTPUTS:
;       date = returned date string.      out
;              (like 1984 Apr 25 06:00:00 Wed).
; COMMON BLOCKS:
; NOTES:
;       Notes: Default format has changed.  If this causes
;         problems add form='d$-n$-Y$' to ydn2date call for
;         old format.
; MODIFICATION HISTORY:
;       Ray Sterner,    25 APR, 1986.
;       Johns Hopkins University Applied Physics Laboratory
;       R. Sterner, 1994 May 27 --- Renamed from dn2date.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ydn2date, yr, dn0, help=hlp, format=frmt
 
	if (n_params(0) lt 2) or keyWord_set(hlp) then begin
	  print,' Convert year and day of the year to a date string.'
	  print,' date = ydn2date(Year, dn)'
	  print,'   Year = year.                      in'
	  print,'   dn = day of the year.             in'
	  print,'   date = returned date string.      out'
	  print,'          (like 1984 Apr 25 06:00:00 Wed).
	  print,' Keywords:' 
	  print,'   FORMAT = format string.  (see dt_tm_mak(/help)).'
	  print,' Notes: Default format has changed.  If this causes'
	  print,"   problems add form='d$-n$-Y$' to ydn2date call for"
	  print,'   old format.'
	  return, -1
	endif
 
	dn = fix(dn0)
	frac = dn0-dn
 
	ydn2md,yr,dn,m,d
	if m lt 0 then begin
	  print,' Error in month in dn2date.'
	  m = 0
	endif
	s = frac*86400
 
	js = ymds2js(yr,m,d,s)
	dt = dt_tm_fromjs(js,format=frmt)
 
	return, dt
 
	end
