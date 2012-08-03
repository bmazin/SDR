;-------------------------------------------------------------
;+
; NAME:
;       VNORM
; PURPOSE:
;       Normalize an array of values to 0. to 1.
; CATEGORY:
; CALLING SEQUENCE:
;       v2 = vnorm(v1, [scale, offset])
; INPUTS:
;       v1 = input array.                              in
;       scale = optional scale factor (def=1).         in
;       offset = optional offset (def=0).              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v2 = Returned values normalized as indicated.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 23
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function vnorm, val, scale, offset, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Normalize an array of values to 0. to 1.'
	  print,' v2 = vnorm(v1, [scale, offset])'
	  print,'   v1 = input array.                              in'
	  print,'   scale = optional scale factor (def=1).         in'
	  print,'   offset = optional offset (def=0).              in'
	  print,'   v2 = Returned values normalized as indicated.  out'
	  return, ''
	endif
 
	if n_elements(scale) eq 0 then scale=1.
	if n_elements(offset) eq 0 then offset=0.
 
	v1 = val + 0.		; Float.
	v1 = v1-min(v1)
	v1 = v1/max(v1)
 
	return, v1*scale + offset
 
	end
