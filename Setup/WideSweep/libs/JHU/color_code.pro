;-------------------------------------------------------------
;+
; NAME:
;       COLOR_CODE
; PURPOSE:
;       Color code a range of value.
; CATEGORY:
; CALLING SEQUENCE:
;       clr = color_code(val)
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         V1=v1, V2=v2  Start and end values to code (def=min, max).
;         H1=h1, H2=h2  Start and end Hues (def=0, 300).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Sat and Val are set to 1.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 16
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function color_code, val, v1=v1, h1=h1, v2=v2, h2=h2, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Color code a range of value.'
	  print,' clr = color_code(val)'
	  print,'   val = Array of values to color code.'
	  print,'   clr = Returned array of colors.'
	  print,' Keywords:'
	  print,'   V1=v1, V2=v2  Start and end values to code (def=min, max).'
	  print,'   H1=h1, H2=h2  Start and end Hues (def=0, 300).'
	  print,' Note: Sat and Val are set to 1.'
	  return,''
	endif
 
	;-------  Defaults  -----------
	if n_elements(v1) eq 0 then v1=min(val)
	if n_elements(v2) eq 0 then v2=max(val)
	if n_elements(h1) eq 0 then h1=0.
	if n_elements(h2) eq 0 then h2=300.
 
	;-------  Scale values  -------
	h = scalearray(val,v1,v2,h1,h2)
 
	;-------  Make colors  --------
	n = n_elements(val)
	clr = lonarr(n)
	for i=0,n-1 do clr(i)=tarclr(/hsv,h(i),1.,1.)
 
	return,clr
	end
