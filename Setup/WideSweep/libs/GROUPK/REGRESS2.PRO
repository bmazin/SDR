;+
; NAME:
;        REGRESS2
;
; PURPOSE:
;        Multiple linear regression fit.
;        Fit the function:
;        Y(i) = A(0)*X(0,i) + A(1)*X(1,i) + ... +
;             A(Nterms-1)*X(Nterms-1,i)
;
; CATEGORY:
;        G2 - Correlation and regression analysis.
;
; CALLING SEQUENCE:
;        Result = REGRESS(X, Y, W [, YFIT, SIGMA, FTEST, R, RMUL, CHISQ])
;
; INPUTS:
;        X:   array of independent variable data.  X must
;             be dimensioned (Nterms, Npoints) where there are Nterms
;             coefficients to be found (independent variables) and
;             Npoints of samples.
;
;        Y:   vector of dependent variable points, must have Npoints
;             elements.
;
;        W:   vector of weights for each equation, must be a Npoints
;             elements vector.  For instrumental weighting
;             w(i) = 1/standard_deviation(Y(i)), for statistical
;             weighting w(i) = 1./Y(i).   For no weighting set w(i)=1,
;             and also set the RELATIVE_WEIGHT keyword.
;
; OUTPUTS:
;        Function result = coefficients = vector of
;        Nterms elements.  Returned as a column vector.
;
; OPTIONAL OUTPUT PARAMETERS:
;        Yfit:     array of calculated values of Y, Npoints elements.
;
;        Sigma:    Vector of standard deviations for coefficients.
;
;        Ftest:    value of F for test of fit.
;
;        Rmul:     multiple linear correlation coefficient.
;
;        R:        Vector of linear correlation coefficient.
;
;        Chisq:    Reduced chi squared.
;
; KEYWORDS:
;RELATIVE_WEIGHT: if this keyword is non-zero, the input weights
;             (W vector) are assumed to be relative values, and not based
;             on known uncertainties in the Y vector.    This is the case for
;             no weighting W(*) = 1.
;
; PROCEDURE:
;        Adapted from the program REGRES, Page 172, Bevington, Data Reduction
;        and Error Analysis for the Physical Sciences, 1969.
;
; MODIFICATION HISTORY:
;        Written, DMS, RSI, September, 1982.
;        Added RELATIVE_WEIGHT keyword, W. Landsman, August 1991
;        29-AUG-1994:   H.C. Wen - Used simpler, clearer algorithm to determine
;                       fit coefficients. The constant term, A0 is now just one
;                       of the X(iterms,*) vectors, enabling the algorithm to
;                       now return the sigma associated with this constant term.
;                       I also made a special provision for the case when
;                       Nterm = 1; namely, "inverting" a 1x1 matrix, i.e. scalar.
;        26-MAR-1996:   Added the DOUBLE and CHECK keywords to the call to DETERM.
;        02-APR-1996:   Test matrix singularity using second argument in INVERT
;                       instead of call to DETERM.
;-
function REGRESS2,X,Y,W,Yfit,Sigma,Ftest,R,Rmul,Chisq, RELATIVE_WEIGHT=relative_weight

         On_error,2              ;Return to caller if an error occurs

         NP = N_PARAMS()
         if (NP lt 3) or (NP gt 9) then $
              message,'Must be called with 3-9 parameters: '+$
                      'X, Y, W [, Yfit, Sigma, Ftest, R, RMul, Chisq]'

;  Determine the length of these arrays and the number of sources

         SX        = SIZE( X )
         SY        = SIZE( Y )
         nterm     = SX(1)
         npts      = SY(1)

         if (N_ELEMENTS(W) NE SY(1)) OR $
            (SX(0) NE 2) OR (SY(1) NE SX(2)) THEN $
              message, 'Incompatible arrays.'

         WW   = REPLICATE(1.,nterm) # W
         curv = ( X*WW ) # TRANSPOSE( X )
         beta = X # (Y*W)

         if nterm eq 1 then begin
              sigma  = 1./sqrt(curv)
              X_coeff= beta/curv
         endif else begin
              err     = INVERT( curv, status )

              if (status eq 1) then begin
                   print,'det( Curvature matrix )=0 .. Using REGRESS'
                   X1   = X
                   linechk   = X(0,0) - X(0,fix( npts*randomu(seed) ))
                   if linechk eq 0 then begin
                        print,'Cannot determine sigma for CONSTANT'
                        X1  = X1(1:nterm-1,*)
                   endif

                   coeff = REGRESS( X1,Y,W,Yfit,A0, Sigma,Ftest,R,Rmul,Chisq)

                   if linechk eq 0 then begin
                        coeff     = [A0,reform(coeff)]
                        Sigma     = [ 0,reform(Sigma)]
                        R         = [ 0,R]
                   endif
                   return, coeff
              endif else if (status eq 2) then begin
                print,'WARNING -- small pivot element used in matrix inversion.'
                print,'           significant accuracy probably lost.'
              endif

              diag    = indgen( nterm )
              sigma   = sqrt( err( diag,diag ) )
              X_coeff = err # beta
         endelse

         Yfit     = TRANSPOSE(X_coeff # X)

         dof   = npts - nterm > 1
         Chisq = TOTAL( (Y-Yfit)^2.*W )
         Chisq = Chisq/dof

;   To calculate the "test of fit" parameters, we revert back to the original
;   cryptic routine in REGRESS1. Because the constant term (if any) is now
;   included in the X variable, NPAR = NTERM_regress2 = NTERM_regress1 + 1.

         if nterm eq 1 then goto, SKIP

         SW = TOTAL(W)           ;SUM OF WEIGHTS
         YMEAN = TOTAL(Y*W)/SW   ;Y MEAN
         XMEAN = (X * (REPLICATE(1.,NTERM) # W)) # REPLICATE(1./SW,NPTS)
         WMEAN = SW/NPTS
         WW = W/WMEAN
         ;
         NFREE = NPTS-1          ;DEGS OF FREEDOM
         SIGMAY = SQRT(TOTAL(WW * (Y-YMEAN)^2)/NFREE) ;W*(Y(I)-YMEAN)
         XX = X- XMEAN # REPLICATE(1.,NPTS)      ;X(J,I) - XMEAN(I)
         WX = REPLICATE(1.,NTERM) # WW * XX      ;W(I)*(X(J,I)-XMEAN(I))
         SIGMAX = SQRT( XX*WX # REPLICATE(1./NFREE,NPTS)) ;W(I)*(X(J,I)-XM)*(X(K,I)-XM)
         R = WX #(Y - YMEAN) / (SIGMAX * SIGMAY * NFREE)


         WW1 = WX # TRANSPOSE(XX)

         ARRAY = INVERT(WW1/(NFREE * SIGMAX #SIGMAX))
         A     = (R # ARRAY)*(SIGMAY/SIGMAX)         ;GET COEFFICIENTS

         FREEN = NPTS-NTERM > 1                 ;DEGS OF FREEDOM, AT LEAST 1.

         CHISQ = TOTAL(WW*(Y-YFIT)^2)*WMEAN/FREEN ;WEIGHTED CHI SQUARED
         IF KEYWORD_SET(relative_weight) then varnce = chisq $
                                         else varnce = 1./wmean

         RMUL = TOTAL(A*R*SIGMAX/SIGMAY)         ;MULTIPLE LIN REG COEFF
         IF RMUL LT 1. THEN FTEST = RMUL/(NTERM-1)/ ((1.-RMUL)/FREEN) ELSE FTEST=1.E6
         RMUL = SQRT(RMUL)

SKIP:    return, X_coeff

end

