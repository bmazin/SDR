;-------------------------------------------------------------
;+
; NAME:
;       REPWORD
; PURPOSE:
;       Replace a word in a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       txt2 = repword(txt1, n, new, [old])
; INPUTS:
;       txt1 = original text string.             in
;       n = word number to replace (0 = first).  in
;       new = new word.                          in
; KEYWORD PARAMETERS:
;       Keywords:
;         /COMPRESS compress out all extra white space.
;         /TRIM trim white space front front and back.
; OUTPUTS:
;       old = optionally returned old word.      out
;       txt2 = modified text string.             out
; COMMON BLOCKS:
; NOTES:
;       Notes: if n lt 0 then txt1 is returned.
; MODIFICATION HISTORY:
;       R. Sterner. 22 Apr, 1988.
;       R. Sterner, 4 Feb 1990 --- converted to SUN.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION REPWORD, TXT1, N, NEW_WORD, OLD_WORD, help=hlp, $
	  compress=comp, trim=trm
 
	NP = N_PARAMS(0)
 
	IF (NP LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Replace a word in a text string.'
	  print,' txt2 = repword(txt1, n, new, [old])'
	  print,'   txt1 = original text string.             in'
	  print,'   n = word number to replace (0 = first).  in'
	  print,'   new = new word.                          in'
	  print,'   old = optionally returned old word.      out'
	  print,'   txt2 = modified text string.             out'
	  print,' Keywords:'
	  print,'   /COMPRESS compress out all extra white space.'
	  print,'   /TRIM trim white space front front and back.'
	  print,' Notes: if n lt 0 then txt1 is returned.'
	  RETURN, -1
	ENDIF
 
	if n lt 0 then begin
	  old_word = ''
	  return, txt1
	endif
 
	FNDWRD, TXT1, NWDS, LOC, LEN
	LST = NWDS - 1
 
	IF N EQ 0 THEN BEGIN
	  FRNT = ''
	ENDIF ELSE BEGIN
	  FRNT = STRMID(TXT1, 0, LOC(N>0<LST))
	ENDELSE
 
	IF N EQ LST THEN BEGIN
	  BCK = ''
	ENDIF ELSE BEGIN
	  BCK = STRMID(TXT1, LOC(N>0<LST)+LEN(N>0<LST), 999)
	ENDELSE
 
	IF NP GT 3 THEN OLD_WORD = GETWRD(TXT1, N>0<LST)
 
	RETURN, FRNT + NEW_WORD + BCK
	END
