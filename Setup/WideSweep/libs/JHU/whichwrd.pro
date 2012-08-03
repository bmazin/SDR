;-------------------------------------------------------------
;+
; NAME:
;       WHICHWRD
; PURPOSE:
;       Find which word is a given string is in.
; CATEGORY:
; CALLING SEQUENCE:
;       n = whichwrd( txt, sub)
; INPUTS:
;       txt = text string to examinei (scalar).      in
;       sub = substring to search for (scalar).      in
; KEYWORD PARAMETERS:
;       Keywords:
;         DELIMITER=del  Word delimiter character (def=white space).
;         OCCUR=occ Which occurance of sub to use (def=first).
; OUTPUTS:
;       n = Word number where found (-1=not there).  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Sep 25
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function whichwrd, txtstr, sub, delimiter=delim, occur=occ, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find which word is a given string is in.'
	  print,' n = whichwrd( txt, sub)'
	  print,'   txt = text string to examinei (scalar).      in'
 	  print,'   sub = substring to search for (scalar).      in'
	  print,'   n = Word number where found (-1=not there).  out'
	  print,' Keywords:'
	  print,'   DELIMITER=del  Word delimiter character (def=white space).'
	  print,'   OCCUR=occ Which occurance of sub to use (def=first).'
	  return, ''
	endif
 
	if n_elements(occ) eq 0 then occ=1
	occ = occ>1
 
	;---  Convert text to byte array (deal with white space)  ------
	ddel = ' '			; Def del is a space.
	if n_elements(delim) ne 0 then ddel = delim	; Use given delimiter.
	tst = (byte(ddel))(0)		; Del to byte value.
	tb = byte(txtstr(0))		; String to bytes.
	if ddel eq ' ' then begin	; Check for tabs?
	  w = where(tb eq 9B, cnt)	; Yes.
	  if cnt gt 0 then tb(w) = 32B	; Convert any to space.
	endif
 
	;---  Find word number table  -----------
	x = tb ne tst			; Non-delchar (=words).
	x = [0,x,0]			; 0s at ends.
	wtab = cumulate(1-x)*x-1	; Word # for each character.
	wtab = wtab(1:*)		; Clip off first entry.
 
	;---  Find sub string position and then word #  ------
	pos = 0				; Search start char.
	for i=1, occ do begin		; Search for occurance # occ.
	  p = strpos(txtstr, sub, pos)	; Find next case.
	  if p lt 0 then return, -1	; Not found in string.
	  pos = p+1			; Next search start.
	endfor
 
	;----  Do word # table lookup  ------------
	return, wtab(p)
 
	end
