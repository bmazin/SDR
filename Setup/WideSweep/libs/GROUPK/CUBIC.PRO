;+
; NAME:
;        CUBIC
;
; PURPOSE:
;        Solve for the roots of a cubic polynomial OR
;        find the value(s) of a cubic polynomial (INVERSE)
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = CUBIC( X, Coeff )
;
; INPUTS:
;        X:   For the forward transform, it is the VALUE of the cubic
;             polynomial. If the INVERSE keyword is set then it is
;             the ARGUMENT of the cubic polynomial.
;
;        Coeff:    Array of coefficients of the cubic polynomial, fltarr(4).
;
; KEYWORD PARAMETERS:
;
;        INVERSE:  Set this keyword to determine the value of the cubic
;             polynomial, (0=Default).
;
; OUTPUTS:
;        Returns the ARGUMENT of a cubic polynomial for the forward
;        transform or the VALUE of a cubic polynomial for the inverse
;        transform (if the INVERSE keyword is set).
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1994.
;
;-
function CUBIC, X, Coeff, INVERSE=Inverse

         a    = Coeff(0)
         b    = Coeff(1)
         c    = Coeff(2)
         d    = Coeff(3)

         if keyword_set( INVERSE ) then begin

              h=X
              t=a+b*h+c*h^2+d*h^3

              return, t

         endif else begin

              t=X

              s1= ATAN(SQRT(3)*(27*a*d^2-9*b*c*d+2*c^3-27*d^2*t)/(9*d*(c^2 $
                       -3*b*d)^(1.5)*SQRT((27*a^2*d^2-2*a*(9*b*c*d $
                       -2*c^3+27*d^2*t)+4*b^3*d-b^2*c^2+18*b*c*d*t $
                       -t*(4*c^3-27*d^2*t))/(3*b*d-c^2)^3)) $
                      )/3

              r1= SQRT(3)*SQRT(c^2-3*b*d)*COS(s1)/(3*d)
              r2= SQRT(c^2-3*b*d)*SIN(s1)/(3*d)
              r3= -c/(3*d)

              h1= 2*SQRT(c^2-3*b*d)*SIN(s1)/(3*ABS(d))+r3
              h2=-SIGN(d)*(r1 + r2) + r3
              h3= SIGN(d)*(r1 - r2) + r3

              h = [[h1],[h2],[h3]]
              h = REFORM(h)

              return, h

         endelse
end
