;-------------------------------------------------------------
;+
; NAME:
;       SHOWTABS
; PURPOSE:
;       List text array on screen, with tabs as a printable char.
; CATEGORY:
; CALLING SEQUENCE:
;       showtabs, txt
; INPUTS:
;       txt = Input text.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         CHAR=ch  Character to show for tabs (def='#').
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Use detab, txt to detab text array.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 27
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro showtabs, txt, char=char, help=hlp
 
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' List text array on screen, with tabs as a printable char.'
	  print,' showtabs, txt'
	  print,'   txt = Input text.   in'
	  print,' Keywords:'
	  print,"   CHAR=ch  Character to show for tabs (def='#')."
	  print,' Notes: Use detab, txt to detab text array.'
	  return
	endif
 
	if n_elements(char) eq 0 then char='#'
	ch = (byte(char))(0)
 
	b = byte(txt)
	w = where(b eq 9,cnt9)
	if cnt9 gt 0 then b(w)=ch
	txt2 = string(b)
	more,txt2
 
	end
