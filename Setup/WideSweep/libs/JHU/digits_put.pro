;-------------------------------------------------------------
;+
; NAME:
;       DIGITS_PUT
; PURPOSE:
;       Combine separate digits into a number.
; CATEGORY:
; CALLING SEQUENCE:
;       num = digits_put(d)
; INPUTS:
;       d = array of digits.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       num = returned number.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Mar 13
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function digits_put, d, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Combine separate digits into a number.'
	  print,' num = digits_put(d)'
	  print,'   d = array of digits.    in'
	  print,'   num = returned number.  out'
	  return,''
	endif
 
	return, 0LL + string(byte(d+48))
 
	end
