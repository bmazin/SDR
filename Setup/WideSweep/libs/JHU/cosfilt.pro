;-------------------------------------------------------------
;+
; NAME:
;       COSFILT
; PURPOSE:
;       Cosine tapered weighting array to use for FFT filtering.
; CATEGORY:
; CALLING SEQUENCE:
;       W = COSFILT(DATA, F1, F2, [F3, F4])
; INPUTS:
;       DATA = 1-d data array (only used to find array size).   in
;       F1 = filter start of rolloff (fraction of sample freq). in
;       F2 = end of rolloff (fraction of sample freq).          in
;          or
;       F1 = filter start of rollup (fraction of sample freq).  in
;       F2 = end of rollup (fraction of sample freq).           in
;       F3 = filter start of rolloff (fraction of sample freq). in
;       F4 = end of rolloff (fraction of sample freq).          in
;         F1 < F2 < F3 < F4 <= .5
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner., B. Gotwols  7 Apr, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION COSFILT, DATA, F1, F2, F3, F4, help=hlp
 
	NEL = N_ELEMENTS(DATA)
	NP = N_PARAMS(0)
 
	IF (NP LT 3) or keyword_set(hlp) THEN BEGIN
	  print,' Cosine tapered weighting array to use for FFT filtering.'
	  print,' W = COSFILT(DATA, F1, F2, [F3, F4])
	  print,'   DATA = 1-d data array (only used to find array size).   in'
	  print,'   F1 = filter start of rolloff (fraction of sample freq). in'
	  print,'   F2 = end of rolloff (fraction of sample freq).          in'
	  print,'      or'
	  print,'   F1 = filter start of rollup (fraction of sample freq).  in'
	  print,'   F2 = end of rollup (fraction of sample freq).           in'
	  print,'   F3 = filter start of rolloff (fraction of sample freq). in'
	  print,'   F4 = end of rolloff (fraction of sample freq).          in'
	  print,'     F1 < F2 < F3 < F4 <= .5
	  RETURN, -1
	ENDIF
 
	IF (F1 GT F2) OR (F2 GT .5) THEN BEGIN
	  PRINT,' Error in COSTAP: Fractions must be <= .5 and f1 < f2.'
	  RETURN, -1
	ENDIF
 
	I1 = F1*NEL
	I2 = F2*NEL
	IF I2 EQ I1 THEN BEGIN
	  IF F1 LT .25 THEN BEGIN
	    I2 = I1 + 1
	  ENDIF ELSE BEGIN
	    I1 = I2 - 1
	  ENDELSE
	ENDIF
	W = 1 - BLEND(NEL/2+1, FIX(I1), FIX(I2))
 
	IF NP EQ 5 THEN BEGIN
	  IF (F3 GT F4) OR (F3 LT F2) OR (F4 GT .5) THEN BEGIN
	    PRINT,' Error in COSTAP: Fract. must be <.5 and f1<f2<f3<f4.'
	    RETURN, -1
	  ENDIF
 
	  I3 = F3*NEL
	  I4 = F4*NEL
	  IF I3 EQ I4 THEN BEGIN
	    IF F3 LT .25 THEN BEGIN
	      I4 = I3 + 1
	    ENDIF ELSE BEGIN
	      I3 = I4 - 1
	    ENDELSE
	  ENDIF
	  W = (1 - BLEND(NEL/2+1, FIX(I3), FIX(I4)))*(1 - W)
	ENDIF
 
	R = REVERSE(W(1:*))
	IF (NEL MOD 2) EQ 0 THEN BEGIN
	  W = [W, R(1:*)]
	ENDIF ELSE BEGIN
	  W = [W, R]
	ENDELSE
 
	RETURN, W
	END
