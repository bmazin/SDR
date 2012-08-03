;-------------------------------------------------------------
;+
; NAME:
;       MAKE_WINDOW
; PURPOSE:
;       Make a window, regular or scrolling.
; CATEGORY:
; CALLING SEQUENCE:
;       make_window, xs, ys
; INPUTS:
;       xs,ys = x and y window size.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         X_SCR=x_scr X size of scrolling region.
;         Y_SCR=y_scr Y size of scrolling region.
;           Def = up to 90% of screen size.
;         TITLE=tt Window title (def=none).
;         XPOS=x, YPOS=y  Optional window position.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 16
;       R. Sterner, 2003 Mar 13 --- Added XPOS, YPOS keywords.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro make_window, xs, ys, x_scr=x_scr, y_scr=y_scr, $
	  title=tt, xpos=xpos, ypos=ypos, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a window, regular or scrolling.'
	  print,' make_window, xs, ys'
	  print,'   xs,ys = x and y window size.   in'
	  print,' Keywords:'
	  print,'   X_SCR=x_scr X size of scrolling region.'
	  print,'   Y_SCR=y_scr Y size of scrolling region.'
	  print,'     Def = up to 90% of screen size.'
	  print,'   TITLE=tt Window title (def=none).'
	  print,'   XPOS=x, YPOS=y  Optional window position.'
	  return
	endif
 
	if n_elements(tt) eq 0 then tt=' '
	if n_elements(xpos) eq 0 then xpos=0
	if n_elements(ypos) eq 0 then ypos=0
 
	;----  Get size limits  --------
	device,get_screen_size=sz0
	sz = 0.90*sz0
	xmx = round(sz(0))
	ymx = round(sz(1))
 
 
	;----  Set up window  -----------
	if (xs gt xmx) or (ys gt ymx) then begin
	  if n_elements(x_scr) eq 0 then x_scr=xmx
	  if n_elements(y_scr) eq 0 then y_scr=ymx
	  x_scr = xs<xmx<x_scr
	  y_scr = ys<ymx<y_scr
	  xoff = xpos
	  yoff = sz0(1)-(y_scr+ypos)
	  swindow,xs=xs,ys=ys,x_scr=x_scr,y_scr=y_scr,$
	    xoff=xoff, yoff=yoff, titl=tt
	endif else begin
	  window,/free,xs=xs,ys=ys,titl=tt,xpos=xpos,ypos=ypos
	endelse
 
	end
