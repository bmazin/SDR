;-------------------------------------------------------------
;+
; NAME:
;       SWSHAKE
; PURPOSE:
;       Shake an swindow.
; CATEGORY:
; CALLING SEQUENCE:
;       swshake, in
; INPUTS:
;       in = window number to shake (def=current).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /HARD shake hard.
;         /INSIDE shake inside.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Aug 14
;       R. Sterner, 2005 Sep 06 --- Added more comments.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro swshake, in, hard=hard, inside=inside, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Shake an swindow.'
	  print,' swshake, in'
	  print,'   in = window number to shake (def=current).  in'
	  print,' Keywords:'
	  print,'   /HARD shake hard.'
	  print,'   /INSIDE shake inside.'
	  return
	endif
 
	;-----------------------------------------------------
	;  Get window widget IDs
	;  Both b and d are -1 if not an swindow.
	;-----------------------------------------------------
	b = swinfo(in,/base)	; ID of top level base containing draw widget.
	d = swinfo(in,/draw)	; ID of draw widget inside top level base.
	if b lt 0 then begin
	  print,' Window not an swindow.'
	  return
	endif
 
	;-----------------------------------------------------
	;  Get position
	;  Position of from upper-left corner of screen.
	;-----------------------------------------------------
	g = widget_info(b,/geometry)
	x0 = g.xoffset
	y0 = g.yoffset
 
	;-----------------------------------------------------
	;  Amount
	;  Set up random displacements.
	;-----------------------------------------------------
	if keyword_set(hard) then begin
	  a = 200
	  n = 200
	endif else begin
	  a = 10
	  n = 50
	endelse
	dx = randomu(k,n)*a
	dy = randomu(k,n)*a
 
	;-----------------------------------------------------
	;  In or out?
	;
	;  Inside:
	;    Shift the viewport.  The viewport is set by
	;    setting the lower left corner of the view to
	;    dx,dy pixels from the lower left corner of the
	;    image.  Out of range values are handled correctly.
	;    To center a point, must offset by half the visible
	;    area size.  Not sure how to get that value for
	;    draw widgets in general but for swindows can use
	;    swinfo(/vis).
	;
	;  Outside:
	;    Add a random offset to the original position.
	;-----------------------------------------------------
	if keyword_set(inside) then begin
	  for i=0,n-1 do begin
	    widget_control, d, set_draw_view=[dx(i),dy(i)]
	    wait,.01
	  endfor
	endif else begin
	  for i=0,n-1 do begin
	    widget_control, b, xoff=x0+dx(i),yoff=y0+dy(i)
	    wait,.01
	  endfor
;	  widget_control, b, xoff=x0,yoff=y0
	endelse
 
	end
