; noise analysis

; rebin function y from index x to idx by averaging the data
function BenRebin, y, x, idx

  k = n_elements(x)
  k1 = n_elements(idx)
  
  n = dblarr(k)
  n[*] = 0.0
  n[0] = y[0]
  n[k1-1] = y[k-1] 

  for i=1,k1-2 do begin
  
    ; average value of y around the idx[i]
    mini = idx[i] - (idx[i] - idx[i-1])/2.0
    maxi = idx[i] + (idx[i+1] - idx[i])/2.0
  
  
    minidx = where( mini GT x )
    o = n_elements(minidx)
    minidx=minidx[o-1]
    maxidx = (where( maxi LT x ))[0]
    
    if( maxidx - minidx EQ 0 ) then continue
  
    if( maxidx - minidx LE 3 ) then begin 
      n[i] = interpol(y,x,idx[i])
    endif
    
    if( maxidx - minidx GT 3 ) then n[i] = mean( y[minidx:maxidx],/double)
    
    ;if( i EQ 900 ) then stop
      
  endfor
 
  return, n
end

function welch, m
;
;       Construct Welch window of length M
;
welch = fltarr(m)
m2 = m / 2
for i = 0L, m-1 do welch[i] = 1. - ((i - m2)/float(m2))^2
;
return, welch
end
;
;----------------------------------------------------------------------------
;
pro pwelch, x, psd, m, freq, dt
;
; Calculates the PSD of timeseries x using Welch's method
; using overlapping (50%) windows of length M.
; M should be even.
; FREQ is array of sampled frequencies assuming unit timestep
;
nt = n_elements(x)
m2 = m / 2
if ( m NE 2*m2) then begin
  print,'Odd Interval Length: M = ',m
  m = 2*m2
  print,'             Using M-1 = ',m
endif
;
;dt = 1.
df = 1./ (m * dt)
freq = findgen(m2+1) * df
;
k2 = nt / m2    ; number of half-intervals - drop trailing elements
k  = k2 - 1   ; number of (50% overlap) intervals of length m
;
;     Choose Window
;window = 1. + fltarr(m)
window  = welch(m)
win_norm = total(window^2)*m
;
psd_sum = fltarr(m2+1)
pk      = fltarr(m2+1)
;
for ik = 0L, k-1 do begin
  n0 = ik * m2
  n1 = n0 + m - 1
  xk = x[n0:n1] * window
  sk = fft(xk,/inverse)
  pk[0]      = abs(sk[0])^2
  pk[1:m2-1] = abs(sk[1:m2-1])^2 * 2.
  pk[m2]     = abs(sk[m2])^2
  psd_sum = psd_sum + pk
endfor
;
; Normalize
norm = float(k) * win_norm
psd = psd_sum / norm
;
end

Function correl, x, y
   RETURN, FFT( FFT(x,-1) * CONJ(FFT(y,-1)), 1)
END


function NoiseAna,datasel,noisefile,z,r,data,loss

; make sure noise file is present and check size
if( (FILE_INFO(noisefile)).exists EQ 0 ) then return,-1
len = long((FILE_INFO(noisefile)).size - 14.0*4)

print,'Noise file contains ',len/8.0,' samples'

fres1 = 0.0d
fres2 = 0.0d
ttime = 0.0d
Ts = 0.0d
sampr = 0.0d
decim = 0.0d
Izero1 = 0.0d
Izsd1 = 0.0d
Qzero1 = 0.0d
Qzsd1 = 0.0d
Izero2 = 0.0d
Izsd2 = 0.0d
Qzero2 = 0.0d
Qzsd2 = 0.0d


openr,1,noisefile
readu,1,fres1
readu,1,fres2
readu,1,ttime
readu,1,Ts
readu,1,sampr
readu,1,decim
readu,1,Qzero1
readu,1,Qzsd1
readu,1,Izero2
readu,1,Izsd2
readu,1,Qzero2
readu,1,Qzsd2

Ns = 200000L
Ix1 = fltarr(Ns*10L)
Qx1 = fltarr(Ns*10L)
Ix2 = fltarr(Ns*10L)
Qx2 = fltarr(Ns*10L)
dum = intarr(Ns)

for l=0l,9l do begin
  readu,1,dum
  Ix1[l*Ns:l*Ns+Ns-1] = dum*0.2/32767.0
  readu,1,dum
  Qx1[l*Ns:l*Ns+Ns-1] = dum*0.2/32767.0
  readu,1,dum
  Ix2[l*Ns:l*Ns+Ns-1] = dum*0.2/32767.0
  readu,1,dum
  Qx2[l*Ns:l*Ns+Ns-1] = dum*0.2/32767.0
endfor
dum=0

if (datasel EQ 1 ) then begin
Ix1 = Ix2
Qx1 = Qx2
endif
Ix2=0
Qx2=0

close,1

; [radius,p[8],p[9],Izero,Qzero,p[0],Qc,Qi,p[1],atten]
Q=r[5]
Qc=r[6]
Qi=r[7]
f0=r[8]
atten=r[9]

Ix1 = Ix1 - r[3]
Qx1 = Qx1 - r[4]

;set_plot,'X'
;!p.multi=0
;plot,Ix1[0:10000],Qx1[0:10000],psym=3,/xstyle,/ystyle,xr=[-.05,.05],yr=[-.05,.05]
;plots,r[1],r[2],psym=1
;plots,0,0,psym=4
;oplot,data[1,*]-r[3],data[3,*]-r[4]

Ix1 = Ix1 - r[1]
Qx1 = Qx1 - r[2]

resang = atan(mean(Qx1), mean(Ix1) )

nI = (Ix1*cos(resang) + Qx1*sin(resang))
nQ = (-Ix1*sin(resang) + Qx1*cos(resang))

rad = mean(nI)
nI = nI/rad
nQ = nQ/rad
Ix1 = Ix1/rad
Qx1 = Qx1/rad

N = Ns*10L      ;Define the interval.
T=5d-6
N21 = N/2 + 1   ;Midpoint+1 is the most negative frequency subscript.
F = LINDGEN(N)  ;The array of subscripts.
F[N21] = N21 -N + FINDGEN(N21-2)    ;Insert negative frequencies in elements F(N/2 +1), ..., F(N-1).
F = F/(N*T) ;Compute T0 frequency.
wf =1.0
norm = N*T
;NsI1 = FFT( wf*nI, -1)
;AmpNoise = ABS(NsI1)^2*norm
;NsQ1 = FFT( wf*nQ, -1)
;PhaseNoise = ABS(NsQ1)^2*norm


N = Ns*10L      ;Define the interval.
T=5d-6

; now bin 10 times
Na = N/10.0
N21a = Na/2 + 1 ;Midpoint+1 is the most negative frequency subscript.
Fa = LINDGEN(Na)    ;The array of subscripts.
Fa[N21a] = N21a -Na + FINDGEN(N21a-2)   ;Insert negative frequencies in elements F(N/2 +1), ..., F(N-1).
Fa = Fa/(Na*T)  ;Compute T0 frequency.
aveI = dblarr(Na)
aveI[*] = 0.0
aveQ = dblarr(Na)
aveQ[*] = 0.0
;wf = welch(Na)
wf=1.0

for j=0,18 do begin
    ;aveI = aveI + ABS(FFT(wf*nI[Na*j/2:Na*(j+2)/2-1], -1))^2
    ;aveQ = aveQ + ABS(FFT(wf*nQ[Na*j/2:Na*(j+2)/2-1], -1))^2
end
aveI = aveI / 19.0
aveQ = aveQ / 19.0

sz = (size(aveI))[1]

;norm = total(wf^2)/Na
norm=1.0

spec1a = aveI/norm
spec1ph = aveQ/norm

Pn = spec1ph[1:1e5-1]
An = spec1a[1:1e5-1]

;Fn1 = Fa[1:1e5-1]
;Fn2 = Fa[1:1e5-1]
;err = spec1ph[1:1e5-1]/10.0
;LOGREBIN,Fn1,Pn,err,1,1000,DlogX
;LOGREBIN,Fn2,An,err,1,1000,DlogX

; try my own log rebin
dlx = (alog10(1e5)-alog10(1.0))/1000.0
idx =10.0^(alog10(1.0) + dindgen(1000)*dlx)
NewPn = BenRebin(spec1ph[1:1e5-1], Fa[1:1e5-1], idx)
NewAn = BenRebin(spec1a[1:1e5-1], Fa[1:1e5-1], idx)

;************************  Now try the Jiansong way
Pii = dblarr(Na)
Pii[*] = 0.0
Pqi = dblarr(Na)
Pqi[*] = 0.0
Piq = dblarr(Na)
Piq[*] = 0.0
Pqq = dblarr(Na)
Pqq[*] = 0.0

; filter pulses out from noise data
mi = moment(Ix1[0:10000])
meani = mi[0]
sigi = sqrt(mi[1])

mq = moment(Qx1[0:10000])
meanq = mq[0]
sigq = sqrt(mq[1])

for j=0L,1999899L do begin
  if( abs( Ix1[j] - meani) GT 5.0*sigi OR abs( Qx1[j] - meanq) GT 5.0*sigq  ) then begin
    if ( j-200 LE 0 OR j + 100 GE 1999899L) then continue
    Ix1[j-20:j+100] = Ix1[j-200:j-80]
    Qx1[j-20:j+100] = Qx1[j-200:j-80]    
    j+=100  
  endif
end

for j=0,18 do begin
    Pii = Pii + double( FFT(wf*Ix1[Na*j/2:Na*(j+2)/2-1], -1) * conj(FFT(wf*Ix1[Na*j/2:Na*(j+2)/2-1], -1)) )
    Piq = Piq + double( FFT(wf*Ix1[Na*j/2:Na*(j+2)/2-1], -1) * conj(FFT(wf*Qx1[Na*j/2:Na*(j+2)/2-1], -1)) )
    ;Pqi = Pqi + double( FFT(wf*Qx1[Na*j/2:Na*(j+2)/2-1], -1) * conj(FFT(wf*Ix1[Na*j/2:Na*(j+2)/2-1], -1)) )
    Pqq = Pqq + double( FFT(wf*Qx1[Na*j/2:Na*(j+2)/2-1], -1) * conj(FFT(wf*Qx1[Na*j/2:Na*(j+2)/2-1], -1)) )
end
Pii = Pii / 19.0
Piq = Piq / 19.0
Pqi = Piq 
Pqq = Pqq / 19.0

Pii = Pii[1:1e5-1]
Piq = Piq[1:1e5-1]
Pqi = Pqi[1:1e5-1]
Pqq = Pqq[1:1e5-1]

sz = n_elements(Pii)-1

NewPn1 = dblarr(sz+1)
NewAn1 = dblarr(sz+1)

for j=0L,sz do begin
  a = Pii[j]
  b = Piq[j]
  c = Pqi[j]
  d = Pqq[j]
  NewPn1[j] = (a+d)/2.0 + sqrt( 4.0*b*c + (a-d)^2)/2.0 ; eigenvalue 1
  NewAn1[j] = (a+d)/2.0 - sqrt( 4.0*b*c + (a-d)^2)/2.0 ; eigenvalue 2
endfor

NewPn2 = BenRebin(NewPn1, Fa[1:1e5-1], idx)
NewAn2 = BenRebin(NewAn1, Fa[1:1e5-1], idx)

; output data

;set_plot,'X'
;device,/decompose
;!p.multi=0
;plot,Fa,spec1ph,/xlog,/ylog,psym=10,yr=[1e-10,1e-4],xr=[1.0,1e5]
;oplot,Fn2,An,color=100
;oplot,FN1,PN,color=200

; plot phase noise
plot,idx,10.0*alog10(NewPn2),/xlog,psym=10,yr=[-120,-40],xr=[1.0,1e5],xtitle='Frequency (Hz)',ytitle='Phase Noise (dBc/Hz)'
oplot,idx,10.0*alog10(NewAn2),color=100
;oplot,idx,10.0*alog10(NewPn2),color=100
;oplot,idx,10.0*alog10(NewAn2),color=150
al_legend,/top,/right,['Phase Noise','Amplitude Noise'],color=['0','100'],line=[0,0]

; frequency noise
;NewFn = NewPn/(16.0*Q^2)
NewFn2 = NewPn2/(16.0*Q^2)
pow = 10.0^((-atten-loss)/10.0)
Pint = 10.0*alog10((2.0 * Q^2/(!Pi * Qc))*pow)

yf=0
res = linfit(idx[590:610],NewFn2[590:610],yfit=yf)
fn1000 = yf[10]

plot,idx,NewFn2,/xlog,/ylog,psym=10,xr=[1.0,1e5],yr=[1d-21,1d-14],xtitle='Frequency (Hz)',ytitle='Frequency Noise (1/Hz)',title=strcompress('S!Lf!N @ 1 kHz = ' + string(fn1000) + ', P!Lint!N = ' + string(Pint) + ' dBm' )
;oplot,idx,NewFn2,color=150

oplot,idx[590:610],yf,line=1,color=100
plots,idx[600],fn1000,psym=1,color=200

newname = strcompress((strsplit(noisefile,'.',/extract))[0] + '-' +string(datasel+1) +  '.psd',/remove_all)
openw,3,newname
for j=0,(size(idx))[1]-1 do begin
  printf,3,idx[j],NewPn2[j],NewAn2[j],NewFn2[j]
endfor
close,3

return,fn1000

end