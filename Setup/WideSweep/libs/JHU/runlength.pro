;-------------------------------------------------------------
;+
; NAME:
;       RUNLENGTH
; PURPOSE:
;       Give run lengths for array values.
; CATEGORY:
; CALLING SEQUENCE:
;       y = runlength(x,[r])
; INPUTS:
;       x = 1-d array of values.                  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = X with multiple values squeezed out.  out
;       r = run length of each element in Y.      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       RES  30 Jan, 1986.
;       R. Sterner, 25 Sep, 1990 --- converted to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION RUNLENGTH,X,R, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Give run lengths for array values.'
	  print,' y = runlength(x,[r])'
	  print,'   x = 1-d array of values.                  in'
	  print,'   y = X with multiple values squeezed out.  out'
	  print,'   r = run length of each element in Y.      out'
	  return, -1
	endif
 
	;---  The easiest way to understand how this works is to try
	;---  these statements interactively.
	A = X - SHIFT(X,1)	; Distance to next value.
	A(0) = 1		; Always want first value.
	W = WHERE(A NE 0)	; Look for value changes.
	Y = X(W)		; Pick out unique values.
	IF N_PARAMS(0) LT 2 THEN RETURN, Y
	R = ([W,N_ELEMENTS(X)])(1:(N_ELEMENTS(Y))) - W  ; run lengths.
	RETURN, Y
	END
