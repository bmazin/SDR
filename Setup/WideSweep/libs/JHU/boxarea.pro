;-------------------------------------------------------------
;+
; NAME:
;       BOXAREA
; PURPOSE:
;       Select an area with a box.
; CATEGORY:
; CALLING SEQUENCE:
;       boxarea, x1, y1, x2, y2
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FLAG=flg  Exit flag: 0=ok, 1=abort.
; OUTPUTS:
;       x1,y1 = first box point.   out
;       x2,y2 = second box point.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Open a box by dragging with left mouse button.
;         Repeat to get desired box.
;         Accept box with middle button.
;         Reject box with right button.
;         All coordinates are device coordinates.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Oct 31
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro boxarea, x1, y1, x2, y2, flag=flag, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Select an area with a box.'
	  print,' boxarea, x1, y1, x2, y2'
	  print,'   x1,y1 = first box point.   out'
	  print,'   x2,y2 = second box point.  out'
	  print,' Keywords:'
	  print,'   FLAG=flg  Exit flag: 0=ok, 1=abort.'
	  print,' Notes: Open a box by dragging with left mouse button.'
	  print,'   Repeat to get desired box.'
	  print,'   Accept box with middle button.'
	  print,'   Reject box with right button.'
	  print,'   All coordinates are device coordinates.'
	  return
	endif
 
	!mouse.button = 0		; Clear button flag.
	device, set_graphics = 6	; Set XOR mode.
	x1=100  &  y1=100		; Initial old box.
	x2=100  &  y2=100
 
	;------  Loop until button 2 or 3 pressed  ----------
	repeat begin
 
	  ;-----  Loop until any button pressed  ----------
	  while !mouse.button eq 0 do cursor,/dev,xa,ya
 
	  ;-----  Process button 1 hold  ---------
	  if !mouse.button eq 1 then begin
	    plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]      	; Erase old box.
	    x1=xa  &  y1=ya					; New pt 1.
	    x2=x1  &  y2=y1					; Initial pt 2.
 
	    ;------  Loop until button 1 released (drag) -------
	    repeat begin
	      cursor,/dev,/change,xb,yb				; Get new pt 2.
	      plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]	; Erase old box.
	      plots,/dev,[x1,xb,xb,x1,x1],[y1,y1,yb,yb,y1]	; Draw new box.
	      x2=xb  &  y2=yb					; Save new pt 2.
	    endrep until !mouse.button eq 0	; End button 1 drag.
 
	  endif					; End process button 1.
 
	endrep until !mouse.button ge 2		; End wait for button 2.
 
	plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]	; Erase box on exit.
	device, set_graphics = 3		; Restore plot mode.
	flag = !mouse.button ne 2		; Exit flag.
 
	end
