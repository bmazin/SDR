

;function z=fdigamma(z)
function digamma(z)

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



sz=size(z);

z=z(:);

for k=1:length(z)

    if (imag(z(k))==0 && -z(k)-floor(abs(z(k)))==0)

        z(k)=NaN; % infinite for negative integers

    else

        if abs(z(k))<=1

            z(k)=digammasmall(z(k));

        elseif real(z(k))>=10 && abs(z(k))>=10

            z(k)=digammalarge(z(k));

        else % compute using distant neighbor formulas

            if (real(z(k))<10 && abs(imag(z(k)))<1)

                if real(z(k))>0

                    n=1:floor(real(z(k)));

                    z(k)=digammasmall(z(k)-floor(real(z(k)))) ...

                        + sum(1./(z(k)-n));

                else

                    n=0:-ceil(real(z(k)))-1;

                    z(k)=digammasmall(z(k)-ceil(real(z(k)))) ...

                        - sum(1./(z(k)+n));

                end

            else

                if real(z(k))>=0

                    n=0:10;

                    z(k)=digammalarge(z(k)+11)-sum(1./(z(k)+n));

                else

                    n=1:11;

                    z(k)=digammalarge(z(k)-11)+sum(1./(z(k)-n));

                end

            end

        end

    end

end



z=reshape(z,sz);

end % fdigamma



function z=digammasmall(z)

% DIGAMMA function for complex arguments with abs(z)<=1.

%

% Algorithm: The Laurent series expansion about z=0.

%

%   digammaz=-1/z - gamma + sum((-1)^j (zeta(j+2)-1) z^(j+1),j=0..infinity)

%             + z/(1+z)

%   gamma=0.5772156649015328606065121

%

% Accuracy: Everywhere 16-digit accurate in the disk abs(z)<=1.



% numerical values of the zeta function

zt=[0.6449340668482264364724    ; 0.202056903159594285399738;

    0.8232323371113819151600e-1 ; 0.36927755143369926331365e-1;

    0.1734306198444913971451e-1 ; 0.8349277381922826839798e-2;

    0.4077356197944339378684e-2 ; 0.2008392826082214417853e-2;

    0.9945751278180853371459e-3 ; 0.4941886041194645587023e-3;

    0.2460865533080482986380e-3 ; 0.1227133475784891467518e-3;

    0.6124813505870482925855e-4 ; 0.3058823630702049355173e-4;

    0.1528225940865187173257e-4 ; 0.7637197637899762273600e-5;

    0.3817293264999839856462e-5 ; 0.1908212716553938925657e-5;

    0.9539620338727961131520e-6 ; 0.4769329867878064631167e-6;

    0.2384505027277329900036e-6 ; 0.1192199259653110730678e-6;

    0.5960818905125947961244e-7 ; 0.2980350351465228018606e-7;

    0.1490155482836504123466e-7 ; 0.7450711789835429491981e-8;

    0.3725334024788457054819e-8 ; 0.1862659723513049006404e-8;

    0.9313274324196681828718e-9 ; 0.4656629065033784072989e-9;

    0.2328311833676505492001e-9 ; 0.1164155017270051977593e-9;

    0.5820772087902700889244e-10; 0.2910385044497099686929e-10;

    0.1455192189104198423593e-10; 0.7275959835057481014521e-11;

    0.3637979547378651190237e-11; 0.1818989650307065947585e-11;

    0.9094947840263889282533e-12; 0.4547473783042154026799e-12;

    0.2273736845824652515227e-12; 0.1136868407680227849349e-12;

    0.5684341987627585609277e-13; 0.2842170976889301855455e-13;

    0.1421085482803160676983e-13; 0.7105427395210852712877e-14;

    0.3552713691337113673298e-14; 0.1776356843579120327473e-14;

    0.8881784210930815903096e-15; 0.4440892103143813364198e-15;

    0.2220446050798041983999e-15; 0.1110223025141066133721e-15;

    0.5551115124845481243723e-16; 0.2775557562136124172582e-16;

    0.1387778780972523276284e-16; 0.6938893904544153697446e-17;

    0.3469446952165922624744e-17; 0.1734723476047576572049e-17;

    0.8673617380119933728342e-18; 0.433680869002065048750e-18;

    0.2168404344997219785014e-18; 0.108420217249424140646e-18;

    0.5421010862456645410919e-19; 0.2710505431223468831955e-19;

    0.1355252715610116458149e-19; 0.6776263578045189097995e-20;

    0.3388131789020796818086e-20; 0.1694065894509799165406e-20];



  K=0:length(zt)-1;

  K=reshape(K,size(zt));

  z=-1/z - 0.5772156649015328606065121+sum((-1).^K.*zt.*z.^(K+1))+z/(1+z);

end % digammasmall



function z=digammalarge(z)

% DIGAMMA function for complex arguments with abs(z)>=9.

%

% Algorithm: The asymptotic expansion for the digamma function.

%

%    digammaz ~ Log(z) - 1/(2z) - sum(B_2k/(2k z^(2k)))

%

% where the B_2k's are the Bernoulli numbers. Works only when arg(z)<pi/2. 

%

% Accuracy: 15 to 16 decimal places



z=abs(z)*exp(i*angle(z)); 



  if real(z)>=0 % for arg(z)<=pi/2 use asympotic series

      z=digammal(z);

  else % for arg(z)>pi/2 use distant neigbor formula

      N=-floor(real(z))+22;

      n=0:N-1;

      z=digammalarge(z+N)-sum(1./(z+n));

  end



    function z=digammal(z)

    % The bernoulli numbers.

      B=[ 0.166666666666666666666667    ; -0.3333333333333333333333333e-1;

          0.238095238095238095238095e-1 ; -0.3333333333333333333333333e-1;

          0.7575757575757575757575768e-1; -.2531135531135531135531136    ;

          1.166666666666666666666667    ; -7.092156862745098039215686    ;

          54.97117794486215538847118    ; -529.1242424242424242424242    ;

          6192.123188405797101449275    ; -86580.25311355311355311355    ;

          1425517.166666666666666667    ; -27298231.06781609195402299    ;

          601580873.9006423683843039    ; -15116315767.09215686274510    ;

          429614643061.1666666666667    ; -13711655205088.33277215909    ;

          488332318973593.1666666667    ; -19296579341940068.14863267    ;

          841693047573682615.0005537    ; -40338071854059455413.07681    ;

          2115074863808199160560.145    ; -120866265222965259346027.3]   ;

      K=1:length(B+1);

      B=reshape(B,size(K));

      z=log(z)-1/(2*z) - sum(B./(2*K.*z.^(2*K)));

    end % subfunction digammal

end % digammalarge