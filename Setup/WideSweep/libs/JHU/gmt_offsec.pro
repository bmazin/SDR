;-------------------------------------------------------------
;+
; NAME:
;       GMT_OFFSEC
; PURPOSE:
;       Return offset in seconds from local time to GMT (UT).
; CATEGORY:
; CALLING SEQUENCE:
;       off = gmt_offsec()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Times are rounded to the nearest 1/4 hour.
;         This should handle any time zone, even fractional ones.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Dec, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function gmt_offsec, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return offset in seconds from local time to GMT (UT).'
 	  print,' off = gmt_offsec()'
	  print,'   off = offset in seconds from local time to GMT (UT).'
	  print,' Note: Times are rounded to the nearest 1/4 hour.'
	  print,'   This should handle any time zone, even fractional ones.'
	  return,''
	endif
 
	jsg = systime(1) + dt_tm_tojs('1970 Jan 1')  ; GMT Julian Seconds.
	jsl = dt_tm_tojs(systime())		     ; Local Julian Seconds.
 
	diff = jsg - jsl			     ; Diff in seconds.
 
	return, round(diff/900.)*900.		     ; Time to nearest .25 hr.
 
	end
