;-------------------------------------------------------------
;+
; NAME:
;       VARIANCE
; PURPOSE:
;       Computes the variance of an array of numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       v = variance(a, [m])
; INPUTS:
;       a = input array.                    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v = variance of array a.            out
;       m = optionally returned mean of a.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       blg 23-feb-86
;       Johns Hopkins University Applied Physics Laboratory.
;       Modified B. Gotwols, R. Sterner --- 1 Oct, 1986  error check.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
     FUNCTION VARIANCE,A, MU, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Computes the variance of an array of numbers.'
	  print,' v = variance(a, [m])'
	  print,'   a = input array.                    in'
	  print,'   v = variance of array a.            out'
	  print,'   m = optionally returned mean of a.  out'
	  return, -1
	endif
 
	IF NOT ISARRAY(A) THEN BEGIN
	  PRINT,'Error in VARIANCE: argument must be an array.'
	  RETURN, -1
	ENDIF
	T = DATATYPE(A)
	IF T EQ 'UND' THEN BEGIN
	  PRINT,'Error in VARIANCE: Undefined argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'STR') OR (T EQ 'COM') THEN BEGIN
	  PRINT,'Error in VARIANCE: Wrong type argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'BYT') OR (T EQ 'INT') OR (T EQ 'LON') THEN BEGIN
	  TMP = FLOAT(A)
	ENDIF
	IF (T EQ 'FLO') OR (T EQ 'DOU') THEN BEGIN
	  TMP = A
	ENDIF
 
	mu = mean(tmp)
	tmp= tmp-mu		; This assures we won't lose precision!
        var = mean(tmp*tmp)
 
        RETURN,var
        END
