;-------------------------------------------------------------
;+
; NAME:
;       MAKELABELS
; PURPOSE:
;       Make an array of tick mark labels.
; CATEGORY:
; CALLING SEQUENCE:
;       lbl = makelabels(value_array, ndec)
; INPUTS:
;       value_array = Array of values.		in
;       ndec = Number of decimal places to use.	in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       lbl = String array of labels.		out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 7 Nov, 1988.
;       R. Sterner, 26 Feb, 1991 --- Renamed from make_labels.pro
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function makelabels, v, nd,help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Make an array of tick mark labels.'
	  print,' lbl = makelabels(value_array, ndec)'
	  print,'   value_array = Array of values.		in'
	  print,'   ndec = Number of decimal places to use.	in'
	  print,'   lbl = String array of labels.		out'
	  return,-1
	endif
 
 
	n = n_elements(v)
 
	mx = 0
	ff = '(f20.' + strtrim(nd,2) + ')'
	if nd gt 0 then begin
	  for i = 0, n-1 do begin
	    mx = mx > strlen( strtrim( string(v(i), ff),2))
	  endfor
	endif else begin
	  for i = 0, n-1 do begin
	    mx = mx > strlen( strtrim( fix(v(i)),2))
	  endfor
	endelse
 
	s = strarr(mx, n)
	if nd gt 0 then ff = '(f' + strtrim(mx,2) + '.' + strtrim(nd,2) + ')'
	if nd eq 0 then fi = '(i' + strtrim(mx,2) + ')'
 
	for i = 0, n-1 do begin
	  if nd gt 0 then s(i) = string(v(i), ff)
	  if nd eq 0 then s(i) = string(fix(v(i)), fi)
	endfor
 
	return, s
	end
