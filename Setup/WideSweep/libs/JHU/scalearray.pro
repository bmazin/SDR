;-------------------------------------------------------------
;+
; NAME:
;       SCALEARRAY
; PURPOSE:
;       Linearly scale array values to specified range.
; CATEGORY:
; CALLING SEQUENCE:
;       b = scalearray( a, in1, in2, [out1, out2])
; INPUTS:
;       a = array to scale.                          in
;       in1 = array value to scale to out1.          in
;       in2 = array value to scale to out2.          in
;       out1 = value in1 gets scaled to (def=0).     in
;       out2 = value in2 gets scaled to (def=255).   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = scaled array.                            out
; COMMON BLOCKS:
; NOTES:
;       Notes: Does not clip input to in1, in2, so outputs
;       can also go beyond out1, and out2.  This allows
;       arrays of data to be linearly scaled.
;       Also be careful using unsigned integers.
; MODIFICATION HISTORY:
;       R. Sterner. 12 Nov, 1986.
;       RES 30 Aug, 1989 --- converted to SUN.
;       R. Sterner, 26 Feb, 1991 --- Renamed from scale_array.pro
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION SCALEARRAY, A, IN1, IN2, OUT1, OUT2, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Linearly scale array values to specified range.'
	  print,' b = scalearray( a, in1, in2, [out1, out2])
	  print,'   a = array to scale.                          in'
	  print,'   in1 = array value to scale to out1.          in'
	  print,'   in2 = array value to scale to out2.          in'
	  print,'   out1 = value in1 gets scaled to (def=0).     in'
	  print,'   out2 = value in2 gets scaled to (def=255).   in'
	  print,'   b = scaled array.                            out'
	  print,' Notes: Does not clip input to in1, in2, so outputs'
	  print,' can also go beyond out1, and out2.  This allows'
	  print,' arrays of data to be linearly scaled.'
	  print,' Also be careful using unsigned integers.'
	  return, -1
	endif
 
	IF N_PARAMS(0) LT 5 THEN BEGIN		; default output is 0 to 255.
	  OUT1 = 0
	  OUT2 = 255
	ENDIF
 
	IF IN1 EQ IN2 THEN BEGIN
	  PRINT,' Warning in SCALEARRAY: the two input values must differ.'
	  print,'   Returning array of 0s.'
	  RETURN, a*0
	ENDIF
 
	B = (A - IN1)*FLOAT(OUT2-OUT1)/(IN2-IN1) + OUT1
 
	RETURN, B
	END
