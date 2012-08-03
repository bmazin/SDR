;-------------------------------------------------------------
;+
; NAME:
;       PLOTPOS
; PURPOSE:
;       Compute plot position for a plot of specified shape.
; CATEGORY:
; CALLING SEQUENCE:
;       pos = plotpos(j, nx, ny)
; INPUTS:
;       j = plot position number (0 to nx*ny-1, def=0).      in
;       nx = number of plots across page or screen (def=1).  in
;       ny = number of plots down page or screen (def=1).    in
; KEYWORD PARAMETERS:
;       Keywords:
;         HWRATIO=hw    plot window height/width ration (def=1.0).
;         XMARGIN=xmar  X axis margin (def=!x.margin).
;         YMARGIN=ymar  Y axis margin (def=!y.margin).
;         CHARSIZE=csz  Character size (def=!p.charsize).
;         ORIGIN=org    Origin of plot window in device coordinates.
;         NORIGIN=norg  Origin of plot window in normalized coords.
;           Origins over-ride margins and plot position number.
;         /NORMAL  means return position in normalized coords (def).
;         /DEVICE  means return position in device coords.
; OUTPUTS:
;       pos = returned plot position.                        out
;         Four element array: [xmn,ymn,xmx,ymx].
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 15 Oct, 1993
;       R. Sterner, 1994 Feb 7 --- Made args have defaults.
;       R. Sterner, 1995 Apr 3 --- Added CHARSIZE.
;       R. Sterner, 1995 Jun 22 --- Added NORIGIN=normalized origin.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function plotpos, j, nx, ny, hwratio=hw, xmargin=xmar, charsize=csz, $
	  ymargin=ymar, normal=norm, device=dev, origin=origin, help=hlp, $
	  norigin=norigin
 
	if keyword_set(hlp) then begin
	  print,' Compute plot position for a plot of specified shape.'
	  print,' pos = plotpos(j, nx, ny)'
	  print,'   j = plot position number (0 to nx*ny-1, def=0).      in'
	  print,'   nx = number of plots across page or screen (def=1).  in'
	  print,'   ny = number of plots down page or screen (def=1).    in'
	  print,'   pos = returned plot position.                        out'
	  print,'     Four element array: [xmn,ymn,xmx,ymx].'
	  print,' Keywords:'
	  print,'   HWRATIO=hw    plot window height/width ration (def=1.0).'
	  print,'   XMARGIN=xmar  X axis margin (def=!x.margin).'
	  print,'   YMARGIN=ymar  Y axis margin (def=!y.margin).'
	  print,'   CHARSIZE=csz  Character size (def=!p.charsize).'
	  print,'   ORIGIN=org    Origin of plot window in device coordinates.'
	  print,'   NORIGIN=norg  Origin of plot window in normalized coords.'
	  print,'     Origins over-ride margins and plot position number.'
	  print,'   /NORMAL  means return position in normalized coords (def).'
	  print,'   /DEVICE  means return position in device coords.'
	  return, -1
	endif
 
	;-------  Set defaults  -------------
	if n_elements(j) eq 0 then j = 0
	if n_elements(nx) eq 0 then nx = 1
	if n_elements(ny) eq 0 then ny = 1
	if n_elements(hw) eq 0 then hw = 1.0
	if n_elements(xmar) eq 0 then xmar = !x.margin
	if n_elements(ymar) eq 0 then ymar = !y.margin
	if n_elements(csz) eq 0 then csz = !p.charsize
	if csz eq 0. then csz = 1.0
 
	;-------  Find subarea corner coordinates  ---------
	xres = !d.x_size	; Find extent of device.
	yres = !d.y_size
	sx = xres/nx		; Find subarea size.
	sy = yres/ny
	xorig = 0         	; POS number 0 coordinates. 
	yorig = yres-1-sy
	iy = fix(j/nx)		; Convert position index to 2-d.
	ix = j - iy*nx
	x0 = xorig + ix*sx	; Corner coordinates.
	y0 = yorig - iy*sy + 1
 
	;-------  Reduce available area by margins  --------
	dx = sx - total(xmar*!d.x_ch_size*csz)	; Reduced area.
	dy = sy - total(ymar*!d.y_ch_size*csz)
	x1 = x0 + xmar(0)*!d.x_ch_size*csz	; Reduced area origin.
	y1 = y0 + ymar(0)*!d.y_ch_size*csz
 
	;-------  Center plot window in reduced area  -----
	rat = float(dy/dx)			; Shape of reduced area.
	if hw gt rat then begin			; Plot taller than area.
	  hy = dy				; Fills in Y direction.
	  hx = fix(float(hy)/hw)		; Plot window X size.
	  x1 = x1 + (dx-hx)/2.			; Update (x1,y1).
	endif else begin			; Plot wider than area.
	  hx = dx				; Fills in X direction.
	  hy = fix(float(hx)*hw)		; Plot window Y size.
	  y1 = y1 + (dy-hy)/2.			; Update (x1,y1).
	endelse
	if n_elements(origin) ne 0 then begin	; Origin over-rides all else.
	  x1 = origin(0)
	  y1 = origin(1)
	endif
	if n_elements(norigin) ne 0 then begin	; Origin over-rides all else.
	  x1 = norigin(0)*xres
	  y1 = norigin(1)*yres
	endif
	x2 = x1 + hx				; Plot window upper right
	y2 = y1 + hy				;   corner.
 
	pos = fix([x1,y1,x2,y2])		; Position in device coord.
	if keyword_set(dev) then return, pos
 
	pos = [x1/float(xres), y1/float(yres), x2/float(xres), y2/float(yres)]
	return, pos
 
	end
