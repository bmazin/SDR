;-------------------------------------------------------------
;+
; NAME:
;       ELLFIT
; PURPOSE:
;       Fit an ellipse to a 2-d probability distribution.
; CATEGORY:
; CALLING SEQUENCE:
;       ellfit, pd, xm, ym, ang, ecc, a, b
; INPUTS:
;       pd = 2-d probability distribution.                  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xm, ym = Mean X and Y coordinates (array indices).  out
;       ang = angle of major axis (deg).                    out
;       ecc = eccentricity of fitted ellipse.               out
;       a, b = semimajor, semiminor axis of fitted ellipse. out
; COMMON BLOCKS:
; NOTES:
;       Notes: An ellipse is fit by matching its moment of inertia
;         to the given array.  A threshold image should be
;         normalized to 1 before doing the fit, otherwise the
;         ellipse will not be the correct size.
;         See also genellipse.
;         Here is a simple example:
;           loadct,13
;           d = rebin(shift(dist(200),100,100),200,400)
;           z = rot(d,30) lt 50
;           tvscl,z
;           ellfit,z,xm,ym,ang,ecc,a,b
;           genellipse,xm,ym,ang,a,b,x,y
;           plots,x,y,/dev,color=!d.n_colors/2
; MODIFICATION HISTORY:
;       R. Sterner.  10 June, 1986.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ellfit, pd, xm, ym, ang, ecc, a, b, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Fit an ellipse to a 2-d probability distribution.'
	  print,' ellfit, pd, xm, ym, ang, ecc, a, b'
	  print,'   pd = 2-d probability distribution.                  in'
	  print,'   xm, ym = Mean X and Y coordinates (array indices).  out'
	  print,'   ang = angle of major axis (deg).                    out'
	  print,'   ecc = eccentricity of fitted ellipse.               out'
	  print,'   a, b = semimajor, semiminor axis of fitted ellipse. out'
	  print,' Notes: An ellipse is fit by matching its moment of inertia'
	  print,'   to the given array.  A threshold image should be'
	  print,'   normalized to 1 before doing the fit, otherwise the'
	  print,'   ellipse will not be the correct size.'
	  print,'   See also genellipse.'
	  print,'   Here is a simple example:'
	  print,'     loadct,13'
	  print,'     d = rebin(shift(dist(200),100,100),200,400)'  
          print,'     z = rot(d,30) lt 50'  
          print,'     tvscl,z'  
          print,'     ellfit,z,xm,ym,ang,ecc,a,b'  
          print,'     genellipse,xm,ym,ang,a,b,x,y'  
          print,'     plots,x,y,/dev,color=!d.n_colors/2'
	  return
	endif
 
	pi2 = !dpi^2
 
	s = size(pd)
 
	;-----  X and Y coordinates for each element in the data array  -------
	makexy, 0, s(1)-1, 1, 0, s(2)-1, 1, xa, ya
 
	;-----  Compute moments to find the principal axes angle.
	m00 = total(pd)
	m10 = total(xa*pd)
	m01 = total(ya*pd)
 
	xm = m10/m00	; Mean X.
	ym = m01/m00	; Mean Y.
 
	;------  Central moments  ------------
	u20 = total(xa^2*pd) - xm*m10
	u02 = total(ya^2*pd) - ym*m01
	u11 = total(xa*ya*pd) - ym*m10
 
	;-----  Angle of principal axes  -------
	tn2 = 2*u11/(u20-u02)
	ang = !radeg*atan(tn2)/2.0
	if u02 gt u20 then ang = ang + 90.0
 
	;-----  Now, rotate data array and re-compute moments  ----
	t = rot( pd, ang)	; ROT rotates by -ANG.
 
	;-----  Compute moments to find the principal axes angle.
	m00 = total(t)
	m10 = total(xa*t)
	m01 = total(ya*t)
 
	xm2 = m10/m00	; Mean X.
	ym2 = m01/m00	; Mean Y.
 
	;------  Central moments  ------------
	u20 = total(xa^2*t) - xm2*m10
	u02 = total(ya^2*t) - ym2*m01
	u11 = total(xa*ya*t) - ym2*m10
 
	;------  Find axes of ellipse with same 2nd moments -------
	aa = ((16.0*u20^3)/(pi2*u02))^(1./8.)
	bb = ((16.0*u02^3)/(pi2*u20))^(1./8.)
 
	a = aa > bb  ; Make sure major axis is the larger of the two.
	b = aa < bb
 
	ecc = sqrt(a^2 - b^2)/a  ; Eccentricity of the ellipse.
 
	return
	end
