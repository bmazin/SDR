;+
; NAME:
;        DTPOIDEV
; PURPOSE:
;        Return an integer random deviate drawn from a dead-time-distorted
;        Poisson distribution with a specified mean.  Adapted from POIDEV
;        procedure in "Numerical Recipes" by Press et al. (1986), Section 7.3
;        and IDL Astronomy User's library routine of the same name by
;        Wayne Landsman.
;
; CALLING SEQUENCE:
;        result = DTPOIDEV( Xm, Npts, Tinterval, Deadtime, [ SEED = ] )
;
; INPUTS:
;        Xm:       Mean of the ORIGINAL (undistorted) Poisson distribution.
;
;        Npts:     Number of deviates to generate.
;
;        Tinterval:The length of the measuring time bin.
;
;        Deadtime: The length of the NON-EXTENDED dead time in the SAME units
;                  as Tinterval.
;
; OUTPUT:
;        An array of deviates, [LONARR(Npts)].
;
; OPTIONAL KEYWORD INPUT-OUTPUT:
;        SEED -  Scalar to be used as the seed for the random distribution.
;             For best results, SEED should be a large (>100) integer.
;             If SEED is undefined, then its value is taken from the system
;             clock (see RANDOMU).    The value of SEED is always updated
;             upon output.   This keyword can be used to have POIDEV give
;             identical results on consecutive runs.
;
; EXAMPLE:
;        (1) Add dead-time-distorted Poisson noise to an integral image array, im
;             IDL> imnoise = POIDEV( im, 100, tbin, tau)
;
;        (2) Verify the expected mean  and sigma for an input value of 81
;             IDL> p = POIDEV( 81, 10000,1,1e-3) ;Test for 10,000 points
;             IDL> print,avg(p),sigma(p)
;        Average and sigma of the 10000 points should be close to
;        81/(1+81*1e-3)=75 and (1+81*1e-3)^(-3/2)*9=8.
;
; RESTRICTIONS:
;        Negative values in the input array will be returned as zeros.
;        Note: there are very subtle correlations between sequential time bins
;        in the presence of dead time.  The time interval between the beginning
;        of a bin and the first count is correlated to the interval between
;        the last count of the previous bin.  This correlation occurs when
;        the time interval between the last count of the previous bin and the
;        end of the time bin is less than the dead time.
;
; PROCEDURE:
;        For small values (observed counts < 20) independent exponential
;        deviates offset by a dead time are generated until their sum exceeds
;        the specfied mean, the number of events required is returned as the
;        Poisson deviate.   For large (observed counts > 20) values, uniform
;        random variates are compared with a Lorentzian distribution function.
;
; REVISION HISTORY:
;        Adapted from Landsman, POIDEV:     Han Wen, July 1996.
;        26-JUL-1996    Bugfix: Lorentzian distribution function falls below
;                       d-t-d Poisson distribution at low observed counts and
;                       low means. Reapplied technique of independent exponential
;                       deviates (with a dead time offset) for cases when the
;                       observed counts falls below 20.
;-
function DTPOIDEV, Xm, Npts, Tinterval, Deadtime, SEED = seed

         On_error,2

         Npar = N_PARAMS()
         if (Npar ne 4) then message, $
            'Must be called with 4 parameters: Mean, Npts, Tinterval, Deadtime'

         if (Xm le 0) then return, LONARR(Npts)
         if (Deadtime eq 0) then return, POIDEV( LONARR(Npts)+Xm,SEED=Seed )

         tbin      = Tinterval
         tau       = Deadtime

;   Determine the variance of the dead-time-distorted Poisson distribution
;
         x         = xm*tau/tbin
         lambda    = 1/(1+x)
         xobs      = xm*lambda
         sig2      = lambda^3*( xm+0.16667*lambda*x^2*( 6+4*x+x^2 ) )

;   Apply exponential deviates technique for small observed counts (<20)

         if (xobs le 20) then begin

              em        = LONARR(Npts)
              tlen      = Npts * float(tbin)
              tavg      = tbin/float(xm)
              dts       = EXPDEV(Seed, Ndts, MEAN=tavg, OFFSET=tau, SUM=tlen)
              dts(0)    = RANDOMU(Seed)*dts(0)   ; first count can have any
              tcum      = 0d0                    ; interval from left bin edge
              j         = 0L
              for i=0L,Ndts-1 do begin
                   tcum = tcum + dts(i)
                   if (tcum ge tbin) then begin  ; move j to the bin where
                        n0   = FIX(tcum/tbin)    ; the next count lies
                        tcum = tcum MOD tbin
                        j    = j+n0
                   endif
                   em(j)     = em(j)+1           ; add count to current bin
              endfor

              return,em
         endif

;   Calculate all probabilities up to 10 sigma + observed mean
;
         em_max    = CEIL(xm*lambda + 10*SQRT(sig2))
         ems       = LINDGEN(em_max+1)
         Prob      = [POIDEAD(TEMPORARY(ems),xm,tbin,tau),0]

;   Apply Lorentzian distribution comparison technique for higher observed counts (>20)
;
         sq        = SQRT( 2.*sig2 )        ;Sq and g are precomputed
         g         = Prob(long(xobs))

         Ngood     =( Ngood1 = Npts )
         good      = LINDGEN( Ngood)
         good1     = good
         y         = FLTARR(Ngood, /NOZERO ) & em = y

REJECT1: y(good)   = TAN( !PI * RANDOMU( seed, Ngood ) )
         em(good)  = sq*y(good) + xobs
         good2     = WHERE( em(good) LT 0. , Ngood )
         if (Ngood GT 0) then begin
              good = good(good2)
              goto, REJECT1
         endif

         fixem= long( em(good1) )
         test = CHECK_MATH( 0, 1)         ;Don't want overflow messages
         t    = 0.9*(1. + y(good1)^2)*Prob(fixem<(em_max+1))/g

         good2 = WHERE( RANDOMU (seed, Ngood1) GT T , Ngood)
         if ( Ngood GT 0 ) then begin
                  good1 = good1(good2)
                  good = good1
                  goto, REJECT1
         endif
         output    = long(em)

 return, output
 end
