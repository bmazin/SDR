
; fit f0 and Q as a function of temperature including TLS effects

FUNCTION Qmodel,p,T

     kb = 8.62d-5
     hbar = 4.14d-15
     q = p[0]
     f = p[1]
     gap0 = p[2]
     a = p[3]
     fdelta = p[4]
     emax = p[5]
     Toff = p[6]
     w = 2.0*!Pi*f

     ;gap = gap0*exp( -sqrt(2.0*!Pi*kb*T/gap0)*exp(-gap0/(kb*T)) )     
     gap = gap0
     sigma2 = ((!Pi*gap)/(hbar*w))*(1.0 - sqrt(2.0*!Pi*kb*T/gap)*exp(-gap/(kb*T)) - 2.0*exp(-gap/(kb*T))*exp(-(hbar*w)/(2.0*kb*T))*beselI((hbar*w)/(2.0*kb*T),0) )
     sigma1 = ((4.0*gap)/(hbar*w))*exp(-gap/(kb*T))*beselK((hbar*w)/(2.0*kb*T),0)*sinh((hbar*w)/(2.0*kb*T))

     Qsigma = (3.0/a)*(sigma2)/(sigma1)
     
     Qtls = 1.0/(fdelta*tanh(hbar*w/(2.0*kb*T)))
     
     ; Final model Q
     Qm = 1.0/( 1.0/Qsigma  + 1.0/Qtls + 1.0/q )

     return,Qm
end

FUNCTION Fmodel,p,T

     kb = 8.62d-5
     hbar = 4.14d-15
     q = p[0]
     f = p[1]
     gap0 = p[2]
     a = p[3]
     fdelta = p[4]
     emax = p[5]
     Toff = p[6]
     w = 2.0*!Pi*f
     
     ;gap = gap0*exp( -sqrt(2.0*!Pi*kb*T/gap0)*exp(-gap0/(kb*T)) )  
     gap = gap0   
     sigma2 = ((!Pi*gap)/(hbar*w))*(1.0 - sqrt(2.0*!Pi*kb*T/gap)*exp(-gap/(kb*T)) - 2.0*exp(-gap/(kb*T))*exp(-(hbar*w)/(2.0*kb*T))*beselI((hbar*w)/(2.0*kb*T),0) )
     sigma1 = ((4.0*gap)/(hbar*w))*exp(-gap/(kb*T))*beselK((hbar*w)/(2.0*kb*T),0)*sinh((hbar*w)/(2.0*kb*T))

     ; change in frequecy
     ;df = ( 1.0 - a*(sigma2[0]-sigma2)/(6.0*sigma2[0]) )
     df = -a*f*sigma2/(6.0*sigma2[0])

     ; TLS contribution
     dfTLS = dblarr(n_elements(T))
     for i=0,n_elements(T)-1 do begin
      dfTLS[i] = f*(fdelta/!Pi)*( double(ComplexDigamma(dcomplex(0.5,-hbar*w/(2.0*!Pi*kb*T[i]) ))) - alog(hbar*w/(2.0*!Pi*kb*T[i])) )
     endfor
     
     df = df + dfTLS
     
     df = df[0] - df
    
     return, df
end

FUNCTION jointDIFF, p, X=x, Y=y, ERR=err

    common output, Qmodel, df

    ; p[0] = Q(T=0)
    ; p[1] = f0(T0)
    ; p[2] = delta
    ; p[3] = alpha
    ; p[4] = Fdelta
    ; p[5] = emax
    ; p[6] = Temp offset of thermometer

     sz = (size(x))[1]/2
     Qdat = y[0:sz-1]
     fdat = y[sz:2*sz-1] 
     Qerr = err[0:sz-1]
     ferr = err[sz:2*sz-1] 
     T = x[0:sz-1]+p[6]

     Qm = Qmodel(p,T)
     Fm = Fmodel(p,T)

    ; terms for dielectric constant changes
    ;dftls = (fdelta/!Pi)*double(ajs_digamma(dcomplex(0.5 - hbar*w/(2.0*)))

    devq =  (Qdat - Qm)/Qerr
    devf =  (fdat - Fm)/ferr 
    
    dev = [devq,devf]
    
    ;if (total(dev^2) LT 60) then stop

    return, dev
end

FUNCTION ajs_digamma, x, eps
  compile_opt idl2

  x = double(x)
  IF n_elements(eps) EQ 0 THEN $
     eps = 1e-12
  
  ;; Euler-Mascheroni constant
  gamma = 0.57721566490153286060651209008240243104215933593992d

  psi = - gamma
  n = 1
  REPEAT BEGIN
      delta_psi = (x - 1) / (n * (n + x - 1))
      psi += delta_psi
      n += 1
  ENDREP UNTIL (abs(delta_psi) LT eps)

  return, psi
END

pro Fitf0Q,data,res,atten

for j=0,1 do begin

A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A)

; make array of d1/Q vs T and df/f0 vs T
dataidx = (where( data[0,*] EQ 2*res-j and data[2,*] EQ atten ))[*]
T = (data[1,dataidx])[*]
Q = (data[3,dataidx])[*]
f0 = (data[5,dataidx])[*]

; figure out upper bound of fitting
maxidx = (where( T GT 0.280 ))[0]-1
Q = Q[0:maxidx]
f = f0[0:maxidx]-f0[0]
T = T[0:maxidx]

; set up fitting initial values
parinfo = replicate({value:0.D, fixed:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 7)
parinfo(0).value = Q[0]
parinfo(0).limits  = [Q[0]*0.2,Q[0]*5.0]

parinfo(1).value = f0[0]
parinfo(1).limits  = [f0[0]*.95,f0[0]*1.05]
parinfo(1).fixed=1

parinfo(2).value = .170e-3
parinfo(2).limits  = [0.15e-3,0.19e-3]
parinfo(2).fixed=1

parinfo(3).value = 0.3      ; alpha
parinfo(3).limits  = [0.01,0.99]

parinfo(4).value = .000002        ; Fdelta
parinfo(4).limits  = [5e-7,.001]
parinfo(4).fixed=0

parinfo(5).value = 1.0        ; Emax
parinfo(5).limits  = [-1.0e6,1e6]
parinfo(5).fixed=1

parinfo(6).value = 0.001        ; Temp offset
parinfo(6).limits  = [-.030,.100]

; Set up parameters for Q fit
x = [T,T]
y = [Q,f]
;err = [(data[3,0:maxidx])[*]/200.0,(data[6,0:maxidx])[*]*500.0]
sz = (size(x))[1]/2
err = [replicate(500,sz) , replicate(2e4,sz) ]
err[0:12] = err[0:12]*5.0
err[sz:sz+12] = err[sz:sz+12]*5.0

fa = {X:x, Y:y, ERR:err}

parms = mpfit('jointDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-16,XTOL=1D-16,GTOL=1D-16,FASTNORM=1,STATUS=status)
print,'Status of Fit= ',status
print,parms

; plot Q and f0 vs T
set_plot,'X'
!p.multi=[0,1,2]
plot,T,Q,xtitle='Temp (K)',ytitle='Q',/xstyle,/ystyle,psym=8,symsize=1;,yr=[0,5e4]
oploterr,T,Q,err[0:sz-1]
oplot,T,Qmodel(parms,T),line=0

plot,T,f0-f0[0],xtitle='Temp (K)',ytitle='f/f!L0!N',/xstyle,/ystyle,psym=8,symsize=1
oploterr,T,f0-f0[0],err[sz:2*sz-1]
oplot,T,Fmodel(parms,T),line=0

;if( j EQ 1) then stop

endfor


end