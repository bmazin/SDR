;-------------------------------------------------------------
;+
; NAME:
;       XYPRO_RADON
; PURPOSE:
;       A crossi xypro procedure to plot lines from radon points.
; CATEGORY:
; CALLING SEQUENCE:
;       xypro_radon, x,y
; INPUTS:
;       x,y = x,y coordinates from a radon transform image.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         INIT=win  Initialize by giving original image window.
;           Only initializes on this call, then returns.
;         THICK=thk May specify line thickness when doing INIT.
;         /ERASE erase last plotted line, then returns.
; OUTPUTS:
; COMMON BLOCKS:
;       xypro_radon_com
; NOTES:
;       Notes: Must have the original image displayed in one
;       window and its radon transform displayed in another.
;       This routine is used to map from a point in the transform
;       display to a line in the original image.
;       The following commands can be used to do this interactively.
;         Display original image:
;           img_disp,img & win1=!d.window
;         Do Radon Transform:
;           img_radon, img, angle=ang, radius=rd, transform=trans
;         Display Radon Transform of image:
;           window,/free
;           izoom, ang, rd, bytscl(trans),/center
;         Explore Radon Transform:
;           xypro_radon,init=win1
;           crossi,xypro='xypro_radon',/mag
;           xypro_radon,/erase
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Jun 28, 29
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xypro_radon, a,r, init=wini0, thick=thk0, erase=erase, help=hlp
 
	common xypro_radon_com, winr, wini, thk, $
	  xrsave, yrsave, prsave, cx, cy, rmax, $
	  xlst, ylst, last_flag
	;------------------------------------------------------------
	;  winr = Radon transform display window.
	;  wini = Original image display window.
	;  thk = Line thickness.
	;  xrsave, yrsave, prsave = !x, !y, !p for the
	;    radon transform window.
	;  cx, cy = Offset from lower left corner to center of image.
	;  rmax = max radius from image window center (pixels).
	;  xlst, ylst = Last plotted line.
	;  last_flag = Last line plotted? 1=yes.
	;------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' A crossi xypro procedure to plot lines from radon points.'
	  print,' xypro_radon, x,y'
	  print,'   x,y = x,y coordinates from a radon transform image.  in'
	  print,' Keywords:'
	  print,'   INIT=win  Initialize by giving original image window.'
	  print,'     Only initializes on this call, then returns.'
	  print,'   THICK=thk May specify line thickness when doing INIT.'
	  print,'   /ERASE erase last plotted line, then returns.'
	  print,' Notes: Must have the original image displayed in one'
	  print,' window and its radon transform displayed in another.'
	  print,' This routine is used to map from a point in the transform'
	  print,' display to a line in the original image.'
	  print,' The following commands can be used to do this interactively.'
	  print,'   Display original image:'
	  print,'     img_disp,img & win1=!d.window'
	  print,'   Do Radon Transform:'
	  print,'     img_radon, img, angle=ang, radius=rd, transform=trans'
	  print,'   Display Radon Transform of image:'
	  print,'     window,/free'
	  print,'     izoom, ang, rd, bytscl(trans),/center'
	  print,'   Explore Radon Transform:'
	  print,"     xypro_radon,init=win1"
	  print,"     crossi,xypro='xypro_radon',/mag"
	  print,"     xypro_radon,/erase"
	  return
	endif
 
	;-------------------------------------------------------------
	;  Initialize common
	;  Assume the current window is the radon transform window
	;  and the original window index is given in win.  Grab
	;  the scaling info for each window so it may be switched
	;  during operation.
	;-------------------------------------------------------------
	if n_elements(wini0) ne 0 then begin
	  winr = !d.window	; Save current window as radon window.
	  xrsave = !x		; Save state of radon window.
	  yrsave = !y
	  prsave = !p
	  wset, wini0		; Set to image window.
	  wini = !d.window	; Save image window.
	  cx = !d.x_size/2.	; Image window half size.
	  cy = !d.y_size/2.
	  rmax = sqrt(cx^2+cy^2)
	  last_flag = 0		; No last plot yet.
	  if n_elements(thk0) eq 0 then thk0=1
	  thk = thk0
	  wset, winr		; Set back to radon (incoming) window.
	  return
	endif
 
	;-------------------------------------------------------------
	;  Erase last plotted line.
	;-------------------------------------------------------------
	if keyword_set(erase) then begin
	  wset, wini			; Set to image window.
	  device, set_graphics=6	; XOR mode.
	  if n_elements(xlst) ne 0 then begin
	    plots,xlst,ylst,/dev,thick=thk ; Erase last line.
	    empty
	    last_flag = 0
	  endif
	  device, set_graphics=3	; Copy mode.
	  wset, winr			; Set current window to radon window.
	  !x = xrsave			; Restore scaling.
	  !y = yrsave
	  !p = prsave
  	  return
	endif
 
	;-------------------------------------------------------------
	;  Process call from crossi
	;-------------------------------------------------------------
	polrec,/deg,rmax,a+90,x1,y1	; Pt 1.
	polrec,/deg,rmax,a-90,x2,y2	; Pt 2.
	polrec,/deg,r,a,rx,ry		; Offset from origin.
	x = [x1,x2] + cx + rx		; Shift line from through
	y = [y1,y2] + cy + ry		; origin to offset of r.
	wset, wini			; Set to image window.
	device, set_graphics=6		; XOR mode.
	if last_flag then begin
	  plots,xlst,ylst,/dev,thick=thk ; Erase last line.
	  empty
	endif
	plots,x,y,/dev,thick=thk	; Plot new line.
	empty
	xlst = x			; Save last line.
	ylst = y
	last_flag = 1			; A line is plotted.
	device, set_graphics=3		; Copy mode.
	wset, winr			; Set current window to radon window.
	!x = xrsave			; Restore scaling.
	!y = yrsave
	!p = prsave
 
	end
