;-------------------------------------------------------------
;+
; NAME:
;       SPC
; PURPOSE:
;       Return a string with the specified number of spaces (or other char).
; CATEGORY:
; CALLING SEQUENCE:
;       s = spc(n, [text])
; INPUTS:
;       n = number of spaces (= string length).   in 
;        text = optional text string.              in
;          # spaces returned is n-strlen(strtrim(text,2))
; KEYWORD PARAMETERS:
;       Keywords:
;         CHARACTER=ch  Character other than a space.
;           Ex: CHAR='-'.
;         /NOTRIM means do not do a strtrim on text.
; OUTPUTS:
;       s = resulting string.                     out
; COMMON BLOCKS:
; NOTES:
;       Note: Number of requested spaces is reduced by the
;         length of given string.  Useful for text formatting.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 16 Dec, 1984.
;       RES --- rewritten 14 Jan, 1986.
;       R. Sterner, 27 Jun, 1990 --- added text.
;       R. Sterner, 1994 Sep  7 --- Allowed text arrays.
;       R. Sterner, 1999 Jul  2 --- Added /NOTRIM keyword.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function spc,n, text, character=char, notrim=notrim, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return a string with the specified number of spaces (or '+$
	    'other char).' 
	  print,' s = spc(n, [text])' 
	  print, '  n = number of spaces (= string length).   in '
	  print,'   text = optional text string.              in'
	  print,'     # spaces returned is n-strlen(strtrim(text,2))'
	  print,'   s = resulting string.                     out' 
	  print,' Keywords:'
	  print,'   CHARACTER=ch  Character other than a space.'
	  print,"     Ex: CHAR='-'."
	  print,'   /NOTRIM means do not do a strtrim on text.'
	  print,' Note: Number of requested spaces is reduced by the'
	  print,'   length of given string.  Useful for text formatting.'
	  return, -1
	endif
 
	if n_params(0) eq 1 then begin
	  n2 = n
	endif else begin
	  if keyword_set(notrim) then $
	    ntxt=strlen(text) else ntxt=strlen(strtrim(text,2))
;	  n2 = n - strlen(strtrim(text,2))
	  n2 = n - ntxt
	endelse
 
	ascii = 32B
	if n_elements(char) ne 0 then ascii = (byte(char))(0)
 
	num = n_elements(n2)
	out = strarr(num)
	for i = 0, num-1 do begin
	  if n2(i) le 0 then out(i) = '' else $
	    out(i) = string(bytarr(n2(i)) + ascii)
	endfor
 
	if n_elements(out) eq 1 then out=out(0)
	return, out
 
	end
