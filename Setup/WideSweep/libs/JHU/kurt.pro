;-------------------------------------------------------------
;+
; NAME:
;       KURT
; PURPOSE:
;       Returns the kurtosis of an array (4th moment/2nd moment^2).
; CATEGORY:
; CALLING SEQUENCE:
;       k = kurt(a)
; INPUTS:
;       a = input array.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       k = kurtosis of a.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function kurt,a, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns the kurtosis of an array (4th moment/2nd moment^2).'
	  print,' k = kurt(a)' 
	  print,'   a = input array.    in'
	  print,'   k = kurtosis of a.  out' 
	  return, -1
	endif
 
	if not isarray(a) then begin
	  print,' Error in kurt: argument must be an array.'
	  return, -1
	endif
	t = datatype(a)
	if t eq 'UND' then begin
	  print,' Error in kurt: Undefined argument.'
	  return, -1
	endif
	if (t eq 'STR') or (t eq 'COM') then begiN
	  print,' Error in kurt: Wrong type argument.'
	  return, -1
	endif
	if (t eq 'BYT') or (t eq 'INT') or (t eq 'LON') then begin
	  tmp = float(a)
	endif
	if (t eq 'FLO') or (t eq 'DOU') then begin
	  tmp = a
	endif
 
	mu = mean(tmp)
	tmp = tmp - mu		; Avoid loss of precision.
	sd = sdev(tmp)
	if sd eq 0. then return, 0.
	s = mean(tmp^4)/sd^4
	return,s
 
	end
