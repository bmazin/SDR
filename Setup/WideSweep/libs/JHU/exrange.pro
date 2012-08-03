;-------------------------------------------------------------
;+
; NAME:
;       EXRANGE
; PURPOSE:
;       Return a range array with range expanded by given fraction.
; CATEGORY:
; CALLING SEQUENCE:
;       b = exrange(a, f)
; INPUTS:
;       a = array.                in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = [mn-, mx+]            out
;       where mn- = min(a) - f*d
;             mx+ = max(a) + f*d
;             d = max(a) - min(a)
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 7 Sep, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function exrange, x, f, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return a range array with range expanded by given fraction.'
	  print,' b = exrange(a, f)'
	  print,'   a = numeric input array.                      in'
	  print,'   f = fraction to expand array range (def=0).'
	  print,'   b = adjusted 2-element range of array.        out'
	  print,'       Min and max of array if adjusted by given fraction'
	  print,'       of the total range to give: [min(a)-f*d,max(a)+f*d]'
	  print,'       where d = max(a) - min(a)'
	  print,' Notes: if fraction f not given the array extremes are'
	  print,'   returned: [min(a), max(a)].'
	  return, -1
	end
 
	d = max(x) - min(x)
	if n_elements(f) eq 0 then f=0.
	return, [min(x)-f*d, max(x)+f*d]
 
	end
