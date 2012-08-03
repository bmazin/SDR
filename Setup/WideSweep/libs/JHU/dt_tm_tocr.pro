;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_TOCR
; PURPOSE:
;       Convert from Date/Time to Carrington Rotation Number.
; CATEGORY:
; CALLING SEQUENCE:
;       cr = dt_tm_tocr(dt_tm)
; INPUTS:
;       dt_tm = date/time string (or JS).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       cr = Carrington Rotation Number.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: Time is Ephemeris Time which is almost UT.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Jun 21
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function dt_tm_tocr, dt_tm, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert from Date/Time to Carrington Rotation Number.'
	  print,' cr = dt_tm_tocr(dt_tm)'
	  print,'   dt_tm = date/time string (or JS).  in'
	  print,'   cr = Carrington Rotation Number.   out'
	  print,' Notes: Time is Ephemeris Time which is almost UT.'
	  return,''
	endif
 
	;------  From date/time find jd  ----------
	js = dt_tm
	if datatype(js) ne 'DOU' then js=dt_tm_tojs(js)
	jd = js2jd(js)
 
	;------  Estimated CR from jd  ---------
	carr = (jd-2398140.227d0)/27.2752316D0
;help,carr
 
	;------  First correction  --------
	jdt = js2jd(dt_tm_tojs(dt_tm_fromcr(carr)))	; True time for est.
	err = (jd-jdt)/27.2752316D0			; Delta carr.
	carr = carr + err
;help,carr
 
;	;------  Second correction  --------
;	jd = jdt
;	jdt = js2jd(dt_tm_tojs(dt_tm_fromcr(carr)))	; True time for est.
;	err = (jd-jdt)/27.2752316D0			; Delta carr.
;	carr = carr + err
;help,carr
 
	return, carr
	end
