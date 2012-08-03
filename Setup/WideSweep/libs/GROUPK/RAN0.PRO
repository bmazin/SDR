;+
; NAME:
;        RAN0
;
; PURPOSE:
;        The RAN0 function returns one or more uniformly-
;        distributed, floating-point, pseudo-random numbers in the
;        range 0 LE Y < 1.0.
;
;        The random number generator is taken from: "Numerical Recipes in C"
;        2nd Edition.  It is the "minimal" random number generator of
;        Park and Miller (with the MASK removed) and is IDENTICAL to the
;        IDL RANDOMU function.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = RAN0(Seed [, D1, ..., Dn])
;
; INPUTS:
;         Seed:    A named variable containing the seed value for
;                  random number generation. Seed is updated by RAN0
;                  once for each random number generated. The initial
;                  value of Seed should be set to different values in
;                  order to obtain different random sequences. If Seed
;                  is undefined, it is derived from the system clock.
;
; OPTIONAL INPUTS:
;        Di:       The dimensions of the result. The dimension
;                  parameters can be any scalar expression. Up to eight
;                  dimensions can be specified. If no dimensions are
;                  specified, RAN0 returns a scalar result
;
; OUTPUTS:
;        This function returns uniform random deviates between 0.0 and 1.0
;        (exclusive of the endpoint values) with array dimensions given
;        by the input parameters, D1, ..., Dn.
;
; RESTRICTIONS:
;        Currently only available on the AIX platform.
;
; PROCEDURE:
;        This function uses CALL_EXTERNAL to call an external sharable
;        C object (ran0_.lib).  This was done because coding the routine
;        entirely in IDL would resulted in an unacceptably slow algorithm
;        due to unavoidable for loops.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, March 1996.
;-
function RAN0, Seed, D1, D2, D3, D4, D5, D6, D7, D8

         NP   = N_PARAMS()
         case NP of
              1    : r=0.0
              2    : r=FLTARR(D1)
              3    : r=FLTARR(D1,D2)
              4    : r=FLTARR(D1,D2,D3)
              5    : r=FLTARR(D1,D2,D3,D4)
              6    : r=FLTARR(D1,D2,D3,D4,D5)
              7    : r=FLTARR(D1,D2,D3,D4,D5,D6)
              8    : r=FLTARR(D1,D2,D3,D4,D5,D6,D7)
              9    : r=FLTARR(D1,D2,D3,D4,D5,D6,D7,D8)
              else : message,'Must have 1-9 parameters, '+$
                             'Seed [, D1,... D8]'
         endcase
         Ds = long(N_ELEMENTS(r))

         if (N_ELEMENTS(Seed) eq 0) then Seed=long(SYSTIME(1))
         Seed= long(Seed)

         junk = CALL_EXTERNAL(GRPKPATH()+'ran0_.lib', 'ran0_', $
                              Seed,Ds,r, /F_VALUE)
         return,r
end
