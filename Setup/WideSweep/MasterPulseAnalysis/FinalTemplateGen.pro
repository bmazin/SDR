FUNCTION TemplateDIFF, p, X=x, Y=y, ERR=err
;p[0] = rise time
;p[1] = fall time
;p[2] = time offset of peak
;p[3] = peak height
;p[4] = peak height of long pulse
;p[5] = fall time of long pulse

; CDMS: y(t) = A (1 - exp( -(t - t0)/tau ) ) (exp(-(t-t0)/kappa) - B*exp( -(t - t0)/tau )
;  f = exp((x-1250.0+p[2])/p[0])*exp(-(x-1250.0+p[2])/p[1])

   f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) - p[4]*exp( -(x - 1250.0 + p[2])/p[5] )
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1])  +  p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) + p[4]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[5]) 

  k = where( f LT 0.0 )
  f[k]=0.0
  
  dev = y
  dev[*] = 0.0
  dev[900:1700] = (y[900:1700]-f[900:1700])/err[900:1700]
  
return, dev
end

; Fit a pulse or template
PRO TemplateFit,t1,idx,p,fit

x = double(idx)
y = double(t1)
err = replicate(1.0, (size(x))[1] )

parinfo = replicate({value:0.D, fixed:0, step:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 6)

;p[0] = rise time
;p[1] = fall time
;p[2] = time offset of peak
;p[3] = peak height
;p[4] = peak height of long pulse
;p[5] = fall time of long pulse

parinfo[0].value = 4.0
parinfo[0].limits  = [0.1,60.0]

parinfo[1].value = 30.0
parinfo[1].limits  = [4.0,200.0]

parinfo[2].value = 8.0
parinfo[2].limits  = [0.0,100.0]

parinfo[3].value = 1.0
parinfo[3].limits  = [0.1,4.0]

parinfo[4].value = 30.0
parinfo[4].limits  = [0.1,90.0]
parinfo[4].fixed=1

parinfo[5].value = 100.0
parinfo[5].limits  = [60.0,2000.0]
parinfo[5].fixed=1

; Do the optimization
fa1 = {X:x, Y:y, ERR:err}
bestnorm=0.0
covar=0.0
perror=0.0

p = mpfit('TemplateDIFF',functargs=fa1,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-18,XTOL=1D-18,GTOL=1D-18,FASTNORM=0,STATUS=status,/QUIET)
;print,'Status of Fit= ',status
;print,bestnorm
DOF     = N_ELEMENTS(X)*2.0 - N_ELEMENTS(PARMS) ; deg of freedom
PCERROR = PERROR * SQRT(BESTNORM / DOF)   ; scaled uncertainties

t1f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) ;- B*exp( -(t - t0)/tau )
k = where( t1f LT 0.0 )
t1f[k]=0.0
fit = t1f

end

PRO FinalTemplateGen,datapath,outpath,pulsename,StartT,atten,res,pm,life

path=datapath
iqsweep = strcompress(path+string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
maincap = path+pulsename
fitdata = path+'Series-ps.dat'

; load first pass template
dat = read_ascii(path+'Template.dat')
dat = dat.field1 
idx = (dat[0,*])[*]
t1 = (dat[1,*])[*]
t2 = (dat[2,*])[*]

dat = read_ascii(path+'NoiseSpectra.dat')
dat = dat.field1 
Fa = (dat[0,0:799])[*]
n1 = (dat[1,0:799])[*]
n2 = (dat[2,0:799])[*]

ch1nc = n1
ch2nc = n2

; rebin noise
N = 800 
T = 1.25d-6
N21 = N/2 + 1 
F = INDGEN(N) 
F[N21] = N21 -N + FINDGEN(N21-2) 
F = (F/(N*T))[0:399] 

;construct optimal filters
opt1 = FFT(t1[900:1700],-1)
opt2 = FFT(t2[900:1700],-1)
phi1=conj(opt1)/ch1nc
phi2=conj(opt2)/ch2nc
optnorm1c = total( abs(opt1)^2/ch1nc  )
optnorm2c = total( abs(opt2)^2/ch2nc  )

; now make optimcal filter array for different pulse start times
phi1arr = dcomplexarr(41,800)
phi2arr = dcomplexarr(41,800)
v1 = dblarr(41)
v2 = dblarr(41)
for i=-20,20 do begin
  opt1temp = FFT(shift(t1[900:1700],i),-1)
  opt2temp = FFT(shift(t2[900:1700],i),-1)
  phi1arr[i+20,*] = conj(opt1temp)/ch1nc
  phi2arr[i+20,*] = conj(opt2temp)/ch2nc  
endfor

f1 = 0.0d
f2 = 0.0d
ttime = 0.0d
Izero1 = 0.0d
Izsd1 = 0.0d
Qzero1 = 0.0d
Qzsd1 = 0.0d
Izero2 = 0.0d
Izsd2 = 0.0d
Qzero2 = 0.0d
Qzsd2 = 0.0d
Ts = 0.0d

; load up IQ sweeps
openr,1,iqsweep
readf,1,fstart1,fend1,fsteps1,atten1
readf,1,fstart2,fend2,fsteps2,atten2
readf,1,Tstart,Tend
readf,1,Iz1,Izsd1
readf,1,Qz1,Qzsd1
readf,1,Iz2,Izsd2
readf,1,Qz2,Qzsd2
data = dblarr(5,1000)
readf,1,data
close,1

fitdat = read_ascii(fitdata)
fitdat = fitdat.field01

device,filename=path+'template-secondpass.ps'
loadct,4
!p.multi=[0,1,2]

openr,1,maincap
header = dblarr(14)
readu,1,header

;N = 2000L
N = long(((FILE_INFO(maincap)).size-14.0*4.0)/16000.0) - 2
print,'Reading',N,' pulses'

ch1 = dblarr(N)
ch2 = dblarr(N)
ch1[*] = 0.0
ch2[*] = 0.0

Ix1 = intarr(2000)
Qx1 = intarr(2000)
Ix2 = intarr(2000)
Qx2 = intarr(2000)

;plot,data[1,1:499],data[3,1:499],/ynozero,/xstyle,psym=3
xc1 = fitdat[16,0] + Iz1
yc1 = fitdat[17,0] + Qz1
;plots,xc1,yc1,psym=1
readu,1,Ix1
readu,1,Qx1
readu,1,Ix2
readu,1,Qx2
readu,1,Ix1
readu,1,Qx1
readu,1,Ix2
readu,1,Qx2
Ix1d = (double(Ix1)/32767.0)*0.2
Qx1d = (double(Qx1)/32767.0)*0.2
Ix2d = (double(Ix2)/32767.0)*0.2
Qx2d = (double(Qx2)/32767.0)*0.2
;oplot,Ix1d,Qx1d,psym=3

;plot,data[1,500:999 ],data[3,500:999],/ynozero,/xstyle,psym=3
xc2 = fitdat[16,1] + Iz2
yc2 = fitdat[17,1] + Qz2
;plots,xc2,yc2,psym=1
;oplot,Ix2d,Qx2d,psym=3

!p.multi=[0,2,3]
;plot,ch1,ch2,psym=3,/xstyle,/ystyle,xr=[0,pm[0]*2.0],yr=[0,pm[2]*2.0],title='Pulse Height (degrees) Ch1 vs Ch2',/nodata
idx = dindgen(2000)
t1 = dblarr(2000)
t2 = dblarr(2000)
t1i = dblarr(2000)
t1q = dblarr(2000)
t2i = dblarr(2000)
t2q = dblarr(2000)
t1[*] = 0.0
t2[*] = 0.0
t1i[*] = 0.0
t1q[*] = 0.0
t2i[*] = 0.0
t2q[*] = 0.0
n1 = dblarr(900)
n2 = dblarr(900)
na1 = dblarr(900)
na2 = dblarr(900)
n1[*] = 0.0
n2[*] = 0.0
na1[*] = 0.0
na2[*] = 0.0
sig1 = 0.0d
sig2 = 0.0d

n1c=0.0d
n1d=0.0d
n2c=0.0d
n2d=0.0d

count1 = 0
count2 = 0

for i=0L,N-1L do begin
    readu,1,Ix1
    readu,1,Qx1
    readu,1,Ix2
    readu,1,Qx2
    Ix1d = (double(Ix1)/32767.0)*0.2
    Qx1d = (double(Qx1)/32767.0)*0.2
    Ix2d = (double(Ix2)/32767.0)*0.2
    Qx2d = (double(Qx2)/32767.0)*0.2
    
    if( i mod 1000 EQ 0 ) then print,i,' /',N
    
    ; reference all pulses to first pulse zero
    if( i EQ 0 ) then begin
      Ix1m = mean([Ix1d[1:900],Ix1d[1900:1999]])
      Qx1m = mean([Qx1d[1:900],Qx1d[1900:1999]])
      Ix2m = mean([Ix2d[1:900],Ix2d[1900:1999]])
      Qx2m = mean([Qx2d[1:900],Qx2d[1900:1999]])  
      rad1 = sqrt( double(Qx1m-yc1)^2 + double(Ix1m-xc1)^2 ) 
      rad2 = sqrt( double(Qx2m-yc2)^2 + double(Ix2m-xc2)^2 ) 
      
          ;r1 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix1d[0:900],Ix1d[1850:1999]],2)
          ;r2 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx1d[0:900],Qx1d[1850:1999]],2)
          ;r3 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix2d[0:900],Ix2d[1850:1999]],2)
          ;r4 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx2d[0:900],Qx2d[1850:1999]],2)
          ;Ix1m = (idx[1000]*idx[1000]*r1[2] + idx[1000]*r1[1] + r1[0])
          ;Qx1m = (idx[1000]*idx[1000]*r2[2] + idx[1000]*r2[1] + r2[0])
          ;Ix2m = (idx[1000]*idx[1000]*r3[2] + idx[1000]*r3[1] + r3[0])
          ;Qx2m = (idx[1000]*idx[1000]*r4[2] + idx[1000]*r4[1] + r4[0])    
    endif
    ;Ix1d = Ix1d + (Ix1m - mean(Ix1d[1:900]))
    ;Qx1d = Qx1d + (Qx1m - mean(Qx1d[1:900]))
    ;Ix2d = Ix2d + (Ix2m - mean(Ix2d[1:900]))
    ;Qx2d = Qx2d + (Qx2m - mean(Qx2d[1:900]))
    
    ; LINEAR FIT : do a better job removing the baselines and centering pulses
    r1 = linfit( [idx[0:900],idx[1850:1999]], [Ix1d[0:900],Ix1d[1850:1999]])
    r2 = linfit( [idx[0:900],idx[1850:1999]], [Qx1d[0:900],Qx1d[1850:1999]])
    r3 = linfit( [idx[0:900],idx[1850:1999]], [Ix2d[0:900],Ix2d[1850:1999]])
    r4 = linfit( [idx[0:900],idx[1850:1999]], [Qx2d[0:900],Qx2d[1850:1999]])
    Ix1d = Ix1d + (Ix1m - (idx*r1[1] + r1[0]))
    Qx1d = Qx1d + (Qx1m - (idx*r2[1] + r2[0]))
    Ix2d = Ix2d + (Ix2m - (idx*r3[1] + r3[0]))
    Qx2d = Qx2d + (Qx2m - (idx*r4[1] + r4[0]))

    ; 2nd order FIT : do a better job removing the baselines and centering pulses
    ;r1 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix1d[0:900],Ix1d[1850:1999]],2)
    ;r2 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx1d[0:900],Qx1d[1850:1999]],2)
    ;r3 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix2d[0:900],Ix2d[1850:1999]],2)
    ;r4 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx2d[0:900],Qx2d[1850:1999]],2)
    ;Ix1d = Ix1d + (Ix1m - (idx*idx*r1[2] + idx*r1[1] + r1[0]))
    ;Qx1d = Qx1d + (Qx1m - (idx*idx*r2[2] + idx*r2[1] + r2[0]))
    ;Ix2d = Ix2d + (Ix2m - (idx*idx*r3[2] + idx*r3[1] + r3[0]))
    ;Qx2d = Qx2d + (Qx2m - (idx*idx*r4[2] + idx*r4[1] + r4[0]))

    ; transform to phase
    P1 = atan( double(Qx1d-yc1), double(Ix1d-xc1) )
    P2 = atan( double(Qx2d-yc2), double(Ix2d-xc2) )
    m1 = moment(P1[0:200])
    m2 = moment(P2[0:200])
    
    P1 = fixang(P1,/RADIANS)
    P2 = fixang(P2,/RADIANS)
    
    ; amplitude pulses
    A1 = sqrt( double(Qx1d-yc1)^2 + double(Ix1d-xc1)^2 ) / rad1
    A2 = sqrt( double(Qx2d-yc2)^2 + double(Ix2d-xc2)^2 ) / rad2

    ; subtract baseline
    result = linfit( [idx[0:800],idx[1900:1999]], [P1[0:800],P1[1900:1999]])
    P1 = P1 - idx*result[1] - result[0]
    result = linfit( [idx[0:800],idx[1900:1999]], [P2[0:800],P2[1900:1999]])
    P2 = P2 - idx*result[1] - result[0]

    ; subtract amplitude baseline
    result = linfit( [idx[0:800],idx[1900:1999]], [A1[0:800],A1[1900:1999]])
    A1 = A1 - idx*result[1] - result[0]
    result = linfit( [idx[0:800],idx[1900:1999]], [A2[0:800],A2[1900:1999]])
    A2 = A2 - idx*result[1] - result[0]

    P1 = -P1
    P2 = -P2
    
    A1 = -A1
    A2 = -A2    
 
    if( i EQ 0 ) then begin  ; set up derivatives for intro pulse detection
        d1sd = sqrt((moment(smooth(deriv(P1[0:800]),11,/EDGE_TRUNCATE)))[1])       
        d2sd = sqrt((moment(smooth(deriv(P2[0:800]),11,/EDGE_TRUNCATE)))[1])           
    endif
    d1 = smooth(deriv(P1),11,/EDGE_TRUNCATE)        
    d2 = smooth(deriv(P2),11,/EDGE_TRUNCATE)
  
    sig1 += sqrt((moment(P1[0:799]))[1])
    sig2 += sqrt((moment(P2[0:799]))[1])
  
    ; skip event if bad baseline sub
    if( abs(P1[0]-P1[1999]) GT 10.0*sqrt(m1[1]) ) then continue
    if( abs(P2[0]-P2[1999]) GT 10.0*sqrt(m2[1]) ) then continue

    ch1[i] = max(P1[900:1100]*180.0/!Pi)
    ch2[i] = max(P2[900:1100]*180.0/!Pi)
    
    ;plots,ch1[i],ch2[i],psym=3
    
    min1 = pm[0]-pm[1]
    if( min1 LT 2.0 ) then min1=10.0
    
    min2 = pm[2]-pm[3]
    if( min2 LT 2.2 ) then min1=3.0    
    
    if( max(P1[980:1020]*180.0/!Pi) GT min1 AND max(P1[980:1020]*180.0/!Pi) LT (pm[0]+pm[1])) then begin
    ;if( max(P1[980:1020]*180.0/!Pi) GT 30.0 AND max(P2[980:1020]*180.0/!Pi) GT 30.0) then begin
      ; align on maximum using optimal filter time offset
       P1f = FFT(P1[900:1700],-1)
       for j=0,40 do begin
         v1[j] = abs(total((phi1arr[j,*])[*]*P1f)*180.0/(optnorm1c*!Pi))
       endfor
       ks = (where( v1 EQ max(v1)))[0] + 980.0
       if( ks LT 981 or ks GT 1019 ) then continue
       ;if( P1[ks] GT P1[ks+20]*2.0 ) then continue

       t1[20:1980] += P1[ks-980:ks+980]/max(v1)
       
       ; compute template in I and Q
       t1i[20:1980] =  t1i[20:1980] + Ix1d[ks-980:ks+980]
       t1q[20:1980] =  t1q[20:1980] + Qx1d[ks-980:ks+980] 
       n2c += 1.0

    endif

    if( max(P2[980:1020]*180.0/!Pi) GT min2 AND max(P2[980:1020]*180.0/!Pi) LT (pm[2]+pm[3]) ) then begin
    ;if( max(P1[980:1020]*180.0/!Pi) GT 30.0 AND max(P2[980:1020]*180.0/!Pi) GT 30.0) then begin
       ; align on maximum using optimal filter time offset
       P2f = FFT(P2[900:1700],-1)
       for j=0,40 do begin
        v2[j] = abs(total((phi2arr[j,*])[*]*P2f)*180.0/(optnorm2c*!Pi))
       endfor
       ks = (where( v2 EQ max(v2)))[0] + 980.0
       if( ks LT 981 or ks GT 1019 ) then continue
       ;if( P2[ks] GT P2[ks+20]*2.0 ) then continue
       t2[20:1980] += P2[ks-980:ks+980]/max(v2)
       
       ; compute template in I and Q
       t2i[20:1980] =  t2i[20:1980] + Ix2d[ks-980:ks+980]
       t2q[20:1980] =  t2q[20:1980] + Qx2d[ks-980:ks+980] 
       n2d += 1.0    
    endif
    
    ; construct noise, but try to eliminate data that has photons    
    if( max(d1[20:970]) LT d1sd*4.0 ) then begin
      n1 += ABS(FFT(P1[0:799], -1))^2
      na1 += ABS(FFT(A1[0:799], -1))^2
      n1c += 1.0             
    endif
      
    if( max(d2[20:970]) LT d2sd*4.0  ) then begin 
      n2 += ABS(FFT(P2[0:799], -1))^2   
      na2 += ABS(FFT(A2[0:799], -1))^2 
      n1d += 1.0
      ;if( max(P2[980:1020]*180.0/!Pi) GT 60.0 ) then stop
    endif
    
    ; plot up some normal pulses
    if( count1 LE 8 AND max(P1*180.0/!Pi) GT pm[0] AND max(P1*180.0/!Pi) LT (pm[0]+pm[1])) then begin
      plot,dindgen(801)*1.25 - 125.0,P1[900:1700]*180.0/!Pi,title='Resonator 1',xtitle='Microseconds'
      count1++
      
      ; output to file for plotting
      openw,3,outpath+'phasepulses.txt',/APPEND
      for k=0,799 do printf,3,P1[900+k]*180.0/!Pi
      close,3
      
    endif
    
    if( count2 LE 8 AND max(P2*180.0/!Pi) GT pm[2] AND max(P2*180.0/!Pi) LT (pm[2]+pm[3]) ) then begin
      plot,dindgen(801)*1.25 - 125.0,P2[900:1700]*180.0/!Pi,title='Resonator 2',xtitle='Microseconds',color=150
      count2++
    endif
   
endfor

t1 = t1/max(t1)
t2 = t2/max(t2)

t1i = t1i/n2c
t1q = t1q/n2c

t2i = t2i/n2d
t2q = t2q/n2d

t1[0:50] = 0.0
t1[1950:1999]=0.0

t2[0:50] = 0.0
t2[1950:1999]=0.0

n1  /= n1c
n2  /= n1d
na1  /= n1c
na2  /= n1d

sig1 /= N
sig2 /= N

; normalize FFT
n1 *= (1.25d-6*800.0)
n2 *= (1.25d-6*800.0)
na1 *= (1.25d-6*800.0)
na2 *= (1.25d-6*800.0)

;n1[0] = 2.0*n1[1]
;n2[0] = 2.0*n2[1]
;n1[0] = n1[1]
;n2[0] = n2[1]

A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A)

TemplateFit,t1,idx*1.25,p,fit
!p.multi=[0,1,2]
plot,idx*1.25,t1,xr=[0,2500],/xstyle,title='Ch1 Final Template',xtitle='Time (microseconds)',psym=8,symsize=.3
oplot,idx*1.25,fit,color=100
al_legend,/top,/right,[strcompress('Rise Time = ' + string(p[0],format='(F5.2)') + ' !9m!3s'),strcompress('QP Lifetime = ' + string(p[1],format='(F6.2)') + ' !9m!3s')]
life[0] = p[0]
life[1] = p[1]

TemplateFit,t2,idx*1.25,p,fit
plot,idx*1.25,t2,xr=[0,2500],/xstyle,title='Ch2 Final Template',xtitle='Time (microseconds)',psym=8,symsize=.3
oplot,idx*1.25,fit,color=100
al_legend,/top,/right,[strcompress('Rise Time = ' + string(p[0],format='(F5.2)') + ' !9m!3s'),strcompress('QP Lifetime = ' + string(p[1],format='(F6.2)') + ' !9m!3s')]
life[2] = p[0]
life[3] = p[1]

N = 2000 
T = 1.25d-6
N21 = N/2 + 1 
F = INDGEN(N) 
F[N21] = N21 -N + FINDGEN(N21-2) 
F = F/(N*T) 

PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t1, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)',title='Final Noise Spectra'

Na = 800
N21a = Na/2 + 1 
Fa = INDGEN(Na) 
Fa[N21a] = N21a -Na + FINDGEN(N21a-2) 
Fa = Fa/(Na*T) 

OPLOT, SHIFT(Fa, -N21a), 10.0*alog10(SHIFT(n1,-N21a)),psym=10,color=100


PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t2, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'

OPLOT, SHIFT(Fa, -N21a), 10.0*alog10(SHIFT(n2,-N21a)),psym=10,color=100

close,1

; output templates and noise spectra
openw,2,path+'Template-2pass.dat'
for i=0,1999 do begin
  printf,2,idx[i]*1.25,t1[i],t2[i]
endfor
close,2

t1i[0:20] = t1i[21:41]
t1i[1979:1999] = t1i[1958:1978]
t2i[0:20] = t2i[21:41]
t2i[1979:1999] = t2i[1958:1978]

t1q[0:20] = t1q[21:41]
t1q[1979:1999] = t1q[1958:1978]
t2q[0:20] = t2q[21:41]
t2q[1979:1999] = t2q[1958:1978]

openw,2,path+'Template-iq.dat'
for i=0,1999 do begin
  printf,2,idx[i]*1.25,t1i[i],t1q[i],t2i[i],t2q[i]
endfor
close,2

openw,2,path+'NoiseSpectra-2pass.dat'
for i=0,799 do begin
  printf,2,Fa[i],n1[i],n2[i],na1[i],na2[i]
endfor
close,2

device,/close

end