;-------------------------------------------------------------
;+
; NAME:
;       LASTPLOT
; PURPOSE:
;       Backup !p.multi to last plot position.
; CATEGORY:
; CALLING SEQUENCE:
;       lastplot
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: needed for !p.multi plots using multiple plot calls.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Feb 16.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro lastplot, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Backup !p.multi to last plot position.'
	  print,' lastplot'
	  print,'   No args.'
	  print,' Notes: needed for !p.multi plots using multiple plot calls.'
	  return
	endif
 
	nn = (!p.multi(1)>1)*(!p.multi(2)>1)
	k = (!p.multi(0) + 1) mod nn
	!p.multi(0) = k
 
	return
	end 
