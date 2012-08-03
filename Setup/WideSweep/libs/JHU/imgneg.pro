;-------------------------------------------------------------
;+
; NAME:
;       IMGNEG
; PURPOSE:
;       Display negative of current image.
; CATEGORY:
; CALLING SEQUENCE:
;       imgneg
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Made as a test routine.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Oct 1
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgneg, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Display negative of current image.'
	  print,' imgneg'
	  print,'   No args.'
	  print,' Notes: Made as a test routine.'
	  return
	endif
 
	if !d.window lt 0 then return
	tvlct,r,g,b,/get
	tvlct,255-r,255-g,255-b
 
	return
	end
