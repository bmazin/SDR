;-------------------------------------------------------------
;+
; NAME:
;       POLYFILLP
; PURPOSE:
;       Polyfill with pen code for multiple polygons.
; CATEGORY:
; CALLING SEQUENCE:
;       polyfillp, x, y, pen
; INPUTS:
;       x, y = Polygon points arrays.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       pen = Optional pen code: 0=up, 1=down.  out
;          For multiple polygons pen is 0 for
;          first point of each.  Not needed for
;          a single polygon.
; COMMON BLOCKS:
; NOTES:
;       Note: Any keywords that apply to polyfill are
;         allowed.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Oct 14
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro polyfillp, x, y, p0, _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Polyfill with pen code for multiple polygons.'
	  print,' polyfillp, x, y, pen'
	  print,'   x, y = Polygon points arrays.           in'
	  print,'   pen = Optional pen code: 0=up, 1=down.  out'
	  print,'      For multiple polygons pen is 0 for'
	  print,'      first point of each.  Not needed for'
	  print,'      a single polygon.'
	  print,' Note: Any keywords that apply to polyfill are'
	  print,'   allowed.'
	  return
	endif
 
	;-----  Deal with pen code  ----------
	if n_elements(p0) eq 0 then p0=x*0+1	; Default pen code.
	p = p0					; Copy pencode.
	p(0) = 0				; First point must be 0.
	w0 = where([p(0:*),0] eq 0)		; Find all 0s plus end of p.
	nw0 = n_elements(w0)			; # polygons + 1
 
	;------  Loop through polygons  -------
	for i=0L, nw0-2 do begin
	  xx = x(w0(i):(w0(i+1)-1))     ; Extract first connected set.
	  yy = y(w0(i):(w0(i+1)-1))
	  polyfill, xx, yy, _extra=extra
	endfor
 
	end
