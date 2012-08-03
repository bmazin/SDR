;-------------------------------------------------------------
;+
; NAME:
;       UPCASE1
; PURPOSE:
;       Capitalize first letter in string.
; CATEGORY:
; CALLING SEQUENCE:
;       out = upcase1(in)
; INPUTS:
;       in = Input text string.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Output text string.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Jun 26
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function upcase1, txt, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Capitalize first letter in string.'
	  print,' out = upcase1(in)'
	  print,'   in = Input text string.          in'
	  print,'   out = Output text string.        out'
	  return,''
	endif
 
	;-------  Look for first letter  ----------
	b = byte(txt)			; Work with a byte array.
	w = where(((b ge 65) and (b le 90)) or ((b ge 97) and (b le 122)),cnt)
	if cnt eq 0 then return, txt	; No letters.
 
	b(w(0)) = b(w(0)) and 95	; Force 1st letter upper case.
 
	return, string(b)
 
	end
