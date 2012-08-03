;+
; NAME:
;        FASPER
;
; PURPOSE:
;        Given abscissas x (which need not be equally spaced) and ordinates
;        y, and given a desired oversampling factor ofac (a typical value
;        being 4 or larger). this routine creates an array wk1 with a
;        sequence of nout increasing frequencies (not angular frequencies)
;        up to hifac times the "average" Nyquist frequency, and creates
;        an array wk2 with the values of the Lomb normalized periodogram at
;        those frequencies.  The arrays x and y are not altered.  This
;        routine also returns jmax such that wk2(jmax) is the maximum
;        element in wk2, and prob, an estimate of the significance of that
;        maximum against the hypothesis of random noise. A small value of prob
;        indicates that a significant periodic signal is present.
;
; CATEGORY:
;        Numerical Recipes routines.
;
; CALLING SEQUENCE:
;
;        FASPER, X, Y, Ofac, Hifac, Wk1, Wk2 [, Nout, Jmax, Prob]
;
; INPUTS:
;        X:       Abscissas array, (e.g. an array of times).
;
;        Y:       Ordinates array, (e.g. an array of corresponding counts).
;
;        Ofac:     Oversampling factor.
;
;        Hifac:    Hifac * "average" Nyquist frequency = highest frequency
;                  for which values of the Lomb normalized periodogram will
;                  be calculated.
;
; OUTPUTS:
;        Wk1:      An array of Lomb periodogram frequencies.
;
;        Wk2:      An array of corresponding values of the Lomb periodogram.
;
; OPTIONAL OUTPUTS:
;        Nout:     The dimension of Wk1 and Wk2, i.e. the number of frequencies
;                  calculated.
;
;        Jmax:     The array index corresponding to the MAX( Wk2 ).
;
;        Prob:     The False Alarm Probability (FAP) of the largest value of
;                  of Lomb normalized periodogram.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994. (Adapted from a Numerical
;                       Recipes routine with the same name).
;        15-AUG-1996    Andrew Lee, Modified spread and fasper to use arrays
;                       starting at 0 instead of 1, and fixed some bugs where
;                       int was used instead of long.
;-


pro SPREAD, y, yy, n, x, m
;
;   Given an array yy(0:n-1), extirpolate (spread) a value y into
;   m actual array elements that best approximate the "fictional"
;   (i.e., possible noninteger) array element number x.  The weights
;   used are coefficients of the Lagrange interpolating polynomial

         nfac=[0,1,1,2,6,24,120,720,5040,40320,362880]

         if (m gt 10) then message,'factorial table too small in spread'
         ix=long(x)
         if x eq float(ix) then yy(ix)=yy(ix)+y $
         else begin

              ilo= ( long(x-0.5*m+1.0) > 0 ) < (n-m)
              ihi=ilo+m-1
              nden=nfac(m)
              fac=x-ilo
              for j=ilo+1,ihi do fac = fac*(x-j)
              yy(ihi) = yy(ihi) + y*fac/(nden*(x-ihi))
              for j=ihi-1,ilo,-1 do begin
                   nden=(nden/(j+1-ilo))*(j-ihi)
                   yy(j) = yy(j) + y*fac/(nden*(x-j))
              endfor
         endelse
end
; (C) Copr. 1986-92 Numerical Recipes Software


pro FASPER, x, y, ofac, hifac, wk1, wk2, nout, jmax, prob

         MACC = 4  ;Number of interpolation points per 1/4 cycle
                   ;of highest frequency

;   Check dimensions of input arrays
         n    = n_elements( x )
         sz   = size( y )
         if n ne sz(1) then message, 'Incompatible arrays.'

         nout=0.5*ofac*hifac*n
         nfreqt=long(ofac*hifac*n*MACC)     ;Size the FFT as next power
         nfreq=64L                          ;of 2 above nfreqt.

         while (nfreq lt nfreqt) do nfreq = ISHFT( nfreq,1 )
         ndim=long(ISHFT( nfreq,1 ))

         var=(stdev(y,ave))^2.              ;Compute the mean, variance
                                            ;and range of the data.
         xmin=MIN( x, MAX=xmax )
         xdif=xmax-xmin

         wk1 =complexarr(ndim)            ;Extirpolate the data into
         wk2 =complexarr(ndim)            ;the workspaces.
         fac=ndim/(xdif*ofac)
         fndim=ndim
         ck  =(x-xmin)*fac MOD fndim
         ckk =2.0*ck MOD fndim

         for j=0L,n - 1 do begin
              SPREAD, y(j)-ave,wk1,ndim,ck(j),MACC
              SPREAD, 1.0,wk2,ndim,ckk(j),MACC
         endfor

         wk1  = FFT( wk1,1, /OVERWRITE )    ;Take the Fast Fourier Transforms.
         wk2  = FFT( wk2,1, /OVERWRITE )

         wk1  = wk1(1:nout)
         wk2  = wk2(1:nout)
         rwk1 = double( wk1 ) & iwk1 = imaginary( wk1 )
         rwk2 = double( wk2 ) & iwk2 = imaginary( wk2 )
         df=1.0/(xdif*ofac)

         hypo2 = 2.0 * abs( wk2 )                  ;Compute the Lomb value for each
         hc2wt= rwk2/hypo2               ;frequency.
         hs2wt= iwk2/hypo2

         cwt  = sqrt(0.5+hc2wt)
         swt  = SIGN(sqrt(0.5-hc2wt),hs2wt)
         den  = 0.5*n+hc2wt*rwk2+hs2wt*iwk2
         cterm= (cwt*rwk1+swt*iwk1)^2./den
         sterm= (cwt*iwk1-swt*rwk1)^2./(n-den)

         wk1  = df*(findgen(nout)+1.)
         wk2  = (cterm+sterm)/(2.0*var)
         pmax = MAX( wk2, jmax )

         expy =exp(-pmax)                   ;Estimate significance of largest
         effm =2.0*(nout)/ofac              ;peak value.
         prob =effm*expy
         if (prob gt 0.01) then prob=1.0-(1.0-expy)^effm

end
; (C) Copr. 1986-92 Numerical Recipes Software
