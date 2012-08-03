;+
; NAME:
;        KSTWO
;
; PURPOSE:
;        Given an array data1, and an array data2, this routine returns
;        the Kolmogorov-Smirnov statistic d, and the significance level
;        prob for the null hypothesis that two given data sets are drawn
;        from the same distribution.  Small values of prob show that the
;        cumulative distribution function of data1 is significantly
;        different from that of data2.  The arrays data1 and data2 are
;        modified by being sorted into ascending order
;
;        (Adapted from a routine of the same name in Numerical Recipes in C,
;        Second edition).
;
; CATEGORY:
;        Math.
;
; CALLING SEQUENCE:
;
;        KSTWO, Data1, Data2, D, Prob
;
; INPUTS:
;        Data1/2:  First/second data array.
;
; OUTPUTS:
;
;        Data1/2:  Original Data1/2 array sorted into ascending order.
;
;        D:        K-S statistic.
;
;        Prob:     K-S significance level.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1996.
;-
function PROBKS, Alam
;
;   Kolmogorov-Smirnov probability function

         EPS1 = 0.001
         EPS2 = 1.0e-8

         fac  = 2.0
         sum  =( termbf = 0.0 )

         a2   = -2.0*alam^2
         for j=1,100 do begin
              term = fac*EXP(double(a2)*j^2)
              sum  = sum + term
              if (ABS(term) le EPS1*termbf) or $
                 (ABS(term) le EPS2*sum) then return, sum
              fac       = -fac         ; Alternating signs in sum
              termbf    = abs(term)
         endfor
         return, 1.0
end


pro KSTWO, Data1, Data2, D, Prob
;
         n1   = N_ELEMENTS(Data1)
         n2   = N_ELEMENTS(Data2)

         j1   =( j2=1L )
         fn1  =( fn2=0.0 )

         Data1= Data1(SORT(Data1))
         Data2= Data2(SORT(Data2))
         en1  = float(n1)
         en2  = float(n2)
         D    = 0.0

         while (j1 le n1) and (j2 le n2) do begin     ; If we are not done...
              d1   = float(data1(j1-1))
              d2   = float(data2(j2-1))
              if (d1 le d2) then begin                ; Next step is in data1
                   fn1  = j1/en1
                   j1   = j1 + 1
              endif
              if (d2 le d1) then begin                ; Next step is in data2
                   fn2  = j2/en2
                   j2   = j2 + 1
              endif
              dt   = ABS(fn2-fn1)
              if (dt gt D) then D=dt
         endwhile

         en   = SQRT(en1*en2/(en1+en2))
         Prob = PROBKS((en+0.12+0.11/en)*d)           ; Compute significance
end

