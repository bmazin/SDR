;-------------------------------------------------------------
;+
; NAME:
;       C2RGB
; PURPOSE:
;       Convert a 24-bit color value to Red, Green, Blue values.
; CATEGORY:
; CALLING SEQUENCE:
;       c2rgb, c, r, g, b
; INPUTS:
;       c = input 24-bit color value.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r,g,b = returned R,G,B values.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: example: c=9856050, r,g,b = 50,100,150.
;       
;       Inverse of rgb2c.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jan 09
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro c2rgb, c, r, g, b, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a 24-bit color value to Red, Green, Blue values.'
	  print,' c2rgb, c, r, g, b'
	  print,'   c = input 24-bit color value.   in'
	  print,'   r,g,b = returned R,G,B values.  out'
	  print,' Notes: example: c=9856050, r,g,b = 50,100,150.'
	  print,' '
	  print,' Inverse of rgb2c.'
	  return
	endif
 
	b = c/65536L
	c2 = c-65536L*b
	g = c2/256
	r = c2 mod 256
 
	end
