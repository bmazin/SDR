;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_FROMCR
; PURPOSE:
;       Convert from Carrington Rotation Number to Date/Time.
; CATEGORY:
; CALLING SEQUENCE:
;       dt_tm = dt_tm_fromcr(cr)
; INPUTS:
;       cr = Carrington Rotation Number.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /JS means return Julian Seconds, not date/time string.
; OUTPUTS:
;       dt_tm = date/time string.          out
; COMMON BLOCKS:
; NOTES:
;       Notes: Time is Ephemeris Time which is almost UT.
;         Ref: Astronomical Algorithms, Jean Meeus.
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
	function dt_tm_fromcr, carr0, js=js, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert from Carrington Rotation Number to Date/Time.'
	  print,' dt_tm = dt_tm_fromcr(cr)'
	  print,'   cr = Carrington Rotation Number.   in'
	  print,'   dt_tm = date/time string.          out'
	  print,' Keywords:'
	  print,'   /JS means return Julian Seconds, not date/time string.'
	  print,' Notes: Time is Ephemeris Time which is almost UT.'
	  print,'   Ref: Astronomical Algorithms, Jean Meeus.'
	  return,''
	endif
 
	;------  Force double precision  -------
	carr = double(carr0)
 
	;------  Find JD from CR ---------
	jd = 2398140.227d0 + 27.2752316d0*double(carr)
 
	m = (281.96d0 + 26.882476d0*carr)/!radeg
	corr = 0.1454*sin(m) - 0.0085*sin(2*m) - 0.0141*cos(2*m)
 
	;------  Find JS  ----------------
	jsec = jd2js(jd+corr)
	if keyword_set(js) then return, jsec
 
	;------  Find date/time from JD  --------
	dt_tm = dt_tm_fromjs(jsec)
 
	return, dt_tm
	end
