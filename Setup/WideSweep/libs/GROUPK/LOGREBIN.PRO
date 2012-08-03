;+
; NAME:
;        LOGREBIN
;
; PURPOSE:
;        Rebins a XYdY distribution into equal logarithmic (base 10)
;        intervals in X.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        LOGREBIN, X, Y, Dy, Ny, Nbins, DlogX
;
; INPUTS:
;        X:        Array of abcissae.
;
;        Y:        Array of Y values.
;
;        Dy:       Array of 1 sigma error bars along Y.
;
;        Ny:       Number of points used to determine each Dy, LONG.
;
;        Nbins:    Number of bins of the rebinned XYdY distribution.
;
; OUTPUTS:
;        X,Y,Dy:   The X-Y-dY distribution rebinned into Nbins equal
;                  logarithmic intervals in X, Array(Nbins)
;
;        Ny:       Number of points used to determine each rebinned Dy,
;                  LONARR(Nbins).
;
;        DlogX:    The width or bin size of each equal logarithmic
;                  interval in X.
;
; RESTRICTIONS:
;        Each input data point, X, Y, Dy is assumed to be derived from
;        averaging Ny distributions of XY.
;
; EXAMPLE:
;        ; Create some simple data from a SIN wave
;        X = FINDGEN(100)+50
;        Y = ABS(SIN(X/10))
;        dY= SQRT(Y/10)
;        ny= 5
;        nbins = 30
;
;        ; Plot original and rebinned XYdY distributions as log-scalar plots
;        ploterr,  X, Y, Dy, PSYM=3, /XTYPE, XRANGE=[MIN(X,MAX=mx),mx]
;        LOGREBIN, X, Y, Dy, Ny, Nbins, DlogX
;        oploterr, X, Y, Dy
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;        19-AUG-1996    Corrected numerical round off errors and the case
;                       when Ny=1, leading to negative or NaNQ variances.
;                       Location of the last bin edge defined to be
;                       consistent with [min,max) convention.
;-
pro LOGREBIN, X, Y, Dy, Ny, Nbins, DlogX

;   Check integrity of input parameters

         NP   = N_PARAMS()
         if (NP lt 5) then message, $
              'Must be called with 5-6 parameters: X, Y, Dy, Ny, Nbins [,DlogX]'

         if (N_ELEMENTS(Ny) gt 1) then message, 'Ny parameter must be a scalar.'

         X0   = MIN(X,MAX=X1)
         if (X0 lt 0) then message, 'X parameter must be > 0.'

;   Define logarithmic interval, dlogX such that the last logarithmic bin
;   boundaries are [ logXmax+eps - dlogX, logXmax+eps ).

         logX = ALOG10(TEMPORARY(X))
         logX1= ALOG10(DOUBLE(X1))
         eps  = 10.^(FLOOR(ALOG10(logX1))-7)
         dlogX= ((logX1+eps) - ALOG10(DOUBLE(X0)))/Nbins

;   Rebin distribution with considerations for divide by 0s or round off
;   errors leading to negative variances, (>0)

         Y2   = Dy^2*(Ny-1) + Y^2
         hkeys= { BINSIZE: dlogX, MAX: logX1 }
         Ysum = HIST1D( logX, TEMPORARY(Y) , _EXTRA=hkeys, $
                        OBIN=ologX, DENSITY=nX )
         Y2sum= HIST1D( logX, TEMPORARY(Y2), _EXTRA=hkeys )

         nX_  = (nX > 1)               ; > 1 to avoid divide by 0s
         Yavg = Ysum /nX_
         Y2avg= Y2sum/nX_

         Ny   = nX*LONG(Ny)
         Ny_  = Ny > 2
         var  = (Ny/((Ny_-1.)))*( Y2avg - Yavg^2 ) > 0
         Dy   = SQRT( var/Ny_ )

         X    = 10L^ologX
         Y    = Yavg
end
