;-------------------------------------------------------------
;+
; NAME:
;       SPLOT
; PURPOSE:
;       Make a shaded plot.
; CATEGORY:
; CALLING SEQUENCE:
;       splot, x, y
; INPUTS:
;       x, y = x and y arrays to plot (must have both).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         SHADE=txt  Name of a color (like "red").
;           Do color,/list for a list of available colors.
;         STHICK=t   Thickness of shaded colors (def=1).
;         POSITION=pos  Plot position array, must be in device
;           coordinates.
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
 
	pro splot, x, y, shade=ctxt, sthick=sthk, position=pos, $
	  color=col, help=hlp, _EXTRA=xtr
 
	if (n_params(0) lt 2) or keyword_set(help) then begin
	  print,' Make a shaded plot.'
	  print,' splot, x, y'
	  print,'   x, y = x and y arrays to plot (must have both).  in'
	  print,' Keywords:'
	  print,'   SHADE=txt  Name of a color (like "red").'
	  print,'     Do color,/list for a list of available colors.'
	  print,'   STHICK=t   Thickness of shaded colors (def=1).'
	  print,'   POSITION=pos  Plot position array, must be in device'
	  print,'     coordinates.'
	  print,'   COLOR=c  Color index to use for shade color.  Uses'
	  print,'     indices +/-1 also.'
	  print,'   + any keywords allowed to plot.'
	  return
	endif
 
	;----------  Position  --------
	if n_elements(pos) eq 0 then pos = [.2,.2,.8,.8]
	x1 = fix(pos(0)*!d.x_size)
	y1 = fix(pos(1)*!d.y_size)
	x2 = fix(pos(2)*!d.x_size)
	y2 = fix(pos(3)*!d.y_size)
 
	;---------  Set up colors  ----------
	if n_elements(ctxt) eq 0 then ctxt = 'Green'
	if n_elements(col) eq 0 then col = 20
	ic = col
	color,ctxt,ic
	color,'very pale '+ctxt,ic+1
	color,'dark '+ctxt,ic-1
 
	if n_elements(sthk) eq 0 then sthk = 1
 
	;--------  Dark side  ----------
	for t = -1,-(1>sthk/2),-1 do begin
	  plot, x, y, color=ic-1, pos=[x1,y1,x2,y2]+t*[1,1,1,1],$
	    /dev,_EXTRA=xtr,/noerase
	endfor
 
	;--------  Bright side  ----------
	for t = sthk,sthk+(1>(sthk/2-1)) do begin
	  plot, x, y, color=ic+1, pos=[x1,y1,x2,y2]+t*[1,1,1,1],$
	    /dev,_EXTRA=xtr,/noerase
	endfor
 
	;--------  Normal  ----------
	;  Note: leaves position off by sthk-1 in both x and y.
	;  Correct for this in soplot.
	;----------------------------
	for t = 0, sthk-1 do begin
	  plot, x, y, color=ic, pos=[x1,y1,x2,y2]+t*[1,1,1,1],$
	    /dev,_EXTRA=xtr,/noerase
	endfor
 
	return
	end
