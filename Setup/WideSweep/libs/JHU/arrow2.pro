;-------------------------------------------------------------
;+
; NAME:
;       ARROW2
; PURPOSE:
;       Draw arrows on screen.
; CATEGORY:
; CALLING SEQUENCE:
;       arrow2, xt, yt, xh, yh
; INPUTS:
;       xt, yt = x,y of arrow tail.     in
;       xh, yh = x,y of arrow head.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA means use data coordinates (def).
;         /NORM means use normalized coordinates.
;         /DEVICE means use device coordinates.
;         COLOR=c arrow outline color (def=255).
;           Make same as FILL for no outline.
;         THICK=t arrow outline thickness (def=0).
;         LINESTYLE=s arrow outline line style (def=0).
;         FILL=f set arrow fill color (0-255, def = -1 = no fill).
;         LENGTH=l  Arrow head length in % plot width (def = 3).
;         WIDTH=w  Arrow head width in % plot width (def = 2).
;         SHAFT=s  Arrow shaft width in % plot width (def = 1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;       R. Sterner, 11 Nov, 1993 --- renamed from arrow.
;       R. Sterner, 20001 May 22 --- Cleaned up and plotted in /dev.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro arrow2, xt, yt, xh, yh, device=device, data=data, norm=norm, $
          help=hlp, color=color, linestyle=linestyle, thick=thick, $
	  fill=fill, length=alen0, width=awid0, shaft=ash0
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Draw arrows on screen.'
	  print,' arrow2, xt, yt, xh, yh'
	  print,'   xt, yt = x,y of arrow tail.     in'
	  print,'   xh, yh = x,y of arrow head.     in'
	  print,' Keywords:'
	  print,'   /DATA means use data coordinates (def).'
	  print,'   /NORM means use normalized coordinates.'
	  print,'   /DEVICE means use device coordinates.'
	  print,'   COLOR=c arrow outline color (def=255).'
	  print,'     Make same as FILL for no outline.'
	  print,'   THICK=t arrow outline thickness (def=0).'
	  print,'   LINESTYLE=s arrow outline line style (def=0).'
	  print,'   FILL=f set arrow fill color (0-255, def = -1 = no fill).'
	  print,'   LENGTH=l  Arrow head length in % plot width (def = 3).'
	  print,'   WIDTH=w  Arrow head width in % plot width (def = 2).'
	  print,'   SHAFT=s  Arrow shaft width in % plot width (def = 1).'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(device) eq 0 then device = 0
	if n_elements(data) eq 0 then data = 0
	if n_elements(norm) eq 0 then norm = 0
	if (device+data+norm) eq 0 then data = 1
	if n_elements(alen0) eq 0 then alen0 = 3.0
	if n_elements(awid0) eq 0 then awid0 = 2.0
	if n_elements(ash0) eq 0 then ash0 = 1.0
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(fill) eq 0 then fill = -1
 
	alen = alen0/100.
	awid2 = awid0/100./2.
	ash2 = ash0/100./2.
	;  Arrows have a problem in normalized coordinates.  A length of 1 unit
	;  will in general be different in X and Y.  This may be handled easily
	;  by converting to an isotropic coordinate system, computing the arrow,
	;  then converted back to norm. to plot.  The factor ff is the x to y
	;  shape ratio that does this conversion.
	ff = float(!d.x_size)/float(!d.y_size)	; Fudge fact to cor norm coord.
 
 
	;---------  Convert arrow to normalized coordinates  --------
	if keyword_set(data) then begin
	  t = convert_coord([xt,xh],[yt,yh],/data,/to_norm)
	  x1 = (t(0,*))(0)
	  x2 = (t(0,*))(1)
	  y1 = (t(1,*))(0)
	  y2 = (t(1,*))(1)
	endif
	if keyword_set(device) then begin
	  t = convert_coord([xt,xh],[yt,yh],/dev,/to_norm)
	  x1 = (t(0,*))(0)
	  x2 = (t(0,*))(1)
	  y1 = (t(1,*))(0)
	  y2 = (t(1,*))(1)
	endif
	if keyword_set(norm) then begin
	  x1 = xt
	  x2 = xh
	  y1 = yt
	  y2 = yh
	endif
	x1 = x1*ff
	x2 = x2*ff
 
	dx = x2 - x1  & dy = y2 - y1	; Set up arrow.
	m1 = sqrt(dx^2 + dy^2)>.1
	u1x = dx/m1  & u1y = dy/m1		; Unit vector along arrow.
	u2x = -u1y  & u2y = u1x		; Unit vector across arrow.
	x2b = x2 - alen*u1x  & y2b = y2 - alen*u1y	  ; Midpt back of head.
	hx1 = x2b + ash2*u2x  & hy1 = y2b + ash2*u2y     ; ARROW HEAD BACK.
	hx2 = x2b - ash2*u2x  & hy2 = y2b - ash2*u2y     ; ARROW HEAD BACK.
	hx3 = x2b + awid2*u2x  & hy3 = y2b + awid2*u2y   ; ARROW HEAD BACK.
	hx4 = x2b - awid2*u2x  & hy4 = y2b - awid2*u2y   ; ARROW HEAD BACK.
	tx1 = x1 + ash2*u2x  & ty1 = y1 + ash2*u2y	     ; ARROW TAIL.
	tx2 = x1 - ash2*u2x  & ty2 = y1 - ash2*u2y	     ; ARROW TAIL.
	xp = [tx1, hx1, hx3, x2, hx4, hx2, tx2, tx1]
	yp = [ty1, hy1, hy3, y2, hy4, hy2, ty2, ty1]
 
	;------  Convert to device to plot (for rounding)  ---------
	;------  Plot coordinates are truncated so must round.  ----
	t = convert_coord(xp/ff,yp,/to_dev,/norm)
	ix = round(t(0,*)+0.5)
	iy = round(t(1,*)+0.5)
 
	if fill ne -1 then polyfill, /dev , ix, iy, color=fill
	plots, ix, iy, /dev, color=color, linestyle=linestyle, $
	  thick=thick
	
	end
