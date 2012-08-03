;-------------------------------------------------------------
;+
; NAME:
;       MAKEMS
; PURPOSE:
;       Make array of values from start to end with a max step size.
; CATEGORY:
; CALLING SEQUENCE:
;       a = makems(start,stop,maxstep)
; INPUTS:
;       start = starting value.         in
;       stop = ending value.            in
;       maxstep = max step size to use. in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a = returned array of values.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: example: print,makems(0,360000,100000) gives
;         0      100000      200000      300000      360000
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Apr 15
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function makems, p0, p1, s, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make array of values from start to end with a max step size.'
	  print,' a = makems(start,stop,maxstep)'
	  print,'   start = starting value.         in'
	  print,'   stop = ending value.            in'
	  print,'   maxstep = max step size to use. in'
	  print,'   a = returned array of values.   out'
	  print,' Notes: example: print,makems(0,360000,100000) gives'
	  print,'   0      100000      200000      300000      360000'
	  return,''
	endif
 
	if p0 lt p1 then begin
	  a = (p0+dindgen(ceil(float(p1-p0)/s)+1)*s)<p1>p0
	endif else begin
	  a = (p0-dindgen(ceil(float(p0-p1)/s)+1)*s)<p0>p1
	endelse
 
	return,a
 
	end
