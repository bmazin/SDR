;-------------------------------------------------------------
;+
; NAME:
;       FNDWRD
; PURPOSE:
;       Find number, locations, lengths of words in a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       fndwrd, txt, nwds, loc, len
; INPUTS:
;       txt = text string to examine.                    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       nwds = number of words found in txt.             out
;       loc = array of word start positions (0=first).   out
;       len = array of word lengths.                     out
; COMMON BLOCKS:
; NOTES:
;       Note: Words must be separated by spaces or tabs.
; MODIFICATION HISTORY:
;       Ray. Sterner,  11 Dec, 1984.
;       RES  Handle null strings better.   16 Feb, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;       BLG  9 Dec, 1992 --- Modified to use tabs as delimiters as well.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO FNDWRD,TXTSTR,NWDS,LOC,LEN, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Find number, locations, lengths of words in a text string.'
	  print,' fndwrd, txt, nwds, loc, len'
	  print,'    txt = text string to examine.                    in'
	  print,'    nwds = number of words found in txt.             out'
	  print,'    loc = array of word start positions (0=first).   out'
	  print,'    len = array of word lengths.                     out'
	  print,' Note: Words must be separated by spaces or tabs.'
	  return
	endif
 
	IF TXTSTR EQ '' THEN BEGIN
	  NWDS = 0
	  LOC = INTARR(1)-1
	  LEN = LOC
	  RETURN
	ENDIF
	B = BYTE(TXTSTR)
	X = (B NE 32) AND (B NE 9)    ; Ignore spaces and tabs
	X = [0,X,0]
 
	Y = (X-SHIFT(X,1)) EQ 1
	Z = WHERE(SHIFT(Y,-1) EQ 1)
	Y2 = (X-SHIFT(X,-1)) EQ 1
	Z2 = WHERE(SHIFT(Y2,1) EQ 1)
 
	NWDS = fix(TOTAL(Y))
	LOC = Z
	LEN = Z2 - Z - 1
 
	RETURN
 
	END
