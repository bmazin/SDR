
function digammal,z

    ;The bernoulli numbers.

      B=[ 0.166666666666666666666667    , -0.3333333333333333333333333e-1, $
          0.238095238095238095238095e-1 , -0.3333333333333333333333333e-1, $
          0.7575757575757575757575768e-1, -.2531135531135531135531136    , $
          1.166666666666666666666667    , -7.092156862745098039215686    , $
          54.97117794486215538847118    , -529.1242424242424242424242    , $
          6192.123188405797101449275    , -86580.25311355311355311355    , $
          1425517.166666666666666667    , -27298231.06781609195402299    , $
          601580873.9006423683843039    , -15116315767.09215686274510    , $
          429614643061.1666666666667    , -13711655205088.33277215909    , $
          488332318973593.1666666667    , -19296579341940068.14863267    , $
          841693047573682615.0005537    , -40338071854059455413.07681    , $
          2115074863808199160560.145    , -120866265222965259346027.3   ] 

      ;K=1:length(B+1);
      K = dindgen(n_elements(B))

      ;B=reshape(B,size(K));

      z=alog(z)-1.0/(2.0*z) - total(B/(2.0*K*z^(2.0*K)))

end

function digammalarge,z

;DIGAMMA function for complex arguments with abs(z)>=9.
;Algorithm: The asymptotic expansion for the digamma function.
;digammaz ~ Log(z) - 1/(2z) - sum(B_2k/(2k z^(2k)))
;where the B_2k's are the Bernoulli numbers. Works only when arg(z)<pi/2. 
;Accuracy: 15 to 16 decimal places

z=abs(z)*exp(dcomplex(0,atan(imaginary(z),double(z)))); 

  if (double(z) GE 0) then begin
    z=digammal(z) ;for arg(z)<=pi/2 use asympotic series
  endif else  begin  ; arg(z)>pi/2 use distant neigbor formula
      N=-floor(double(z))+22;
      n=dindgen(N-1)
      z=digammalarge(z+N)-total(1.0/(z+n));
  endelse

return,z

end

FUNCTION ComplexDigamma,z

; FDIGAMMA: the PSI (Maple)/POLYGAMMA (Mathematica) function 
; for complex arguments.
;
; Accuracy:
;      16 decimal places accurate away from the singularities
;      (z=-1, -2, -3, ...). Full 16 digit accuracy is guaranteed
;      for all z with real(z)>=0. Accuracy decreases as z appro-
;      aches any of the singularities.
;
;      If -n, with n>0, is the nearest singularity to the given
;      argument z, then a minimum of 15 digit accuracy is obtained
;      for abs(z+n)>2 for all abs(z)<=10e5. The accuracy, however,
;      is greater for abs(z)<100 for smaller abs(z+n).
;
; Performance : 
;      About 28 times faster than Matlab's mfun for 100x100 complex
;      matrix arguments. About 12 times faster than mfun for scalar
;      arguments.
;
; Author:
;      EAG <special.functions@gmail.com>
;
; Matlab 7.2
; May 17, 2006 v1.0
;
; print,Complexdigamma(dcomplex(.5,-4)) ; test

    if (imaginary(z) EQ 0 AND -z-floor(abs(z)) EQ 0) then begin
      
      z=1d38  ;  infinite for negative integers
      return,z
      
    endif 
    
        if ( abs(z) LE 1 ) then begin  
          z=digammasmall(z)
          print,'Small'
          return,z 
        endif  
        

        if ( double(z) GE 10 AND abs(z) GE 10 ) then begin
          z=digammalarge(z)
          print,'Large'
          return,z
        endif


            if (double(z) LE 10 AND abs(imaginary(z)) LE 1 ) then begin
            
             print,'Bad Digamma'

             ;   if (real(z) GT 0) then begin

             ;       n=1:floor(real(z(k)));

             ;       z(k)=digammasmall(z(k)-floor(real(z(k)))) ... + sum(1./(z(k)-n));
                        
             ;   endif else begin

             ;       n=0:-ceil(real(z(k)))-1;

             ;       z(k)=digammasmall(z(k)-ceil(real(z(k)))) ... - sum(1./(z(k)+n));
             ;   endelse

            endif else begin
            
                ;print,'Medium'

                if ( double(z) GE 0 ) then begin

                    ;n=0:10
                    n = dindgen(11)
                    z=digammalarge(z+11)-total(1.0/(z+n))

                endif else begin

                    ;n=1:11;
                    n = dindgen(11)
                    z=digammalarge(z-11)+total(1.0/(z-n));

                endelse

            endelse

  return, z
end