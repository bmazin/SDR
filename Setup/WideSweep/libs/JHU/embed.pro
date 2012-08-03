;-------------------------------------------------------------
;+
; NAME:
;       EMBED
; PURPOSE:
;       Embed an array in a larger array.
; CATEGORY:
; CALLING SEQUENCE:
;       b = embed(a,w)
; INPUTS:
;       a = input array (2-d).                      in
;       w = number of elements to add around edge.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         VALUE=v.  Value for added border (def=0).
; OUTPUTS:
;       b = resulting larger array with a centered. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 13 Dec, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function embed, a, dw0, value=val, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Embed an array in a larger array.'
	  print,' b = embed(a,w)'
	  print,'   a = input array (2-d).                      in'
	  print,'   w = number of elements to add around edge.  in'
	  print,'   b = resulting larger array with a centered. out'
	  print,' Keywords:'
	  print,'   VALUE=v.  Value for added border (def=0).'
	  return, -1
	endif
 
	s = size(a)
	nx = s(1)
	ny = s(2)
	typ = s(s(0)+1)
 
	if n_elements(val) eq 0 then val = 0
	dw = dw0>0
 
	b = make_array(nx+2*dw, ny+2*dw, type=typ, value=val)
 
	b(dw,dw) = a
 
	return, b
	end
