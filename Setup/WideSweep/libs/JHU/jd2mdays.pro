;-------------------------------------------------------------
;+
; NAME:
;       JD2MDAYS
; PURPOSE:
;       Convert a range of Julian Days to month start and end JDs.
; CATEGORY:
; CALLING SEQUENCE:
;       jd2mdays, jd1, jd2, mjds, mjde
; INPUTS:
;       jd1, jd2 = first and last Julian day of a time range.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         APPROX_MAJOR=amaj Approximate number of days between
;           major tick marks.  Used to derive actual # days.
;         MAJOR_V=majv  Array of labeled tick mark values in
;           Julian Days.
;         MINOR_V=majv  Array of minor tick mark values in
;           Julian Days.
;         FORMAT=frm    Returned suggested format for time labels.
; OUTPUTS:
;       mjds = array of Julian days for the first of each      out
;         month covered by the range.
;       mjde = array of Julian days for the end of each        out
;         month covered by the range.
; COMMON BLOCKS:
; NOTES:
;       Notes: intended for time axes involving month labels.
;         Ex: if jd1 is for 29-Jan-1992 and jd2 is for 13-Jun-1993
;         then mjds and mjde each have 18 elements giving the
;         Julian day numbers for the start and end of each of the
;         18 months from Jan 1992 to Jun 1993 inclusive.
; MODIFICATION HISTORY:
;       R. Sterner, 29 Apr, 1993
;       R. Sterner, 1994 Mar 30 --- Extended time range upward.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
	pro jd2mdays, jd1, jd2, mjds, mjde, approx_maj=amaj, $
	  major_v=majv, minor_v=minv, format=frm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert a range of Julian Days to month start and end JDs.'
	  print,' jd2mdays, jd1, jd2, mjds, mjde'
	  print,'   jd1, jd2 = first and last Julian day of a time range.  in'
	  print,'   mjds = array of Julian days for the first of each      out'
	  print,'     month covered by the range.'
	  print,'   mjde = array of Julian days for the end of each        out'
	  print,'     month covered by the range.'
	  print,' Keywords:'
	  print,'   APPROX_MAJOR=amaj Approximate number of days between'
	  print,'     major tick marks.  Used to derive actual # days.'
	  print,'   MAJOR_V=majv  Array of labeled tick mark values in'
	  print,'     Julian Days.'
	  print,'   MINOR_V=majv  Array of minor tick mark values in'
	  print,'     Julian Days.'
	  print,'   FORMAT=frm    Returned suggested format for time labels.'
	  print,' Notes: intended for time axes involving month labels.'
	  print,'   Ex: if jd1 is for 29-Jan-1992 and jd2 is for 13-Jun-1993'
	  print,'   then mjds and mjde each have 18 elements giving the'
	  print,'   Julian day numbers for the start and end of each of the'
	  print,'   18 months from Jan 1992 to Jun 1993 inclusive.'
	  return
	endif
 
	;--------  Initialize  ------------
	jd2ymd, jd1, y, m, d		    ; Convert 1st JD to yr, mnth, day.
	mjds = [ymd2jd(y,m,1)]		    ; 1st value in month start array.
	mjde = [ymd2jd(y,m,monthdays(y,m))] ; 1st value in month end array.
 
	;--------  Loop through time range  ----------
loop:	m = m + 1			    ; Next month.
	if m gt 12 then begin		    ; Next year.
	  y = y + 1
 	  m = 1
	endif
	jd = ymd2jd(y,m,1)		    ; Next first of month.
	if jd gt jd2 then goto, next	    ; Got all values.
	mjds = [mjds,jd]		    ; Add new start to list.
	mjde = [mjde,ymd2jd(y,m,monthdays(y,m))]   ; Add new end to list.
	goto, loop
 
	;-------  Find major and minor tick marks  --------
next:	if n_elements(amaj) eq 0 then return
	if amaj lt 1. then amaj = 1.
 
	;-------  Filter down through tick spacing values  ---------
	;-------  Boundaries are geometric means between spacings  -----
	dx = 720 	; Major tick spacing.  Values are in days.
	dx2 = 360 	; Minor tick spacing.
	frm = 'y$'
	if amaj lt 1800  then begin dx=360 & dx2=180 & frm = 'n$ y$' & end
	if amaj lt 255   then begin dx=180 & dx2=90  & frm = 'n$ y$' & end
	if amaj lt 147   then begin dx=120 & dx2=60  & frm = 'n$ y$' & end
	if amaj lt 104   then begin dx=90  & dx2=30  & frm = 'n$ y$' & end
	if amaj lt 73.48 then begin dx=60  & dx2=30  & frm = 'n$ y$' & end
	if amaj lt 42.43 then begin dx=30  & dx2=10  & frm = 'd$ n$ y$' & end
	if amaj lt 21.21 then begin dx=15  & dx2=5   & frm = 'd$ n$ y$' & end
	if amaj lt 12.25 then begin dx=10  & dx2=5   & frm = 'd$ n$ y$' & end
	if amaj lt  7.07 then begin dx=5   & dx2=1   & frm = 'd$ n$ y$' & end
	if amaj lt  3.16 then begin dx=2   & dx2=1   & frm = 'd$ n$' & end
	if amaj lt  1.41 then begin dx=1   & dx2=1   & frm = 'd$ n$' & end
 
	;--------  Generate tick values  --------------
	if dx le 30 then begin
	  ;---------- Labeled tick spacing LE 30 days  ----------
	  majv = [0L]	; Major tick values array seed.
	  minv = [0L]	; Major tick values array seed.
	  for i = 0, n_elements(mjds)-1 do begin
	    lo = mjds(i)-1+dx	; Start at day 0 + dx (skips 0).
	    hi=mjde(i)-(dx<2)	; Stop before end.
	    if dx le 2 then hi=mjde(i)	; For 1 day steps do all.
	    if lo lt hi then begin
	      majv = [majv, mjds(i),makei(lo,hi,dx)]
	    endif else begin
	      majv = [majv, mjds(i)]
	    endelse
	    lo = mjds(i)-1+dx2
	    hi = mjde(i)
	    if lo lt hi then begin
	      minv = [minv, mjds(i),makei(lo,hi,dx2)]
	    endif else begin
	      minv = [minv, mjds(i)]
	    endelse
	  endfor
	endif else begin
	  ;--------  Labeled tick spacing GT 30 days  -----------
	  minv = mjds	; Assume minor ticks are all month start JD.
	  if dx eq 60 then begin
	    majv = jdselect(mjds,['jan','mar','may','jul','sep','nov'],/mon)
	  endif
	  if dx eq 90 then begin
	    majv = jdselect(mjds,['jan','apr','jul','oct'],/mon)
	  endif
	  if dx eq 180 then begin
	    majv = jdselect(mjds,['jan','jul'],/mon)
	    minv = jdselect(mjds,['apr','oct'],/mon)
	  endif
	  if dx eq 360 then begin
	    majv = jdselect(mjds,['jan'],/mon)
	    minv = jdselect(mjds,['apr','jul','oct'],/mon)
	  endif
	  if dx eq 720 then begin
	    majv = jdselect(mjds,['jan'],/mon)
	    minv = jdselect(mjds,['jul'],/mon)
	  endif
	endelse
 
	;--------  Trim tick values to range  ----------
	w = where((jd1 le majv) and (jd2 ge majv), c)
	if c gt 0 then majv = majv(w)
	w = where((jd1 le minv) and (jd2 ge minv), c)
	if c gt 0 then minv = minv(w)
 
	end
