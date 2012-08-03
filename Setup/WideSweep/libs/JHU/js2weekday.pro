;-------------------------------------------------------------
;+
; NAME:
;       JS2WEEKDAY
; PURPOSE:
;       Compute weekday given Julian Second.
; CATEGORY:
; CALLING SEQUENCE:
;       wd = js2weekday(js)
; INPUTS:
;       js = Julian Second (sec after 0:00 Jan 1 2000).      in
;          May be a scalar or array of values.
; KEYWORD PARAMETERS:
;       Keywords:
;         /NAME  Returned name of weekday instead of
;           number: Sunday, Monday, ...
; OUTPUTS:
;       wd = Weekday number (Sun=1, Mon=2, ... Sat=7).       out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Dec 31
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function js2weekday, js, name=name, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute weekday given Julian Second.'
	  print,' wd = js2weekday(js)'
	  print,'   js = Julian Second (sec after 0:00 Jan 1 2000).      in'
	  print,'      May be a scalar or array of values.'
	  print,'   wd = Weekday number (Sun=1, Mon=2, ... Sat=7).       out'
	  print,' Keywords:'
	  print,'   /NAME  Returned name of weekday instead of
	  print,'     number: Sunday, Monday, ...'
	  return, ''
	endif
 
	names = ['','Sunday','Monday','Tuesday',$
		 'Wednesday','Thursday','Friday','Saturday']
 
	nwd = (round(js2jd(js) + 1.5) mod 7) + 1
 
	if keyword_set(name) then return, names(nwd)
 
	return, nwd
 
	end
