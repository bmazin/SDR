;-------------------------------------------------------------
;+
; NAME:
;       JDSELECT
; PURPOSE:
;       Select Julian Day array subset by month or weekday.
; CATEGORY:
; CALLING SEQUENCE:
;       jd_out = jdselect(jd_in, list)
; INPUTS:
;       jd_in = Array of potential Julian Days.     in
;       list = Text array listing desired values.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /MONTH means match months in list.
;         /DAY   means match weekdays in list.
; OUTPUTS:
;       jd_out = Julian Days that match list.       out
; COMMON BLOCKS:
; NOTES:
;       Notes: list consists of either a text array of month
;         or weekday names, at least 3 characters long.
;         Ex: JD2=jdselect(JD1,/mon,['jan','apr','jul','oct'])
; MODIFICATION HISTORY:
;       R. Sterner, 20 May, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function jdselect, jdin, match, months=month, days=day, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Select Julian Day array subset by month or weekday.'
	  print,' jd_out = jdselect(jd_in, list)'
	  print,'   jd_in = Array of potential Julian Days.     in'
	  print,'   list = Text array listing desired values.   in'
	  print,'   jd_out = Julian Days that match list.       out'
	  print,' Keywords:'
	  print,'   /MONTH means match months in list.'
	  print,'   /DAY   means match weekdays in list.'
	  print,' Notes: list consists of either a text array of month'
	  print,'   or weekday names, at least 3 characters long.'
	  print,"   Ex: JD2=jdselect(JD1,/mon,['jan','apr','jul','oct'])"
	  return, ''
	endif
 
	list = strupcase(strmid(match,0,3))	; Force 3 char, upper case.
 
	jd2 = [0L]				; No match.
 
	;------------  Set format  -------------
	frm = ''				; Set format to null.
	if keyword_set(month) then frm = 'n$'	; Set format to month.
	if keyword_set(day) then frm = 'w$'	; Set format to weekday.
	if frm eq '' then return,0		; No keyword given.
 
	;------  Loop through JDs looking for matches.  -------
	for i = 0, n_elements(jdin)-1 do begin
	  jd = jdin(i)
	  t = strupcase(dt_tm_mak(jd,form=frm))
	  w = where(t(0) eq list, c)
	  if c gt 0 then jd2 = [jd2,jd]
	endfor
 
	if n_elements(jd2) ge 2 then jd2 = jd2(1:*)
 
	return, jd2
 
	end
