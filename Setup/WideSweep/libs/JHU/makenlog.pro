;-------------------------------------------------------------
;+
; NAME:
;       MAKENLOG
; PURPOSE:
;       Make array of N values, logarithmic between two given limits.
; CATEGORY:
; CALLING SEQUENCE:
;       x = makenlog( first, last, num)
; INPUTS:
;       first, last = array start and end values.          in
;       num = number of values from first to last.         in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x = array of logarithmically spaced values.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  4 Sep, 1992, original by Bruce Gotwols.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makenlog,xlo,xhi,n, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make array of N values, logarithmic between two given limits.'
	  print,'  x = makenlog( first, last, num)
	  print,'    first, last = array start and end values.          in'
	  print,'    num = number of values from first to last.         in'
	  print,'    x = array of logarithmically spaced values.        out' 
	  return, -1
	endif
 
	if n le 1 then return, [xlo]		; spec. case.
 
	xlhi = alog(xhi)
	xllo = alog(xlo)
	xst = (xlhi-xllo)/float(n-1)		; step size.
 
	return, exp(xllo+xst*findgen(n))
 
	end
