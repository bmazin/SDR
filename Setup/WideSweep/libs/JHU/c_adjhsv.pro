;-------------------------------------------------------------
;+
; NAME:
;       C_ADJHSV
; PURPOSE:
;       Adjust Hue, Saturation, and Value for a given 24-bit color.
; CATEGORY:
; CALLING SEQUENCE:
;       out = c_adjhsv(in)
; INPUTS:
;       in = Input color.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         HUE=off  Offset to add to Hue, which is in degrees, 0-360.
;         SAT=fct  Factor to apply to Saturation (clipped to 0-1).
;         VAL=fct  Factor to apply to Value (clipped to 0-1).
;           Defaults are no change.
; OUTPUTS:
;       out = Output color.      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 06
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function c_adjhsv, in, hue=hh, sat=ss, val=vv, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Adjust Hue, Saturation, and Value for a given 24-bit color.'
	  print,' out = c_adjhsv(in)'
	  print,'   in = Input color.        in'
	  print,'   out = Output color.      out'
	  print,' Keywords:'
	  print,'   HUE=off  Offset to add to Hue, which is in degrees, 0-360.'
	  print,'   SAT=fct  Factor to apply to Saturation (clipped to 0-1).'
	  print,'   VAL=fct  Factor to apply to Value (clipped to 0-1).'
	  print,'     Defaults are no change.'
	  return, ''
	endif
 
	if n_elements(hh) eq 0 then hh=0
	if n_elements(ss) eq 0 then ss=1
	if n_elements(vv) eq 0 then vv=1
	if (hh eq 0) and (ss eq 1) and (vv eq 1) then return, in
 
	c2rgb, in, r, g, b
	color_convert,r,g,b,h,s,v,/rgb_hsv
	h = h + hh
	s = (s*ss)>0<1
	v = (v*vv)>0<1
	out = tarclr(h,s,v,/hsv)
 
	return, out
 
	end
