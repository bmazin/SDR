FUNCTION QuickTemplateGen,datapath,outpath,pulsename,StartT,atten,res

path=datapath
iqsweep = strcompress(path+string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
maincap = path+pulsename
fitdata = path+'Series-ps.dat'

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

device,filename=outpath+'template.ps'
loadct,4
!p.multi=[0,1,2]

openr,1,maincap
header = dblarr(14)
readu,1,header

;N=2000
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

plot,data[1,1:499],data[3,1:499],/ynozero,/xstyle,psym=3
xc1 = fitdat[16,0] + Iz1
yc1 = fitdat[17,0] + Qz1
plots,xc1,yc1,psym=1
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
oplot,Ix1d,Qx1d,psym=3
;ch = get_kbrd(1)

plot,data[1,500:999 ],data[3,500:999],/ynozero,/xstyle,psym=3
xc2 = fitdat[16,1] + Iz2
yc2 = fitdat[17,1] + Qz2
plots,xc2,yc2,psym=1
oplot,Ix2d,Qx2d,psym=3
;ch = get_kbrd(1)

!p.multi=[0,1,1]
;plot,ch1,ch2,psym=3,/xstyle,/ystyle,xr=[0,Pmax],yr=[0,Pmax],title='Pulse Height (degrees) Ch1 vs Ch2',/nodata
;oplot,pred[0,8:90],pred[1,8:90],line=0,color=150
;plots,[6.2,63.5],[52.0,7.2],line=0
idx = dindgen(2000)
t1 = dblarr(2000)
t2 = dblarr(2000)
t1[*] = 0.0
t2[*] = 0.0
n1 = dblarr(900)
n2 = dblarr(900)
n1[*] = 0.0
n2[*] = 0.0
sig1 = 0.0d
sig2 = 0.0d

n1c=0.0d
n2c=0.0d

for i=0L,N-1L do begin
    readu,1,Ix1
    readu,1,Qx1
    readu,1,Ix2
    readu,1,Qx2
    Ix1d = (double(Ix1)/32767.0)*0.2
    Qx1d = (double(Qx1)/32767.0)*0.2
    Ix2d = (double(Ix2)/32767.0)*0.2
    Qx2d = (double(Qx2)/32767.0)*0.2
       
    ; reference all pulses to first pulse zero
    if( i EQ 0 ) then begin
      Ix1m = mean([Ix1d[1:900],Ix1d[1800:1999]])
      Qx1m = mean([Qx1d[1:900],Qx1d[1800:1999]])
      Ix2m = mean([Ix2d[1:900],Ix2d[1800:1999]])
      Qx2m = mean([Qx2d[1:900],Qx2d[1800:1999]])      
    endif
    Ix1d = Ix1d + (Ix1m - mean(Ix1d[1:900]))
    Qx1d = Qx1d + (Qx1m - mean(Qx1d[1:900]))
    Ix2d = Ix2d + (Ix2m - mean(Ix2d[1:900]))
    Qx2d = Qx2d + (Qx2m - mean(Qx2d[1:900]))

    ; transform to phase
    P1 = atan( double(Qx1d-yc1), double(Ix1d-xc1) )
    P2 = atan( double(Qx2d-yc2), double(Ix2d-xc2) )
    
    P1 = fixang(P1,/RADIANS)
    P2 = fixang(P2,/RADIANS)

    ; subtract baseline
    result = linfit( [idx[0:800],idx[1800:1999]], [P1[0:800],P1[1800:1999]])
    P1 = P1 - idx*result[1] - result[0]
    result = linfit( [idx[0:800],idx[1800:1999]], [P2[0:800],P2[1800:1999]])
    P2 = P2 - idx*result[1] - result[0]

    P1 = -P1
    P2 = -P2

    m1 = moment(P1[0:200])
    m2 = moment(P2[0:200])

    sig1 += sqrt((moment(P1[0:799]))[1])
    sig2 += sqrt((moment(P2[0:799]))[1])
  
    ; skip event if bad baseline sub
    if( abs(P1[0]-P1[1999]) GT 10.0*sqrt(m1[1]) ) then continue
    if( abs(P2[0]-P2[1999]) GT 10.0*sqrt(m2[1]) ) then continue

    ch1[i] = max(P1[900:1100]*180.0/!Pi)
    ch2[i] = max(P2[900:1100]*180.0/!Pi)

    ; skip double pulse events
    ;d1 = smooth(deriv(P1),11,/EDGE_TRUNCATE)
    ;if( max(d1[20:970]) GT 0.8 ) then continue
    ;if( max(d1[1050:1980]) GT 0.8 ) then continue
 
    ; fit over broad range of pulses for initial template fit
    if( max(P1) GT 10.0*!Pi/180.0 AND max(P1) LT 120.0*!Pi/180.0) then begin
      ; align on max
      ks = (where( P1 EQ max(P1)))[0]
      if( ks LT 900 or ks GT 1100 ) then continue
      t1[500:1800] += P1[ks-500:ks+800]/max(P1)
    endif

   if( max(P2) GT 10.0*!Pi/180.0 AND  max(P2) LT 120.0*!Pi/180.0) then begin
      ;t2 += P2/max(P2)
      ; align on max
      ks = (where( P2 EQ max(P2)))[0]
      if( ks LT 900 or ks GT 1100 ) then continue
      t2[500:1800] += P2[ks-500:ks+800]/max(P2)
    endif
    
    ; construct noise
    n1 += ABS(FFT(P1[0:799], -1))^2
    n1c += 1.0
    n2 += ABS(FFT(P2[0:799], -1))^2   
    n2c += 1.0

endfor

t1 = t1/max(t1)
if( finite(t1[0]) EQ 0 ) then t1[*] = 0.0

t2 = t2/max(t2)
if( finite(t2[0]) EQ 0 ) then t2[*] = 0.0

n1  /= n1c
n2  /= n2c
sig1 /= N
sig2 /= N

; normalize FFT
n1 *= (1.25d-6*800.0)
n2 *= (1.25d-6*800.0)

;n1[0] = 2.0*n1[1]
;n2[0] = 2.0*n2[1]

;Don't set DC offset to zero as a test
;n1[0] = n1[1]
;n2[0] = n2[1]

;ch1m = median(ch1[where(ch1 GT m1*5.0*180.0/!Pi )])
;ch1sd = sqrt((moment(ch1[where(ch1 GT m1*5.0*180.0/!Pi )]))[1])

if( n_elements(where(ch1 GT sig1*5.0*180.0/!Pi )) LE 1 ) then begin
  ch1m = 60.0
  ch1sd = 10.0
endif else begin
  ch1m = median(ch1[where(ch1 GT sig1*5.0*180.0/!Pi )])
  ch1sd = sqrt((moment(ch1[where(ch1 GT sig1*5.0*180.0/!Pi)]))[1])
  
  ;ch1m = 35.0
  ;ch1sd = 5.0
endelse

;ch2m = median(ch2[where(ch2 GT m2*5.0*180.0/!Pi )])
;ch2sd = sqrt((moment(ch2[where(ch2 GT m2*5.0*180.0/!Pi )]))[1])

if( n_elements(where(ch2 GT sig2*5.0*180.0/!Pi )) LE 1 ) then begin
   ch2m = 40.0
   ch2sd = 10.0
endif else begin
   ch2m = median(ch2[where(ch2 GT sig2*5.0*180.0/!Pi )])
   ch2sd = sqrt((moment(ch2[where(ch2 GT sig2*5.0*180.0/!Pi)]))[1])
   
   ;ch2m = 35.0
   ;ch2sd = 5.0
endelse

plot,ch1,ch2,psym=3,/xstyle,/ystyle,xr=[0,ch1m*2.0],yr=[0,ch2m*2.0],title='Pulse Height (degrees) Ch1 vs Ch2'
;plot,ch1,ch2,psym=3,/xstyle,/ystyle,xr=[0,50.0],yr=[0,50.0],title='Pulse Height (degrees) Ch1 vs Ch2'

plots,[ch1m-ch1sd,ch1m-ch1sd],[0,20.0],line=1,color=150
plots,[ch1m,ch1m],[0,20.0],line=0,color=150
plots,[ch1m+ch1sd,ch1m+ch1sd],[0,20.0],line=1,color=150

plots,[0,20.0],[ch2m-ch2sd,ch2m-ch2sd],line=1,color=200
plots,[0,20.0],[ch2m,ch2m],line=0,color=200
plots,[0,20.0],[ch2m+ch2sd,ch2m+ch2sd],line=1,color=200

plot,idx*1.25,t1,xr=[1000,2000],/xstyle,xtitle='Time (Microseconds)'
oplot,idx*1.25,t2,color=100
al_legend,/top,/right,line=[0,0],color=[0,100],['Channel 1','Channel 2']

N = 2000 
T = 1.25d-6
N21 = N/2 + 1 
F = INDGEN(N) 
F[N21] = N21 -N + FINDGEN(N21-2) 
F = F/(N*T) 
!p.multi=[0,1,2]

PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t1, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'

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
openw,2,path+'Template.dat'
for i=0,1999 do begin
  printf,2,idx[i]*1.25,t1[i],t2[i]
endfor
close,2

openw,2,path+'NoiseSpectra.dat'
for i=0,799 do begin
  printf,2,Fa[i],n1[i],n2[i]
endfor
close,2

device,/close

return,[ch1m,ch1sd,ch2m,ch2sd,sig1,sig2]

end