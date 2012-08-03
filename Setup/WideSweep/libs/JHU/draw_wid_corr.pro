;-------------------------------------------------------------
;+
; NAME:
;       DRAW_WID_CORR
; PURPOSE:
;       Get draw widget scroll size correction.
; CATEGORY:
; CALLING SEQUENCE:
;       draw_wid_corr, x, y, xc, yc
; INPUTS:
;       x,y = desired x and y scroll size.             in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xc,yc = Needed correction to get those sizes.  out
;         In the call to widget_draw use:
;         x_scroll=x-xc and y_scroll=y-yc to get x and y.
; COMMON BLOCKS:
; NOTES:
;       Note: The x and y scroll sizes requested for a draw widget
;       may not the actual values of the realized widget.  This
;       routine tries to determine the difference to allow
;       compensation. The coorections still do not give an exact
;       result, they seem a bit small.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 04
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro draw_wid_corr, x, y, xc, yc, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Get draw widget scroll size correction.'
	  print,' draw_wid_corr, x, y, xc, yc'
	  print,'   x,y = desired x and y scroll size.             in'
	  print,'   xc,yc = Needed correction to get those sizes.  out'
	  print,'     In the call to widget_draw use:'
	  print,'     x_scroll=x-xc and y_scroll=y-yc to get x and y.'
	  print,' Note: The x and y scroll sizes requested for a draw widget'
	  print,' may not the actual values of the realized widget.  This'
	  print,' routine tries to determine the difference to allow'
	  print,' compensation. The coorections still do not give an exact'
	  print,' result, they seem a bit small.'
	  return
	endif
 
	;--------------------------------------------
	;  Set up a draw widget, get it's sizes,
	;  delete it (it is never visible).
	;--------------------------------------------
	top = widget_base(/col)
	id = widget_draw(top,xsize=2*x, ysize=2*y, $
	  x_scroll=x, y_scroll=y)
	g = widget_info(id,/geometry)
	widget_control, top, /dest
 
	xc = g.scr_xsize - x
	yc = g.scr_ysize - y
 
	end
