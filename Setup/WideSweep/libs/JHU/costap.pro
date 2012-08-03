;-------------------------------------------------------------
;+
; NAME:
;       COSTAP
; PURPOSE:
;       Cosine taper weighting from 1 at center to 0 at ends.
; CATEGORY:
; CALLING SEQUENCE:
;       w = costap(n,[f])
; INPUTS:
;       n = # of pts in weighting array.               in
;       f = fraction of pts in flat region (def=0).    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       w = weight with values from 0 to 1.            out
; COMMON BLOCKS:
; NOTES:
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
 
	function costap,w,r, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Cosine taper weighting from 1 at center to 0 at ends.'
	  print,' w = costap(n,[f])
	  print,'   n = # of pts in weighting array.               in'
	  print,'   f = fraction of pts in flat region (def=0).    in' 
	  print,'   w = weight with values from 0 to 1.            out'
	  return, -1
	endif
 
	if n_params(0) lt 2 then r = 0.
	pi = 3.1415926535
	h = w/2.
	return,.5*(1.+cos(((abs(findgen(w)-h)-r*h)*(pi/(h*(1.-r))) > 0.) < pi))
	end
