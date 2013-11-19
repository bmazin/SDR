
PRO OptimalPulseFilter,datapath,outpath,pulsename,StartT,atten,res,pm

path=datapath
iqsweep = strcompress(path+string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
maincap = path+pulsename
fitdata = path+'Series-ps.dat'
Pmaxx = pm[0]*2.0
Pmaxy = pm[2]*2.0

; load templates and noise spectra
dat = read_ascii(path+'Template-2pass.dat')
;dat = read_ascii(path+'Template.dat')
dat = dat.field1 
idx = (dat[0,*])[*]
t1 = (dat[1,*])[*]
t2 = (dat[2,*])[*]

dat = read_ascii(path+'NoiseSpectra-2pass.dat')
;dat = read_ascii(path+'NoiseSpectra.dat')
dat = dat.field1 
Fa = (dat[0,0:799])[*]
n1 = (dat[1,0:799])[*]
n2 = (dat[2,0:799])[*]

; mess around with lowest FFT bin
n1[0] = 5.0*n1[1]
n1[799] = 5.0*n1[798]

n2[0] = 5.0*n2[1]
n2[799] = 5.0*n2[798]

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
opt1 = FFT(t1[900:1699],-1)
;opt1 = FFT((hanning(2000)*t1)[900:1699],-1)

opt2 = FFT(t2[900:1699],-1)
;opt2 = FFT((hanning(2000)*t2)[900:1699],-1)

phi1=conj(opt1)/ch1nc
phi2=conj(opt2)/ch2nc

;optnorm1c = total( abs(opt1[1:798])^2/ch1nc[1:798]  )
;optnorm2c = total( abs(opt2[1:798])^2/ch2nc[1:798]  )
optnorm1c = total( abs(opt1)^2/ch1nc)
optnorm2c = total( abs(opt2)^2/ch2nc)

; now make optimal filter array for different pulse start times
phi1arr = dcomplexarr(41,800)
phi2arr = dcomplexarr(41,800)
v1 = dblarr(41)
v2 = dblarr(41)
for i=-20,20 do begin
  opt1temp = FFT(shift(t1[900:1699],i),-1)
  opt2temp = FFT(shift(t2[900:1699],i),-1)
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
data = dblarr(5,500)
readf,1,data
close,1

fitdat = read_ascii(fitdata)
fitdat = fitdat.field01
xc1 = fitdat[16,0] + Iz1
yc1 = fitdat[17,0] + Qz1
xc2 = fitdat[16,1] + Iz2
yc2 = fitdat[17,1] + Qz2

device,filename=path+'Strip.ps',/inches,xsize=7.5,ysize=7.5,xoffset=.5,yoffset=1,encapsulated=0  ; more square 2x2 plots
loadct,4
!p.multi=[0,1,2]

openr,1,maincap
header = dblarr(14)
readu,1,header

;N = 5000L
N = long(((FILE_INFO(maincap)).size-14.0*4.0)/16000.0) - 2
print,'Reading',N,' pulses'

ch1 = dblarr(N)
ch2 = dblarr(N)
ch1[*] = 0.0
ch2[*] = 0.0

ch1c = dblarr(N)
ch2c = dblarr(N)
ch1c[*] = 0.0
ch2c[*] = 0.0

ch1d = dblarr(N)
ch2d = dblarr(N)
ch1d[*] = 0.0
ch2d[*] = 0.0

ch1e = dblarr(N)
ch2e = dblarr(N)
ch1e[*] = 0.0
ch2e[*] = 0.0

lf1 = dblarr(N)
lf2 = dblarr(N)
lf1[*] = 0.0
lf2[*] = 0.0

chisq = dblarr(N)
chisq[*] = 0.0

chisq2 = dblarr(N)
chisq2[*] = 0.0

tdiff = dblarr(N)
tdiff[*] = 0.0
xrpos = dblarr(N)
xrpos[*] = 0.0

xymove = dblarr(N)
xymove[*] = 0.0

Ix1 = intarr(2000)
Qx1 = intarr(2000)
Ix2 = intarr(2000)
Qx2 = intarr(2000)

!p.multi=[0,2,2]
plot,ch1,ch2,psym=3,/xstyle,/ystyle,xr=[0,Pmaxx],yr=[0,Pmaxy],title='Pulse Height Ch1 vs Ch2',/nodata

for i=0L,N-1L do begin
    readu,1,Ix1
    readu,1,Qx1
    readu,1,Ix2
    readu,1,Qx2
    Ix1d = (double(Ix1)/32767.0)*0.2
    Qx1d = (double(Qx1)/32767.0)*0.2
    Ix2d = (double(Ix2)/32767.0)*0.2
    Qx2d = (double(Qx2)/32767.0)*0.2
            
    ;reference all pulses to first pulse zero
    if( i EQ 0 ) then begin
      ;Ix1m = mean([Ix1d[1:900],Ix1d[1900:1999]])
      ;Qx1m = mean([Qx1d[1:900],Qx1d[1900:1999]])
      ;Ix2m = mean([Ix2d[1:900],Ix2d[1900:1999]])
      ;Qx2m = mean([Qx2d[1:900],Qx2d[1900:1999]])  
      
          r1 = linfit( [idx[0:900],idx[1850:1999]], [Ix1d[0:900],Ix1d[1850:1999]])
          r2 = linfit( [idx[0:900],idx[1850:1999]], [Qx1d[0:900],Qx1d[1850:1999]])
          r3 = linfit( [idx[0:900],idx[1850:1999]], [Ix2d[0:900],Ix2d[1850:1999]])
          r4 = linfit( [idx[0:900],idx[1850:1999]], [Qx2d[0:900],Qx2d[1850:1999]])
          Ix1m = (idx[1000]*r1[1] + r1[0])
          Qx1m = (idx[1000]*r2[1] + r2[0])
          Ix2m = (idx[1000]*r3[1] + r3[0])
          Qx2m = (idx[1000]*r4[1] + r4[0])    
      
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

    ; 3rd order FIT : do a better job removing the baselines and centering pulses
    ;r1 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix1d[0:900],Ix1d[1850:1999]],3)
    ;r2 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx1d[0:900],Qx1d[1850:1999]],3)
    ;r3 = poly_fit( [idx[0:900],idx[1850:1999]], [Ix2d[0:900],Ix2d[1850:1999]],3)
    ;r4 = poly_fit( [idx[0:900],idx[1850:1999]], [Qx2d[0:900],Qx2d[1850:1999]],3)
    ;Ix1d = Ix1d + (Ix1m - (idx*idx*idx*r1[3] + idx*idx*r1[2] + idx*r1[1] + r1[0]))
    ;Qx1d = Qx1d + (Qx1m - (idx*idx*idx*r2[3] + idx*idx*r2[2] + idx*r2[1] + r2[0]))
    ;Ix2d = Ix2d + (Ix2m - (idx*idx*idx*r3[3] + idx*idx*r3[2] + idx*r3[1] + r3[0]))
    ;Qx2d = Qx2d + (Qx2m - (idx*idx*idx*r4[3] + idx*idx*r4[2] + idx*r4[1] + r4[0]))
    
    ; transform to phase
    P1 = atan( double(Qx1d-yc1), double(Ix1d-xc1) )
    P2 = atan( double(Qx2d-yc2), double(Ix2d-xc2) )
    m1 = moment(P1[0:200])
    m2 = moment(P2[0:200])
    
    ; amplitude pulses
    ;A1 = sqrt( double(Qx1d-yc1)^2 + double(Ix1d-xc1)^2 )
    ;A2 = sqrt( double(Qx2d-yc2)^2 + double(Ix2d-xc2)^2 )
    ;A1 = A1 - median(A1)
    ;A2 = A2 - median(A2)

    P1 = fixang(P1,/RADIANS)
    P2 = fixang(P2,/RADIANS)

    ; subtract baseline
    result = linfit( [idx[0:800],idx[1900:1999]], [P1[0:800],P1[1900:1999]])
    P1 = P1 - idx*result[1] - result[0]
    result = linfit( [idx[0:800],idx[1900:1999]], [P2[0:800],P2[1900:1999]])
    P2 = P2 - idx*result[1] - result[0]

    ;if(min(P1) LT -30.0/57.0) then stop
    ;if(min(P2) LT -30.0/57.0) then stop
    
    ; skip event if bad baseline sub
    if( abs(P1[0]-P1[1999]) GT 10.0*sqrt(m1[1]) ) then continue
    if( abs(P2[0]-P2[1999]) GT 10.0*sqrt(m2[1]) ) then continue

    P1 = -P1[900:1699]
    P2 = -P2[900:1699]

    ch1[i] = max(P1[10:200]*180.0/!Pi)
    ch2[i] = max(P2[10:200]*180.0/!Pi)

    plots,ch1[i],ch2[i],psym=3
 
    ; Optimal filter
    P1f = FFT(P1,-1)
    P2f = FFT(P2,-1)
    
    ;ch1c[i] = abs(total(phi1[1:798]*P1f[1:798])*180.0/(optnorm1c*!Pi))
    ;ch2c[i] = abs(total(phi2[1:798]*P2f[1:798])*180.0/(optnorm2c*!Pi))
    ch1c[i] = abs(total(phi1*P1f)*180.0/(optnorm1c*!Pi))
    ch2c[i] = abs(total(phi2*P2f)*180.0/(optnorm2c*!Pi))
 
    
    if( i mod 1000 EQ 0 ) then print,i,' /',N
    
    ; Optimal filter with time offsets
    for j=0,40 do begin
      ;v1[j] = abs(total((phi1arr[j,1:798])[*]*P1f[1:798])*180.0/(optnorm1c*!Pi))
      ;v2[j] = abs(total((phi2arr[j,1:798])[*]*P2f[1:798])*180.0/(optnorm2c*!Pi))
      v1[j] = abs(total((phi1arr[j,*])[*]*P1f[*])*180.0/(optnorm1c*!Pi))
      v2[j] = abs(total((phi2arr[j,*])[*]*P2f[*])*180.0/(optnorm2c*!Pi))
    endfor
    
    ch1d[i]=max(v1)
    ch2d[i]=max(v2)
    
    ; add flags for short lifetime
    peak = where(v1 EQ max(v1))
    if( P1[80+peak] GT P1[100+peak]*2.0 ) then lf1[i] = 1.0

    peak = where(v2 EQ max(v2))
    if( P2[80+peak] GT P2[100+peak]*2.0 ) then lf2[i] = 1.0
    
    if( max(P1*57.0) GT 100000.0 ) then begin
      set_plot,'X'
      ;tidx = dindgen(800)*1.25-125.0
      !p.multi=0
      stop
      ;plot,tidx,P1*180.0/!Pi,xr=[-100,875],yr=[-5,60],xtitle='Microseconds',ytitle='Phase (Degrees)',psym=3,/ystyle
      ;oplot,tidx,t1*max(P1*180.0/!Pi),color=100

      ;d1 = smooth(deriv(P1),11,/EDGE_TRUNCATE)
      ;oplot,tidx,d1*120,color=100
      ; cursor,as,ds,/data,/down
      
      ;if( max(d1[200:780]) GT 0.05 ) then xyouts,100,30,'Double!'
  
      ;oplot,tidx,P1filt[900:1699]*57.0,color=100

      ;window,0
      ;plot,data[1,1:499],data[3,1:499],/ynozero,/xstyle,psym=3
      ;plots,xc1,yc1,psym=1
      ;oplot,Ix1d,Qx1d,psym=1
      ;if(i LT 1500) then continue

      ;plots,mean(Ix1d[0:900]),mean(Qx1d[0:900]),psym=2,color=200
      
      ;plot,data1[1,500:999],data1[3,500:999],/ynozero,/xstyle,psym=3
      ;plots,xc2,yc2,psym=1
      ;oplot,Ix2d,Qx2d,psym=1
      ;if(i LT 1500) then continue

      ;plots,mean(Ix2d[0:900]),mean(Qx2d[0:900]),psym=2,color=200
      
      ;window,1
      if( i LT 20 ) then plot,P1
      if (i GT 20 AND i LT 500) then begin
        oplot,P1,color=i/2
      end
      
      
      ;ch = get_kbrd()

    endif
    
    ; fit parabola to channel 1
    mx = where( v1 EQ max(v1) )
    ;if( ch1d[i] GT 5.0 ) then chisq[i] = 4.0*total( abs(P1f-ch1d[i]*FFT(shift(t1[900:1699],mx-20),-1)*!Pi/180.0)^2/ch1nc)/optnorm1c
    ;if( ch1d[i] GT 5.0 ) then chisq[i] = total( abs(P1f-ch1d[i]*FFT(shift(t1[900:1699],mx-20),-1)*!Pi/180.0)^2/ch1nc)/optnorm1c
    if( ch1d[i] GT 5.0 ) then chisq[i] = total( abs(P1f-ch1d[i]*FFT(shift(t1[900:1699],mx-20),-1)*!Pi/180.0)^2/ch1nc)*(1.25d-6*800.0)/800.0
      
    if( (mx+5 GE 39 OR mx-5 LE 0) OR max(v1) LE 10 ) then begin
      ch1e[i]=max(v1)
    endif else begin
      re = poly_fit( dindgen(11), v1[mx-5:mx+5],2)
      ch1e[i] = re[0] - re[1]^2/(4.0*re[2])
    endelse
    
    ; fit parabola to channel 2
    mx = where( v2 EQ max(v2) )
    ;if( ch2d[i] GT 5.0 ) then chisq2[i] = 4.0*total( abs(P2f-ch2d[i]*FFT(shift(t2[900:1699],mx-20),-1)*!Pi/180.0)^2/ch2nc)/optnorm2c
    ;if( ch2d[i] GT 5.0 ) then chisq2[i] = total( abs(P2f-ch2d[i]*FFT(shift(t2[900:1699],mx-20),-1)*!Pi/180.0)^2/ch2nc)/optnorm2c
    if( ch2d[i] GT 5.0 ) then chisq2[i] = total( abs(P2f-ch2d[i]*FFT(shift(t2[900:1699],mx-20),-1)*!Pi/180.0)^2/ch2nc)*(1.25d-6*800.0)/800.0
      
    if( (mx+5 GE 39 OR mx-5 LE 0) OR max(v2) LE 10 ) then begin
      ch2e[i]=max(v2)
    endif else begin
      re = poly_fit( dindgen(11), v2[mx-5:mx+5],2)
      ch2e[i] = re[0] - re[1]^2/(4.0*re[2])
    endelse
    
    ;if( ch1d[i] GT 30.0 ) then stop
        
    
endfor

plot,ch1c,ch2c,psym=3,/xstyle,/ystyle,xr=[0,Pmaxx],yr=[0,Pmaxy],title='Opt Pulse Height'
plot,ch1d,ch2d,psym=3,/xstyle,/ystyle,xr=[0,Pmaxx],yr=[0,Pmaxy],title='Opt Time-shifted PH'
plot,ch1e,ch2e,psym=3,/xstyle,/ystyle,xr=[0,Pmaxx],yr=[0,Pmaxy],title='ParaFit PH'

;hist = histogram( ch1c, MIN = 0, MAX = 200, BINSIZE = 0.5)
;bins = FINDGEN(N_ELEMENTS(hist))*0.5
;plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,50],/xstyle,xtitle='Pulse Height (degrees)',title='Channel 1 Histogram'

!p.multi=[0,2,2]
hist = histogram( ch1c, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxx],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 1, No Time Shift'

hist = histogram( ch2c, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxy],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 2, No Time Shift'

hist = histogram( ch1d, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxx],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 1 Histogram, Time Shift'

hist = histogram( ch2d, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxy],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 2 Histogram, Time Shift'

hist = histogram( ch1e, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxx],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 1 Histogram, Para Fit'

hist = histogram( ch2e, MIN = 0, MAX = 200, BINSIZE = 0.5)
bins = FINDGEN(N_ELEMENTS(hist))*0.5
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,Pmaxy],/xstyle,xtitle='Pulse Height (degrees)',title='Ch 2 Histogram, Para Fit'

hist = histogram( chisq, MIN = 0, MAX = 10, BINSIZE = 0.01)
hist[0]=0.0
bins = FINDGEN(N_ELEMENTS(hist))*0.01
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xtitle='Reduced Chi!U2!N',title='Ch 1 Chi!U2!N',/xstyle,xr=[0,3]

hist = histogram( chisq2, MIN = 0, MAX = 10, BINSIZE = 0.01)
hist[0]=0.0
bins = FINDGEN(N_ELEMENTS(hist))*0.01
hist[0:2] = 0.0
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xtitle='Reduced Chi!U2!N',title='Ch 2 Chi!U2!N',/xstyle,xr=[0,3]

;hist = histogram( tdiff, MIN = 0, MAX = 1, BINSIZE = 0.01)
;bins = FINDGEN(N_ELEMENTS(hist))*0.01
;idx = (where( hist EQ max(hist) ))[0]
;plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[0,1],/xstyle,title=strcompress('Channel 2 Rise Time = ' + string(bins[idx]) ),xtitle='Radians/1.25 !9u!3sec'

close,1

openw,2,path+'pulses.dat'
for i=0,N-1 do printf,2,ch1[i],ch2[i],ch1c[i],ch2c[i],ch1d[i],ch2d[i],ch1e[i],ch2e[i],chisq[i],chisq2[i],lf1[i],lf2[i],format='(12F)'
close,2

device,/close

end