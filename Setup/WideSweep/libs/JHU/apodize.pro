;-------------------------------------------------------------
;+
; NAME:
;       APODIZE
; PURPOSE:
;       Weighting array for apodizing an image.  Cosine taper.
; CATEGORY:
; CALLING SEQUENCE:
;       a = apodize(w, r)
; INPUTS:
;       w = size of square array a to make.             in
;       r = radius of flat top as a fraction 0 to 1.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a = resulting array.                            out
; COMMON BLOCKS:
; NOTES:
;       Notes: Output array is square.  To convert to rectangular
;          use congrid to specify desired size and shape:
;          b = congrid(a, 100,50)
; MODIFICATION HISTORY:
;       Written by R. Sterner, 6 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION APODIZE,W,R, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Weighting array for apodizing an image.  Cosine taper.' 
	  print,' a = apodize(w, r)
	  print,'   w = size of square array a to make.             in'
	  print,'   r = radius of flat top as a fraction 0 to 1.    in'
	  print,'   a = resulting array.                            out'
	  print,'Notes: Output array is square.  To convert to rectangular'
	  print,'   use congrid to specify desired size and shape:'
	  print,'   b = congrid(a, 100,50)'
	  return, -1
	endif
 
	IF N_PARAMS(0) LT 2 THEN R = 0.
	PI = 3.1415926535
	H = W/2.
	RETURN,.5*(1.+COS(((SHIFT(DIST(W),H,H)-R*H)*(PI/(H*(1.-R))) > 0.)$
	  < PI))
	END
