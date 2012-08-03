;-------------------------------------------------------------
;+
; NAME:
;       ANG_MEAN
; PURPOSE:
;       Return the mean (and sdev) of a set of angles.
; CATEGORY:
; CALLING SEQUENCE:
;       ma = ang_mean(ang)
; INPUTS:
;       ang = array of angles.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES Angles are in degrees (else Radians).
;         MAGNITUDES=mag Weighting for each angle (def=1).
;         SDEV=sd Returned standard deviation of angle.
; OUTPUTS:
;       ma = mean of angles.     out
; COMMON BLOCKS:
; NOTES:
;       Notes: Uses component method, treating each angle
;       as the angle of a vector.  May give weight each value
;       by giving vector magnitudes.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Feb 17
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ang_mean, ang, degrees=deg, magnitudes=mag, $
	  sd=sd, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the mean (and sdev) of a set of angles.'
	  print,' ma = ang_mean(ang)'
	  print,'   ang = array of angles.   in'
	  print,'   ma = mean of angles.     out'
	  print,' Keywords:'
	  print,'   /DEGREES Angles are in degrees (else Radians).'
	  print,'   MAGNITUDES=mag Weighting for each angle (def=1).'
	  print,'   SDEV=sd Returned standard deviation of angle.'
	  print,' Notes: Uses component method, treating each angle'
	  print,' as the angle of a vector.  May give weight each value'
	  print,' by giving vector magnitudes.'
	  return,''
	endif
 
	;------------------------------------------------
	;  Resolve vectors into components
	;------------------------------------------------
	n = n_elements(ang)
	if n_elements(mag) eq 0 then mag=fltarr(n)+1.
	polrec,mag,ang,deg=deg,x,y
 
	;------------------------------------------------
	;  Average components and find angle
	;------------------------------------------------
	recpol, mean(x),mean(y),r,ma,deg=deg
 
	;------------------------------------------------
	;  Sdev
	;
	;  Using the mean angle, the vectors are rotated
	;  to put the mean angle at 180 deg.  That makes
	;  all the angles range from 0 to 360 (for deg).
	;  The sdev is than computed for these modified
	;  angles.
	;------------------------------------------------
	if arg_present(sd) then begin
	  if keyword_set(deg) then a0=180. else a0=!pi
	  rotate_xy,x,y,(a0-ma),0,0,x2,y2,deg=deg	; Rotate vectors.
	  recpol,x2,y2,r2,a2,deg=deg			; Convert to polar.
	  sd = sdev(a2)					; Sdev of angles.
	endif
 
	return, ma
 
	end
