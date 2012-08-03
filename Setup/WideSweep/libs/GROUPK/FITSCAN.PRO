;+
; NAME:
;        FITSCAN
;
; PURPOSE:
;        Fits for the source intensities and background in a scan assuming
;        constant intensities and a polynomial background.  The method of
;        multiple linear regression is employed.
;
; CATEGORY:
;        Curve fitting.
;
; CALLING SEQUENCE:
;
;        FITSCAN, Cts, Trns, Ndegree
;
; INPUTS:
;          Cts:    Counts or "data" in each bin of the scan, [float(nbin)]
;
;         Trns:    A nsrc x nbin array of transmission functions, [float( nsrc, nbin )].
;
;      Ndegree:    The degree of the polynomial to be fitted to the background.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;       NOTRNS:    If this keyword is set, then the transmissions are ignored,
;             and ONLY the background regions are fitted.  All variables
;             associated with the transmissions are either set to 0 or -1.
;             ( Note: if all sources fit for negative intensities then this
;             mode is automatically set! )
;
;      MIN_TRN:    Sets the minimum transmission peak allowed for all
;             sources.  Sources which fall below this minimum have their
;             intensities set to 0 and are excluded from the fitting.
;             The default value is 0, and must be GE 0 and LE 1.
;
;     MAX_FDER:    The fractional derivative cut used in the routine GLITCH for
;             removing glitches from the background data, [float].
;
;       NOWARN:    Suppress printing of warning messages.
;
;          LOG:    Write warning messages to log file.
;
; OUTPUT KEYWORD PARAMETERS:
;
;
;       OCOEFF:    Structure holding all the coefficients of the fit. Its tags
;             are defined as follows:
;
;             intensity :  fitted intensities for each source, [float( nbin )].
;                   bkd :  coefficients of the polynomial background fit,
;                       starting from the constant term, ending at the
;                       Cn * bin^ndegree term, [float( ndegree+1 )].
;
;             (NOTE:if source fits for a negative intensity, the intensity is
;              set to 0, but its corresponding uncertainty, OSIGMA.intensity
;              is kept)
;
;       OSIGMA:    Structure holding the sigmas associated with each of the
;             fitted coefficients defined in OCOEFF.  Its tags are defined as
;             follows:
;
;             intensity :  sigmas of OCOEFF.intensity, [float( nbin )].
;                   bkd :  sigmas of OCOEFF.bkd, [float( ndegree+1 )].
;
;         OFIT:    Structure holding the fit of the scan at each bin. Its tags
;             are defined as follows:
;
;                  data :  overall fit to the data at each bin, [float( nbin )].
;                   bkd :  polynomial fit to the background, [float( nbin )].
;                   sig :  sum of Intensity * Transmission over all the
;                       sources at each bin, [float( nbin )].
;
;     OREGRESS:    Structure holding some of the "tests of fit" results from
;             the multiple linear regression. Its tags are defined as follows:
;
;                 Ftest :  value of F for test of fit.
;                     R :  vector of linear correlation coefficient.
;                  Rmul :  multiple linear correlation coefficient.
;                    CL :  confidence level of the overall reduced chi-squared
;                       per degree of freedom.
;
;      ORCHISQ:    Structure holding the reduced chi-squared per degree of
;             freedom for the various regions of fitting.  All bins with
;             glitches are excluded. Its tags are defined as follows:
;
;                  data :  overall reduced chi-squared over all the bins.
;                   bkd :  reduced chi-squared for the background region.
;                   sig :  reduced chi-squared for the signal region where
;                       transmissions > 0.
;
;      OGLITCH:    Structure holding all glitches found in the data for the
;             various regions of fitting. Its tags are defined as follows:
;
;               nglitch :  number of glitches found in the data.
;                  nbkd :  number of glitches found in the background region.
;                  nsig :  number of glitches found in the signal region.
;              here_bkd :  array of indices pointing to glitch bins in the
;                       background region. (Set to -1 if there are no glitches.)
;              here_sig :  array of indices pointing to glitch bins in the
;                       signal region. (Set to -1 if there are no glitches.)
;
; EXAMPLE:
;
;   Let's create some fake data...
;
;   Define our fake sources
;
;    nsrc = 5
;    nbin = 512
;    nglitch = 10
;    here_bin = indgen(nbin)
;    ctrs = [50, 100, 110, 250, 300]
;    sigs = [10,  20,  30,  15,  10]
;    Amps = [0.8, 0.6, 0.4, 0.9, 0.2]
;    Ins = [100., 450., 210., 230., 120.]
;
;   Create gaussain transmission sources
;
;    trns = fltarr( nsrc, nbin )
;    for i=0,nsrc-1 do begin
;         trns( i,* ) = Amps(i) * exp( -( here_bin - ctrs(i) )^2./sigs(i)^2. )
;         here_ltcut  = WHERE( trns( i,* ) lt 0.01, nltcut )
;         if nltcut gt 0 then trns( i,here_ltcut ) = 0.0
;    endfor
;
;   Put in montonically increasing background with normally distributed noise
;
;    A0   = 50.
;    slope= 0.05
;    bkd  = A0 + slope * here_bin + 5. * randomn( seed, nbin )
;
;   Add the background and the signal
;
;    cts  = bkd + TRANSPOSE(Ins # trns)
;
;   Put in zero and overflow glitches
;
;    here_glitch = intarr( nglitch )
;    for i=0,nglitch/2 -1 do begin
;         j = fix( randomu( seed ) * (nbin-1) )
;         cts(j) = cts(j) + 1000.
;         here_glitch(i) = j
;    endfor
;
;    for i=nglitch/2,nglitch-1 do begin
;         j = fix( randomu( seed ) * (nbin-1) )
;         cts(j) = 0.0
;         here_glitch(i) = j
;    endfor
;
;    plot,bkd,/xstyle & wshow & pause
;   for i=0,nsrc-1 do begin
;         plot,trns(i,*),/xstyle
;         pause
;    endfor
;    plot,cts,psym=10,/xstyle & pause
;
;   Fit the data!
;
;    FITSCAN, cts, trns, 1, OCOEFF=Ocoeff, OSIGMA=Osigma, OFIT=Ofit, $
;              ORCHISQ=Orchisq, OGLITCH = Oglitch
;
;    oplot,ofit.bkd  & pause
;    oplot,ofit.sig  & pause
;    oplot,Ofit.data & pause
;    wdelete,0
;
;    print,'Real Intensities:',Ins
;    print,'Fit  Intensities:',ocoeff.intensity
;    print,'Fit  sigmas     :',osigma.intensity
;    pause
;
;    print,'Real background:',A0,' + ',slope,' * bins'
;    print,'Fit  background:',ocoeff.bkd
;    print,'Fit  sigmas    :',osigma.bkd
;    pause
;
;    print,'Real glitches:', here_glitch
;    print,'Fit  glitches: number:',oglitch.nglitch
;    print,'          bkd: number:',oglitch.nbkd
;    print,'                 bins:',oglitch.here_bkd
;    print,'          sig: number:',oglitch.nsig
;    print,'                 bins:',oglitch.here_sig
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1994.
;        10-MAY-1994:   Removes glitches from underneath non-zero transmission
;                       regions and excludes these data points from the fitting.
;        19-MAY-1994:   Adapted from CT_RATE, restricting to regression analysis;
;                       Fit signal and background simultaneously; If fitted
;                       intensities are negative, set to 0, exclude from analysis
;                       and refit the data.
;        09-JUN-1994:   Minor bug fixes for improbable cases, added BADFIT label.
;        20-JUL-1994:   Bug fix: the ZERO_ONLY/CUT keywords were switched between
;                       background/peak GLITCH calls!
;        28-AUG-1994:   Formerly named, INTENSITY. Changed optional outputs
;                       to output KEYWORD structures. Made code more intelligible
;                       and readable.  Added the NOTRNS keyword.
;        19-SEP-1994:   Added the Confidence level for the overall fit, CL.
;        19-NOV-1994:   Bug fix: problem with properly zeroing transmissions
;                       corresponding to negative fitted intensities.
;        15-DEC-1994:   Added the BADFIT label for the case of NO good bkd bins.
;        10-JAN-1995:   Bug fix: include case when nsig=0.
;-
pro FITSCAN, Cts, Trns, Ndegree, NOTRNS=Notrns, MIN_TRN=min_trn, MAX_FDER=max_fder,$
              NOWARN=nowarn, LOG=log, OCOEFF=Ocoeff, Osigma=Osigma,  $
              OFIT=Ofit, OREGRESS=Oregress, ORCHISQ=Orchisq, OGLITCH = Oglitch


         ON_ERROR,2              ; Return to caller if an error occurs

         NP = N_PARAMS()
         if (NP ne 3) then $
            message, 'Must be called with 3 parameters: Cts, Trns, Ndegree'

         if NOT keyword_set( MIN_TRN ) then MIN_TRN = 0.0

;   Let's determine the length of these arrays and the number of sources

         ndeg1= Ndegree
         Cts1 = Cts
         Trns1= Trns

         SCts = SIZE( Cts1 )
         STrns= SIZE( Trns1 )
         nbin = SCts(1)
         nsrc = STrns(1)

         IF (STrns(0) ne 2) or (STrns(2) ne nbin) then $
              message,'Size of Cts and Trns arrays are incompatible.'

         In        = fltarr(nsrc)      ;array tha will hold fitted intensities
         sigma_In  = fltarr(nsrc)      ;and their sigmas

;   NOTE: A here_XXXX array points to elements whose values are real data.
;   However, a hhere_XXXX array points to elements whose values points to
;   elements whose values are real data!

;   First, determine "background" and "signal" regions

         here_data      = indgen( nbin )

         trn_tot   = TOTAL( Trns1, 1 )
         here_bkd  = WHERE( trn_tot eq 0, nbkd )
         if nbkd eq 0 then message,'No background bins in data.'

         here_sig  = WHERE( trn_tot gt 0, nsig )

         if keyword_set( NOTRNS ) then goto, NO_TRNFIT
         if nsig eq 0 then begin
              printdev,'No signal bins in data.',$
                       NODISPLAY=nowarn, LOG=log
              goto, NO_TRNFIT
         endif

         if nbin ne (nsig + nbkd) then message,'Negative transmission bins.'

;   Find "glitches" in the data

         hhere_badbkd   = GLITCH( cts( here_bkd ), nglitch_bkd, $
                                  CUT=max_fder, NOWARN=nowarn)
         hhere_badsig   = GLITCH( cts( here_sig ), nglitch_sig, $
                                  /ZERO_ONLY, NOWARN=nowarn)
         nglitch        = nglitch_bkd + nglitch_sig

;   WARNING: We must be careful here because hhere_badbkd is an array
;   of indices pointing to the here_bkd elements, NOT the here_data elements.
;   But, the here_bkd array values points back to the here_data array!
;   Namely, the glitches for the background occur at
;   cts( here_bkd( hhere_badbkd ) ), NOT cts( hhere_badbkd ).

;   Remove any "glitches" from the analysis

         if nglitch_bkd gt 0 then begin
              here_badbkd = here_bkd( hhere_badbkd )
              here_bkd( hhere_badbkd ) = -1          ;mark glitch bins in bkd
              here_data( here_badbkd ) = -1          ;and overall data
         endif else $
              here_badbkd = -1

         if nglitch_sig gt 0 then begin
              here_badsig = here_sig( hhere_badsig )
              here_sig(  hhere_badsig ) = -1         ;mark glitch bins in sig
              here_data(  here_badsig ) = -1         ;and overall data
         endif else $
              here_badsig = -1

;   Use these marked indices to find which remaining indices point to
;   good data in background, signal and overall

         hhere_goodbkd  = WHERE( here_bkd  ne -1, nbkd  )
         hhere_goodsig  = WHERE( here_sig  ne -1, nsig  )
         hhere_gooddata = WHERE( here_data ne -1, ndata )

         if nbkd eq 0 then begin
              message,'No GOOD background bins in data.',/INF
              goto, BADFIT
         endif

         if nsig eq 0 then begin
              message,'No GOOD signal bins in data.',/INF
              goto, BADFIT
         endif

         here_bkd       = here_bkd(  hhere_goodbkd  )
         here_sig       = here_sig(  hhere_goodsig  )
         here_data      = here_data( hhere_gooddata )

         Cts1 = Cts1( here_data  )
         Trns1= Trns1( *,here_data )

         ngoodsrc       = nsrc
         here_src       = indgen(nsrc)

;   Remove sources with peak transmissions equal or below MIN_TRN.
;   These sources are set with 0 In.


REFIT:   here_trnpks    = WHEREPKS( Trns1(here_src,*), OMAXS=trnpks )
         hhere_badsrc   = WHERE( trnpks le min_trn, nbadsrc )

         if nbadsrc gt 0 then begin
              here_badsrc         = here_src( hhere_badsrc )
              In( here_badsrc )   = 0.0

              here_src( hhere_badsrc ) = -1                 ;mark bad sources
              hhere_src = WHERE( here_src ne -1, ngoodsrc)  ;find good sources

              if ngoodsrc eq 0 then begin
                   print,'All sources fit for negative intensities.'
                   goto, NO_TRNFIT
              endif

              here_src  = here_src( hhere_src )
         endif

;   Form the fitting function

         x    = fltarr( (ndeg1+1)+ngoodsrc, ndata )

;   Form polynomial arrays for the background fit

         xpoly= fltarr( ndeg1+1, ndata )
         xpoly( 0,* ) = replicate( 1., ndata )
         for i= 1,ndeg1 do $
              xpoly( i,* ) = here_data^i

         x( 0:ndeg1,* )  = xpoly

;   Insert the transmissions into the fitting function

         here_ytrns          = ndeg1+1 + indgen(ngoodsrc)
         x( here_ytrns ,* )  = Trns1( here_src,* )

;   Assuming CONSTANT sources, fit the transmissions with a polynomial
;   background to the data using multiple linear regression.

         y         = Cts1
         wgt       = 1./abs(y)
         coeffs    = REGRESS2( x, y, wgt, yfit, $
                               sigma_fit, FTest, R, RMul, Rchisq_data)

;   Namely, yfit =      coeffs(0) + coeffs(1) * t
;                 ... + coeffs(ndeg1) * t^(ndeg1)
;                     +            coeffs(ndeg1) * Trns(0,*)
;                 ... + coeffs(ndeg1+1+ngoodsrc-1) * Trns(ngoodsrc-1,*)

;   Take care of badly fitted functions

         if (N_ELEMENTS( coeffs ) eq 1) then $
              if coeffs eq 1.e+30 then begin
BADFIT:            coeffs         = REPLICATE( -1., ndeg1+1 + nsrc )
                   sigma_fit      = REPLICATE( -1., ndeg1+1 + nsrc )
                   FTest          = -1
                   R              = -1
                   Rmul           = -1
                   CL             = 0
                   datafit        = REPLICATE( -1., nbin )
                   sigfit         = datafit
                   bkdfit         = datafit
                   rchisq_sig     = 1.e+30
                   rchisq_bkd     = 1.e+30
                   rchisq_data    = 1.e+30
                   goto, OUTPUT
              endif

         dof       = ndata - ( ngoodsrc + (ndeg1+1) )
         CL        = 1. - CHI_SQR1( Rchisq_data * dof, dof )

;   If any sources fit for negative intensities, zero the transmission and
;   redo the fit:

         In( here_src )      = coeffs( here_ytrns )
         sigma_In( here_src )= sigma_fit( here_ytrns )

         here_neg  = WHERE( In lt 0, nneg )
         if nneg gt 0 then begin
              Trns1( here_neg,* ) = REPLICATE( 0., nneg, ndata )

              printdev,'WARNING: Source(s):'+arr2str( here_neg )+$
                       ' fit for NEGATIVE intensities.', $
                       NODISPLAY=nowarn, LOG=log
              printdev,'Zeroing their intensities '+$
                       '... removing them from analysis '+$
                       '... redoing fit.',$
                       NODISPLAY=nowarn, LOG=log

              goto, REFIT
         endif


;   Determine fit for all data points, including the glitch bins
;   for the background...

         bkdfit = POLY( findgen(nbin), coeffs(0:ndeg1) )

;   for the sources....

         sigfit    = TRANSPOSE( In # Trns )

;   and for the data....

         datafit   = bkdfit + sigfit

;   Determine the reduced chi-squared for the background and signal regions

         y              = Cts
         yfit           = datafit
         wgt            = 1./abs(y)

         dof_bkd        = nbkd - (ndeg1+1)
         chisq_bkd      = ( y( here_bkd ) - yfit( here_bkd ) )^2.
         chisq_bkd      = TOTAL( chisq_bkd * wgt( here_bkd ) )
         rchisq_bkd     = chisq_bkd/dof_bkd

         dof_sig        = nsig - nsrc
         chisq_sig      = ( y( here_sig ) - yfit( here_sig ) )^2.
         chisq_sig      = TOTAL( chisq_sig * wgt( here_sig ) )
         rchisq_sig     = chisq_sig/dof_sig

;   return fitted information

         goto, OUTPUT

;========================================================================
;
;   Only fit the background regions
;
;========================================================================

NO_TRNFIT:

;   Find "glitches" in the data

         hhere_badbkd   = GLITCH( cts( here_bkd ), nglitch_bkd, $
                                  CUT=max_fder, NOWARN=nowarn)
         nglitch_sig    = 0
         nglitch        = nglitch_bkd

;   WARNING: We must be careful here because hhere_badbkd is an array
;   of indices pointing to the here_bkd elements, NOT the here_data elements.
;   But, the here_bkd array values points back to the here_data array!
;   Namely, the glitches for the background occur at
;   cts( here_bkd( hhere_badbkd ) ), NOT cts( hhere_badbkd ).

;   Remove any "glitches" from the analysis

         if nglitch_bkd gt 0 then begin
              here_badbkd = here_bkd( hhere_badbkd )
              here_bkd( hhere_badbkd ) = -1          ;mark glitch bins in bkd
              here_data( here_badbkd ) = -1          ;and overall data
         endif else $
              here_badbkd = -1

         here_badsig    = -1

;   Use these marked indices to find which remaining indices point to
;   good data in background, signal and overall

         hhere_goodbkd  = WHERE( here_bkd  ne -1, nbkd  )
         hhere_gooddata = WHERE( here_data ne -1, ndata )

         here_bkd       = here_bkd(  hhere_goodbkd  )
         here_data      = here_data( hhere_gooddata )

         Cts1 = Cts1( here_data  )
         Trns1= Trns1( *,here_data )

         ngoodsrc       = nsrc
         here_src       = indgen(nsrc)

;   Form the fitting function

         x    = fltarr( ndeg1+1, nbkd )

;   Form polynomial arrays for the background fit

         xpoly= fltarr( ndeg1+1, nbkd )
         xpoly( 0,* ) = replicate( 1., nbkd )
         for i= 1,ndeg1 do $
              xpoly( i,* ) = here_bkd^i

         x( 0:ndeg1,* )  = xpoly


;   Ignoring the transmissions, fit the background ONLY using
;   multiple linear regression.

         y         = Cts1( here_bkd )
         wgt       = 1./abs(y)

         coeffs    = REGRESS2( x, y, wgt, yfit, $
                               sigma_fit, FTest, R, RMul, Rchisq_bkd)

;   Namely, yfit =      coeffs(0) + coeffs(1)*t
;                 ... + coeffs(ndeg1) * t^(ndeg1)

;   Take care of badly fitted functions

         if (N_ELEMENTS( coeffs ) eq 1) then $
              if coeffs eq 1.e+30 then begin
                   coeffs         = REPLICATE( -1., ndeg1+1 )
                   sigma_fit      = REPLICATE( -1., ndeg1+1 )
                   FTest          = -1
                   R              = -1
                   Rmul           = -1
                   CL             = 0
                   datafit        = REPLICATE( -1., nbin )
                   sigfit         = datafit
                   bkdfit         = datafit
                   rchisq_sig     = 1.e+30
                   rchisq_bkd     = 1.e+30
                   rchisq_data    = 1.e+30
                   goto, OUTPUT
              endif

;   Determine fit for all data points, including the glitch bins
;   for the background...

         bkdfit = POLY( findgen(nbin), coeffs(0:ndeg1) )

;   for the sources....

         sigfit    = replicate( 0., nbin )

;   and for the data....

         datafit   = bkdfit + sigfit

;   Reduced chi-squared for the signal and data are N/A

         rchisq_sig     = -1
         rchisq_data    = -1
         CL             =  0


;========================================================================
;
;   Package all this information into KEYWORD structures
;
;========================================================================

OUTPUT:  Ocoeff    = { Intensity  : In,               $
                       bkd        : coeffs( 0:ndeg1 ) $
                     }

         Osigma    = { Intensity  : sigma_In,              $
                       bkd        : sigma_fit( 0:ndeg1 )   $
                     }

         Ofit      = { data       : datafit, $
                       bkd        : bkdfit,  $
                       sig        : sigfit   $
                     }

         Oregress  = { Ftest      : Ftest,  $
                       R          : R,      $
                       Rmul       : Rmul,   $
                       CL         : CL      $
                     }

         Orchisq   = { data       : rchisq_data, $
                       bkd        : rchisq_bkd,  $
                       sig        : rchisq_sig   $
                     }

         Oglitch = { nglitch : nglitch,     $
                     nbkd    : nglitch_bkd, $
                     nsig    : nglitch_sig, $
                     here_bkd: here_badbkd, $
                     here_sig: here_badsig  $
                   }

end
