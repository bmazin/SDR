;-------------------------------------------------------------
;+
; NAME:
;       ROUND2
; PURPOSE:
;       Round that works for big double precision numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       out = round2(in)
; INPUTS:
;       in = input number or array.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Rounded result.         out
; COMMON BLOCKS:
; NOTES:
;       Notes: works for both floats and doubles, returns
;         long result for float and double for double.
;         Example: round2(9000000001.4999d0) gives
;         9000000001.00000
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Jun 4
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function round2, x, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Round that works for big double precision numbers.'
	  print,' out = round2(in)'
	  print,'   in = input number or array.   in'
	  print,'   out = Rounded result.         out'
	  print,' Notes: works for both floats and doubles, returns'
	  print,'   long result for float and double for double.'
	  print,'   Example: round2(9000000001.4999d0) gives'
	  print,'   9000000001.00000'
	  return,''
	endif
 
	if datatype(x) eq 'DOU' then begin
	  y = (x+0.5d0) - ((x+0.5d0) mod 1d0)
	endif else begin
	  y = round(x)
	endelse
 
	return, y
 
	end
