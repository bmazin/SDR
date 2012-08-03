;-------------------------------------------------------------
;+
; NAME:
;       NUM_DEC
; PURPOSE:
;       Number of decimal places in given number.
; CATEGORY:
; CALLING SEQUENCE:
;       nd = num_dec(val)
; INPUTS:
;       val = number to examine.              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       nd = number of decimal places in val. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 15 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function num_dec, val,help=hlp
	
	if keyword_set(hlp) then begin
	  print,' Number of decimal places in given number.'
	  print,' nd = num_dec(val)'
	  print,'  val = number to examine.              in'
	  print,'  nd = number of decimal places in val. out'
	  return,''
	endif
 
	t = strtrm2(val,2,'0')
	if strpos(t,'.') eq -1 then begin
	  nd = 0
	endif else begin
	  nd = strlen(t)-strpos(t,'.')-1
	endelse
 
	return, nd
 
	end
