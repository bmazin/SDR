;-------------------------------------------------------------
;+
; NAME:
;       NEXTPLOT
; PURPOSE:
;       Update !p.multi to next plot position.
; CATEGORY:
; CALLING SEQUENCE:
;       nextplot
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: needed for plots using the /noerase option.
; MODIFICATION HISTORY:
;       R. Sterner, 26 Sep, 1990
;       R. Sterner, 8 Jul, 1993 --- Handled the case where nx or
;       ny is 0 but used as 1.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro nextplot, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Update !p.multi to next plot position.'
	  print,' nextplot'
	  print,'   No args.'
	  print,' Notes: needed for plots using the /noerase option.'
	  return
	endif
 
	nn = (!p.multi(1)>1)*(!p.multi(2)>1)
	k = (!p.multi(0) - 1) mod nn
	if k lt 0 then k = k + nn
	!p.multi(0) = k
 
	return
	end 
