;+
; NAME:
;        POIDEAD
;
; PURPOSE:
;        This function calculates the probability of detecting N counts in a
;        given measuring time bin for a non-extended dead-time-distorted
;        poisson process.  The algorithm uses formulae from Muller,
;        "Some Formulae for a Dead-Time-Distorted Poisson Process", NIM 117
;        (1974) 401.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = POIDEAD( Ncount, Mean [, Tinterval, Deadtime ])
;
; INPUTS:
;        Ncount:   A scalar or array of number of counts DETECTED in the given
;                  measuring time bin.
;
;        Mean:     A scalar or array of TRUE mean number of counts in the given
;                  measuring time bin due to the ORIGINAL Poissonian process.
;
; OPTIONAL INPUTS:
;
;        Tinterval:The length of the measuring time bin, (Default=1).
;
;        Deadtime: The length of the non-extended dead time in the SAME units
;                  as Tinterval, (Default=0).
;
; OUTPUTS:
;        An scalar or array is returned giving the probability of detecting
;        the counts specified in each element of Ncount and/or Mean.
;
; RESTRICTIONS:
;        If Ncount and Mean are both arrays, they must have the same number
;        of elements.
;        Negative values in the input array will be returned as zeros.
;
; EXAMPLE:
;        To determine the probability of detecting 0..100 counts in a 10 msec
;        time bin if the true mean is 50 and the dead time is 20 usec, do the
;        following:
;
;        N    = lindgen(101)
;        mu   = 50.0
;        bin  = 10.0
;        tau  = 20e-3
;        Prob = POIDEAD( N, mu, bin, tau )
;        plot,N,Prob,psym=10
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, March 1996.
;        15-JUL-1996    Suppress underflow error messages.
;                       Bugfix: corrected roundoff error in Kappa
;        17-JUL-1996    Accept an array argument for the Mean parameter.
;-
function POI_, Ncount, Mu

         if (Mu eq 0) then return, FLTARR(N_ELEMENTS(Ncount))

         lnP  = Ncount*ALOG(double(Mu))-Mu-LNGAMMA(Ncount+1)
         return, EXP(lnP)
end

function POIDEAD, Ncount, Mean, Tinterval, Deadtime, NSIGMA_CUT=Nsigma_cut

         ON_ERROR, 2          ; on error, return control to caller

         NP   = N_PARAMS()
         if (NP lt 2) then message,'Must be called with 3-4 parameters: '+$
                                   'Ncount, Mean [, Tinterval, Deadtime]'

         if N_ELEMENTS(Tinterval)eq 0 then Tinterval= 1.0
         if N_ELEMENTS(Deadtime) eq 0 then Deadtime = 0.0

         Tbin      = Tinterval
         Tau       = Deadtime
;        Kappa     = long(Tbin/Tau)         ; Bugfix, 07/15/96
         Kappa     = CEIL(Tbin/Tau-1)       ; for cases when Tbin/Tau = integer

         Nc        = N_ELEMENTS(Ncount)
         Nm        = N_ELEMENTS(Mean)
         npts      = Nc > Nm
         ct        = Ncount
         mu        = Mean > 0.0
         if (npts gt 1) and (Nc ne Nm) then begin
              case 1 of
              (Nc eq 1) : ct = REPLICATE( Ncount(0), npts )
              (Nm eq 1) : mu = REPLICATE( Mean(0)>0.0,   npts )
              else      : message, 'Invalid array dimensions: Ncount, Mean.'
              endcase
         endif

;   If no dead time, then return normal Poisson distribution
;
         if (Tau eq 0) then begin
              if (Nm eq 1) then return, POI_(ct,mu(0))
              Prob = FLTARR(npts,/NOZERO)
              for i=0,npts-1 do Prob(i) = POI_(ct(i),mu(i))
              return, Prob
         endif

         junk = CHECK_MATH(0,1)             ; Suppress math error messages

         Rho       = mu/Tbin
         Prob      = FLTARR(npts)
         for i=0,npts-1 do begin
              k    = ct(i)
              s    = 0.0
              x    = Rho(i)*Tau

;   Delta_k(t) term
;
              if (k gt (Kappa+1)) then goto, FILL $
              else if (k eq Kappa) then s = (Kappa+1)*(1+x)-mu(i) $
                   else if (k eq (Kappa+1)) then s = mu(i) - Kappa*(1+x)

;   NOTE: We need double-precision in TOTAL and POI_() to avoid
;         numerical round-off errors.
;
;   U(T_k-1) term
;
              if (k ge 2) and (k le (Kappa+1)) then begin
                   j = LINDGEN(k-1)
                   mu_eff = Rho(i)*(Tbin-(k-1)*tau)
                   s = s + TOTAL( (k-1-j)*POI_(j,mu_eff),/DOUBLE)
              endif

;   U(T_k) term
;
              if (k ge 1) and (k le Kappa) then begin
                   j = LINDGEN(k)
                   mu_eff = Rho(i)*(Tbin-k*tau)
                   s = s - 2*TOTAL( (k-j)*POI_(j,mu_eff),/DOUBLE)
              endif

;   U(T_k+1) term
;
              if (k ge 0) and (k le (Kappa-1)) then begin
                   j = LINDGEN(k+1)
                   mu_eff = Rho(i)*(Tbin-(k+1)*tau)
                   s = s + TOTAL( (k+1-j)*POI_(j,mu_eff),/DOUBLE)
              endif

;   Scale by lambda = 1/(1+x) factor
;
              s    = s/(1+x) > 0.0

FILL:         Prob(i) = s
         endfor
         if (npts eq 1) then Prob = Prob(0)

         junk = CHECK_MATH(0,0)             ; Turn err msgs back on

         return, Prob
end
