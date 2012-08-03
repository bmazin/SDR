;-------------------------------------------------------------
;+
; NAME:
;       PLOT_LIMBOX
; PURPOSE:
;       Plot map limits array as a box on the map.
; CATEGORY:
; CALLING SEQUENCE:
;       plot_limbox, lim
; INPUTS:
;       lim = Map limits array.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /RECT means do a rectangular plot instead of great circle.
;         COLOR=clr  Plot color (def=!p.color).
;         THICKNESS=thk Plot thickness (def=!p.thick).
;         LINESTYLE=sty Plot linestyle (def=!p.linestyle).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Plots limit box edges along great circles.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Nov 05
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro plot_limbox, lim, color=clr, thickness=thk, linestyle=sty, $
	  rect=rect, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot map limits array as a box on the map.'
	  print,' plot_limbox, lim'
	  print,'   lim = Map limits array.   in'
	  print,' Keywords:'
	  print,'   /RECT means do a rectangular plot instead of great circle.'
	  print,'   COLOR=clr  Plot color (def=!p.color).'
	  print,'   THICKNESS=thk Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=sty Plot linestyle (def=!p.linestyle).'
	  print,' Notes: Plots limit box edges along great circles.'
	  return
	endif
 
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(sty) eq 0 then sty=!p.linestyle
 
	y1 = lim(0)
	x1 = lim(1)
	y2 = lim(2)
	x2 = lim(3)
 
	if keyword_set(rect) then begin
	  plots,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1],col=clr,thick=thk,linestyl=sty
	endif else begin
	  mapgc,x1,y1,x2,y1,col=clr,thick=thk,linestyl=sty,step=1
	  mapgc,x2,y1,x2,y2,col=clr,thick=thk,linestyl=sty,step=1
	  mapgc,x2,y2,x1,y2,col=clr,thick=thk,linestyl=sty,step=1
	  mapgc,x1,y2,x1,y1,col=clr,thick=thk,linestyl=sty,step=1
	endelse
 
	end
