;-------------------------------------------------------------
;+
; NAME:
;       STRTRM2
; PURPOSE:
;       Trim given character (and spaces) from ends of given string.
; CATEGORY:
; CALLING SEQUENCE:
;       s2 = strtrm2(s1,[flag],[chr])
; INPUTS:
;       s1 = String to trim.                          in
;       flag = 0: remove trailing                     in
;              1: remove leading
;              2: remove both. No flag same as 0.
;       chr = character to trim (def = spaces).       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s2 = trimmed string.  Works just like strtrim.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 11 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function strtrm2,s,fx,cx,help=hlp
 
 
	if (keyword_set(hlp)) then begin
	  print,' Trim given character (and spaces) from ends of given string.'
	  print,' s2 = strtrm2(s1,[flag],[chr])'
	  print,'   s1 = String to trim.                          in'
	  print,'   flag = 0: remove trailing                     in'
	  print,'          1: remove leading'
	  print,'          2: remove both. No flag same as 0.
	  print,'   chr = character to trim (def = spaces).       in'
	  print,' s2 = trimmed string.  Works just like strtrim.  out'
	  return,-1
	endif
 
	C = ' '
	F = 0
	IF N_PARAMS(0) EQ 3 THEN C = CX
	IF N_PARAMS(0) GE 2 THEN F = FX
 
	X = STRING([1B])	     ; set up a place saving character.
	S2 = STRTRIM(S,F)	     ; trim spaces.
	S2 = STRESS(S2,'R',0,' ',X)  ; Put a place holder in left over spaces.
	S2 = STRESS(S2,'R',0,C,' ')  ; Turn trim char into spaces.
	S2 = STRTRIM(S2,F)	     ; Trim off ends.
	S2 = STRESS(S2,'R',0,' ',C)  ; Put back whatever trim chars are left.
	S2 = STRESS(S2,'R',0,X,' ')  ; Put back desired spaces.
 
	RETURN, S2
 
	END
