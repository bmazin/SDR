;+
; NAME:
;        PERIOD
;
; PURPOSE:
;        Given data points with abscissas x (which need not be equally spaced)
;        and ordinates y, and given a desired oversampling factor ofac (a
;        typical value being 4 or larger), this routine fills array px
;        with an increasing sequence of frequencies (not angular frequencies)
;        up to hifac times the "average" Nyquist frequency, and fills array
;        py with the values of the Lomb normalized periodogram at those
;        frequencies.  The arrays x and y are not altered. The routine also
;        returns jmax such that py(jmax) is the maximum element in py, and
;        prob, an estimate of the significance of that maximum against the
;        hypothesis of random noise.  A small value of prob indicates that
;        a significant periodic signal is present.
;
;        (Adapted from routine of the same routine in Numerical Recipes in C,
;        Second edition).
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        PERIOD, X, Y, Ofac, Hifac, Px, Py, Nout, Jmax, Prob
;
; INPUTS:
;        X:        The abscissas of the data points.
;
;        Y:        The ordinates of the data points.
;
;        Ofac:     Oversampling factor.
;
;        Hifac:    Maximum frequency of Px = Hifac * "average" Nyquist
;                  frequency,.
;
; OUTPUTS:
;        Px:       The frequencies of the Lomb normalized periodogram.
;
;        Py:       The spectral powers of the Lomb normalized periodogram.
;
;        Nout:     The number of elements of the Px or Py array.
;
;        Jmax:     Index to the maximum element in Py.
;
;        Prob:     Significance of Py(Jmax) against the hypothesis of
;                  random noise.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;        07-AUG-1996    Eliminated redundant variables.
;-
pro PERIOD, x, y, ofac, hifac, px, py, nout, jmax, prob

;   Check dimensions of input arrays
         n    = N_ELEMENTS( x )
         sz   = SIZE( y )
         if n ne sz(1) then message, 'Incompatible arrays.'


         nout=0.5*ofac*hifac*n

         var=(STDEV(y,ave))^2.              ;Compute the mean, variance
                                            ;and range of the data.
         xmin=MIN( x, MAX=xmax )
         xdif=xmax-xmin
         xave=0.5*(xmax+xmin)

         pymax=0.0
         pnow =1.0/(xdif*ofac)              ;Starting frequency

         arg  = 2.0*!dpi*(x-xave)*pnow      ;Initialize values for the
         wpr  = -2.0*SIN(0.5*arg)^2         ;trigonometric recurrences at each
         wpi  = SIN(arg)                    ;data point.  The recurrences are
         wr   = COS(arg)                    ;done in double precision
         wi   = wpi

         px   = pnow + FINDGEN(nout)/(ofac*xdif)
         py   = FLTARR(nout)
         yy   = y-ave
         for i=0L,nout-1 do begin           ;Main loop over the frequencies to
                                            ;be evaluated
              sumsh= TOTAL(wi*wr)           ;First, loop over the data to get
              sumc = TOTAL((wr-wi)*(wr+wi)) ;tau and related quantities.

              wtau =0.5*ATAN(2.0*sumsh,sumc)
              swtau=SIN(wtau)
              cwtau=COS(wtau)

              ss   =wi*cwtau-wr*swtau       ;Get the periodogram value.
              cc   =wr*cwtau+wi*swtau
              sums =TOTAL(ss^2)
              sumc =TOTAL(cc^2)
              sumsy=TOTAL(yy*ss)
              sumcy=TOTAL(yy*cc)
              wtemp=wr
              wr   =(wtemp*wpr-wi*wpi)+wr   ;Update the trigonometric recurrences
              wi   =wi*wpr+wtemp*wpi+wi

              py(i)=0.5*(sumcy^2/sumc+sumsy^2/sums)/var
         endfor

         pymax=MAX(py,jmax)
         expy =EXP(-pymax)
         effm =2.0*nout/ofac
         prob =effm*expy
         if prob gt 0.01 then prob=1.0-(1.0-expy)^effm
end
