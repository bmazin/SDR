;-------------------------------------------------------------
;+
; NAME:
;       GCEIL
; PURPOSE:
;       Generalized ceil function, step not limited to 1.
; CATEGORY:
; CALLING SEQUENCE:
;       fnum = gceil(num, step)
; INPUTS:
;       num = Input value.              in
;       step = interval size (def=1).   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       fnum = Returned gceil of num.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: The gceil of num with a given step is the
;       next multiple of step GE num. For example
;       gceil(137,25) is 150, gceil(12.33,0.5) is 12.0.
;       Make sure to use a decimal when needed, like for
;       gceil(-137.,25) is 125.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Apr 12
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function gceil, num, step, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Generalized ceil function, step not limited to 1.'
	  print,' fnum = gceil(num, step)'
	  print,'   num = Input value.              in'
	  print,'   step = interval size (def=1).   in'
	  print,'   fnum = Returned gceil of num.  out'
	  print,' Notes: The gceil of num with a given step is the'
	  print,' next multiple of step GE num. For example'
	  print,' gceil(137,25) is 150, gceil(12.33,0.5) is 12.0.'
	  print,' Make sure to use a decimal when needed, like for'
	  print,' gceil(-137.,25) is 125.'
	  return,''
	endif
 
	if n_elements(step) eq 0 then step=1.
 
	r = num/step		; Ratio.
	fr = pmod(r,1)		; Fractional part of ratio.
	fl = r - fr		; Floor of r.
 
	return, (fl + 1)*step	; First multiple of step above num.
 
	end
