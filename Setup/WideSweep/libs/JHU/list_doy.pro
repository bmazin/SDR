;-------------------------------------------------------------
;+
; NAME:
;       LIST_DOY
; PURPOSE:
;       List day of year for current and nearby dates.
; CATEGORY:
; CALLING SEQUENCE:
;       list_doy, date
; INPUTS:
;       date = date of interest (def=current).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBER=num  number of dates to list (def=7).
;         OUT=txt Returned listing text.
;         /REVERSE list dates from earlier to later.
;         /QUIET do not list to screen.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Lists day of year for dates centered on
;       current date or given date of interest.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Sep 16
;       R. Sterner, 2004 Sep 22 --- Added /REVERSE, /QUIET, OUT=txt
;       R. Sterner, 2004 Sep 27 --- Added week day to date.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro list_doy, date0, number=num, out=txt, $
	  reverse=rev, quiet=quiet, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' List day of year for current and nearby dates.'
	  print,' list_doy, date'
	  print,'   date = date of interest (def=current).  in'
	  print,' Keywords:'
	  print,'   NUMBER=num  number of dates to list (def=7).'
	  print,'   OUT=txt Returned listing text.'
	  print,'   /REVERSE list dates from earlier to later.'
	  print,'   /QUIET do not list to screen.'
	  print,' Notes: Lists day of year for dates centered on'
	  print,' current date or given date of interest.'
	  return
	endif
 
	if n_elements(date0) eq 0 then date0=systime()
	if n_elements(num) eq 0 then num=7
 
	off = indgen(num)-fix(num)/2	; Offset in days to list.
	date2ymd, date0, yy, mm, dd	; Reference date to y,m,d.
	js0 = ymds2js(yy,mm,dd,0)	; JS of reference date.
	js = js0 + off*86400D0		; JS of days to list.
	date = dt_tm_fromjs(js,form='Y$ n$ 0d$ w$')  ; Date.
	doy = dt_tm_fromjs(js,form='doy$')	  ; Day number.
	if keyword_set(rev) then begin
	  lo = 0
	  hi = n_elements(date)-1
	  st = 1
	endif else begin
	  lo = n_elements(date)-1
	  hi = 0
	  st = -1
	endelse
 
	tprint,/init
	tprint,' '
	tprint,'      Date         DOY'
	tprint,' ---------------   ---'
	for i=lo,hi,st do tprint,' '+date(i)+' = '+doy(i)
	tprint,out=txt
	if not keyword_set(quiet) then tprint,/print
 
	end
