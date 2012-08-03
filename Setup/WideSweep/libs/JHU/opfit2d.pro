;-------------------------------------------------------------
;+
; NAME:
;       OPFIT2D
; PURPOSE:
;       Calculate orthonormal polynomial fit for 2-d data.
; CATEGORY:
; CALLING SEQUENCE:
;       zfit = opfit2d( z, xdeg, ydeg, [x, y, c, px, py])
; INPUTS:
;       z    = Image to fit.                                   in
;       xdeg = Degree of polynomial to use in X direction.     in
;       ydeg = Degree of polynomial to use in Y direction.     in
;         X and Y degrees must be greater than 1.
;       x = optional vector of independant variable values.    in
;       y = optional vector of independant variable values.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       c = opt. matrix of orthonormal polynomial coef.        out
;       px = optional vector of orthonormal polynomial values. out
;       py = optional vector of orthonormal polynomial values. out
;       zfit = 2-d fit to original image.                      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Method is based on Forsythe, J. Soc. Indust. 
;         Appl. Math. 5, 74-88,1957.
; MODIFICATION HISTORY:
;       19-MAR-85 -- Initial entry by RBH@APL
;       R. Sterner, 29 Mar, 1990 --- converted to SUN.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function opfit2d,z,xdeg,ydeg,x,y,c,px,py, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Calculate orthonormal polynomial fit for 2-d data.'
	  print,' zfit = opfit2d( z, xdeg, ydeg, [x, y, c, px, py])'
	  print,'   z    = Image to fit.                                   in'
	  print,'   xdeg = Degree of polynomial to use in X direction.     in'
	  print,'   ydeg = Degree of polynomial to use in Y direction.     in'
	  print,'     X and Y degrees must be greater than 1.'
	  print,'   x = optional vector of independant variable values.    in'
	  print,'   y = optional vector of independant variable values.    in'
	  print,'   c = opt. matrix of orthonormal polynomial coef.        out'
	  print,'   px = optional vector of orthonormal polynomial values. out'
	  print,'   py = optional vector of orthonormal polynomial values. out'
	  print,'   zfit = 2-d fit to original image.                      out'
	  print,' Notes: Method is based on Forsythe, J. Soc. Indust. '
	  print,'   Appl. Math. 5, 74-88,1957.'
	  return, -1
	endif
 
	;---  Check degrees  -----------
	if xdeg lt 2 then begin
	  print,' Error in opfit2d: x degree must be greater than 1.'
	  print,' Processing aborted.'
	  return, -1
	endif
	if ydeg lt 2 then begin
	  print,' Error in opfit2d: y degree must be greater than 1.'
	  print,' Processing aborted.'
	  return, -1
	endif
 
	;---  Generate X & Y vectors if not supplied ---
	s=size(z)
	if n_elements(x) eq 0 then x=findgen(s(1))
	if n_elements(y) eq 0 then y=findgen(s(2))
 
	;--- Scale X & Y vectors to -1 thru +1. ---
	minx=min(x, max=maxx)
	xs=((x-minx)/(maxx-minx))*2-1		; Scale the Xs to -1 thru +1
	miny=min(y, max=maxy)
	ys=((y-miny)/(maxy-miny))*2-1		; Scale the Ys to -1 thru +1
 
	;---  Create polynomials  ---
	Px = orthopoly(xs,xdeg)
	Py = orthopoly(ys,ydeg)
 
	;---  Perform fit  ---
	c=(transpose(px)#z)#py
	zout=(px#c)#transpose(py)
 
	return, zout
	end
