;-------------------------------------------------------------
;+
; NAME:
;       JD2JS
; PURPOSE:
;       Convert from Julian Day Number to Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       js = jd2js(jd)
; INPUTS:
;       jd = Julian Day Number.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js = Equivalent Julian Second.    out
; COMMON BLOCKS:
; NOTES:
;       Notes: JS are seconds after 2000 Jan 1 0:00.
;       >>>==> Julian Day Number starts at noon. Example:
;       JD of 2450814 is 1997 Dec 31 12:00:00 Wed.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Oct 13
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function jd2js, jd, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert from Julian Day Number to Julian Seconds.'
	  print,' js = jd2js(jd)'
	  print,'   jd = Julian Day Number.           in'
 	  print,'   js = Equivalent Julian Second.    out'
	  print,' Notes: JS are seconds after 2000 Jan 1 0:00.'
          print,' >>>==> Julian Day Number starts at noon. Example:'
          print,' JD of 2450814 is 1997 Dec 31 12:00:00 Wed.'
	  return,''
	endif
 
	jd2000 = ymd2jd(2000,1,1) - 0.5d0	; JD at 2000 Jan 1 0:00.
	js = (jd-jd2000)*86400d0		; JS.
 
	;------  Round to nearest millisecond -----
	t = js*1000+.5
	return, (t-(t mod 1))/1000
 
	end
