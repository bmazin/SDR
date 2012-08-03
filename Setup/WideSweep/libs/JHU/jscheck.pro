;-------------------------------------------------------------
;+
; NAME:
;       JSCHECK
; PURPOSE:
;       Check accuracy of "Julian Seconds" over a given time span.
; CATEGORY:
; CALLING SEQUENCE:
;       jscheck
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Julian seconds (not an official unit) serve the
;         same purpose as Julian Days, interval computations.
;         The zero point is 0:00 1 Jan 2000, so js < 0 before then.
;         Julian Seconds are double precision and have a precision
;         better than 1 millisecond over a span of +/- 1000 years.
;       
;       See also ymds2js, js2ymds, dt_tm_fromjs, dt_tm_tojs.
; MODIFICATION HISTORY:
;       R. Sterner, 3 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro jscheck, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Check accuracy of "Julian Seconds" over a given time span.'
	  print,' jscheck'
	  print,'   No args, prompts for time span in years'
          print,' Notes: Julian seconds (not an official unit) serve the'
          print,'   same purpose as Julian Days, interval computations.'
          print,'   The zero point is 0:00 1 Jan 2000, so js < 0 before then.'
          print,'   Julian Seconds are double precision and have a precision'
          print,'   better than 1 millisecond over a span of +/- 1000 years.'
          print,' '
          print,' See also ymds2js, js2ymds, dt_tm_fromjs, dt_tm_tojs.'
	  return
	endif
 
	print,' '
	print,' Check accuracy of Julian Seconds over a given time span.'
	txt = ''
loop:	print,' '
	read,' Enter time span in years: ',txt
	if txt eq '' then return
	y = double(txt)
	sec = 365.25d0*24*60*60*y	; Seconds in time span (very close).
	err = dblarr(1000)		; Error array.
	for i=0,999 do err(i) = ((sec+i*1e-3)-sec)-i*1e-3
	print,' The worst case error between the desired time and the'
	print,' time stored as Julian Seconds is '
	print,max(abs(err))*1e3,' milliseconds.'
	goto, loop
 
	end
