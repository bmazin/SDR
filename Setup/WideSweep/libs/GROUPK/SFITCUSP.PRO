;+
; NAME:
;   SFITCUSP
;
; PURPOSE:
;   This function determines a "cusp" polynomial weighted fit to a surface.
;
; CATEGORY:
;   Curve and surface fitting.
;
; CALLING SEQUENCE:
;   Result = SFITCUSP( Degree, X, Y, Z, W)
;
; INPUTS:
;
;   Degree:   The maximum degree of fit (in one dimension), [integer].
;
;      X,Y:   The x- and y-coordinates for each data point, [double(npt)].
;
;        Z:   The surface value for each data point, [double(npt)].
;
;        W:   The weight associated with each data point, [double(npt)].
;         For poisson statistics use 1/sigma2 = 1/Z.
;
; INPUT KEYWORDS:
;
; DEADTIME:   Set this keyword to include a dead time correction in the fit.
;
; OUTPUT:
;   This function returns a fitted array, [double(npt)].
;
; OUTPUT KEYWORDS:
;    COEFF:   The array of coefficients for a cusp-polynomial function
;         of x and y to fit data.
;         This parameter is returned as a (Degree+1)^2 element [double] array.
;
;      ERR:   The error matrix of dimension (Degree+1)^2 x (Degree+1)^2
;         containing the variances and covariances of the fitted coefficients.
;
; PROCEDURE:
;   Fit a 1D array Z as a polynomial function of x and y.
;   The function fitted is:
;       F(x,y) = Sum over i and j of coeff(i*(degree+1)+j) * abs( x^i * y^j )
;   where coeff is returned as a keyword.
;
;   The deadtime correction is of the form
;       D(z)   = - coeff * cts^2
;   where coeff = (deadtime)/(timing mode=(320 or 5 ms)
;   WARNING: This functional form for the deadtime correction is only an
;
;
; MODIFICATION HISTORY:
;   July, 1994               H.C. Wen
;   07-SEP-1994              Added the DEADTIME keyword.
;
;-
function SFITCUSP, degree, x, y, z, w, DEADTIME=Cts, COEFF=coeff, ERR=err

         on_error, 2
         npts = N_ELEMENTS( x )
         ndim = (degree+1)^2
         if keyword_set( Cts ) then ndim = ndim + 1

         beta = dblarr( ndim, /nozero )
         alpha= dblarr( ndim, ndim, /nozero )

;   Enter matrix and vector elements
;   for the cusp-polynomial

         for jj=0,degree do for kk=0,degree do begin
              beta( jj*(degree+1)+kk) = TOTAL( z*w*abs( x^jj*y^kk ) )
              for j=0,degree do for k=0,degree do $
                   alpha( jj*(degree+1)+kk, j*(degree+1)+k ) =$
                   TOTAL( w*abs( x^(j+jj)*y^(k+kk) ) )
         endfor

;   for the dead time correction

         if keyword_set( Cts ) then begin
              beta( ndim-1 )      = TOTAL( z*w* (-cts^2) )
              for j=0,degree do for k=0,degree do $
                   alpha( ndim-1, j*(degree+1)+k ) = $
                        TOTAL( w*abs( x^j * y^k )*( -cts^2 ) )
              alpha( *, ndim-1 )  = alpha( ndim-1, * )
              alpha( ndim-1, ndim-1 ) = TOTAL( w* (-cts^2)^2 )
         endif

;   Invert matrix to determine regression coefficients

         detA = DETERM( alpha )
         if detA eq 0 then message, 'Determinant = 0!'

         err   = INVERT( alpha )       ;error matrix
         coeff = err # beta

         fit = dblarr( npts)
         for j=0,degree do for k=0,degree do $
              fit = fit+coeff( j*(degree+1)+k )*abs( x^j*y^k )

         if keyword_set( Cts ) then $
              fit = fit + coeff( ndim-1 )*( -cts^2 )

         return, fit
end
