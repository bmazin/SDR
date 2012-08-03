;-------------------------------------------------------------
;+
; NAME:
;       STR_DROP_PUNC
; PURPOSE:
;       Return a string with punctuation removed.
; CATEGORY:
; CALLING SEQUENCE:
;       out = str_drop_punc(in).
; INPUTS:
;       txt = input string.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LOWER convert to all lowercase.
;         /UPPER convert to all uppercase.
;         /COMPRESS remove all white space.
; OUTPUTS:
;       out = returned string.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful for comparing strings with minor differences.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 18
;       R. Sterner, 2004 Aug 05 --- Dropped all but alphanumeric characters.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function str_drop_punc, txt, lower=lower, upper=upper, $
	  compress=comp, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return a string with punctuation removed.'
	  print,' out = str_drop_punc(in).'
	  print,'   txt = input string.     in'
	  print,'   out = returned string.  out'
	  print,' Keywords:'
	  print,'   /LOWER convert to all lowercase.'
	  print,'   /UPPER convert to all uppercase.'
	  print,'   /COMPRESS remove all white space.'
	  print,' Notes: Useful for comparing strings with minor differences.'
	  return,''
	endif
 
	;--------  Remove punctuation  -----------
	b = byte(txt)			; Convert text to bytes.
;	w = where(b le 47B, c)		; Find punctuation.
	w = where(((b lt 48B) or $
	          ((b gt 57B) and (b lt 65B)) or $
	          ((b gt 90B) and (b lt 97B)) or $
	          (b gt 122B)), c)	; Find any non alphanumeric.
	if c gt 0 then b(w)=32		; Set to space.
	out = string(b)			; Convert bytes to text.
 
	;--------  Postprocess  -------------------
	if keyword_set(lower) then out = strlowcase(out)
	if keyword_set(upper) then out = strupcase(out)
	if keyword_set(comp) then out = strcompress(out,/remove)
 
	return, out
 
	end
