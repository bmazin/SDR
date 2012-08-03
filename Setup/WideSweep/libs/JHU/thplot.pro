;-------------------------------------------------------------
;+
; NAME:
;       THPLOT
; PURPOSE:
;       Plot a curve with varying thickness along it.
; CATEGORY:
; CALLING SEQUENCE:
;       thplot, x, y  or thplot, y
; INPUTS:
;       x, y = array of x,y values along curve.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         CTHICK=cthk Thickness along curve (def=0).
;         FILL=fclr   Fill color of thick curve (def=!p.color).
;         /CCLIP  means clip a thick curve to plot window.
;         CBACK=cbak  0 thickness curve background color (def=none).
;         CCOLOR=cclr 0 thickness curve foreground color.
;         CSTYLE=csty 0 thickness curve line style (def=1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: CTHICK must be given an array with same number of
;         elements as x and y (or it may be a scalar).  Curve is
;         plotted with filled region between y-cthk/2 and y+cthk/2.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Dec 7
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro thplot, x0, y0, help=hlp, cthick=cthk, fill=fill, $
	  ccolor=cclr, cback=cbak, cstyle=csty, cclip=cclip, _extra=extra
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a curve with varying thickness along it.'
	  print,' thplot, x, y  or thplot, y'
	  print,'   x, y = array of x,y values along curve.   in'
	  print,' Keywords:'
	  print,'   CTHICK=cthk Thickness along curve (def=0).'
	  print,'   FILL=fclr   Fill color of thick curve (def=!p.color).'
	  print,'   /CCLIP  means clip a thick curve to plot window.'
	  print,'   CBACK=cbak  0 thickness curve background color (def=none).'
	  print,'   CCOLOR=cclr 0 thickness curve foreground color.'
	  print,'   CSTYLE=csty 0 thickness curve line style (def=1).'
	  print,' Note: CTHICK must be given an array with same number of'
	  print,'   elements as x and y (or it may be a scalar).  Curve is'
	  print,'   plotted with filled region between y-cthk/2 and y+cthk/2.'
	endif
 
	;-------  Set defaults  ---------
	if n_elements(cthk) eq 0 then begin
	  print,' Error in thplot: must give a value to CTHICK.'
	  return
	endif
	if n_elements(fill) eq 0 then fill = !p.color
	if n_elements(cclr) eq 0 then cclr = !p.color
	if n_elements(csty) eq 0 then csty = 1
 
	;---------  Handle 1 or 2 args  --------
	if n_params(0) eq 2 then begin
	  x = x0
	  y = y0
	endif else begin
	  y = x0
	  x = findgen(n_elements(y))
	endelse
 
	;--------  Scale plot  ------------------
	plot, x, y, /nodata, _extra=extra
	oplot, x, y, linestyle=csty, color=cclr
 
	;--------  Do thick curve  --------------
	noclip=1
	if keyword_set(cclip) then noclip=0
	polyfill, [x,reverse(x)],[(y-cthk/2.),reverse(y+cthk/2.)],$
	  noclip=noclip, color=fill
	plot, x, y, /nodata, /noerase, _extra=extra
 
	;--------  Do curve center and 0 thickness  ----
	if n_elements(cbak) ne 0 then begin
	  oplot, x, y, color=cbak
	  oplot, x, y, linestyle=csty, color=cclr
	endif
	
	return
	end
