FUNCTION TwinGaussDIFF, p, X=x, Y=y, ERR=err
  ;p[0] = center of line 1
  ;p[1] = width of line 1
  ;p[2] = height of line 1
  ;p[3] = center of line 2
  ;p[4] = width of line 2
  ;p[5] = height of line 2

  z1 = (x-p[0])/p[1]
  z2 = (x-p[3])/p[4]  
  f = p[2]*exp(-z1^2/2.0) + p[5]*exp(-z2^2/2.0)
  dev = (y-f)/err
return, dev
end

; fit the optimally filtered pulse data
PRO HistoFit,datapath,outpath,pulsename,StartT,atten,res,pm,phr

path=outpath
filename = 'pulses.dat'
data = read_ascii(path+filename)
data = data.field01

device,filename=path+'histfit.ps'
!p.multi=0

bs = 0.5

; Loop and repeat for ch1 and ch2
for i=0,3 do begin

if( i EQ 0 ) then begin 
  ch1 = data[4,*]  ;parabolic fit data, ch1
  ;ch1 = data[4,*]  ;shift fit data, ch1
  chisq = data[8,*] ; chisq
  Pmax = pm[0]
  Psd = pm[1]
  histzr = fix(pm[5]*2.0*180.0/!Pi/bs)
endif

if( i EQ 1 ) then begin 
  ch1 = data[5,*]  ;parabolic fit data, ch2
  ;ch1 = data[5,*]  ;shift fit data, ch2
  chisq = data[9,*] ; chisq
  Pmax = pm[2]
  Psd = pm[3]
  histzr = fix(pm[4]*2.0*180.0/!Pi/bs)
endif

if( i EQ 2 ) then begin 
  ch1 = data[6,*]  ;parabolic fit data, ch1
  ;ch1 = data[4,*]  ;shift fit data, ch1
  chisq = data[8,*] ; chisq
  Pmax = pm[0]
  Psd = pm[1]
  histzr = fix(pm[5]*2.0*180.0/!Pi/bs)
endif

if( i EQ 3 ) then begin 
  ch1 = data[7,*]  ;parabolic fit data, ch2
  
  ;ch1 = data[5,*]  ;shift fit data, ch2
  chisq = data[9,*] ; chisq
  
  Pmax = pm[2]
  Psd = pm[3]
  histzr = fix(pm[4]*2.0*180.0/!Pi/bs)
endif

; screen for chisq
for j=0,n_elements(chisq)-1 do begin
  ;if( i EQ 0 AND chisq[j] GE 1.2 ) then ch1[j] = 0.0
  ;if( i EQ 1 AND ( chisq[j] GE 1.7 OR chisq[j] LE 1.2) ) then ch1[j] = 0.0
   ;if( ( chisq[j] GE 2.0 OR chisq[j] LE 0.8) ) then ch1[j] = 0.0
endfor

hist = histogram( ch1, MIN = 0, MAX = 200, BINSIZE = bs)
hist[0:histzr] = 0.0 ; remove false trigger tail
bins = FINDGEN(N_ELEMENTS(hist))*bs
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmax*2.0],/xstyle,xtitle='Pulse Height (degrees)',title=strcompress('Channel' + string(((i mod 2)+1)))

x = double(bins)
y = double(hist)
err = replicate(1.0, (size(x))[1] )

parinfo = replicate({value:0.D, fixed:0, step:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 6)

;p[0] = center of line 1
;p[1] = width of line 1, sigma
;p[2] = height of line 1
;p[3] = center of line 2
;p[4] = width of line 2
;p[5] = height of line 2

;parinfo[0].value = Pmax
parinfo[0].value = 110.0
parinfo[0].limits  = [10.0,160.0]

;parinfo[1].value = Psd
parinfo[1].value = 3.0
parinfo[1].limits  = [0.1,10.0]

;parinfo[2].value = max(hist)
parinfo[2].value = 100.0
;parinfo[2].limits  = [max(hist)/10.0,max(hist)*3.0]
parinfo[2].limits  = [1.0,1000.0]

;parinfo[3].value = Pmax*0.7
parinfo[3].value = 40.0
parinfo[3].limits  = [5.0,130.0]

;parinfo[4].value = Psd*2.0
parinfo[4].value = 3.0
parinfo[4].limits  = [0.1,50.0]

;parinfo[5].value = max(hist)/5.0
;parinfo[5].limits  = [1.0,max(hist)/2.0]
parinfo[5].value = 115.0
parinfo[5].limits  = [1.0,1000.0]

; Do the optimization
fa = {X:x, Y:y, ERR:err}
bestnorm=0.0
covar=0.0
perror=0.0

p = mpfit('TwinGaussDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-18,XTOL=1D-18,GTOL=1D-18,FASTNORM=0,STATUS=status,/QUIET)

;print,'Status of Fit= ',status
;print,bestnorm

DOF     = N_ELEMENTS(X)*2.0 - N_ELEMENTS(PARMS) ; deg of freedom
PCERROR = PERROR * SQRT(BESTNORM / DOF)   ; scaled uncertainties

bestp = p
bn = bestnorm

; monte carlo fit parameters
for j=0,19 do begin
  parinfo[0].value = Pmax + randomu(seed)*20.0
  if( parinfo[0].value LE 5.0) then parinfo[0].value=5.0
  parinfo[1].value = 2.0 + randomu(seed)*2.0
  parinfo[2].value = max(hist)*randomu(seed)*2.0
 
  fa = {X:x, Y:y, ERR:err}
  bestnorm=0.0
  covar=0.0
  perror=0.0
  p = mpfit('TwinGaussDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-18,XTOL=1D-18,GTOL=1D-18,FASTNORM=0,STATUS=status,/QUIET)
  ;print,bestnorm,status,p[0]
  if( status NE 0 AND bn GT bestnorm) then begin
    bn = bestnorm
    bestp = p
  endif

endfor

p = bestp

z1 = (bins-p[0])/p[1]
z2 = (bins-p[3])/p[4]  
f = p[2]*exp(-z1^2/2.0) + p[5]*exp(-z2^2/2.0)

oplot,bins,f,line=0,color=150

r1 = string(p[0]/(p[1]*2.355), format='(F6.2)' )
r2 = string(p[3]/(p[4]*2.355), format='(F6.2)' )
c1 =  string(p[0], format='(F6.2)' )
c2 =  string(p[3], format='(F6.2)' )
h1 =  string(p[2], format='(F6.2)' )
h2 =  string(p[5], format='(F6.2)' )

al_legend,/top,/right,[strcompress('R1 = ' + r1),strcompress('Center1 = ' + c1),strcompress('Height1 = ' + h1),strcompress('R2 = ' + r2),strcompress('Center2 = ' + c2),strcompress('Height2 = ' + h2)]
;print,r1,r2

phr[i] = p[0]

endfor

device,/close

end