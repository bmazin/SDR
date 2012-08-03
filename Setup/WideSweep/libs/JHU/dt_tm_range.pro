;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_RANGE
; PURPOSE:
;       Extract date/time range from string with two date/times.
; CATEGORY:
; CALLING SEQUENCE:
;       dt_tm_range, in,js1,js2
; INPUTS:
;       in = input string with 2 date/time strings.         in
;         Must both have same form (at least same length).
; KEYWORD PARAMETERS:
;       Keywords:
;         MISSING=def  Defaults for missing date values:
;           Must be string with year, month, day in that order.
;           Ex: miss='1996 May 12'
;           Default for MISSING is current day.
;           ERROR=err  Error flag: 0=ok.
; OUTPUTS:
;       js1, js2 = returned times as Julian Seconds.        out
; COMMON BLOCKS:
; NOTES:
;       Notes: Tries to split input string into 2 equal parts.
;         Missing year, month, or day may be added from default.
;         If second time is before first then 1 day is added.
;         This allows time ranges with only times, default
;         applies to first day.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Nov 4
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro dt_tm_range, in,js1,js2,missing=miss,error=err,help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Extract date/time range from string with two date/times.'
	  print,' dt_tm_range, in,js1,js2'
	  print,'   in = input string with 2 date/time strings.         in'
	  print,'     Must both have same form (at least same length).'
	  print,'   js1, js2 = returned times as Julian Seconds.        out'
	  print,' Keywords:'
	  print,'   MISSING=def  Defaults for missing date values:'
	  print,'     Must be string with year, month, day in that order.'
	  print,"     Ex: miss='1996 May 12'"
	  print,'     Default for MISSING is current day.'
	  print,'     ERROR=err  Error flag: 0=ok.'
	  print,' Notes: Tries to split input string into 2 equal parts.'
	  print,'   Missing year, month, or day may be added from default.'
	  print,'   If second time is before first then 1 day is added.'
	  print,'   This allows time ranges with only times, default'
	  print,'   applies to first day.'
 	 return
	endif
 
	;------  Set default missing date part string  -----------
	if n_elements(miss) eq 0 then $
	  miss=dt_tm_fromjs(dt_tm_tojs(systime()),form='Y$ n$ d$')
 
	;--------  Split input string into 2 parts  ------------
	s = strlen(in)/2
	in1 = strmid(in,0,s)
	in2 = strmid(in,s,999)
 
	;--------  Deal with first string  ------------
	in1 = repchr(in1,'/')
	in1 = repchr(in1,'-')
	in1 = repchr(in1,',')
	dt_tm_brk, in1,dt1,tm1
	n = nwrds(dt1)
	if n eq 0 then dt1=getwrd(miss,0,2)
	if n eq 1 then dt1=getwrd(miss,0,1)+' '+dt1
	if n eq 2 then dt1=getwrd(miss,0)+' '+dt1
	js1 = dt_tm_tojs(dt1+' '+tm1, error=err)
	if err ne 0 then return
 
	;--------  Deal with second string  ------------
	in2 = repchr(in2,'/')
	in2 = repchr(in2,'-')
	in2 = repchr(in2,',')
	dt_tm_brk, in2,dt2,tm2
	n = nwrds(dt2)
	if n eq 0 then dt2=getwrd(miss,0,2)
	if n eq 1 then dt2=getwrd(miss,0,1)+' '+dt2
	if n eq 2 then dt2=getwrd(miss,0)+' '+dt2
	js2 = dt_tm_tojs(dt2+' '+tm2, error=err)
	if err ne 0 then return
 
	;-------  Fix day wrap around  ----------------
	if js2 lt js1 then js2 = js2+86400L
 
	return
	end
