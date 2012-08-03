;-------------------------------------------------------------
;+
; NAME:
;       DIGITS_GET
; PURPOSE:
;       Get digits in a number.
; CATEGORY:
; CALLING SEQUENCE:
;       d = digits_get(num)
; INPUTS:
;       num = Number to split.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         NDIGITS=n  Number of digits in number.
;           To get leading zeros.  Default is non-zero digits.
; OUTPUTS:
;       d = array of digits (bytes).  out
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
	function digits_get, x, ndigits=n, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get digits in a number.'
	  print,' d = digits_get(num)'
	  print,'   num = Number to split.        in'
	  print,'   d = array of digits (bytes).  out'
	  print,' Keywords:'
	  print,'   NDIGITS=n  Number of digits in number.'
	  print,'     To get leading zeros.  Default is non-zero digits.'
	  return, ''
	endif
 
	if n_elements(n) eq 0 then n=fix(alog10(x)+1)
 
	nn = strtrim(n,2)
	fmt = '(I'+nn+'.'+nn+')'
	s = string(x,form=fmt)
 
	return, byte(s)-48
 
	end
