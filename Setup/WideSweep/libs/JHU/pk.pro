;-------------------------------------------------------------
;+
; NAME:
;       PK
; PURPOSE:
;       Pick a set of points on a plot.
; CATEGORY:
; CALLING SEQUENCE:
;       pk, x, y, ind
; INPUTS:
;       x,y = point coordinate arrays.              in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOMARK means don't mark selected points.
;         XRANGE=xr  Return x range of selected box.
;         YRANGE=yr  Return y range of selected box.
;           Use to zoom plot:
;           plot,x,y,xrange=xr,yrange=yr
;         CODE=c  box exit code: 4=normal exit, 2=alternate exit.
; OUTPUTS:
;       ind = array of indices of selected points.  out
;             ind = -1 if no points selected.
; COMMON BLOCKS:
;       pk_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 16 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pk, px, py, ind, nomark=nomark, xrange=xran, yrange=yran, $
	  code=code, help=hlp
 
	common pk_com, sx1, sy1, sdx, sdy
 
	if keyword_set(hlp) then begin
	  print,' Pick a set of points on a plot.'
	  print,' pk, x, y, ind'
	  print,'   x,y = point coordinate arrays.              in'
	  print,'   ind = array of indices of selected points.  out'
	  print,'         ind = -1 if no points selected.'
	  print,' Keywords:'
	  print,"   /NOMARK means don't mark selected points."
	  print,'   XRANGE=xr  Return x range of selected box.'
	  print,'   YRANGE=yr  Return y range of selected box.'
	  print,'     Use to zoom plot:'
	  print,'     plot,x,y,xrange=xr,yrange=yr'
	  print,'   CODE=c  box exit code: 4=normal exit, 2=alternate exit.'
	  return
	endif
 
	if n_elements(px) eq 0 then px = [0]
	if n_elements(py) eq 0 then py = [0]
 
	;=======  Get device coords of box  ==========
	;=======  Works for any plot type (linear and/or log)  =====
	if n_elements(sx1) eq 0 then begin	; Init last box.
	  sx1 = 100
	  sy1 = 100
	  sdx = 100
	  sdy = 100
	endif
	movbox, sx1, sy1, sdx, sdy, code	; Interactive box.
	sx2 = sx1 + sdx - 1
	sy2 = sy1 + sdy - 1
	;========  Convert device coords to data coords  ========
	xy = convert_coord([sx1,sx2],[sy1,sy2],/device,/to_data)
	x1 = xy(0,0)
	x2 = xy(0,1)
	y1 = xy(1,0)
	y2 = xy(1,1)
 
	;=======  Find points inside selected box  ==========
	ind = where((px ge x1) and (px le x2) and $
	          (py ge y1) and (py le y2), count)
 
	;=======  Mark selected points  ========
	if (count gt 0) and (not keyword_set(nomark)) then begin
	  oplot, px(ind), py(ind), psym=4, symsize=1.5
	endif
	
	;========  Set box range  ==========
	xran = [x1,x2]
	yran = [y1,y2]
 
	return
	end
