;-------------------------------------------------------------
;+
; NAME:
;       PMOD
; PURPOSE:
;       Find the positive modulo value of a number.
; CATEGORY:
; CALLING SEQUENCE:
;       out = pmod(in,m)
; INPUTS:
;       in = input value (may be an array).   in
;       m = divisor.                          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Remainder of in divided by m.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: output is always in the range 0 to m-1.
;         To see the difference between mod and pmod try:
;         plot,(indgen(500)-250) mod 50, yran=[-60,60]
;         plot,pmod(indgen(500)-250, 50), yran=[-60,60]
; MODIFICATION HISTORY:
;       R. Sterner, 1996 May 12
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function pmod, in, m, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find the positive modulo value of a number.'
	  print,' out = pmod(in,m)'
	  print,'   in = input value (may be an array).   in'
	  print,'   m = divisor.                          in'
	  print,'   out = Remainder of in divided by m.   out'
	  print,' Notes: output is always in the range 0 to m-1.'
	  print,'   To see the difference between mod and pmod try:'
	  print,'   plot,(indgen(500)-250) mod 50, yran=[-60,60]'
	  print,'   plot,pmod(indgen(500)-250, 50), yran=[-60,60]'
	  return,''
	endif
 
	out = in mod m				; Do basic modulo.
	w = where(out lt 0, c)			; Deal with negative values.
	if c gt 0 then out(w) = out(w)+m
	return, out
	end
