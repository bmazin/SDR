;-------------------------------------------------------------
;+
; NAME:
;       SCREEN
; PURPOSE:
;       Print a terminal screen layout sheet on PS printer.
; CATEGORY:
; CALLING SEQUENCE:
;       screen, [num]
; INPUTS:
;       num = optional postscript printer number (def=0).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 10 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro screen, num, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Print a terminal screen layout sheet on PS printer.'
	  print,' screen, [num]'
	  print,'   num = optional postscript printer number (def=0).  in'
	  return
	endif
 
	if n_elements(num) eq 0 then num = 0
 
	print,' '
	print,' Generating a terminal screen layout sheet'
	print,' '
 
	psinit, num, /land
 
	;-------   Sheet title  ------------
	xyouts,/norm,.51, .88, 'Terminal Screen Layout Sheet',$
	  size=1.5, align=.5
	plot, [0,80],[0,24],/nodata,xstyle=5,ystyle=5,pos=[.04,.1,.98,.82],$
	  /noerase
 
	;--------  Shade rows  --------
	for y = 5, 20, 5 do begin
	  polyfill, [0,80,80,0],[-1,-1,0,0]+y, color=240
	  xyouts, -.5, y-.75, strtrim(25-y,2), align=1.
	endfor
 
	;--------  Shade columns  ------
	for x = 5, 75, 5 do begin
	  polyfill, [-1,0,0,-1]+x,[0,0,24,24],color=240
	  xyouts, x-.5, -1, strtrim(x,2), align=.5
	endfor
 
	;-------  Outline character cells -------
	hor, findgen(25)
	ver, findgen(81)
 
	psterm
	return
	end
