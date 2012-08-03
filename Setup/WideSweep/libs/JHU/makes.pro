;-------------------------------------------------------------
;+
; NAME:
;       MAKES
; PURPOSE:
;       Make a string array of integers from lo to hi by step.
; CATEGORY:
; CALLING SEQUENCE:
;       s = makes(lo, hi, step)
; INPUTS:
;       lo, hi = array start and end values.       in
;       step = distance beteen values.             in
;         Sign of step determines order of result.
; KEYWORD PARAMETERS:
;       Keywords:
;         DIGITS=d  Number of digits in result.
;           Forces leading zeros if needed.
; OUTPUTS:
;       s = resulting string array.                out
; COMMON BLOCKS:
; NOTES:
;       Note: no leading or trailing spaces, useful for
;         generating file names with embedded numbers.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Feb 22
;       R. Sterner, 1995 Aug 14 --- Added DIGITS keyword.
;       R. Sterner, 2002 Apr 29 --- Replaced string with stringform.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makes,lo,hi,st, digits=digits, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make a string array of integers from lo to hi by step.'
	  print,' s = makes(lo, hi, step)'
	  print,'   lo, hi = array start and end values.       in'
	  print,'   step = distance beteen values.             in'
	  print,'     Sign of step determines order of result.'
	  print,'   s = resulting string array.                out'
	  print,' Keywords:'
	  print,'   DIGITS=d  Number of digits in result.'
	  print,'     Forces leading zeros if needed.'
	  print,' Note: no leading or trailing spaces, useful for'
	  print,'   generating file names with embedded numbers.'
	  return, -1
	endif
 
	if n_elements(digits) eq 0 then digits = 0
	d = strtrim(digits,2)
	fmt = '(I'+d+'.'+d+')'
	return, strtrim(stringform(makei(lo,hi,st),form=fmt),2)
 
	end
