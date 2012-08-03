;-------------------------------------------------------------
;+
; NAME:
;       KEPLER
; PURPOSE:
;       Solve Kepler's equation given mean anomaly and eccentricity.
; CATEGORY:
; CALLING SEQUENCE:
;       kepler
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ANOM=m  Mean anomaly in radians (input).
;         ECC=e   Eccentricity            (input).
;         TRUE=v  True anomaly in radians (output).
;         RAD=r   Normalized Radius       (output).
;            Multiply r by semimajor axis.
;         SEMI=aa Semimajor axis size.    (optional input).
;           If given multiplies r.
;         X=x, Y=y, Z=z Satellite vector. (optional input).
;           In orbit coordinates. Only computed if requested.
;         /DEBUG  List values.
; OUTPUTS:
; COMMON BLOCKS:
;       kepler_com
; NOTES:
;       Note: make sure to give at least ECC in double precision.
;         If not then an endless loop may occur.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Jul 20
;       R. Sterner, 2003 Nov 26 --- Added note to help.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro kepler, anom=anom, ecc=ecc, true=v, rad=r, $
	  semi=semi, debug=debug, x=xx, y=yy, z=zz, help=hlp
 
	common kepler_com, radeg, pi2
 
	if keyword_set(hlp) then begin
	  print," Solve Kepler's equation given mean anomaly and eccentricity."
	  print,' kepler'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   ANOM=m  Mean anomaly in radians (input).'
	  print,'   ECC=e   Eccentricity            (input).'
	  print,'   TRUE=v  True anomaly in radians (output).'
	  print,'   RAD=r   Normalized Radius       (output).'
	  print,'      Multiply r by semimajor axis.'
	  print,'   SEMI=aa Semimajor axis size.    (optional input).'
	  print,'     If given multiplies r.'
	  print,'   X=x, Y=y, Z=z Satellite vector. (optional input).'
	  print,'     In orbit coordinates. Only computed if requested.'
	  print,'   /DEBUG  List values.'
	  print,'   Note: make sure to give at least ECC in double precision.'
	  print,'     If not then an endless loop may occur.'
	  return
	endif
 
	if n_elements(radeg) eq 0 then begin
	  radeg = 180D0/!dpi
	  pi2 = 2d0*!dpi
	endif
 
	if n_elements(anom) eq 0 then begin		; Check mean anomaly.
	  print,' Error in kepler: must give mean anomaly (deg).'
	  return
	endif
	if n_elements(ecc) eq 0 then begin		; Check ecc.
	  print,' Error in kepler: must give eccentricity.'
	  return
	endif
 
	m = anom
	e = ecc
 
	;--------------  Find true anomaly  -------------
	if keyword_set(debug) then begin
	  print,' Mean anomaly = ',m*radeg
	  print,' Ecc = ',e
	endif
 
	;--------------  Solve Kepler's equation   ---------
	;--------------  First find starting guess for E0  -----
	mr = m						; M in radians.
	if (abs(m) lt 30) and (e gt 0.975) then begin	; Danger zone.
	  a = (1-e)/(4*e + 0.5D0)
	  b = mr/(8*e + 1.0D0)
	  sn = sign(b)
	  z = (b + sn*sqrt(b^2 + a^3))^(1./3.)
	  s0 = z - a/2
	  s = s0 - 0.078*s0^5/(1+e)
	  e0 = mr + e*(3*s - 4*s^3)			; Starting E.
	endif else e0 = mr
 
	;-------------  Now iterate to get E  --------------
loop:
	e1 = e0 + (mr + e*sin(e0) - e0)/(1 - e*cos(e0))
	if abs(e1-e0) le 1D-12 then goto, done
	e0 = e1
	if keyword_set(debug) then print,form='(F15.9)',e0*radeg
	goto, loop
 
	;------------  Now compute true anomaly from E1  -----------
done:
	tv2 = sqrt((1+e)/(1-e)) * tan(e1/2)
	v = 2*atan(tv2)				; True anomaly in radians.
	if v lt 0 then v = v + pi2		; Want 0 to 2 Pi.
 
	;-----------  Radial distance from center  ----------
	cv = cos(v)
	r = (1D0-e^2)/(1D0+e*cv)		; Normalized distance.
	if n_elements(semi) then r=r*semi	; Scale for semimajor axis.
 
	;-----------  Satellite vector  ---------------------
	if arg_present(xx) then begin
	  xx = r*cv
	  yy = r*sin(v)
	  zz = 0D0
	endif
 
	if keyword_set(debug) then begin
	  print,form='(A,F13.9)',' True Anomaly (deg) = ',v*radeg
	  print,' Normalized radius = ',r
	  if n_elements(xx) ne 0 then begin
	    print,' X,Y,Z = ',xx,yy,zz
	  endif
	endif
 
	end
