;-------------------------------------------------------------
;+
; NAME:
;       COLOR_ARRAY
; PURPOSE:
;       Make an array of colors.
; CATEGORY:
; CALLING SEQUENCE:
;       clr = color_array(n, h1, h2, s1, s2, v1, v2)
; INPUTS:
;       n = Number of colors to make.     in
;       h1 = Starting hue.                in
;       h2 = Ending hue.                  in
;       s1 = Starting saturation (def=1). in
;       s2 = Ending saturation (def=s1).  in
;       v1 = Starting value (def=1).      in
;       v2 = Ending value (def=v1).       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       clr = Returned color array.       out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 09
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function color_array, n, h1, h2, s1, s2, v1, v2, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make an array of colors.'
	  print,' clr = color_array(n, h1, h2, s1, s2, v1, v2)'
	  print,'   n = Number of colors to make.     in'
	  print,'   h1 = Starting hue.                in'
	  print,'   h2 = Ending hue.                  in'
	  print,'   s1 = Starting saturation (def=1). in'
	  print,'   s2 = Ending saturation (def=s1).  in'
	  print,'   v1 = Starting value (def=1).      in'
	  print,'   v2 = Ending value (def=v1).       in'
	  print,'   clr = Returned color array.       out'
	  return,''
	endif
 
	if n_elements(s1) eq 0 then s1=1.
	if n_elements(s2) eq 0 then s2=s1
	if n_elements(v1) eq 0 then v1=1.
	if n_elements(v2) eq 0 then v2=v1
	
	h = maken(h1,h2,n)
	s = maken(s1,s2,n)
	v = maken(v1,v2,n)
	clr = lonarr(n)
	for i=0,n-1 do clr(i)=tarclr(/hsv,h(i),s(i),v(i))
	return,clr
 
	end
