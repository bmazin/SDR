;+
; NAME:
;        SIGN
;
; PURPOSE:
;        Mimics the intrinsic FORTRAN function, SIGN.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = SIGN( A [, B ] )
;
; OUTPUTS:
;        If ONE parameter is specified then
;
;        returns -1 if A < 0, +1 if A > 0.
;
;        If TWO parameters are specified then
;
;        returns A if B >= 0 or -A if B<0
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1994.
;        8-DEC-1994:    Accepts A, B as vectors.
;        16-JUN-1995:   Bugfix: if A is a scalar, return a scalar
;                       instead of a 1-element vector.
;-
function SIGN, A, B

         NP   = N_PARAMS()
         npt  = n_elements( A )

         if NP eq 1 then begin
              n    = A
              m    = replicate( 1.d0,npt )
         endif else begin
              n    = B
              m    = A
         endelse

         if npt eq 1 then begin
              if n ge 0 then $
                   return, m(0) $
              else           $
                   return,-m(0)
         endif else begin
              signs   = A*0
              here_ge = WHERE( n ge 0, nge )
              here_lt = WHERE( n lt 0, nlt )
              if nge gt 0 then signs( here_ge ) =  m( here_ge )
              if nlt gt 0 then signs( here_lt ) = -m( here_lt )
              return, signs
         endelse

end
