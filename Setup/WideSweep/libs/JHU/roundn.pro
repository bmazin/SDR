;-------------------------------------------------------------
;+
; NAME:
;       ROUNDN
; PURPOSE:
;       Round values to n decimal places.
; CATEGORY:
; CALLING SEQUENCE:
;       v2 = roundn(v1, n)
; INPUTS:
;       v1 = input value (may be an array).                in
;       n = number of decimal places to round to (def=0).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /STRING return value(s) as string(s).
;         FORMAT=fmt  Format to use with /STRING instead of default.
; OUTPUTS:
;       v2 = returned rounded value(s).                    out
; COMMON BLOCKS:
; NOTES:
;       Note: v2 has same data type as v1.  Giving an incorrect
;         format may give invalid rounding.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 04
;       R. Sterner, 2005 Apr 08 --- Added /L64 to round.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function roundn, v1, n, string=string, format=fmt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Round values to n decimal places.'
	  print,' v2 = roundn(v1, n)'
	  print,'   v1 = input value (may be an array).                in'
	  print,'   n = number of decimal places to round to (def=0).  in'
	  print,'   v2 = returned rounded value(s).                    out'
	  print,' Keywords:'
	  print,'   /STRING return value(s) as string(s).'
	  print,'   FORMAT=fmt  Format to use with /STRING instead of default.'
	  print,' Note: v2 has same data type as v1.  Giving an incorrect'
	  print,'   format may give invalid rounding.'
	  return,''
	endif
 
	if n_elements(n) eq 0 then n=0
 
	typ = size(v1,/type)
 
	v2 = fix(round(v1*10D0^n,/L64)/10d0^n, type=typ)
 
	if keyword_set(string) then begin
	  if n_elements(fmt) eq 0 then $
	    if n le 0 then fmt='(I22)' else fmt='(F30.'+strtrim(n,2)+')'
	  v2 = strtrim(string(v2,form=fmt),2)
	endif
 
	return, v2
 
	end
