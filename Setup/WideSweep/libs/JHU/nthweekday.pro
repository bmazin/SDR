;-------------------------------------------------------------
;+
; NAME:
;       NTHWEEKDAY
; PURPOSE:
;       Julian Day of N'th weekday of month (like 2nd tues).'
; CATEGORY:
; CALLING SEQUENCE:
;       jd = nthweekday(yr,mn,wd,n)
; INPUTS:
;       yr = year number (like 1991).       in
;       mn = month number (like 12).        in
;       wd = weekday number.                in
;         Sun=1, Mon=2, ... Sat=7.
;       n = occurance number.               in
;         1st=1, 2nd=2, ...
; KEYWORD PARAMETERS:
;       Keywords:
;         /LAST  means last occurance.  If n is given
;           it may be < 0 to offset from last like:
;           next to last monday, n=-1, wd=2, /LAST.
;           If /LAST is used and n > 0 then dates beyond
;           the end of the month will be found.  Ex:
;           n=1, wd=2, /LAST gives the next monday after
;           the last monday in the month.
; OUTPUTS:
;       jd = Julian Day of desired date.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 31 Jan, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function nthweekday, yr, mn, wd, n, last=last, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print," Julian Day of N'th weekday of month (like 2nd tues).'
	  print,' jd = nthweekday(yr,mn,wd,n)'
	  print,'   yr = year number (like 1991).       in'
	  print,'   mn = month number (like 12).        in'
	  print,'   wd = weekday number.                in'
	  print,'     Sun=1, Mon=2, ... Sat=7.'
	  print,'   n = occurance number.               in'
	  print,'     1st=1, 2nd=2, ...'
	  print,'   jd = Julian Day of desired date.    out'
	  print,' Keywords:'
	  print,'   /LAST  means last occurance.  If n is given'
	  print,'     it may be < 0 to offset from last like:'
	  print,'     next to last monday, n=-1, wd=2, /LAST.'
	  print,'     If /LAST is used and n > 0 then dates beyond'
	  print,'     the end of the month will be found.  Ex:'
	  print,'     n=1, wd=2, /LAST gives the next monday after'
	  print,'     the last monday in the month.'
	  return, -1
	endif
 
 
	;----------  Offset from front of month  -----------------------
	if not keyword_set(last) then begin
	  if n_elements(n) eq 0 then n=1  ; Default = first occ.
	  jd0 = ymd2jd(yr, mn, 1)	  ; jd of first day of month.
	  tmp = weekday(yr, mn, 1, wd0)	  ; Weekday # of first day of month.
	  d = wd - wd0			  ; Offset from first day of month.
	  if d lt 0 then d = d + 7	  ; Step to first occurance of wd.
	  jd = jd0 + d			  ; JD of first occ.
	  jd = jd + (n-1)*7		  ; Step to correct date.
	  return, jd			  ; JD of n'th occurance.
	endif
 
	;----------  Offset from end of month (/LAST) -------------------
	if n_elements(n) eq 0 then n=0    ; Default no offset from last.
	days = monthdays(yr, mn)	  ; Days in month.
	jd0 = ymd2jd(yr, mn, days)	  ; JD of last day of month.
	tmp = weekday(yr, mn, days, wd0)  ; Weekday # of last day of month.
	d = wd - wd0			  ; Offset from last day of month.
	if d gt 0 then d = d - 7	  ; Step to last occurance of wd.
	jd = jd0 + d			  ; JD of last occ.
	jd = jd + n*7			  ; Step to correct date.
	return, jd
 
	end
