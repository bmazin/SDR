;+
; NAME:
;        FIT_BKD
;
; PURPOSE:
;        Perform a least-square polynomial fit to the background of a major
;        frame with optional error estimates.
;
;        This routine uses matrix inversion.  A newer version of this routine,
;        SVDFIT, uses Singular Value Decomposition.  The SVD technique is more
;        flexible, but slower.
;
;        Another version of this routine, POLYFITW, performs a weighted
;        least square fit.
;
; CATEGORY:
;        Curve fitting.
;
; CALLING SEQUENCE:
;        Result = FIT_BKD(Cts, Trns [, NDegree ,Yfit, Yband, Sigma, A, Chisq] )
;
; INPUTS:
;      Cts:    An array holding the counts for this major frame, [float( nbin )].
;
;     Trns:    A nsrc x nbin array holding all the transmission functions
;         for this major frame.
;
; OPTIONAL INPUT KEYWORDS:
;  NDegree: The degree of the polynomial to fit. If the USER does not
;         specify this, NDegree defaults to 1.
;         NOTE: if the USER sets NDegree= 0 then the background
;         is simply the weighted average, assuming Poisson statistics,
;         (i.e. sigma2 = Counts )
;
;      CUT:    The fractional derivative cut used in the routine GLITCH for
;        removing glitches from the background data, [float].
;
; OUTPUTS:
;        FIT_BKD returns a vector of coefficients with a length of NDegree+1.
;
; OPTIONAL OUTPUT PARAMETERS:
;
;     Yfit: The vector of calculated Y's.  These values have an error
;      of + or - Yband.
;
;    Yband: Error estimate for each point = 1 sigma
;
;    Sigma: The standard deviation in Y units.
;
;        A: Correlation matrix of the coefficients.
;
;    Chisq: The Chi-squared for this fit, assuming poisson statistics.
;
; OPTIONAL OUTPUT KEYWORDS:
;
; GLITCHES: A list of bins where glitches were found in the background.
;        Returns a -1 if no glitches were found, [integer( nbad )]
;
;   BIN_PK: A list of bins where the transmissions are a maximum, [integer( nsrc )].
;
;   BKD_PK: The fitted background values at the bins where the transmissions
;        are a maximum, [float( nsrc )].
;
; EXAMPLE:
;       Let's find the background for some major frame in 320ms mode with 2 sources
;       in the field of view:
;
;
;       let's generate random background and data:
;
;       cts = randomn( seed, 128 )
;       trns = fltarr( 2, 128 )
;       for i=20,80 do  trns( 0,i ) = randomn( seed )
;       for i=50,100 do trns( 1,i ) = randomn( seed )
;
;       coeff = FIT_BKD( Cts, Trns, 1, Bkd, ErrBars )
;
; MODIFICATION HISTORY:
;   Written by:    H. C. Wen, April, 1994.
;   27-APR-1994    Changed the name from GET_BKD and added the option to fit the
;                  background to a polynomial.
;   04-MAY-1994    For Ndegree=0, changed the average background to a
;                  weighted average, where sigma2 = counts.
;   05-MAY-1994    Added Chisq as an optional output. Converted the
;                  for/do loops into matrix algebra.
;   08-MAY-1994    Removed glitches from the background data with GLITCH routine.
;-
function FIT_BKD, Cts, Trns, Ndegree, Yfit, Yband, Sigma, A, Chisq, $
                  CUT=Cut, BIN_PK=Bin_pk, BKD_PK=Bkd_pk, GLITCHES=Glitches, $
                  NOWARN=nowarn, LOG=log

         ON_ERROR, 2          ; on error, return control to caller


         NP = N_PARAMS()
         if (NP lt 2) or (NP gt 8) then $
            message, 'Must be called with 2-8 parameters: '+ $
                     'Cts, Trns [, Ndegree, Yfit, Yband, Sigma, A, Chisq]'

;  Let's determine the length of these arrays and the number of sources

         SCts      = SIZE( Cts )
         STrns     = SIZE( Trns )
         nbin      = SCts(1)
         nsrc      = STrns(1)

         IF (STrns(0) ne 2) or (STrns(2) ne nbin) then $
            message,'Size of Cts and Trns arrays are incompatible.'

;  Let's get the peak bins

         bin_pk = GET_PEAK( Trns )

;  Add the transmission functions for all the sources then add counts
;  to the background array at each bin where the total transmission = 0.
;  If the two mjf's are not sequential then add the previous mjf.

         trns_sum = TOTAL( Trns, 1 )

;  Put counts into the background array for all bins where the total
;  transmission is 0

         i_bkd0 = WHERE( trns_sum eq 0, nbkd0 )
         if nbkd0  gt fix(0.10*nbin) then        $
            bkd0 = Cts( i_bkd0 )   $
         else begin
            printdev,'Not enough data points to fit background.',$
                     NODISPLAY=nowarn, LOG=log
            printdev,'Returning counts minimum.',$
                     NODISPLAY=nowarn, LOG=log
            const    = MIN( Cts )
            yfit     = REPLICATE( const,nbin )
            yband    = REPLICATE( const,nbin )
            Sigma    = 0.0
            A        = 0.0
            Chisq    = 0.0
            Bkd_pk   = REPLICATE( const,nsrc )
            glitches = -1
            return, -const    ; Return a negative value as a flag
         endelse

;  Remove any "glitches" from the data

         okbins  = indgen( nbkd0 )
         badbins = GLITCH( bkd0,nbad,CUT=cut )
         if nbad gt 0 then begin
              glitches = i_bkd0( badbins )
              for i=0,nbad-1 do $
                  okbins = okbins( WHERE( okbins ne badbins(i) ) )
              nbkd = N_ELEMENTS( okbins )
         endif else begin
              nbkd = nbkd0
              glitches = -1
         endelse

         i_bkd= i_bkd0( okbins )
         bkd = bkd0( okbins )
         sigma2_bkd = abs(bkd)
         w = 1./sigma2_bkd

         if N_ELEMENTS( Ndegree ) eq 0 then ndegree = 1

         if ndegree eq 0 then begin    ;weighted average, sigma2 = bkd

              norm = TOTAL( w )
              wgt_avg = TOTAL( w*bkd )/norm
              errbar  = sqrt( 1./norm )

              yfit    = REPLICATE( wgt_avg,nbin  )
              yband   = REPLICATE( errbar,nbin )
              A       = 0
              dof     = nbkd - 1.
              Chisq   = TOTAL( (bkd-yfit)^2./sigma2_bkd )
              Chisq   = Chisq/dof
              Bkd_pk  = yfit( Bin_pk )
              return, wgt_avg

         endif else begin

;  Fit the background data to a polynomial the degree, ndegree

              fit     = POLYFITW( i_bkd, bkd, w, ndegree, yfit0, yband0, sigma, A )
              dof     = nbkd - (1.+ndegree)
              Chisq   = TOTAL( (bkd-yfit0)^2./sigma2_bkd )
              Chisq   = Chisq/dof


              yfit      = REPLICATE( 0.,nbin )
              yband     = REPLICATE( 0.,nbin )

              yfit( i_bkd )  = yfit0
              yband( i_bkd ) = yband0

;  Fill in bin region(s) where the total transmission is NON-ZERO

              i_pk      = WHERE( trns_sum ne 0, nsig )

              t_arr     = fltarr( nsig,ndegree+1 )
              for k=0,ndegree do t_arr(*,k) = i_pk^k
              yfit( i_pk )   = t_arr # transpose( fit )   ; Must take the
                                                 ; transpose because
                                                 ; POLYFITW returns a
                                                 ; (0,Ndegree) array,
                                                 ; NOT a (Ndegree) array!

;  Fill in bins where "glitches" were found

              if nbad gt 0 then begin
                   t_arr     = fltarr( nbad,ndegree+1 )
                   for k=0,ndegree do t_arr(*,k) = glitches^k
                   yfit( glitches ) = t_arr # transpose( fit )
              endif

              Bkd_pk  = yfit( Bin_pk )
              return, fit

         endelse

end

