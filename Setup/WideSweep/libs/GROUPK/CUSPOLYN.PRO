;+
; NAME:
;   CUSPOLYN
;
; PURPOSE:
;   This function returns a "cusp" polynomial determined by a given set of
;   coefficients.
;
; CATEGORY:
;   Curve and surface fitting.
;
; CALLING SEQUENCE:
;   Result = CUSPOLYN( Degree, X, Y, Coeff [,/MATRIX])
;
; INPUTS:
;
;   Degree:   The degree (in one dimension) of the 2D polynomial, [integer].
;
;      X,Y:   The x- and y-vectors [double(npt)].
;
;    Coeff:   The vector of coefficients for the cusp-polynomial,
;         which is dimensioned as [double( (Degree+1)^2 )]. (See SFITCUSP)
;
; INPUT KEYWORDS:
;
;   MATRIX:   Treat X as a "row" vector and Y as a "column" vector and find
;         the cusp-polynomial matrix associated with this XY-matrix.
;
; OUTPUT:
;   This function returns the values of the cusp-polynomial at the values
;   set by the X and Y vectors, [double(npt)] OR [double(nx,ny)] if MATRIX
;   keyword is set.
;
; PROCEDURE:
;   The cusp-polynomial is defined as:
;       F(x,y) = Sum over i and j of coeff(i*(degree+1)+j) * abs( x^i * y^j )
;
; MODIFICATION HISTORY:
;   July, 1994               H.C. Wen
;   24-AUG-1994              Added MATRIX keyword to return a fit "matrix"
;                            Return a fit "matrix" whose x-component is
;                            defined by the x array and y-component is defined
;                            by the y array. (i.e. fit_matrix( x, y ))
;
;-
function CUSPOLYN, degree, x, y, coeff, MATRIX=Matrix

         on_error, 2

         nx = N_ELEMENTS(x)
         ny = N_ELEMENTS(y)

         if keyword_set( MATRIX ) then begin
              xm = x # REPLICATE(1.d,ny)
              ym = REPLICATE(1.d,nx) # y
              fit= dblarr(nx,ny)
         endif else begin
              if nx ne ny then message,'Incompatible arrays.'
              xm = x
              ym = y
              fit= dblarr(nx)
         endelse

         for j=0,degree do for k=0,degree do $
              fit = fit+coeff( j*(degree+1)+k )*abs( xm^j*ym^k )

         return, REFORM( fit )
end
