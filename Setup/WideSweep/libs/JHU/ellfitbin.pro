;-------------------------------------------------------------
;+
; NAME:
;       ELLFITBIN
; PURPOSE:
;       Fit an ellipse to a 2-d binary blob image.
; CATEGORY:
; CALLING SEQUENCE:
;       ellfitbin, array, xm, ym, ang, ecc, a, b
; INPUTS:
;       array = 2-d binary blob image.                      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xm, ym = Mean X and Y coordinates (array indices).  out
;       ang = angle of major axis (deg).                    out
;       ecc = eccentricity of fitted ellipse.               out
;       a, b = semimajor, semiminor axis of fitted ellipse. out
; COMMON BLOCKS:
; NOTES:
;       Notes: The method used is that listed on David Fanning's
;       web site and uses techniques from Craig Markwardt.
;       Appears to give a better fit then ellfit.
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Jan 08 after David Fanning & Craig Markwardt.
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ellfitbin, array, xm, ym, ang, ecc, a, b, help=hlp
 
	if (n_params(0) lt 7) or keyword_set(hlp) then begin
	  print,' Fit an ellipse to a 2-d binary blob image.'
          print,' ellfitbin, array, xm, ym, ang, ecc, a, b'
          print,'   array = 2-d binary blob image.                      in'
          print,'   xm, ym = Mean X and Y coordinates (array indices).  out'
          print,'   ang = angle of major axis (deg).                    out'
          print,'   ecc = eccentricity of fitted ellipse.               out'
          print,'   a, b = semimajor, semiminor axis of fitted ellipse. out'
          print," Notes: The method used is that listed on David Fanning's"
	  print,' web site and uses techniques from Craig Markwardt.'
	  print,' Appears to give a better fit then ellfit.'
	  return
	endif
 
	indices = where(array ne 0)		; Find non-zero pixels.
	xsize = dimsz(array,1)			; Array dimensions.
	ysize = dimsz(array,2)
 
	;---  Find center of ellipse  ----
	totalMass = Total(array)
	xm = Total( Total(array, 2) * Indgen(xsize) ) / totalMass
	ym = Total( Total(array, 1) * Indgen(ysize) ) / totalMass
	center = [xm, ym]
 
	;---  Move origin to center of mass  ----
	x = Findgen(xsize)
	y = Findgen(ysize)
	xx = (x # (y * 0 + 1)) - xm
	yy = ((x * 0 + 1) # y) - ym
 
	;---  mass distribution tensor  ----
	npts = N_Elements(indices)
	i11 = Total(yy[indices]^2) / npts
	i22 = Total(xx[indices]^2) / npts
	i12 = -Total(xx[indices] * yy[indices]) / npts
	tensor = [ [i11, i12], [i12,i22] ]
 
	;---  eigenvalues and eigenvectors  ----
	evals = Eigenql(tensor, Eigenvectors=evecs)
 
	;---  semi-major and semi-minor  ----
	a2 = evals[0]*4.0
	b2 = evals[1]*4.0
	a = sqrt(a2)
	b = sqrt(b2)
 
	;---  Eccentricity  ----
	ecc = sqrt(a2-b2)/a
 
	;---  Angle  ----
	evec = evecs[*,0]
	ang = ATAN(evec[1], evec[0]) * 180. / !Pi - 90.0
 
	end
