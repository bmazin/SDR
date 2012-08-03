;-------------------------------------------------------------
;+
; NAME:
;       NEAREST
; PURPOSE:
;       Return multiple of a given step nearest a target value.
; CATEGORY:
; CALLING SEQUENCE:
;       v = nearest( s, t, [ vlo, vhi ])
; INPUTS:
;       s = step size.                      in
;       t = target value.                   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       vlo =  largest multiple of S <= T.  out
;       vhi = smallest multiple of S >= T.  out
;       v = multiple of S nearest T.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner  10 Apr, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner  2005 Apr 12 --- Upgraded to work for big numbers.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function nearest, s, t, vlo, vhi,help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return multiple of a given step nearest a target value.'
	  print,' v = nearest( s, t, [ vlo, vhi ])'
	  print,'   s = step size.                      in'
	  print,'   t = target value.                   in'
	  print,'   vlo =  largest multiple of S <= T.  out'
	  print,'   vhi = smallest multiple of S >= T.  out'
	  print,'   v = multiple of S nearest T.        out'
	  return,-1
	endif
 
;	vlo = floor(t/s)*s 
;	vhi =  ceil(t/s)*s
 
	;----------------------------------------------------------
	;  pmod(r,1) is the fractional part of the ratio t/s.
	;----------------------------------------------------------
	r = t/s			; Ratio.
	fr = pmod(r,1)		; Fractional part of ratio.
	fl = r - fr		; Floor of r.
 
	vlo = fl*s		; First multiple of s below t.
	vhi = (fl + 1)*s	; First multiple of s above t.
 
	if (abs(t-vlo) lt abs(t-vhi)) then return, vlo else return, vhi
 
	end
