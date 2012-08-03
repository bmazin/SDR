;-------------------------------------------------------------
;+
; NAME:
;       MAPWINDOW
; PURPOSE:
;       Find screen window used by last map.
; CATEGORY:
; CALLING SEQUENCE:
;       mapwindow
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         IX1=ix1, IX2=ix2  Map area device x position.  out
;         IY1=iy1, IY2=iy2  Map area device y position.  out
;         NX=nx, NY=ny  Map area size in pixels.         out
;         /QUIET means do not display window.
;         ERROR=err Error flag: 0=Last plot was not a map.
;         /OUTLINE  means outline window.
;         COLOR=clr Outline color (def=!p.color).
;         THICKNESS=thk  Outline thickness (def=!p.thick).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Map area seems to be a non-integer size.  Try
;         print,!x.window*!d.x_size,!y.window*!d.y_size
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Dec 28
;       R. Sterner, 2001 Dec 30 --- Had to keep map area as floating.
;       R. Sterner, 2002 Jan 09 --- Added keyword THICKNESS=thk.
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mapwindow, help=hlp, error=err, quiet=quiet, $
	  ix1=ix1, ix2=ix2,iy1=iy1,iy2=iy2,nx=nx,ny=ny, $
	  outline=outline, color=clr, thickness=thk
 
	if keyword_set(hlp) then begin
	  print,' Find screen window used by last map.'
	  print,' mapwindow'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   IX1=ix1, IX2=ix2  Map area device x position.  out'
	  print,'   IY1=iy1, IY2=iy2  Map area device y position.  out'
	  print,'   NX=nx, NY=ny  Map area size in pixels.         out'
	  print,'   /QUIET means do not display window.'
	  print,'   ERROR=err Error flag: 0=Last plot was not a map.'
	  print,'   /OUTLINE  means outline window.'
	  print,'   COLOR=clr Outline color (def=!p.color).'
	  print,'   THICKNESS=thk  Outline thickness (def=!p.thick).'
	  print,' Note: Map area seems to be a non-integer size.  Try'
	  print,'   print,!x.window*!d.x_size,!y.window*!d.y_size'
	  return
	endif
 
	;------  Check last plot type  -----------------
	if !x.type ne 3 then begin
	  print,' Error in mapwindow: last plot was not a map.'
	  err = 1
	  return
	endif
 
	;------  Find map window on screen  ------------
	x = !d.x_size*!x.window
	y = !d.y_size*!y.window
	ix1=x(0) & ix2=x(1)
	iy1=y(0) & iy2=y(1)
	nx = ix2-ix1
	ny = iy2-iy1
 
	;---------  Display values  -------------
	if not keyword_set(quiet) then begin
	  print,' Map area device x range: ',fix(ix1),fix(ix2)
	  print,' Map area device y range: ',fix(iy1),fix(iy2)
	  print,' Map area size in pixels: ',fix(nx),fix(ny)
	  print,' map = tvrd('+strtrim(fix(ix1),2)+','+strtrim(fix(iy1),2)+$
	    ','+strtrim(fix(nx),2)+','+strtrim(fix(ny),2)+')'
	endif
 
	;-------  Plot outline  -------------------
	if keyword_set(outline) then begin
	  if n_elements(clr) eq 0 then clr=!p.color
	  if n_elements(thk) eq 0 then thk=!p.thick
	  plots,/dev,[ix1,ix2,ix2,ix1,ix1],[iy1,iy1,iy2,iy2,iy1], $
	    col=clr,thick=thk
	endif
 
	err = 0
 
	end
