;-------------------------------------------------------------
;+
; NAME:
;       WRAP_PLOT
; PURPOSE:
;       Simple wrapper routine to demonstrate _extra.
; CATEGORY:
; CALLING SEQUENCE:
;       wrap_plot, x, y
; INPUTS:
;       x,y = array to plot.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         Any plot keywords are be passed through _extra.
;         keywords in the call.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Keywords sent through _extra override matching
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Apr 23
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro wrap_plot, x0, y0, _extra=extra, help=hlp
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Simple wrapper routine to demonstrate _extra.'
	  print,' wrap_plot, x, y'
	  print,'   x,y = array to plot.   in'
	  print,' Keywords:'
	  print,'   Any plot keywords are be passed through _extra.'
	  print,' Note: Keywords sent through _extra override matching'
	  print,'   keywords in the call.'
	  return
	endif
 
	;-------  Deal with 1 or 2 arguments  -----
	if n_elements(y0) gt 0 then begin
	  x = x0
	  y = y0
	endif else begin
	  y = x0
	  x = findgen(n_elements(x0))
	endelse
 
	clr = tarclr(0,255,0)
	thk = 2
 
	plot, x, y, thick=thk, col=clr, _extra=extra
 
	end
