;+
; NAME:
;        EXPDEV
;
; PURPOSE:
;        Returns an exponentially distributed, positive, random deviate
;        using RAN2( seed ) as the source of uniform deviates. The
;        default unit mean and zero offset of the deviates may be modified
;        by setting the appropriate keywords.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = EXPDEV( Seed [,N] )
;
; INPUTS:
;        Seed:     Seed for the random number generator. (It can be undefined)
;
; OPTIONAL INPUTS:
;        N:        Number of deviates to return, (1=Default).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;        MEAN:     Mean of the deviates, (1=Default).
;
;        OFFSET:   Offset of the deviates, (0=Default).  The resulting
;                  exponential distribution and its mean is offset by
;                  this amount.
;
;        SUM:      Open upper limit to the sum of all the deviates,
;                  (i.e. TOTAL(EXPDEV(Seed,..)) < SUM), (0=Default).
;                  Deviates will be generated until their sum is equal to
;                  or greater than this cutoff. If this keyword is specified,
;                  then the number of deviates generated is returned in the
;                  optional argument, N.
;
;        CUTOFF:   Minimum possible value of the deviates, (1e-37=Default).
;                  If set, this value MUST be > 0.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1995.
;        02-NOV-1995    Formerly, EXPDT, changed keywords TAU -> OFFSET,
;                       AVG -> MEAN, added CUTOFF keyword.
;        24-NOV-1995    Return a scalar when called with 1 argument,
;                       (i.e. EXPDEV(Seed)).
;        03-JAN-1996    Bugfixes: TOTAL(dts)->TOTAL(dts,/DOUBLE),
;                       N = round(N) -> round(N) > 1
;        28-MAR-1996    This SPECIAL version for the AIX utilized RAN2
;                       instead of RANDOMU.
;-
function EXPDEV, Seed, N, MEAN=Mean, OFFSET=Offset, CUTOFF=Cutoff, SUM=Sum


         NP   = N_PARAMS()
         if (NP lt 2) then N=1

         if (N_ELEMENTS(Mean) eq 0) then Mean = 1 $
         else if (Mean le 0) then message,'MEAN must be > 0.'
         if (N_ELEMENTS(Offset) eq 0) then Offset = 0
         if (N_ELEMENTS(Cutoff) eq 0) then Cutoff = 1.e-37 $
         else if (Cutoff le 0) then message,'CUTOFF must be > 0.'
         if (N_ELEMENTS(Sum) eq 0) then Sum = 0 $
         else if (Sum le Offset) then begin
                   N    = 0
                   dts  = -1
                   return, dts
              endif

         if (Sum eq 0) then begin
              pdf  = 1./Mean * RAN2(Seed,N) > Cutoff
              dts  = Offset -Mean*alog(pdf*Mean)
              if (NP lt 2) then dts=dts(0)
         endif else begin
              rho  = 1./Mean
              N    = rho*Sum/(1.+rho*Offset)     ; Estimate of how many
              N    = round(N) > 1                ; deviates to generate
              nadd = 0L
              pdf  = rho * RAN2(Seed,N) > Cutoff
              dts  = Offset -Mean*alog(pdf*Mean)
              tsum = TOTAL(dts,/DOUBLE)

              ; If sum of current deviates is LESS than SUM then
              ; generate additional deviates one at a time until the
              ; sum of all the deviates is > SUM.

              if (tsum lt Sum) then begin
                   repeat begin
                        pdf    = rho * RAN2(Seed) > Cutoff
                        new_dt = Offset -Mean*alog(pdf*Mean)
                        dts    = [dts,new_dt]
                        tsum   = tsum + new_dt
                        nadd   = nadd + 1
                   endrep until (tsum ge Sum)
                   dts  = dts(0:N+nadd-2)
                   if (N eq 0) and (nadd gt 2) then begin
                        N    = nadd-2
                        dts  = dts(1:N)
                   endif else N = N + nadd-1

              ; If the sum of current deviates is GREATER than or EQUAL to
              ; SUM then eliminate deviates one at a time until the
              ; sum of the remaining deviates is < SUM.

              endif else begin
                   k    = N
                   repeat begin
                        k    = k-1
                        tsum = tsum - dts(k)
                   endrep until (tsum lt Sum)
                   N    = k
                   if (N gt 0) then dts  = dts(0:N-1) $
                   else dts = -1
              endelse
              if (N le 1)  then dts=dts(0)
         endelse

         return,dts
end
