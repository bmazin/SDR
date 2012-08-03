;-------------------------------------------------------------
;+
; NAME:
;       C2HSV
; PURPOSE:
;       Convert a 24-bit color value to Hue, Saturation, Value.
; CATEGORY:
; CALLING SEQUENCE:
;       c2hsv, c, h, s, v
; INPUTS:
;       c = input 24-bit color value.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       h,s,v = returned H,S,V values.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: example: c=13369241, h,s,v = 149.412, 0.4, 1.0
;       
;       Inverse of rgb2c, /hsv.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 17
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro c2hsv, c, h, s, v, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a 24-bit color value to Hue, Saturation, Value.'
	  print,' c2hsv, c, h, s, v'
	  print,'   c = input 24-bit color value.   in'
	  print,'   h,s,v = returned H,S,V values.  out'
	  print,' Notes: example: c=13369241, h,s,v = 149.412, 0.4, 1.0'
	  print,' '
	  print,' Inverse of rgb2c, /hsv.'
	  return
	endif
 
	b = c/65536L
	c2 = c-65536L*b
	g = c2/256
	r = c2 mod 256
 
	color_convert, r, g, b, h, s, v, /rgb_hsv
 
	end
