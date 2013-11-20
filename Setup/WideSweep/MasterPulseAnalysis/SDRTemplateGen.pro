; Generate Templates for SDR from phase data saved in binary format

FUNCTION TemplateDIFF, p, X=x, Y=y, ERR=err
;p[0] = rise time
;p[1] = fall time
;p[2] = time offset of peak
;p[3] = peak height
;p[4] = peak height of long pulse
;p[5] = fall time of long pulse

; CDMS: y(t) = A (1 - exp( -(t - t0)/tau ) ) (exp(-(t-t0)/kappa) - B*exp( -(t - t0)/tau )
;  f = exp((x-1250.0+p[2])/p[0])*exp(-(x-1250.0+p[2])/p[1])

   f = p[3]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[1])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) - p[4]*exp( -(x - 1250.0 + p[2])/p[5] )
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1])  +  p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) + p[4]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[5]) 

  k = where( f LT 0.0 )
  f[k]=0.0
  
  dev = y
  dev[*] = 0.0
  dev[450:850] = (y[450:850]-f[450:850])/err[450:850]
  
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

t1f = p[3]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[1]) ;- B*exp( -(t - t0)/tau )
k = where( t1f LT 0.0 )
t1f[k]=0.0
fit = t1f

end

path='/Users/bmazin/Data/Projects/PulseTaker/'
file = 'PhaseTrig.dat'

set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1
device,filename=path+'template.ps'

openr,1,path+file

N=20000
;N = long(((FILE_INFO(path+file)).size)/2002.0) - 1
print,'Reading',N,' pulses'

chan = 0
phase = intarr(1000)
data = intarr(1000)
idx = indgen(1000)
tplt = fltarr(256,1000)
pnoise = fltarr(256,400)
pnc = fltarr(256)

x = dindgen(1000)*2.0
t1 = (1.0 - exp( -(x - 1000.0)/0.1 ) ) * exp(-(x - 1000.0 )/32.0) 
t1[ where( t1 LT 0.0 ) ] = 0.0

;construct optimal filters
opt1 = FFT(t1[400:899],-1)
phi1=conj(opt1)
optnorm1c = total( abs(opt1)^2 )

; now make optimcal filter array for different pulse start times
phi1arr = dcomplexarr(41,500)
v1 = dblarr(41)
for i=-20,20 do begin
  opt1temp = FFT(shift(t1[400:899],i),-1)
  phi1arr[i+20,*] = conj(opt1temp)
endfor

for i=0L,N-1L do begin

    if( i mod 1000 EQ 0 ) then print,i,' /',N

    readu,1,chan
    readu,1,data
  
    ; subtract baseline
    result = linfit( [idx[0:400],idx[800:999]], [data[0:400],data[800:999]])
    phase = data - idx*result[1] - result[0]
    
    phase = -phase
    
    m1 = moment(phase[0:200])

    ; skip event if bad baseline sub
    if( abs(phase[0]-phase[999]) GT 10.0*sqrt(m1[1]) ) then continue
 
    ; fit over broad range of pulses for initial template fit
    ;if( max(phase) GT 50.0 AND max(phase) LT 500.0) then begin
      ; align on max
      ;ks = (where( phase EQ max(phase)))[0]
      ;ks = (where( smooth(phase,11) EQ max(smooth(phase,11))))[0]
      ;if( ks LT 450 or ks GT 549 ) then continue
      ;tplt[chan,50:849] += float(phase[ks-450:ks+450])/float(max(phase))
    ;endif

    ; construct noise
    pnoise[chan,*] += ABS(FFT(phase[0:400], -1))^2
    pnc[chan] += 1.0
    
    ; align on maximum using optimal filter time offset
     P1f = FFT(phase[400:899],-1)
     for j=0,40 do begin
      v1[j] = abs(total((phi1arr[j,*])[*]*P1f)/optnorm1c)
     endfor
     ks = (where( v1 EQ max(v1)))[0] + 480.0
     if( ks LT 485 or ks GT 515 ) then continue
     ;if( chan EQ 0 ) then print,ks
     tplt[chan,50:849] += float(phase[ks-450:ks+450])/float(max(phase))

    ;if (chan EQ 0 ) then begin
    ;  set_plot,'X'
      ;plot,smooth(phase,21)
    ;  plot,phase
    ;  ch = get_kbrd()
    ;endif

endfor
Na = 1000 
Ta = 2.0d-6
N21a = Na/2 + 1 
Fa = INDGEN(Na) 
Fa[N21a] = N21a -Na + FINDGEN(N21a-2) 
Fa = Fa/(Na*Ta) 

Nb = 800
N21b = Nb/2 + 1 
Fb = INDGEN(Nb) 
Fb[N21b] = N21b -Nb + FINDGEN(N21b-2) 
Fb = Fb/(Nb*Ta) 

for i=0L,255 do begin
  tplt[i,*] = tplt[i,*]/max(tplt[i,*])
  if( finite((tplt[i,0])[*]) EQ 0 ) then tplt[i,*] = 0.0
  pnoise[i,*]  /= pnc[i]
  pnoise[i,*] *= (2.0d-6*800.0)
  plot,idx*2.0,(tplt[i,*])[*],xr=[800,1500],/xstyle,xtitle='Time (Microseconds)'
  
  p=0
  fit=0
  TemplateFit,(tplt[i,*])[*],idx*2.0,p,fit
  oplot,idx*2.0,fit,color=100
  al_legend,/top,/right,[strcompress('Rise Time = ' + string(p[0],format='(F5.2)') + ' !9m!3s'),strcompress('QP Lifetime = ' + string(p[1],format='(F6.2)') + ' !9m!3s')]

  plot,SHIFT(Fa, -N21a), 20.0*alog10(SHIFT(ABS(FFT((tplt[i,*])[*], -1)), -N21a)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'
  OPLOT, SHIFT(Fb, -N21b), 10.0*alog10(SHIFT((pnoise[i,*])[*],-N21b)),psym=10,color=100

endfor

close,1
device,/close

; output templates and noise spectra
;openw,2,path+'Template.dat'
;for i=0,1999 do begin
;  printf,2,idx[i]*1.25,t1[i],t2[i]
;endfor
;close,2

;openw,2,path+'NoiseSpectra.dat'
;for i=0,799 do begin
;  printf,2,Fa[i],n1[i],n2[i]
;endfor
;close,2

end