;-------------------------------------------------------------
;+
; NAME:
;       MAKEI
; PURPOSE:
;       Make a long array with given start and end values and step size.
; CATEGORY:
; CALLING SEQUENCE:
;       in = makei(lo, hi, step)
; INPUTS:
;       lo, hi = array start and end values.       in
;       step = distance beteen values.             in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = resulting index array.                out
; COMMON BLOCKS:
; NOTES:
;       Note: good for subsampling an array.
; MODIFICATION HISTORY:
;       Ray Sterner,  14 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION MAKEI,LO0,HI0,ST, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make a long array with given start and end '+$
	    'values and step size.'
	  print,' in = makei(lo, hi, step)'
	  print,'   lo, hi = array start and end values.       in'
	  print,'   step = distance beteen values.             in'
	  print,'   in = resulting index array.                out'
	  print,' Note: good for subsampling an array.'
	  return, -1
	endif
 
	if st lt 0 then begin
	  lo = lo0>hi0
	  hi = lo0<hi0
	endif else begin
	  lo = lo0<hi0
	  hi = lo0>hi0
	endelse

	return, long(lo)+long(st)*lindgen(1+(long(hi)-long(lo))/long(st))

	end
