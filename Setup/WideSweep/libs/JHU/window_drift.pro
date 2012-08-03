;-------------------------------------------------------------
;+
; NAME:
;       WINDOW_DRIFT
; PURPOSE:
;       Return window drift in x and y.
; CATEGORY:
; CALLING SEQUENCE:
;       window_drift, dx, dy
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dx, dy = Returned window drift distances.  out
; COMMON BLOCKS:
;       window_drift_com
; NOTES:
;       Note: The measured position of a graphics window differs
;       from the position used to create it.  This routine returns
;       that difference.  Example:
;         window,xpos=x0,ypos=y0  ; Create a window at x0,y0.
;       The measured position if used to recreated the window
;       will give a shifted window.  Position the window at
;       x0-dx and y0-dy to get a measured position of x0, y0.
;       The difference between the set and measured positions is
;       due to the thickness of the frame around the window.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 21
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro window_drift, dx, dy, measure=measure, help=hlp
 
	common window_drift_com, dx0, dy0
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Return window drift in x and y.'
	  print,' window_drift, dx, dy'
	  print,'   dx, dy = Returned window drift distances.  out'
	  print,' Note: The measured position of a graphics window differs'
	  print,' from the position used to create it.  This routine returns'
	  print,' that difference.  Example:'
	  print,'   window,xpos=x0,ypos=y0  ; Create a window at x0,y0.'
	  print,' The measured position if used to recreated the window'
	  print,' will give a shifted window.  Position the window at'
	  print,' x0-dx and y0-dy to get a measured position of x0, y0.'
	  print,' The difference between the set and measured positions is'
	  print,' due to the thickness of the frame around the window.'
	  return
	endif
 
	if (n_elements(dx0) eq 0) or keyword_set(measure) then begin
	  xp1 = 100  &  yp1 = 100			; Test window pos.
	  window,/free,xs=50,ys=50,xpos=xp1,ypos=yp1	; Make test window.
	  device, get_window_position=pos		; Get it's position.
	  wdelete					; Delete it.
	  xp2 = pos(0)  &  yp2 = pos(1)			; Measured position.
	  dx0 = xp2-xp1  &  dy0 = yp2-yp1		; Drift.
	endif
 
	dx = dx0	; Return drift values.
	dy = dy0
 
	end
