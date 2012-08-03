;-------------------------------------------------------------
;+
; NAME:
;       BLEND
; PURPOSE:
;       Sets up weighting array for blending arrays together.
; CATEGORY:
; CALLING SEQUENCE:
;       WT = BLEND(N,I1,I2)
; INPUTS:
;       N = size of array to make.				  in
;       I1, I2 = indices of first and last values to blend.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       WT = weighting array.                                 out
;          WT(0:I1) = 0
;          WT(I1:I2) = cosine shaped weighting from 0 to 1.
;          WT(I2:*) = 1
; COMMON BLOCKS:
; NOTES:
;       Notes: to blend arrays A and B: A*(1-WT) + B*WT
;         starts with pure A and ends with pure B.
; MODIFICATION HISTORY:
;       Written by R. Sterner  6 Jan, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION BLEND, N, I1, I2, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Sets up weighting array for blending arrays together.'
	  print,' WT = BLEND(N,I1,I2)'
	  print,'   N = size of array to make.				  in'
	  print,'   I1, I2 = indices of first and last values to blend.   in'
	  print,'   WT = weighting array.                                 out'
	  print,'      WT(0:I1) = 0'
	  print,'      WT(I1:I2) = cosine shaped weighting from 0 to 1.'
	  print,'      WT(I2:*) = 1'
	  print,' Notes: to blend arrays A and B: A*(1-WT) + B*WT'
	  print,'   starts with pure A and ends with pure B.'
	  return, -1
	ENDIF
 
	PI = 3.1415926535D0
	WT = FLTARR(N)
	WT(I2:*)=PI
	LINFILL, WT, I1,I2
	WT = .5*(1.-COS(WT))
	RETURN, WT
	END
