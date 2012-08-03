;-------------------------------------------------------------
;+
; NAME:
;       FIRSTCHAR
; PURPOSE:
;       Position of first non-whitespace char in string.
; CATEGORY:
; CALLING SEQUENCE:
;       p = firstchar(txt)
; INPUTS:
;       txt = text string to examine.                    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = position of first non-whitespece character.  out
; COMMON BLOCKS:
; NOTES:
;       Note: For no non-whitespace characters p = -1.
; MODIFICATION HISTORY:
;       R. Sterner, 20 Sep, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function firstchar, txt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Position of first non-whitespace char in string.'
	  print,' p = firstchar(txt)'
	  print,'   txt = text string to examine.                    in'
	  print,'   p = position of first non-whitespece character.  out'
	  print,' Note: For no non-whitespace characters p = -1.'
	  return, -1
	endif
 
	w = where(byte(txt) gt 32, count)
	if count eq 0 then return, -1
	return, w(0)
	end
