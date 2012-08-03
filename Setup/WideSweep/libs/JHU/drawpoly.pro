;-------------------------------------------------------------
;+
; NAME:
;       DRAWPOLY
; PURPOSE:
;       Draw a polygon using mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       drawpoly, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /CURVE draw a curve instead of a polygon.
;         /DEVICE use device coordinates (def).
;         /DATA use data coordinates.
;         /NORMAL use normalized coordinates.
;         /NOPLOT erase on exit (def=plot).
;         COLOR=c outline or curve color (def=!p.color).
;         THICK=t outline or curve thickness (def=0).
;         LINESTYLE=s outline or curve line style (def=0).
;         FILL=f polygon fill color (def= -1 = no fill).
; OUTPUTS:
;       x,y = polygon vertices.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Oct, 1990
;       R. Sterner, 23 Oct, 1990 --- added some keywords.
;       R. Sterner, 26 Feb, 1991 --- renamed from draw_polygon.pro
;       R. Sterner, 1994 Mar 17 --- Default color=!p.color.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro drawpoly, x, y, linestyle=style, device=device, $
	  data=data, normal=normal, noplot=noplot,  color=color, $
	  help=hlp, thick=thick, poly=poly, curve=curve, fill=fill
 
	if keyword_set(hlp) then begin
	  print,' Draw a polygon using mouse.'
	  print,' drawpoly, x, y'
	  print,'   x,y = polygon vertices.        out'
	  print,' Keywords:'
	  print,'   /CURVE draw a curve instead of a polygon.'
	  print,'   /DEVICE use device coordinates (def).'
	  print,'   /DATA use data coordinates.'
	  print,'   /NORMAL use normalized coordinates.'
	  print,'   /NOPLOT erase on exit (def=plot).'
	  print,'   COLOR=c outline or curve color (def=!p.color).'
	  print,'   THICK=t outline or curve thickness (def=0).'
	  print,'   LINESTYLE=s outline or curve line style (def=0).'
	  print,'   FILL=f polygon fill color (def= -1 = no fill).'
	  return
	endif
 
	pcflag = 0				; Default = draw polygon.
	if keyword_set(curve) then pcflag = 1	; Draw curve.
	dev = 0
	dat = 0
	nor = 0
	if keyword_set(device) then dev = 1
	if keyword_set(data) then dat = 1
	if keyword_set(normal) then nor = 1
	if (dev+dat+nor) eq 0 then dev = 1	; Default is dev coordinates.
	if n_elements(thick) eq 0 then thick = 0
	if n_elements(style) eq 0 then style = 0
	if n_elements(fill) eq 0 then fill = -1
	n = 0
	x = intarr(1)
	y = intarr(1)
 
	device, set_graph=6
 
	print,' '
	if pcflag eq 0 then begin
	  print,' Draw a polygon using the mouse.'
	  print,' Left button --- new side.'
	  print,' Middle button --- delete side.'
	  print,' Right button --- quit polygon.'
	endif else begin
	  print,' Draw a curve using the mouse.'
	  print,' Left button --- new segment.'
	  print,' Middle button --- delete segment.'
	  print,' Right button --- quit curve.'
	endelse
	print,' '
 
loop:	cursor, ix, iy, 1, device=dev, data=dat, normal=nor
	wait, .2
 
	if !err eq 1 then begin
	  if n eq 0 then begin
	    plots, [ix,ix], [iy,iy], $
	      device=dev, data=dat, normal=nor
	  endif else begin
	    plots, [x(n), ix], [y(n), iy], $
	      device=dev, data=dat, normal=nor
	  endelse
	  n = n + 1
	  x = [x,ix]
	  y = [y,iy]
	  goto, loop
	endif
 
	if !err eq 2 then begin
	  if n gt 0 then begin
	    plots, [x((n-1)>1), x(n)], [y((n-1)>1), y(n)], $
	      device=dev, data=dat, normal=nor
	    n = n - 1
	    x = x(0:n)
	    y = y(0:n)
	  endif
	  goto, loop
	endif
 
	if !err eq 4 then begin
	  if n gt 1 then for i = n, 2, -1 do plots, $
	    [x((i-1)>1),x(i>1)],[y((i-1)>1),y(i>1)],device=dev,$
	    data=dat,normal=nor
	  if n gt 1 then plots,[x(1),x(1)], [y(1),y(1)], $
	    device=dev, data=dat, normal=nor
	  device, set_graph=3
	  if n_elements(x) lt 2 then return
	  x = x(1:*)
	  y = y(1:*)
	  if not keyword_set(noplot) then begin
	    if n_elements(color) eq 0 then color = !p.color
	    if pcflag eq 0 then begin
	      if fill ne -1 then polyfill, x, y, color=fill, device=dev,$
	        data=dat,normal=nor
	      plots, [x,x(0)], [y,y(0)], device=dev, data=dat, normal=nor, $
	        color=color, linestyle=style, thick=thick
	    endif else begin
	      plots, x, y, device=dev, data=dat, normal=nor, color=color, $
	        linestyle=style, thick=thick
	    endelse
	  endif
	  return
	endif
 
	end
