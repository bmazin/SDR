FUNCTION TemplateDIFF, p, X=x, Y=y, ERR=err
;p[0] = rise time
;p[1] = fall time
;p[2] = time offset of peak
;p[3] = peak height
;p[4] = peak height of long pulse
;p[5] = fall time of long pulse

; CDMS: y(t) = A (1 - exp( -(t - t0)/tau ) ) (exp(-(t-t0)/kappa) - B*exp( -(t - t0)/tau )
;  f = exp((x-1250.0+p[2])/p[0])*exp(-(x-1250.0+p[2])/p[1])

  ; working single exponential
   ;f = p[3]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[1])
   
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) - p[4]*exp( -(x - 1250.0 + p[2])/p[5] )
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1])  +  p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[4])
;  f = p[3]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[1]) + p[4]*(1.0 - exp( -(x - 1250.0 + p[2])/p[0] ) ) * exp(-(x - 1250.0 + p[2])/p[5]) 

  ; working double exp
  f = p[3]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[1]) + p[4]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[5]) 

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

parinfo[0].value = 1.0
parinfo[0].limits  = [0.1,60.0]

parinfo[1].value = 30.0
parinfo[1].limits  = [4.0,300.0]

parinfo[2].value = 8.0
parinfo[2].limits  = [0.0,100.0]

parinfo[3].value = 1.0
parinfo[3].limits  = [0.1,4.0]

parinfo[4].value = 40.0
parinfo[4].limits  = [0.1,90.0]
;parinfo[4].fixed=1

parinfo[5].value = 80.0
parinfo[5].limits  = [20.0,300.0]
;parinfo[5].fixed=1

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

t1f = p[3]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[1]) + p[4]*(1.0 - exp( -(x - 1000.0 + p[2])/p[0] ) ) * exp(-(x - 1000.0 + p[2])/p[5]) 
k = where( t1f LT 0.0 )
t1f[k]=0.0
fit = t1f

end

; make templates and noise spectra from SDR pulses
path = '/home/kids/filterData/20140921/'
nrows = 99 ; <= number of lines in snap_list.txt
nsecs = 20
  
listpath = path+'snap_list.txt'
openr,2,listpath
pixel_list = intarr(2,nrows)
readf,2,pixel_list
close,2
for ipixel=0,nrows-1 do begin
;for ipixel=17,17 do begin
  ;if (ipixel NE 2) then continue
  print,ipixel

  roach = pixel_list[0,ipixel]
  trim_both_ends = 2
  roach_str = 'r'+strtrim(roach,trim_both_ends)
  pixel = pixel_list[1,ipixel]
  pixel_str = 'p'+strtrim(pixel,trim_both_ends)
  secs_str = strtrim(nsecs,trim_both_ends)
  phasedata = 'ch_snap_'+roach_str+pixel_str+'_'+secs_str+'secs.dat'
  max_pulse_count = 30000
  phase = dblarr(max_pulse_count,2000)
  
  pcount = 0L

  data=intarr(LONG(2)^20*nsecs)
  
  openr,1,path+phasedata,byteorder,/swap_if_little_endian
  readu,1,data
  close,1
  N = n_elements(data)
  
  for i=0L,N-1L do begin
    if( data[i]/2^11 EQ 1) then begin
      data[i]=data[i]+61440
    endif
  endfor
  
  data*=360.0/2.0^16.0*4.0/!PI
  ; scan for pulses
  med = median(data[0:10000])
  sig = sqrt((moment(data[0:10000]))[1])
  nsigma = 7.0
  
  for i=1000L,N-1000L do begin
    if( data[i] LT med - nsigma*sig ) then begin
      phase[pcount,*] = data[i-1000:i+999]
      
      ;set_plot,'X'
      ;plot,phase[pcount,*]
      ;ch = get_kbrd() 
      
      pcount+=1
      i+=1000     ; skip forward to one trigger per photon
      if (pcount GE max_pulse_count) then begin
        break
      end
    endif
  endfor
      
  data=0  ; free data memory
  idx = dindgen(2000)
  pcountMin = 300;
  if(pcount GT pcountMin) then begin
    ; run quicktemplategen on pulses
    t1 = dblarr(2000)
    noiseFT = dblarr(pcount,800)
    noiseFT26 = dblarr(pcount,52)
    ch1 = dblarr(pcount)
    n1c = 0
    print,roach_str+pixel_str+' pcount: '+string(pcount)
    for i=0L,pcount-1L do begin
        
        P1 = (-(phase[i,*] - median(phase[i,0:800])))[*]
        P1 = fixang(P1)
        
        ; subtract baseline
        result = linfit( [idx[0:800],idx[1800:1999]], [P1[0:800],P1[1800:1999]])
        P1 = P1 - idx*result[1] - result[0]
       
        ch1[i] = max(P1[980:1020])
            
        ; fit over broad range of pulses for initial template fit
        ;if( max(P1) GT 10.0*!Pi/180.0 AND max(P1) LT 120.0*!Pi/180.0) then begin
          ; align on max
          ks = (where( P1 EQ max(P1)))[0]
          if( ks LT 980 or ks GT 1020 ) then continue
          t1[100:1800] += P1[ks-900:ks+900]/max(P1)
        ;endif  
        
        ; construct noise
        ;n1 += ABS(FFT(P1[0:799], -1))^2
        ;n1c += 1.0
        noiseFT[n1c,*] = ABS(FFT(P1[0:799]*!Pi/180.0, -1))^2
        noiseFT26[n1c,*] = ABS(FFT(P1[100:151]*!Pi/180.0, -1))^2
        n1c += 1.0
        
        
        ;set_plot,'X'
        ;plot,P1
        ; ch=get_kbrd()
    
    endfor
    
    t1 = t1/max(t1)
    n1 = median(noiseFT[0:n1c-1,*],DIMENSION=1)
    n1_26 = median(noiseFT26[0:n1c-1,*],DIMENSION=1)
    ; normalize FFT
    n1 *= (1.0d-6*800.0)
    n1_26 *= (1.0d-6*52.0)
    
    n1[0] = 2.0*n1[1]
    n1[799] = 2.0*n1[788]
        
    ;n1_26[0] = n1_26[1]*2.0
    
    set_plot,'ps'
    device,/color,encapsulated=0
    loadct,4
    !p.multi=[0,1,2]
    !P.FONT = 0
    device,/helv,/isolatin1      
    device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1
    device,filename=path+roach_str+pixel_str+'pulses.ps'
    
    plot,[0,0],xr=[800,1800],/xstyle,xtitle='Time (Microseconds)',/nodata
    oplot,idx,t1
    
    N = 2000 
    T = 1.0d-6
    N21 = N/2 + 1 
    F = INDGEN(N) 
    F[N21] = N21 -N + FINDGEN(N21-2) 
    F = F/(N*T) 
    
    PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t1, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'
    
    Na = 800
    N21a = Na/2 + 1 
    Fa = INDGEN(Na) 
    Fa[N21a] = N21a -Na + FINDGEN(N21a-2) 
    Fa = Fa/(Na*T) 
    
    Na26 = 52
    N21a26 = Na26/2 + 1 
    Fa26 = INDGEN(Na26) 
    Fa26[N21a26] = N21a26 -Na26 + FINDGEN(N21a26-2) 
    Fa26 = Fa26/(Na26*T) 
    
    OPLOT, SHIFT(Fa, -N21a), 10.0*alog10(SHIFT(n1,-N21a)),psym=10,color=200 
    OPLOT, SHIFT(Fa26, -N21a26), 10.0*alog10(SHIFT(n1_26,-N21a26)),psym=10,color=100    
    close,1
    
    ; output templates and noise spectra
    openw,2,path+roach_str+pixel_str+'Template.dat'
    for i=0,1999 do begin
      printf,2,idx[i]*1.00,t1[i]
    endfor
    close,2
    
    openw,2,path+roach_str+pixel_str+'NoiseSpectra.dat'
    for i=0,799 do begin
      printf,2,Fa[i],n1[i]
    endfor
    close,2
    
    openw,2,path+roach_str+pixel_str+'NoiseSpectra26.dat'
    for i=0,25 do begin
      printf,2,Fa26[i],n1_26[i]
    endfor
    close,2
    
    ch1nc = n1
    
    t1a = dblarr(2000)
    noiseFTa = dblarr(pcount,800)
    ch1a = dblarr(pcount)
    ch1b = dblarr(pcount)
    chisq = dblarr(pcount)
    n1c = 0

    ;construct optimal filters
    opt1 = FFT(t1[900:1700],-1)
    phi1=conj(opt1)/ch1nc
    optnorm1c = total( abs(opt1)^2/ch1nc  )

    ; now make optimcal filter array for different pulse start times
    phi1arr = dcomplexarr(41,800)
    v1 = dblarr(41)
    for i=-20,20 do begin
      opt1temp = FFT(shift(t1[900:1700],i),-1)
      phi1arr[i+20,*] = conj(opt1temp)/ch1nc
    endfor
    
   ; make final template
       for i=0L,pcount-1L do begin
        
        P1 = (-(phase[i,*] - median(phase[i,0:800])))[*]
        P1 = fixang(P1)
        
        ; subtract baseline
        result = linfit( [idx[0:800],idx[1800:1999]], [P1[0:800],P1[1800:1999]])
        P1 = P1 - idx*result[1] - result[0]
      
           P1f = FFT(P1[900:1700],-1)
           for j=0,40 do begin
             v1[j] = abs(total((phi1arr[j,*])[*]*P1f)/(optnorm1c))
           endfor
           ks = (where( v1 EQ max(v1)))[0] + 980.0
           if( ks LT 981 or ks GT 1019 ) then continue
           ;if( P1[ks] GT P1[ks+20]*2.0 ) then continue
           
           ch1b[i] = v1[(where( v1 EQ max(v1)))[0]]
           
           t1a[20:1980] += P1[ks-980:ks+980]/max(v1)
           n1c += 1.0
           
        ; construct noise
        ;n1 += ABS(FFT(P1[0:799], -1))^2
        ;n1c += 1.0
        ;noiseFT[n1c,*] = ABS(FFT(P1[0:799]*!Pi/180.0, -1))^2

    endfor
   
    
    hist = histogram( ch1b, MIN = 0, MAX = 180, BINSIZE = 0.5)
    hist[0]=0.0
    bins = FINDGEN(N_ELEMENTS(hist))*0.5
    hist[0:20] = 0.0
    plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xtitle='Phase (Degrees)',title='Ch 1 Optimal Height - Initial Template',/xstyle,xr=[0,180]
    hmax = max(hist)
    ;plots,[chisqcent,chisqcent],[0,hmax],color=100
    ;plots,[chisqcent-.1,chisqcent-.1],[0,hmax],color=100,line=1
    ;plots,[chisqcent+.1,chisqcent+.1],[0,hmax],color=100,line=1    
 
    t1a = t1a/max(t1a)
    ;n1 = median(noiseFT[0:n1c-1,*],DIMENSION=1)
    
    ; normalize FFT
    
    ;plot,idx,t1a,xr=[800,1800],/xstyle,xtitle='Time (Microseconds)'
    
    TemplateFit,t1a,idx,p,fit
    plot,[0,0],/nodata,xr=[900,1700],/xstyle,title='Ch1 Final Template',xtitle='Time (microseconds)',psym=3,symsize=.3
    oplot,idx,t1a
    oplot,idx,fit,color=100
    al_legend,/top,/right,[strcompress('Rise Time = ' + string(p[0],format='(F5.2)') + ' !9m!3s'),strcompress('QP Lifetime 1 = ' + string(p[1],format='(F6.2)') + ' !9m!3s'),strcompress('QP Lifetime 2 = ' + string(p[5],format='(F6.2)') + ' !9m!3s')]
    ;life[0] = p[0]
    ;life[1] = p[1]
    
    N = 2000 
    T = 1.0d-6
    N21 = N/2 + 1 
    F = INDGEN(N) 
    F[N21] = N21 -N + FINDGEN(N21-2) 
    F = F/(N*T) 
    
    ;PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t1, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'

    
    close,1
    
    ; output templates and noise spectra
    openw,2,path+roach_str+pixel_str+'Template-2pass.dat'
    for i=0,1999 do begin
      printf,2,idx[i]*1.00,t1a[i]
    endfor
    close,2
    
    openw,3,path+roach_str+pixel_str+'TemplateFit-2pass.dat'
    for i=0,1999 do begin
      printf,3,idx[i]*1.00,fit[i]
    endfor
    close,3
    ;openw,2,path+'NoiseSpectra-2pass.dat'
    ;for i=0,799 do begin
    ;  printf,2,Fa[i],n1a[i]
    ;endfor
    ;close,2

    ; Make ye old 800 tap optimal filter   
    opt1 = FFT(fit[900:1699],-1)
    opt1[125:675] = 0.0
    
    phi1=conj(opt1)/ch1nc
    ;phi1=opt1/ch1nc
    optnorm1c = total( abs(opt1)^2/ch1nc  )
 
    ; Make ye old 52 tap optimal filter          
    opt2 = FFT(fit[992:1043],-1)
    opt2[8:44] = 0.0
    phi2=conj(opt2)/n1_26
    ;phi2=opt2/n1_26
    optnorm2c = total( abs(opt2)^2/n1_26  )     
    
    ; go through one last time to get real optimal pulse heights using fit template
    phi1arr = dcomplexarr(41,800)
    v1 = dblarr(41)
    for i=-20,20 do begin
      opt1temp = FFT(shift(fit[900:1700],i),-1)
      phi1arr[i+20,*] = conj(opt1temp)/ch1nc
    endfor
    
    for i=0L,pcount-1L do begin

      P1 = (-(phase[i,*] - median(phase[i,0:800])))[*]
      P1 = fixang(P1)

      ; subtract baseline
      result = linfit( [idx[0:800],idx[1800:1999]], [P1[0:800],P1[1800:1999]])
      P1 = P1 - idx*result[1] - result[0]

      P1f = FFT(P1[900:1700],-1)
      for j=0,40 do begin
        v1[j] = abs(total((phi1arr[j,*])[*]*P1f)/(optnorm1c))
      endfor
      ks = (where( v1 EQ max(v1)))[0] + 980.0
      if( ks LT 981 or ks GT 1019 ) then continue
      ;if( P1[ks] GT P1[ks+20]*2.0 ) then continue

      ch1b[i] = v1[(where( v1 EQ max(v1)))[0]]
      ch1a[i] = max(P1)
      
      ;set_plot,'X'
      ;plot,P1
      ;print,ch1a[i],ch1b[i]
      ;stop
      ;ch=get_kbrd()

    endfor

    hist = histogram( ch1a, MIN = 0, MAX = 180, BINSIZE = 0.5)
    hist[0]=0.0
    bins = FINDGEN(N_ELEMENTS(hist))*0.5
    hist[0:20] = 0.0
    plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xtitle='Phase (Degrees)',title='Ch 1 Max Height',/xstyle,xr=[0,180]
    hmax = max(hist)

    hist = histogram( ch1b, MIN = 0, MAX = 180, BINSIZE = 0.5)
    hist[0]=0.0
    bins = FINDGEN(N_ELEMENTS(hist))*0.5
    hist[0:20] = 0.0
    plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xtitle='Phase (Degrees)',title='Ch 1 Optimal Height',/xstyle,xr=[0,180]
    hmax = max(hist)

   
    ; plot final template FFT, fit, and noise spectra
    PLOT,SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(t1a, -1)), -N21)),psym=10,xr=[100,4e5],/xlog,xtitle='Frequency (Hz)',yr=[-140,-10],/ystyle,ytitle='Phase Noise (dBc/Hz)'
    OPLOT, SHIFT(F, -N21), 20.0*alog10(SHIFT(ABS(FFT(fit, -1)), -N21)),psym=10,color=200
    OPLOT, SHIFT(Fa, -N21a), 10.0*alog10(SHIFT(ch1nc,-N21a)),psym=10,color=200
    OPLOT, SHIFT(Fa26, -N21a26), 10.0*alog10(SHIFT(n1_26,-N21a26)),psym=10,color=100
    
    ; 800 tap optimal filter
    plot,Fa,abs(phi1^2),xr=[1000,5e5],/xstyle,/ylog,/xlog,title='800 Tap Optimal Filter',ytitle='Hz'
    plot,Fa26,abs(phi2^2),xr=[20000,5e5],/xstyle,/ylog,/xlog,title='52 Tap Optimal Filter',ytitle='Hz'
    
    ; plot optimal filter effect on template
    plot,abs(fft(conj(opt1)*phi1))
    plot,abs(fft(conj(opt2)*phi2))
    
    ;output coefficients
    coeff = abs(fft(conj(opt2)*phi2)/max(fft(conj(opt2)*phi2)))
    openw,1,path+'coeff.txt',/APPEND
    printf,1,roach,pixel,coeff
    close,1
    
    openw,1,path+'fitcoeff.txt',/APPEND
    printf,1,roach,pixel,fit[992:1043]
    close,1
    
    openw,1,path+'fitcoeff1.txt',/APPEND
    printf,1,roach,pixel,fit[1000:1051]
    close,1
    
    
    device,/close
    
  ; set_plot,'X'
   ; 800 tap optimal filter
   ;plot,Fa,abs(phi1^2),xr=[1000,1.25e5],/xstyle,/ylog,/xlog
   ;plot,Fa26,abs(phi2^2),xr=[20000,1.25e5],/xstyle,/ylog,/xlog
       
  endif
endfor
end