;-------------------------------------------------------------
;+
; NAME:
;       PH
; PURPOSE:
;       Return the phase of a complex number.
; CATEGORY:
; CALLING SEQUENCE:
;       p = ph(z)
; INPUTS:
;       z = a complex number or array.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEGREES returns result in degrees.
; OUTPUTS:
;       p = phase of z.                   out
; COMMON BLOCKS:
; NOTES:
;       Notes: results between -Pi and Pi (-180 and 180 deg).
;         Phase of z=0=0+i0 is returned as 0.
; MODIFICATION HISTORY:
;       R. Sterner, 13 May, 1993
;       R. Sterner, 2004 Feb 20 --- Corrected to use the /PHASE keyword.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function ph, z, degrees=deg, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the phase of a complex number.'
	  print,' p = ph(z)'
	  print,'   z = a complex number or array.    in'
	  print,'   p = phase of z.                   out'
	  print,' Keywords:'
	  print,'   /DEGREES returns result in degrees.'
	  print,' Notes: results between -Pi and Pi (-180 and 180 deg).'
	  print,'   Phase of z=0=0+i0 is returned as 0.'
	  return, -1
	endif
 
 	if keyword_set(deg) then $
	  return,!radeg*atan(z,/phase) $
	else return,atan(z,/phase)
 
	end
