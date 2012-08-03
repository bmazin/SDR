;-------------------------------------------------------------
;+
; NAME:
;       ORTHOPOLY
; PURPOSE:
;       Calculates a set of orthonormal polynomials.
; CATEGORY:
; CALLING SEQUENCE:
;       p = orthopoly( x, ndeg, [w])
; INPUTS:
;       x = Array of X points to be fitted.        in
;          Range of -1. to +1. is best.
;       ndeg = Highest degree polynomial desired.  in
;          Must be greater than 1.
;       w = opt weighting to be applied to pts.    in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = Orthonormal Polynomial.                out
; COMMON BLOCKS:
; NOTES:
;       Notes: Method is based on Forsythe, J. Soc. Indust.
;         Appl. Math. 5, 74-88,1957.
;         Used by opfit2d.pro.
; MODIFICATION HISTORY:
;       19-MAR-85 -- Converted from FORTRAN by RBH@APL
;       R. Sterner, 29 Mar, 1990 --- converted to SUN.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION ORTHOPOLY,X,NDEG,W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Calculates a set of orthonormal polynomials.'
	  print,' p = orthopoly( x, ndeg, [w])'
	  print,'   x = Array of X points to be fitted.        in'
	  print,'      Range of -1. to +1. is best.
	  print,'   ndeg = Highest degree polynomial desired.  in'
	  print,'      Must be greater than 1.'
	  print,'   w = opt weighting to be applied to pts.    in'
	  print,'   p = Orthonormal Polynomial.                out' 
	  print,' Notes: Method is based on Forsythe, J. Soc. Indust.'
	  print,'   Appl. Math. 5, 74-88,1957.'
	  print,'   Used by opfit2d.pro.'
	  return, -1
	endif
 
	NPTS = N_ELEMENTS(X)
	IF N_PARAMS(1) LT 3 THEN W = REPLICATE(1.0,NPTS) ; Even weights
	D = FLTARR(NDEG+1)				 ; Normal. const array
	P = FLTARR(NPTS,NDEG+1)				 ; Polynomial array
 
;---  Calculate the zeroth order polynomial  ---
	D(0) = TOTAL(W)					 ; Sum of the weights
	P(*,0) = 1.0					 ; 1st poly. is unity
	IF NDEG LE 0 THEN GOTO,DONE
 
;---  Now the first order  ---
	A = TOTAL(W*X)/D(0) 
	P(0,1) = X - A
	IF NDEG LE 1 THEN GOTO,DONE
	D(1) = TOTAL(W*P(*,1)^2)
 
;---  Now loop to get the other degrees  ---
	FOR N=2,NDEG DO BEGIN
    	  SQUARES=W*P(*,N-1)^2
	  SUMSQUARES=TOTAL(SQUARES)
	  A = TOTAL(SQUARES * X) / SUMSQUARES
	  B = SUMSQUARES / TOTAL(W*P(*,N-2)^2)
	  P(0,N) = (X-A)*P(*,N-1) - B*P(*,N-2)
	  D(N) = TOTAL(W*P(*,N)^2)
	ENDFOR
 
;---  Normalize the polynomials  ---
DONE:
	FOR N = 0, NDEG DO P(0,N) = P(*,N)/SQRT(D(N))
 
	RETURN, P
	END
