;-------------------------------------------------------------
;+
; NAME:
;       POLREC
; PURPOSE:
;       Convert 2-d polar coordinates to rectangular coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       polrec, r, a, x, y
; INPUTS:
;       r, a = vector in polar form: radius, angle (radians).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       x, y = vector in rectangular form.                     out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 13 Feb, 1991 --- added /degrees.
;       1999 May 03 --- Made double precision.  R. Sterner.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro polrec, r, a, x, y, help=hlp, degrees=degrees
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert 2-d polar coordinates to rectangular coordinates.
	  print,' polrec, r, a, x, y
	  print,'   r, a = vector in polar form: radius, angle (radians).  in'
	  print,'   x, y = vector in rectangular form.                     out'
          print,' Keywords:'
          print,'   /DEGREES means angle is in degrees, else radians.'
	  return
	endif
 
	cf = 1.D0
	if keyword_set(degrees) then cf = 180/!dpi
 
	x = r*cos(a/cf)
	y = r*sin(a/cf)	
	return
	end
