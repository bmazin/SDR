;-------------------------------------------------------------
;+
; NAME:
;       FIXGAPS
; PURPOSE:
;       Linearly interpolate across data gaps in an array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = fixgaps(a, tag)
; INPUTS:
;       a = array to process.                 in
;       tag = value in data gaps (def=0).     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = interpolated array.             out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       RES 20 Oct, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function fixgaps, y, flag, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Linearly interpolate across data gaps in an array.'
	  print,' out = fixgaps(a, tag)'
	  print,'   a = array to process.                 in'
	  print,'   tag = value in data gaps (def=0).     in'
	  print,'   out = interpolated array.             out'
	  return,-1
	endif
 
	if n_params(0) lt 2 then flag = 0	; Default flag value.
	nx = n_elements(y)			; Array size.
	x = indgen(nx)				; Corresponding x array.
 
	w = where(y ne flag)			; Find good values.
 
	return, interpol(y(w), x(w), x)		; Interpolate missing values.
 
	end
