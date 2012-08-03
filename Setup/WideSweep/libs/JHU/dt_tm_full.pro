;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_FULL
; PURPOSE:
;       Add missing parts of date to get a full date/time string.
; CATEGORY:
; CALLING SEQUENCE:
;       out = dt_tm_full(in,miss)
; INPUTS:
;       in = input date/time string.                     in
;          May have missing date info: '12:34' 'May 7 7:00'
;       miss = Desired year, month, day in that order.   in
;          Like '1996 May 12'.  Default=current date.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  0 if ok, 1 if result is not a valid date/time.
; OUTPUTS:
;       out = Full date/time string.                     out
;          Like '1996 May 12 12:34' or '1996 May 7 7:00'
; COMMON BLOCKS:
; NOTES:
;       Notes: for scalar value only.  Does only limited error
;         checking.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Jul 10
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function dt_tm_full, in, miss, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Add missing parts of date to get a full date/time string.'
	  print,' out = dt_tm_full(in,miss)'
	  print,'   in = input date/time string.                     in'
	  print,"      May have missing date info: '12:34' 'May 7 7:00'"
	  print,'   miss = Desired year, month, day in that order.   in'
	  print,"      Like '1996 May 12'.  Default=current date."
	  print,'   out = Full date/time string.                     out'
	  print,"      Like '1996 May 12 12:34' or '1996 May 7 7:00'"
	  print,' Keywords:'
	  print,'   ERROR=err  0 if ok, 1 if result is not a valid date/time.'
	  print,' Notes: for scalar value only.  Does only limited error'
	  print,'   checking.'
	  return,''
	endif
 
	;------  Set default missing date part string (current date) -------
        if n_elements(miss) eq 0 then $
          miss=dt_tm_fromjs(dt_tm_tojs(systime()),form='Y$ n$ d$')
 
	;------  Check for missing parts and add them  -----------
        dt_tm_brk, in,dt,tm		; Break input into date and time.
	dt = repchr(dt,'-')		; Drop any - in date.
	dt = repchr(dt,'/')		; Drop any / in date.
	dt = repchr(dt,',')		; Drop any , in date.
        n = nwrds(dt)			; How many items in date part?
        if n eq 0 then dt=getwrd(miss,0,2)	    ; None, use all defaults.
        if n eq 1 then dt=getwrd(miss,0,1)+' '+dt   ; One, add year, month.
        if n eq 2 then dt=getwrd(miss,0)+' '+dt	    ; Two, add just year.
	out = dt+' '+tm				    ; Date and time.
        js = dt_tm_tojs(out, error=err)		    ; Check if valid.
        if err ne 0 then return,''		    ; Error exit.
 
	return, out
	end
