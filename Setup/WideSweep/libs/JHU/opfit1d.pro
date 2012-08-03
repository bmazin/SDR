;-------------------------------------------------------------
;+
; NAME:
;       OPFIT1D
; PURPOSE:
;       Calculate orthonormal polynomial fit for 1-d data.
; CATEGORY:
; CALLING SEQUENCE:
;       yfit = opfit1d( y, ndeg, [x, c, p])
; INPUTS:
;       y    = Data to fit.                                   in
;       ndeg = Degree of polynomial to use.                   in
;       x = optional vector of independant variable values.   in
;         Degree must be greater than 1.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       c = opt. matrix of orthonormal polynomial coef.       out
;       p = optional vector of orthonormal polynomial values. out
;       yfit = 1-d fit to original data.                      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Method is based on Forsythe, J. Soc. Indust. 
;         Appl. Math. 5, 74-88,1957.
; MODIFICATION HISTORY:
;       19-MAR-85 -- Initial entry by RBH@APL (as opfit.pro)
;       28-DEC-91 -- Name changed from opfit to opfit1d.   blg
;       R. Sterner, 6 Mar, 1992 --- cleaned up.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function opfit1d,y,ndeg,x,c,p, help=hlp
 
        if (n_params(0) lt 2) or keyword_set(hlp) then begin
          print,' Calculate orthonormal polynomial fit for 1-d data.'
          print,' yfit = opfit1d( y, ndeg, [x, c, p])'
          print,'   y    = Data to fit.                                   in'
          print,'   ndeg = Degree of polynomial to use.                   in'
          print,'   x = optional vector of independant variable values.   in'
	  print,'     Degree must be greater than 1.'
          print,'   c = opt. matrix of orthonormal polynomial coef.       out'
          print,'   p = optional vector of orthonormal polynomial values. out'
          print,'   yfit = 1-d fit to original data.                      out'
          print,' Notes: Method is based on Forsythe, J. Soc. Indust. '
          print,'   Appl. Math. 5, 74-88,1957.'
          return, -1
        endif
 
        ;---  Check degree  -----------
        if ndeg lt 2 then begin
          print,' Error in opfit1d: degree must be greater than 1.'
          print,' Processing aborted.'
          return, -1
        endif
 
	;---  Generate X vector if not supplied  ---
	if n_elements(x) le 0 then x=findgen(n_elements(y))
 
	;---  Scale the x values to -1 thru +1 ---
	xs = ((x-min(x))/(max(x)-min(x)))*2-1
 
	;---  Calculate orthonormal polynomials  ---
	p=orthopoly(xs,ndeg)
 
	;---  Calculate fit coefficents.  ---
	c = transpose(y#p)
 
	return,p#c
	end
