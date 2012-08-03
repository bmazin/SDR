;-------------------------------------------------------------
;+
; NAME:
;       SOPLOT
; PURPOSE:
;       Make a shaded over plot.
; CATEGORY:
; CALLING SEQUENCE:
;       soplot, x, y
; INPUTS:
;       x, y = x and y arrays to plot (must have both).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         SHADE=txt  Name of a color (like "red").
;           Do color,/list for a list of available colors.
;         STHICK=t   Thickness of shaded colors (def=1).
;         COLOR=c  Color index to use for shade color.  Uses
;           indices +/-1 also.
;         + any keywords allowed to plot.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 7 Oct, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro soplot, x, y, shade=ctxt, sthick=sthk, color=col, $
	  help=hlp, _EXTRA=xtr
 
        if (n_params(0) lt 2) or keyword_set(help) then begin
          print,' Make a shaded over plot.'
          print,' soplot, x, y'
          print,'   x, y = x and y arrays to plot (must have both).  in'
          print,' Keywords:'
          print,'   SHADE=txt  Name of a color (like "red").'
          print,'     Do color,/list for a list of available colors.'
          print,'   STHICK=t   Thickness of shaded colors (def=1).'
          print,'   COLOR=c  Color index to use for shade color.  Uses'
          print,'     indices +/-1 also.'
          print,'   + any keywords allowed to plot.'
          return
        endif
 
	;---------  Set up colors  ----------
	if n_elements(ctxt) eq 0 then ctxt = 'Green'
	if n_elements(col) eq 0 then col = 30
	ic = col
	color,ctxt,ic
	color,'very pale '+ctxt,ic+1
	color,'dark '+ctxt,ic-1
 
	if n_elements(sthk) eq 0 then sthk = 1
 
	;--------  1 Pixel shift in data coordinates  -----------
	dx = 1./(!d.x_size*!x.s(1))
	dy = 1./(!d.y_size*!y.s(1))
 
	;--------  Dark side  ----------
	for t = -1,-(1>sthk/2),-1 do begin
	  oplot, x+(t-sthk+1)*dx, y+(t-sthk+1)*dy, color=ic-1, _EXTRA=xtr
	endfor
 
	;--------  Bright side  ----------
	for t = sthk,sthk+(1>(sthk/2-1)) do begin
	  oplot, x+(t-sthk+1)*dx, y+(t-sthk+1)*dy, color=ic+1, _EXTRA=xtr
	endfor
 
	;--------  Normal  ----------
	for t = 0, sthk-1 do begin
	  oplot, x+(t-sthk+1)*dx, y+(t-sthk+1)*dy, color=ic, _EXTRA=xtr
	endfor
 
	return
	end
