;+
; NAME:
;        FACPRIME
;
; PURPOSE:
;        Factor a number into its prime numbers.
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        Result = FACPRIME( N, SUM=Sum )
;
; INPUTS:
;        N:        Number to factor into primes.
;
; OUTPUTS:
;        Returns a two dimensional array, LONARR(2,nprime) where nprime
;        is the number of unique prime numbers.  The first dimension holds
;        the value of each unique prime, Result(0,*) and the second
;        dimension holds the frequency or number of times that prime
;        occurs, Result(1,*).
;
; COMMON BLOCKS:
;        FACPRIME:  Holds an array containing the first 100000 prime numbers.
;
; RESTRICTIONS:
;        The number to be factored must be < 1299709.
;
; EXAMPLE:
;
;        pnums = FACPRIME( 63500 )          ; Factor 63500 into it pnums
;        help, pnums                        ; pnums       LONG = Array(2,3)
;        print,REFORM(pnums(0,*)            ; 2 5 127
;        print,REFORM(pnums(1,*)            ; 2 3 1
;        ck   = 1L                          ; (2^2)(5^3)(127) = 63500
;        for i=0,2 do $
;             ck=ck*long(pnums(0,i))^pnums(1,*)
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;        11-Aug-1996    Missing prime number, 2 in factoring, eliminate
;                       prime number, 1 from result.
;-
function FACPRIME, N1, SUM=Sum

         common FACPRIME, prime_num

         if (N_ELEMENTS(prime_num) eq 0) then $
              restore,GRPKPATH()+'prime10.sav'

         N    = N1
         i    = 0L
         r    = [1L,0L]
         repeat begin
              r    = [r,prime_num(i),0]
              repeat begin
                   rem = N mod prime_num(i)
                   if (rem eq 0) then begin
                        N = N/prime_num(i)
                        j = 2L*(i+2)-1
                        r(j) = r(j) + 1
                   endif
              endrep until (rem ne 0)
              i    = i+1L
         endrep until (N lt prime_num(i))

         r    = REFORM(r,2,i+1,/OVERWRITE)
         hgt0 = WHERE(r(1,*) gt 0)
         r    = r(*,hgt0)

         sum  = LONG(TOTAL(REFORM(r(0,*))*REFORM(r(1,*))))

         return,r
end
