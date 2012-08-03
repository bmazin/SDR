;-------------------------------------------------------------
;+
; NAME:
;       BOX_SIZE
; PURPOSE:
;       Used by MOVBOX to change box size using the cursor.
; CATEGORY:
; CALLING SEQUENCE:
;       BOX_SIZE, x, y, dx, dy, showflag
; INPUTS:
;       x,y = lower left corner device coordinates.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /POSITION prints box position and size on exit.
;         XSIZE = factor.  Mouse changes Y size, computes X size.
;         YSIZE = factor.  Mouse changes X size, computes Y size.
;         /YREVERSE means y is 0 at screen top.
;         XFACTOR=xf convsersion factor from device coordinates
;           to scaled coordinates.
;         YFACTOR=yf convsersion factor from device coordinates
;           to scaled coordinates.
;         DXMIN=dxmn  Minimum allowed box x size (def=1).
;         DYMIN=dymn  Minimum allowed box y size (def=1).
;         COLOR=clr  Box color (-2 for dotted box).
;         ECHO=win2  Echo box in window win2.
; OUTPUTS:
;       dx, dy = box size.                             in, out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  25 July, 1989.
;       R. Sterner, 16 Mar, 1992 --- upgraded box list.
;       R. Sterner,  7 Dec, 1993 --- Added min box size.
;       R. Sterner, 1994 Nov 27 --- Switched !err to !mouse.button.
;       R. Sterner, 2005 Jun 29 --- Added ECHO=win2.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
 
	PRO BOX_SIZE, X, Y, DX, DY, showflag, position=pos, help=hlp, $
	  xsize=xsiz, ysize=ysiz, yreverse=yrev, xfactor=xfact, $
	  yfactor=yfact, dxmin=dxmin, dymin=dymin, color=clr,echo=win2
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Used by MOVBOX to change box size using the cursor.'
	  print,' BOX_SIZE, x, y, dx, dy, showflag'
	  print,'   x,y = lower left corner device coordinates.    in'
	  print,'   dx, dy = box size.                             in, out'
	  print,' Keywords:'
	  print,'   /POSITION prints box position and size on exit.'
	  print,'   XSIZE = factor.  Mouse changes Y size, computes X size.'
	  print,'   YSIZE = factor.  Mouse changes X size, computes Y size.'
	  print,'   /YREVERSE means y is 0 at screen top.'
	  print,'   XFACTOR=xf convsersion factor from device coordinates'
	  print,'     to scaled coordinates.'
	  print,'   YFACTOR=yf convsersion factor from device coordinates'
	  print,'     to scaled coordinates.'
	  print,'   DXMIN=dxmn  Minimum allowed box x size (def=1).'
	  print,'   DYMIN=dymn  Minimum allowed box y size (def=1).'
	  print,'   COLOR=clr  Box color (-2 for dotted box).'
	  print,'   ECHO=win2  Echo box in window win2.'
	  return
	endif
 
	if n_elements(dxmin) eq 0 then dxmin = 1
	if n_elements(dymin) eq 0 then dymin = 1
 
	X2 = X + DX - 1			; Upper right box corner.
	Y2 = Y + DY - 1
	TVCRS, X2, Y2
	wait, .2			; This help vms.
 
loop:	CURSOR, X2, Y2, 2, /DEVICE	; Move upper right corner.
	X2 = X2 > X			; Don't allow negative box sizes.
	Y2 = Y2 > Y
	DX = (X2 - X + 1)>dxmin		; New box size.
	DY = (Y2 - Y + 1)>dymin
	if keyword_set(xsiz) then begin
	  dx = fix(.5+dy*xsiz)
	  if dx gt (!d.x_size - x) then begin
	    dx = !d.x_size - x
	    dy = fix(.5+dx/xsiz)>1<(!d.y_size-y)
	  endif
	  tvcrs, x, y+dy-1
	endif
	if keyword_set(ysiz) then begin
	  dy = fix(.5+dx*ysiz)
	  if dy gt (!d.y_size - y) then begin
	    dy = !d.y_size - y
	    dx = fix(.5+dy/ysiz)>1<(!d.x_size-x)
	  endif
	  tvcrs, x+dx-1, y
	endif
	TVBOX, X, Y, DX, DY, clr, echo=win2		; Draw new box.
	if keyword_set(pos) then begin
	  show_box, x, y, dx, dy, showflag, position=pos, yreverse=yrev,$
	    xfactor=xfact, yfactor=yfact
	endif
	IF !mouse.button NE 1 THEN GOTO, LOOP		; Button 1 pressed?
	!mouse.button = 0
	TVCRS, X, Y
	wait,.2
 
	RETURN
	END
