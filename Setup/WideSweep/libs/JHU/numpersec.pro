;-------------------------------------------------------------
;+
; NAME:
;       NUMPERSEC
; PURPOSE:
;       Given values increasing with time return rate per second.
; CATEGORY:
; CALLING SEQUENCE:
;       rate = numpersec(num)
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DELTA=nsec  Initialize minimum estimate interval (sec).
;           Must do first, also give first value on init call:
;           Ex: rate0 = numpersec(0,delta=60). Ignore rate0.
; OUTPUTS:
; COMMON BLOCKS:
;       numpersec_com
; NOTES:
;       Notes: will only do a new estimate every delta seconds,
;        else returns previous estimate.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Jun 7
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function numpersec, num, delta=delta0, help=hlp
 
	common numpersec_com, last_num, last_time, last_rate, delta_sec
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Given values increasing with time return rate per second.'
	  print,' rate = numpersec(num)'
	  print,'   num = the current numeric value of an increasing item.'
	  print,'   rate = the returned rate estimate.'
	  print,' Keywords:'
	  print,'   DELTA=nsec  Initialize minimum estimate interval (sec).'
	  print,'     Must do first, also give first value on init call:'
	  print,'     Ex: rate0 = numpersec(0,delta=60). Ignore rate0.'
	  print,' Notes: will only do a new estimate every delta seconds,'
	  print,'  else returns previous estimate.'
	  return,''
	endif
 
	cur_time = dt_tm_tojs(systime())		; Current time as JS.
 
	;-----  DELTA was given, initialize  -------
	if n_elements(delta0) ne 0 then begin
	  delta_sec = delta0
	  last_num = num
	  last_time = cur_time
	  last_rate = 0.
	endif
 
	;----  Make sure init was done  ---------
	if n_elements(delta_sec) eq 0 then begin
	  print,' Error in numpersec: must initialize first.'
	  print,' Ex: rate0 = numpersec(0,delta=60), ignore rate0.'
	  return,0.
	endif
 
	delta = cur_time - last_time
	diff = num - last_num
	if diff lt 0 then begin
	  print,' Error in numpersec: input value must increase.'
	  return, 0.
	endif
 
	if delta ge delta_sec then begin
	  rate = diff/delta
	  last_num = num
	  last_time = cur_time
	  last_rate = rate
	  return, rate
	endif else begin
	  return, last_rate
	endelse
 
	end
