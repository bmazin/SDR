;-------------------------------------------------------------
;+
; NAME:
;       GENELLIPSE
; PURPOSE:
;       Generate points on an ellipse.
; CATEGORY:
; CALLING SEQUENCE:
;       genellipse, xm, ym, ang, a, b, x, y
; INPUTS:
;       xm, ym = Center of ellipse.      in
;       ang = Angle of ellipse.          in
;       a, b = Semi-axes.                in
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBER=n Number of points around ellipse.
;           Last point is same as first.  Def=72.
;         /NO_AXES Do not add points on axes.
; OUTPUTS:
;       x, y = Ellipse points.           out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  10 june, 1986.
;       R. Sterner, 2007 Jan 08 --- Added NUMBER=n, /NO_AXES.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro genellipse, xm, ym , ang, a, b, x, y, help=hlp, $
	  number=n, no_axes=no_axes
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Generate points on an ellipse.'
	  print,' genellipse, xm, ym, ang, a, b, x, y'
	  print,'   xm, ym = Center of ellipse.      in'
	  print,'   ang = Angle of ellipse.          in'
	  print,'   a, b = Semi-axes.                in'
	  print,'   x, y = Ellipse points.           out'
	  print,' Keywords:'
	  print,'   NUMBER=n Number of points around ellipse.'
	  print,'     Last point is same as first.  Def=72.'
	  print,'   /NO_AXES Do not add points on axes.'
	  return
	endif
 
	if n_elements(n) eq 0 then n=72
 
;	ap = makex(0, 2*!pi, !pi/36.)		; Angles.
	ap = maken(0, 2*!pi, n)			; Angles.
 
	xt = a*cos(ap)				; XY points.
	yt = b*sin(ap)
 
	x2 = [a, -a, 0,  0,  0]			; Points on axes.
	y2 = [0,  0, 0,  b, -b]
 
	if not keyword_set(no_axes) then begin
	  xt = [xt,x2]
	  yt = [yt,y2]
	endif
 
	cs = cos(ang/!radeg)
	sn = sin(ang/!radeg)
 
	x = xt*cs - yt*sn			; Rotate points.
	y = xt*sn + yt*cs
 
	x = x + xm				; Translate points.
	y = y + ym
 
	return
	end
