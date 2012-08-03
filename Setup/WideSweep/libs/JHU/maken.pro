;-------------------------------------------------------------
;+
; NAME:
;       MAKEN
; PURPOSE:
;       Make an array of N values, linear between two given limits.
; CATEGORY:
; CALLING SEQUENCE:
;       x = makex( first, last, num)
; INPUTS:
;       first, last = array start and end values.          in
;       num = number of values from first to last.         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x = array of values.                               out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  26 Sep, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1984, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function maken,xlo,xhi,n, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make an array of N values, linear between two given limits.'
	  print,'  x = makex( first, last, num)
	  print,'    first, last = array start and end values.          in'
	  print,'    num = number of values from first to last.         in'
	  print,'    x = array of values.                               out' 
	  return, -1
	endif
 
	if n le 1 then return, [xlo]	; spec. case.
	xst = (xhi-xlo)/float(n-1)	; Step size.
	return, xlo+xst*findgen(n)
 
	end
