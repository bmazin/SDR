;-------------------------------------------------------------
;+
; NAME:
;       WIDGET_GETOFFSET
; PURPOSE:
;       Get x/y position of a subwidget.
; CATEGORY:
; CALLING SEQUENCE:
;       widget_getoffset, id, xout, yout
; INPUTS:
;       id = Wiget ID of subwidget (like a button).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /POSITION return widget position from screen lower
;           left corner instead screen upper left corner.
;         ERROR=err  0: ok, else error.
; OUTPUTS:
;       xp, yp = Returned x/y position of subwidget. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Mar 13
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro widget_getoffset, wid, xout, yout, position=pos, $
	  error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get x/y position of a subwidget.'
	  print,' widget_getoffset, id, xout, yout'
	  print,'   id = Wiget ID of subwidget (like a button).  in'
	  print,'   xp, yp = Returned x/y position of subwidget. out'
	  print,' Keywords:'
	  print,'   /POSITION return widget position from screen lower'
	  print,'     left corner instead screen upper left corner.'
	  print,'   ERROR=err  0: ok, else error.'
	  return
	endif
 
	if widget_info(wid,/valid) ne 1 then begin
	  print,' Error in widget_getoffset: Invalid widget ID given: ',wid
	  err = 1
	  return
	endif
 
	tx = 0
	ty = 0
	id = wid
 
	while id ne 0 do begin
	  g = widget_info(id,/geom)
	  tx = tx + g.xoffset
	  ty = ty + g.yoffset
	  id = widget_info(id,/parent)
	endwhile
 
	xout = tx
	if keyword_set(pos) then begin
	  device,get_screen_size=sz
	  yout = sz(1) - ty
	endif else begin
	  yout = ty
	endelse
 
	end
