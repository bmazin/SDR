;-------------------------------------------------------------
;+
; NAME:
;       FIRSTCHR
; PURPOSE:
;       Set first character of a string, add if needed.
; CATEGORY:
; CALLING SEQUENCE:
;       out = firstchr(in,chr)
; INPUTS:
;       in = input text string.       in
;       chr = character to be first.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = modified text string.   out
; COMMON BLOCKS:
; NOTES:
;       Note: if input string already starts with chr nothing is changed.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 31
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function firstchr, in, chr, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Set first character of a string, add if needed.'
	  print,' out = firstchr(in,chr)'
	  print,'   in = input text string.       in'
	  print,'   chr = character to be first.  in'
	  print,'   out = modified text string.   out'
	  print,' Note: if input string already starts with chr nothing is changed.'
	  return,''
	endif
 
	if strmid(in,0,1) eq chr then return, in
	return, chr+in
 
	end
