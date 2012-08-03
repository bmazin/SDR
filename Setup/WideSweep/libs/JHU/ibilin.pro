;-------------------------------------------------------------
;+
; NAME:
;       IBILIN
; PURPOSE:
;       Inverse bilinear interpolation.
; CATEGORY:
; CALLING SEQUENCE:
;       ibilin, x, y, xe, ye, a, b
; INPUTS:
;       x = array of 4 corner x values.   in
;       y = array of 4 corner y values.   in
;       xe = x value of desired point.    in
;       ye = y value of desired point.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a = rectangular image x fraction. out
;       b = rectangular image y fraction. out
;         Fractions not clipped to 0-1.
;       flag = flag for point (xe,ye).    out
;         1=ok, 0=no point.
; COMMON BLOCKS:
; NOTES:
;       Notes: For a rectangular image, if values of some
;         field are known at the corners then values at any
;         point inside the image may be estimated by bilinear
;         interpolation.  The inverse problem, knowing the
;         corner values and the value at a desired point, and
;         finding the image point is not so straight forward.
;         In general, for a single scalar, there may be many
;         such image points.  This routine is not that general,
;         it is intended for 2-d coordinate conversion.
;         Algorithm by Rick Chapman, JHU/APL.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Sep 27
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro ibilin, x, y, xe, ye, fx, fy, flag, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Inverse bilinear interpolation.'
	  print,' ibilin, x, y, xe, ye, a, b'
	  print,'   x = array of 4 corner x values.   in'
	  print,'   y = array of 4 corner y values.   in'
	  print,'   xe = x value of desired point.    in'
	  print,'   ye = y value of desired point.    in'
	  print,'   a = rectangular image x fraction. out'
	  print,'   b = rectangular image y fraction. out'
	  print,'     Fractions not clipped to 0-1.
	  print,'   flag = flag for point (xe,ye).    out'
	  print,'     1=ok, 0=no point.'
	  print,' Notes: For a rectangular image, if values of some'
	  print,'   field are known at the corners then values at any'
	  print,'   point inside the image may be estimated by bilinear'
	  print,'   interpolation.  The inverse problem, knowing the'
	  print,'   corner values and the value at a desired point, and'
	  print,'   finding the image point is not so straight forward.'
	  print,'   In general, for a single scalar, there may be many'
	  print,'   such image points.  This routine is not that general,'
	  print,'   it is intended for 2-d coordinate conversion.'
	  print,'   Algorithm by Rick Chapman, JHU/APL.'
	  return
	endif
 
	;-------  Find coefficients of quadratic for fx  -----
	a = (x(0)-x(1))*(y(2)-y(3)) + (x(3)-x(2))*(y(0)-y(1))
	b = xe*(y(0)-y(1)+y(2)-y(3))-(x(0)-x(1)+x(2)-x(3))*ye + $
	   2*(x(0)*y(3)-x(3)*y(0))+x(3)*y(1)-x(1)*y(3)+x(2)*y(0)-x(0)*y(2)
	c = xe*(y(3)-y(0)) + x(0)*(ye-y(3)) + x(3)*(y(0)-ye)
 
	;-------  Find roots  ------------
	n = (n_elements(xe))		; Number of requested points.
	if a ne 0 then begin		; a ne 0: Quadratic.
	  d = b^2-4*a*c			; Discriminant.
	  flag = intarr(n)		; Point flags.
	  w = where(d ge 0, cnt)	; Where real roots.
	  if cnt gt 0 then flag(w)=1	; Good points.
	  sd = fltarr(n)
	  sd(w) = sqrt(d(w))
	  fxp = ((-b+sd)/(2*a))(0:*)	; +root.
	  fxm = ((-b-sd)/(2*a))(0:*)	; -root.
	  ;-------  Select root closest to image center  --------
	  in = abs(fxp-.5) lt abs(fxm-.5)	; Which root closest?
	  fx = ([[fxm],[fxp]])(indgen(n),in)	; Pick closest root.
	endif else begin		; a eq 0: Linear.
	  fx = -c/float(b)
	  flag = intarr(n)+1		; Point flags.
	  cnt = n
	endelse
 
	;-------  Find fy  -----------------------
	fy = fltarr(n)
	if cnt gt 0 then begin
	  fy(w) = ((ye(w)-y(0))+fx(w)*(y(0)-y(1)))/$
		((1-fx(w))*(y(3)-y(0))+fx(w)*(y(2)-y(1)))
	endif
 
	;--------  Scalarize  -----------
	if n eq 1 then begin
	  fx = fx(0)
	  fy = fy(0)
	  flag = flag(0)
	endif
 
	return
	end
