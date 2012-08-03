;-------------------------------------------------------------
;+
; NAME:
;       MAKEX
; PURPOSE:
;       Make an array with specified start, end and step values.
; CATEGORY:
; CALLING SEQUENCE:
;       x = makex(first, last, step)
; INPUTS:
;       first, last = array start and end values.     in
;       step = step size between values.              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x = resulting array.                          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  7 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;       Added FIX 20 Dec, 1984 to avoid roundoff error.
;       changed it to LONG 8 Mar, 1985 to avoid integer overflows.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makex,xlo,xhi,xst, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make an array with specified start, end and step values.' 
	  print,' x = makex(first, last, step)' 
	  print,'   first, last = array start and end values.     in'
	  print,'   step = step size between values.              in'
	  print,'   x = resulting array.                          out' 
	  return, -1
	endif
 
	return, xlo+xst*findgen(1+ long( (xhi-xlo)/xst) )

	end
