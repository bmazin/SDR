;-------------------------------------------------------------
;+
; NAME:
;       TICKLEN
; PURPOSE:
;       Compute ticklength for specified size in pixels.
; CATEGORY:
; CALLING SEQUENCE:
;       ticklen, x1,y1,x2,y2
; INPUTS:
;       x1, y1 = desired ticklengths in pixels.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         POSITION=pos  Plot position (normalized).
;         /DEVICE       Plot position is in device coordinates.
; OUTPUTS:
;       x2, y2 = values to use in the plot call.  out
;         xticklen=x2, yticklen=y2.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Apr 11
;       R. Sterner, 1995 Jun 22 --- fixed a minor bug.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ticklen, x1,y1,x2,y2, position=pos, device=device, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Compute ticklength for specified size in pixels.'
	  print,' ticklen, x1,y1,x2,y2'
	  print,'   x1, y1 = desired ticklengths in pixels.   in'
	  print,'   x2, y2 = values to use in the plot call.  out'
	  print,'     xticklen=x2, yticklen=y2.'
	  print,' Keywords:'
	  print,'   POSITION=pos  Plot position (normalized).'
	  print,'   /DEVICE       Plot position is in device coordinates.'
	  return
	endif
 
	if n_elements(pos) eq 0 then begin
	  fx=1.  &  fy=1.
	  if keyword_set(device) then begin
	    fx = !d.x_size
	    fy = !d.y_size
	  endif
	  pos = ([[0.0937550,0.971880]*fx,$
	    [0.0781300,0.960943]*fy])([0,2,1,3])	; Make up pos.
	endif
 
	xx = pos([0,2])		; Plot window.
	yy = pos([1,3])
 
	if not keyword_set(device) then begin
	  xx = xx*!d.x_size	; Was normalized coordinates,
	  yy = yy*!d.y_size	;   convert to device.
	endif
 
	dx = xx(1)-xx(0)	; Plot window size in pixels.
	dy = yy(1)-yy(0)
 
	x2 = float(x1)/dy	; Tick lengths as fraction of plot window.
	y2 = float(y1)/dx
 
	return
	end
