;-------------------------------------------------------------
;+
; NAME:
;       DRAW
; PURPOSE:
;       Graphics draw from last point to given point.
; CATEGORY:
; CALLING SEQUENCE:
;       draw, x, y
; INPUTS:
;       x,y = scalar coordinates of point to draw to.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c color of line from last point.
; OUTPUTS:
; COMMON BLOCKS:
;       move_com
; NOTES:
;       Note: see move.
; MODIFICATION HISTORY:
;       R. Sterner, 22 Jan, 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro draw, x, y, help=hlp, color=clr
 
	common move_com, lstx, lsty
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Graphics draw from last point to given point.'
	  print,' draw, x, y'
	  print,'   x,y = scalar coordinates of point to draw to.   in'
	  print,' Keywords:'
	  print,'   COLOR=c color of line from last point.'
	  print,' Note: see move.'
	  return
	endif
 
	if not keyword_set(clr) then clr = !p.color
 
	plots, [lstx, x], [lsty, y], color=clr
	lstx = x
	lsty = y
 
	return
	end
