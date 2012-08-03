;-------------------------------------------------------------
;+
; NAME:
;       BELL
; PURPOSE:
;       Ring terminal bell.
; CATEGORY:
; CALLING SEQUENCE:
;       bell, [n]
; INPUTS:
;       n = number of rings (def=1).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 20 Oct, 1989.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro bell, n, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Ring terminal bell.'
	  print,' bell, [n]'
	  print,' n = number of rings (def=1).  in'
	  return
	endif
 
	if n_elements(n) eq 0 then n = 1
	for i = 1, n do begin
	  print,string(7b), format='($,a)'
	  wait, .1
	endfor
 
	return
	end
