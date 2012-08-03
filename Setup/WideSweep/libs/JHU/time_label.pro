;-------------------------------------------------------------
;+
; NAME:
;       TIME_LABEL
; PURPOSE:
;       Make a time label array
; CATEGORY:
; CALLING SEQUENCE:
;       lbl = time_label(v, form)
; INPUTS:
;       v = Array of values in seconds.   in
;       form = Time date format string.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         JD=jd  Set Julian Day of reference date.
;           If not given the 1-Jan-2000 is used.
; OUTPUTS:
;       lbl = String array of labels.     out
; COMMON BLOCKS:
; NOTES:
;       Notes: The input time array is really an array
;         of seconds from 0:00 on the reference date given
;         by JD=jd.  If format string does not specify a
;         date output then JD=jd need not be given, it
;         defaults to 1-Jan-2000.  When d$ is given in the
;         format string this just counts from day 1 up (to 31).
;         For a description of the time format string
;         see the routine dt_tm_mak.
; MODIFICATION HISTORY:
;       R. Sterner. 18 Nov, 1988.
;       R. Sterner, 22 Feb, 1991 --- Converted to IDL V2.
;       R. Sterner, 26 Feb, 1991 --- Renamed from make_time_labels.pro
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION TIME_LABEL, V, form, help=hlp, jd=jd0
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a time label array'
	  print,' lbl = time_label(v, form)'
	  print,'   v = Array of values in seconds.   in'
	  print,'   form = Time date format string.   in'
	  print,'   lbl = String array of labels.     out'
	  print,' Keywords:'
	  print,'   JD=jd  Set Julian Day of reference date.'
	  print,'     If not given the 1-Jan-2000 is used.'
	  print,' Notes: The input time array is really an array'
	  print,'   of seconds from 0:00 on the reference date given'
	  print,'   by JD=jd.  If format string does not specify a'
	  print,'   date output then JD=jd need not be given, it'
	  print,'   defaults to 1-Jan-2000.  When d$ is given in the'
	  print,'   format string this just counts from day 1 up (to 31).'
	  print,'   For a description of the time format string'
	  print,'   see the routine dt_tm_mak.
	  return,-1
	endif
 
	n = n_elements(v)
 
	s = strarr(n)
 
	if n_elements(form) eq 0 then form = 'h$:m$'
	if n_elements(jd0) eq 0 then jd0 = 2451545
 
	for i = 0, n-1 do begin
	  s(i) = dt_tm_mak( jd0, v(i), form=form)
	endfor
 
	return, s
	end
