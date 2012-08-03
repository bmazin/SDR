;-------------------------------------------------------------
;+
; NAME:
;       UTNOW
; PURPOSE:
;       Return current Universal Time in Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       js = utnow()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       js = returned Universal Time.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 May 07
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function utnow, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return current Universal Time in Julian Seconds.'
	  print,' js = utnow()'
	  print,'   js = returned Universal Time.  out'
	  return, ''
	endif
 
	return, dt_tm_tojs(systime())+gmt_offsec()
 
	end
