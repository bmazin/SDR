;-------------------------------------------------------------
;+
; NAME:
;       SWAP
; PURPOSE:
;       Swap two values.
; CATEGORY:
; CALLING SEQUENCE:
;       swap, a, b
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Nov 12
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro swap, a, b, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Swap two values.'
	  print,' swap, a, b'
	  print,'   a, b = two values to swap.    in,out'
	  return
	endif
 
	t = a
	a = b
	b = t
 
	return
	end
