;-------------------------------------------------------------
;+
; NAME:
;       DT_TM_CHK
; PURPOSE:
;       Check date & time string that both parts exist & are valid.
; CATEGORY:
; CALLING SEQUENCE:
;       status = dt_tm_chk(txt)
; INPUTS:
;       txt = Input data and time string.             in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       status = 1 if ok (true), 0 if error (false).  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 13 Apr, 1989.
;       R. Sterner, 26 Feb, 1991 --- renamed from chk_date_time.pro
;       R. Sterner, 27 Feb, 1991 --- renamed from chk_dt_tm.pro
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function dt_tm_chk, txt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Check date & time string that both parts exist & are valid.'
	  print,' status = dt_tm_chk(txt)'
	  print,'   txt = Input data and time string.             in'
	  print,'   status = 1 if ok (true), 0 if error (false).  out'
 	  return,-1
	endif
 
	dt_tm_brk, txt, dt, tm		; Separate date and time.
	if dt eq '' then return, 0	; No date, error.
	if tm eq '' then return, 0	; No time, error.
	date2ymd, dt, y, m, d		; Break date into y,m,d.
	if y lt 0 then return, 0	; Bad year, error.
	if m lt 1 then return, 0	; bad month, error.
	if m gt 12 then return, 0	; bad month, error.
	if d lt 1 then return, 0	; bad monthday, error.
	mdays = monthdays(y,0)		; Allowed monthdays.
	if d gt mdays(m) then return, 0	; bad monthday, error.
	
	return, 1			; ok.
 
	end
