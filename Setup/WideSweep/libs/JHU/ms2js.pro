;-------------------------------------------------------------
;+
; NAME:
;       MS2JS
; PURPOSE:
;       Convert MicroSoft internal time to Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       js = ms2js(ms_time)
; INPUTS:
;       ms_time = 64-bit MS time (UT).        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js = returned Julian Seconds (Local). out
; COMMON BLOCKS:
;       ms2js_com
; NOTES:
;       Note: MS time is in 100 ns ticks from 1601 Jan 01 0:00.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Aug 12
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ms2js, ms_time, help=hlp
 
	common ms2js_com, ms_js0
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert MicroSoft internal time to Julian Seconds.'
	  print,' js = ms2js(ms_time)'
	  print,'   ms_time = 64-bit MS time (UT).        in'
	  print,'   js = returned Julian Seconds (Local). out'
	  print,' Note: MS time is in 100 ns ticks from 1601 Jan 01 0:00.'
	  return,''
	endif
 
	if n_elements(ms_js0) eq 0 then ms_js0=dt_tm_tojs('1601 Jan 1 0:00')
 
	return, ms_time/1D7+ms_js0-gmt_offsec()
 
	end
