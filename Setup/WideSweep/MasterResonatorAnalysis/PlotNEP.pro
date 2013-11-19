PRO PlotNEP,data,res,atten,outpath,StartT,tau,Tc  

device,filename=strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'-NEP.ps',/remove_all)
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL

; Plot NEP for both resonators

; Load up responsivities
wait,0.1
respname = strcompress(outpath + 'dphi.dat',/remove_all)
resp1 = read_ascii(respname)
resp1 = resp1.field1
resp = (resp1[1,*])[*]
dphi1 = resp[res*2-2]
dphi2 = resp[res*2-1]
resp = (resp1[2,*])[*]
damp1 = resp[res*2-2]
damp2 = resp[res*2-1]

; Load up phase noise spectrum
noisename1 = strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'a-'+ string(fix(atten)) +'-1.psd',/remove_all)
noisename2 = strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'a-'+ string(fix(atten)) +'-2.psd',/remove_all)  

data2 = read_ascii(noisename1)
data2 = data2.field1
x1 = (data2[0,*])[*]
Pn1 = (data2[1,*])[*]
An1 = (data2[2,*])[*]

data2 = read_ascii(noisename2)
data2 = data2.field1
x2 = (data2[0,*])[*]
Pn2 = (data2[1,*])[*]
An2 = (data2[2,*])[*]
  
; compute NEP
;kb = 8.617e-5       ; eV/K
kb = 1.3806504d-23   ; J/K
delta = 1.6 * kb * Tc
eta = 0.57
w = 2.0*!Pi*x1

; tau of resonator
dataidx = (where( data[0,*] EQ 2*res-1 and data[2,*] EQ atten ))[0]
Q = data[3,dataidx]
f0 = data[5,dataidx]
taures1 = Q/(!Pi*f0) 
dataidx = (where( data[0,*] EQ 2*res and data[2,*] EQ atten ))[0]
Q = data[3,dataidx]
f0 = data[5,dataidx]
taures2 = Q/(!Pi*f0) 

NEP1 = sqrt( Pn1*((eta*tau*dphi1/delta)^(-2.0))*(1.0+w^2*tau^2)*(1.0+w^2*taures1^2) )
NEP2 = sqrt( Pn2*((eta*tau*dphi2/delta)^(-2.0))*(1.0+w^2*tau^2)*(1.0+w^2*taures2^2) )

ampNEP1 = sqrt( An1*((eta*tau*damp1/delta)^(-2.0))*(1.0+w^2*tau^2)*(1.0+w^2*taures1^2) )
ampNEP2 = sqrt( An2*((eta*tau*damp2/delta)^(-2.0))*(1.0+w^2*tau^2)*(1.0+w^2*taures2^2) )

kb = 8.617e-5       ; eV/K  
delta = 1.6 * kb * Tc

; opt filtering estimate of energy resolution assuming 90 degree pulse
temp = dblarr(4000)
temp[*] = 0.0
temp[2000:3999] = 1.0*exp(-dindgen(2000)*1.25d-6/tau)
opt1 = fft(temp,-1)
  
; plot NEP
if( dphi1 GT 0.0 ) then begin 
  plot,x1,NEP1,/xlog,/ylog,/xstyle,/ystyle,xr=[1,1e5],yr=[1d-18,1d-15],title=strcompress('Resonator'+string(res*2-1)),xtitle='Frequency (Hz)',ytitle='Noise Equivalent Power (W Hz!U-1/2!N)'
  oplot,x1,ampNEP1,color=100
  legend,/top,/left,['Phase NEP','Amplitude NEP'],line=[0,0],color=[0,100]

  sat = 1.57*delta/(eta*dphi1) ; saturation photon energy in eV
  satamp = 1.57*damp1/dphi1
  ;dE = 6.241506d18*1.0/sqrt(int_tabulated(x1,4.0/(NEP1)^2,/double))   
  ;dE1 = 6.241506d18*1.0/sqrt(int_tabulated(x1,4.0/(ampNEP1)^2,/double))     
  ;legend,/bottom,/right,[strcompress('Max photon energy = ' + string(sat,format='(F8.1)') + ' eV'), strcompress('R (phase) = ' + string(sat/dE,format='(F8.1)')), strcompress('R (amp) = ' + string(sat/dE1,format='(F8.1)'))  ]

  ; rebin noise spectra
  N = 4000 
  T = 1.25d-6
  N21 = N/2 + 1 
  F = INDGEN(N) 
  F[N21] = N21 -N + FINDGEN(N21-2) 
  F = (F/(N*T))[1:2000] 
  
  ch1nc = dblarr(4000)
  Pn1a = Pn1
  Pn1a[980:999] = Pn1a[979]
  ch1nc[1:1999] = interpol(Pn1a,x1,F[1:1999])
  ch1nc[2000:3999] = reverse(ch1nc[0:1999])

  ch1ncb = dblarr(4000)
  Pn1b = An1
  Pn1b[980:999] = Pn1b[979]
  ch1ncb[1:1999] = interpol(Pn1b,x1,F[1:1999])
  ch1ncb[2000:3999] = reverse(ch1ncb[0:1999])

  ; fix zeroes
  ch1nc[0] = ch1nc[1]
  ch1nc[3999] = ch1nc[3998]
  ch1ncb[0] = ch1ncb[1]
  ch1ncb[3999] = ch1ncb[3998]
  
  optns1 = sqrt( 1.0/(5000.0e-6*total(abs(opt1)^2/ch1nc)))
  optns1b = sqrt( 1.0/(5000.0e-6*total(abs(opt1)^2/ch1ncb)))

  ;print,'Opt. Flt. S/N',1.57/optns1
  ;print,'Opt. Flt. R (phase)',1.57/optns1/2.355
  ;print,'Opt. Flt. R (amp)',satamp/optns1b/2.355
  ;print,'Opt. Flt. dE',sat/(1.57/optns1/2.355),' eV'
  
 legend,/bottom,/right,[strcompress('Max photon energy = ' + string(sat,format='(F8.1)') + ' eV'), strcompress('R (phase) = ' + string(1.57/optns1/2.355,format='(F8.1)')), strcompress('R (amp) = ' + string(satamp/optns1b/2.355,format='(F8.1)')), $
   strcompress('R (combined) = ' + string(sqrt((satamp/optns1b/2.355)^2 + (1.57/optns1/2.355)^2),format='(F8.1)')), strcompress('!9D!3E (combined)' + string(sat/sqrt((satamp/optns1b/2.355)^2 + (1.57/optns1/2.355)^2),format='(F8.2)') + ' eV' )  ] 
    
endif

if( dphi2 GT 0.0 ) then begin
  plot,x2,NEP2,/xlog,/ylog,/xstyle,/ystyle,xr=[1,1e5],yr=[1d-18,1d-15],title=strcompress('Resonator'+string(res*2)),xtitle='Frequency (Hz)',ytitle='Noise Equivalent Power (W Hz!U-1/2!N)'
  oplot,x2,ampNEP2,color=100  
  legend,/top,/left,['Phase NEP','Amplitude NEP'],line=[0,0],color=[0,100]
  
  sat = 1.57*delta/(eta*dphi2) ; saturation photon energy in eV
  satamp = 1.57*damp2/dphi2
  
  ; rebin noise spectra
  N = 4000 
  T = 1.25d-6
  N21 = N/2 + 1 
  F = INDGEN(N) 
  F[N21] = N21 -N + FINDGEN(N21-2) 
  F = (F/(N*T))[1:2000] 
  
  ch1nc = dblarr(4000)
  Pn1a = Pn2
  Pn1a[980:999] = Pn1a[979]
  ch1nc[1:1999] = interpol(Pn1a,x1,F[1:1999])
  ch1nc[2000:3999] = reverse(ch1nc[0:1999])

  ch1ncb = dblarr(4000)
  Pn1b = An2
  Pn1b[980:999] = Pn1b[979]
  ch1ncb[1:1999] = interpol(Pn1b,x1,F[1:1999])
  ch1ncb[2000:3999] = reverse(ch1ncb[0:1999])

  ; fix zeroes
  ch1nc[0] = ch1nc[1]
  ch1nc[3999] = ch1nc[3998]
  ch1ncb[0] = ch1ncb[1]
  ch1ncb[3999] = ch1ncb[3998]
  
  optns1 = sqrt( 1.0/(5000.0e-6*total(abs(opt1)^2/ch1nc)))
  optns1b = sqrt( 1.0/(5000.0e-6*total(abs(opt1)^2/ch1ncb)))

  ;print,'Opt. Flt. S/N',1.57/optns1
  ;print,'Opt. Flt. R (phase)',1.57/optns1/2.355
  ;print,'Opt. Flt. R (amp)',0.4/optns1b/2.355
  ;print,'Opt. Flt. R (combined)',sqrt((0.4/optns1b/2.355)^2 + (1.57/optns1/2.355)^2)
  ;print,'Opt. Flt. dE',sat/sqrt((0.4/optns1b/2.355)^2 + (1.57/optns1/2.355)^2),' eV'
  
  legend,/bottom,/right,[strcompress('Max photon energy = ' + string(sat,format='(F8.1)') + ' eV'), strcompress('R (phase) = ' + string(1.57/optns1/2.355,format='(F8.1)')), strcompress('R (amp) = ' + string(satamp/optns1b/2.355,format='(F8.1)')), $
   strcompress('R (combined) = ' + string(sqrt((satamp/optns1b/2.355)^2 + (1.57/optns1/2.355)^2),format='(F8.1)')), strcompress('!9D!3E (combined)' + string(sat/sqrt((satamp/optns1b/2.355)^2 + (1.57/optns1/2.355)^2),format='(F8.2)') + ' eV' )  ] 
  
endif

; output NEP in a txt file

;stop

device,/close

end