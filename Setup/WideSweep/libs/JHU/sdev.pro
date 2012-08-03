;-------------------------------------------------------------
;+
; NAME:
;       SDEV
; PURPOSE:
;       Returns standard deviation of an array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = sdev(a)
; INPUTS:
;       a = input array.               in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = standard deviation of a.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by K. Kostoff, 1/16/85
;       Johns Hopkins University Applied Physics Laboratory.
;       Modified by B. Gotwols, R. Sterner --- 1 Oct, 1986.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function sdev,a, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns standard deviation of an array.'
	  print,' s = sdev(a)' 
	  print,'   a = input array.               in'
	  print,'   s = standard deviation of a.   out' 
	  return, -1
	endif
 
	if not isarray(a) then begin
	  print,'Error in sdev: argument must be an array.'
	  return, -1
	endif
	t = datatype(a)
	if t eq 'UND' then begin
	  print,'Error in sdev: Undefined argument.'
	  return, -1
	endif
	if (t eq 'STR') or (t eq 'COM') then begin
	  print,'Error in sdev: Wrong type argument.'
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
	sd = sqrt( mean(tmp^2))
	return,sd
 
	end
