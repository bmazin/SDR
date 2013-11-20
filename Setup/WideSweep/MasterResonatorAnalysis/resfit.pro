
FUNCTION MAGDIFF, p, X=x, Y=y, ERR=err
    Q = p[0]        ;  Q
    f0 = p[1]       ;  resonance frequency
    carrier = p[2]  ;  value of carrier
    depth = p[3]    ;  depth of dip
    slope = p[4]    ;  slope of background
    curve = p[5]    ;  curve of background

    dx = (x - f0) / f0
    s21 = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    s21a = depth*(abs(s21) + carrier + slope*dx + curve*dx*dx + p[6]*dx*dx*dx)
    dev = (y - s21a)/err
    return, dev
END

function QuickFit,mag,freq

x = freq
y = mag
y = y/max(y)
N = (size(x))[1]
width = fix(N/2)-1
err = replicate( 0.001, N)

; Set up parameters
parinfo = replicate({value:0.D, fixed:0, step:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 7)

Q = 20000.0
parinfo(0).value = Q
parinfo(0).limits  = [5000.0,200000.0]

parinfo(1).value = x[width]
parinfo(1).limits  = [ x[width-N/10], x[width+N/10] ]

parinfo(2).value = 0.3
parinfo(2).limits  = [1e-3,1e2]

parinfo(3).value = max(y)-min(y)
parinfo(3).limits  = [parinfo(3).value*0.5,parinfo(3).value*2.0]

parinfo(4).value = -10.0
parinfo(4).limits  = [-1d4,1d4]

parinfo(5).value = 0.0
parinfo(5).limits  = [-1d7,1d7]
;parinfo(5).fixed = 1

parinfo(6).value = 0.0
parinfo(6).limits  = [-1d12,1d12]
;parinfo(6).fixed=1

; Do the optimization
fa = {X:x, Y:y, ERR:err}
bestnorm=0.0
covar=0.0
perror=0.0

parms = mpfit('MAGDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-18,XTOL=1D-18,GTOL=1D-18,FASTNORM=0,STATUS=status,QUIET=1)
p=parms

; plot results
;plot,x,20.0*alog10(y/max(y)),psym=4,symsize=.2,/ynozero,/xstyle,xtitle='Frequency (GHz)',ytitle='S!L21!N(dB)',/ystyle,yr=[min(20.0*alog10(y/max(y)))-2.0,0]

    Q = p[0]        ;  Q
    f0 = p[1]       ;  resonance frequency
    carrier = p[2]  ;  value of carrier
    depth = p[3]    ;  depth of dip
    slope = p[4]    ;  slope of background
    curve = p[5]    ;  curve of background
    dx = (x - f0) / f0
    s21 = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    s21a = depth*(abs(s21) + carrier + slope*dx + curve*dx*dx + p[6]*dx*dx*dx)

;oplot,x,20.0*alog10(s21a/max(y)),color=150

dipdb = min(20.0*alog10(y/max(y)))
dip = 10.0^(dipdb/20.0)
Qc = Q*(1.0/(1.0/dip + 1.0) + 1.0)
Qi = Qc*(1.0/dip - 1.0)

;legend,/center,/right,[strcompress('Q = ' + string(p[0],format='(F8.0)')),strcompress('Q!Lc!N = ' + string(Qc,format='(F8.0)')),strcompress('Q!Li!N = ' + string(Qi,format='(F8.0)'))  $
;,strcompress('f!L0!N = ' + string(p[1],format='(F9.6)') + ' GHz'), $
;strcompress('S!L21!N = ' + string(dipdb,format='(F6.2)') + ' dB')],SPACING=1.5

return,parms

end

; This function return the weighted difference between the model and data
FUNCTION RESDIFF, p, X=x, Y=y, ERR=err
    Q = p[0]          ;  Q
    f0 = p[1]   ;  resonance frequency
    aleak = p[2]   ;  amplitude of leakage
    ph1 = p[3]     ;  phase shift of leakage
    da = p[4]   ;  variation of carrier amplitude
    ang1 = p[5]    ;  Rotation angle of data
    Igain = p[6]   ;  Gain of I channel
    Qgain = p[7]   ;  Gain of Q channel
    Ioff = p[8]       ;  Offset of I channel
    Qoff = p[9]       ;  Offset of Q channel
    db = p[10]

    dx = (x - f0) / f0

    ; resonance dip function
    s21a = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    s21a = s21a - dcomplex(.5,0)
    s21b = dcomplex(da*dx + db*dx*dx,0) + s21a + aleak*dcomplex(1.0-cos(dx*ph1),-sin(dx*ph1))

    ; scale and rotate
    Ix1 = double(s21b)*Igain
    Qx1 = imaginary(s21b)*Qgain
    nI1 = ((Ix1*cos(ang1) + Qx1*sin(ang1)))[*]
    nQ1 = ((-Ix1*sin(ang1) + Qx1*cos(ang1)))[*]

    ;scale and offset
    nI1 = nI1 + Ioff
    nQ1 = nQ1 + Qoff

    s21 = dcomplex(nI1,nQ1)

    dev = abs((y - s21)/err)

    ;dev = (abs(s21) - abs(y))/abs(err)

    return, dev
END

function ResFit,data,Izero,Qzero,Tave,resnum,atten,outpath,data1a,Izeroa,Qzeroa,bg

  ; prepare data by removing cable term
  ; go to amplitude,phase
  I = (data[1,*])[*]-Izero
  Q = (data[3,*])[*]-Qzero
  mag = (sqrt(I^2+Q^2))[*]
  phase = (atan(Q,I))[*]
  N = (size(I))[1]
  
  ; fit phase and subtract off
  if( bg EQ -1 ) then begin
    res = linfit(dindgen(N/20+1),phase[0:N/20])
    phase = phase - ( res[0] + dindgen(500)*res[1] )
    I1 = mag*cos(phase)
    Q1 = mag*sin(phase)
  endif 
  
  if (bg EQ 0) then begin
    I1= I
    Q1= Q
  endif
  
  if (bg GE 10) then begin
    ioff = mean((data1a[1,*])[*]-Izeroa)
    qoff = mean((data1a[3,*])[*]-Qzeroa)
    I1= (I - ((data1a[1,*])[*]-Izeroa)) + ioff
    Q1= (Q - ((data1a[3,*])[*]-Qzeroa)) + qoff
  endif
  
  ; debug plot
  ;set_plot,'X'
  ;!p.multi=0
  ;plot,I,Q,/xstyle,/ystyle,xr=[-.05,.05],yr=[-.05,.05]
  ;oplot,data1a[1,*]-Izeroa,data1a[3,*]-Qzeroa,color=150
  ;oplot,I1,Q1,color=75
  ;plots,ioff,qoff,psym=1
  ;stop
    
  ; get f0 from IQ velocity
  dist1 = sqrt((I1[1:N-1] - I1[0:N-2])^2  +  (Q1[1:N-1] - Q1[0:N-2])^2)
  dist1[0:10] = 0.0
  dist1[N-12:N-2] = 0.0
  dist1 = smooth(dist1,15)

  residx = (where( dist1 EQ max(dist1) ))[0] + 1
  if( residx LE N/5 ) then residx = N/4+2
  if( residx GE N-N/5 ) then residx = N-N/4-2
  ;print,residx

  ; find resonance zero point
  width = fix(N/5)
  xrc1 = min(I1[residx-width:residx+width]) + (max(I1[residx-width:residx+width]) - min(I1[residx-width:residx+width]))/2.0
  yrc1 = min(Q1[residx-width:residx+width]) + (max(Q1[residx-width:residx+width]) - min(Q1[residx-width:residx+width]))/2.0

  ; do quick magnitude fit
  pg=QuickFit(mag[residx-width:residx+width],(data[0,residx-width:residx+width])[*])
  Qguess = pg[0]
  fguess = pg[1]

  ; calculate distance to center
  dc = sqrt(xrc1^2 + yrc1^2)

  ; calculate rotation angle
  ang1 = atan( -yrc1 + Q1[residx], -xrc1 + I1[residx] )

  x = (data[0,residx-width:residx+width])[*]*1.0d9
  y = dcomplex(I1[residx-width:residx+width], Q1[residx-width:residx+width])

  ; use actual errors
  err = (dcomplex(data[2,residx-width:residx+width],data[4,residx-width:residx+width]))[*]
  ;err = dcomplex( replicate(.001,width*2+1), replicate(.001,width*2+1)  )

  ang = atan(imaginary(y[width]) - yrc1,double(y[width])-xrc1) -  atan(imaginary(y[width+5]) - yrc1,double(y[width+5])-xrc1)
 ; print,ang*180.0/!Pi
  
  ; Set up parameters
  parinfo = replicate({value:0.D, fixed:0, step:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 11)

  ;print,'Qguess=',Qguess
  parinfo(0).value = Qguess
 ; parinfo(0).limits  = [Qguess*0.1,Qguess*20.0]
  parinfo(0).limits  = [5000.0,1000001.0]

  parinfo(1).value = fguess*1d9
  parinfo(1).limits  = [ x[width-N/5], x[width+N/5] ]

  parinfo(2).value = 1.0
  parinfo(2).limits  = [1d-4,100.0D]
  ;parinfo(2).fixed=1

  parinfo(3).value = 800.0
  parinfo(3).limits  = [1.0,4d4]
  ;parinfo(3).fixed=1

  parinfo(4).value = 500.0D
  parinfo(4).limits  = [-5000.0,5000.0]
  ;parinfo(4).fixed=1

  if( ang1 GE 0 and ang1 LE !Pi ) then parinfo(5).value = ang1 - !Pi/2
  if( ang1 GE -!Pi and ang1 LT 0 ) then parinfo(5).value = ang1 + !Pi/2
  ;parinfo(5).value = ang1 + !Pi/2.0
  parinfo(5).limits  = [-4.0*!Pi,4.0*!Pi]
  ;parinfo(5).step = .001

  parinfo(6).value = max(I1[residx-width:residx+width]) - min(I1[residx-width:residx+width])
  parinfo(6).limits  = [0.2*parinfo(6).value,3.0*parinfo(6).value]

  parinfo(7).value = max(Q1[residx-width:residx+width]) - min(Q1[residx-width:residx+width])
  parinfo(7).limits  = [0.2*parinfo(7).value,3.0*parinfo(7).value]

  parinfo(8).value = double(xrc1)
  parinfo(8).limits  = [parinfo(8).value-5000.0,parinfo(8).value+5000.0]

  parinfo(9).value = double(yrc1)
  parinfo(9).limits = [parinfo(9).value-5000.0,parinfo(9).value+5000.0]

  parinfo(10).value = 0.0D
  parinfo(10).limits  = [-100000000.0,10000000.0]
  parinfo(10).fixed=1

  ; Do the optimization
  fa = {X:x, Y:y, ERR:err}
  bestnorm=0.0
  covar=0.0
  perror=0.0

  parms = mpfit('RESDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-16,XTOL=1D-16,GTOL=1D-16,FASTNORM=0,STATUS=status,QUIET=1)

  ;print,'Status of Fit= ',status
  ;print,bestnorm

; monte carlo starting values to attempt to get a lower chisq
parold = parinfo
bestchisq = bestnorm
bestparm = parms
besterr = perror
bestiter = 0
chirecord = dblarr(11)
for k=0,10 do begin
    parinfo = parold
    ;parinfo(0).value = parinfo(0).value + .4*parinfo(0).value * randomn(seed)
    parinfo(0).value = 20000.0 + 30000.0 * randomu(seed)
    if( parinfo(0).value LT 5000 ) then parinfo(0).value = 5001.0
    parinfo(1).value = parinfo(1).value + 5000.0 * randomn(seed)
    parinfo(2).value = parinfo(2).value + .2*parinfo(2).value * randomn(seed)
    parinfo(3).value = parinfo(3).value + .2*parinfo(3).value * randomn(seed)
    parinfo(4).value = parinfo(4).value + 5.0*parinfo(4).value * randomn(seed)
    parinfo(5).value = parinfo(5).value + .2*parinfo(5).value * randomn(seed)
    parinfo(6).value = parinfo(6).value + .5*parinfo(6).value * randomn(seed)
    parinfo(7).value = parinfo(7).value + .5*parinfo(7).value * randomn(seed)
    parinfo(8).value = parinfo(8).value + .5*parinfo(8).value * randomn(seed)
    parinfo(9).value = parinfo(9).value + .5*parinfo(9).value * randomn(seed)
    parms = mpfit('RESDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-16,XTOL=1D-16,GTOL=1D-16,FASTNORM=0,STATUS=status,/QUIET)
    chirecord[k] = bestnorm
    ;print,'Status of Fit= ',status
    if( status GT 0 and bestnorm LT bestchisq ) then begin
         bestchisq = bestnorm
         bestparm = parms
         besterr = perror
         bestiter = k
    endif
endfor

;print,'Found min on iter ',bestiter

  p = bestparm
  perror = besterr
  if( perror[0] EQ 0) then begin 
    perror = !NULL
    perror =[0.0,0.0]
 endif
  
  ;if( status EQ 0 ) then continue;

  DOF     = N_ELEMENTS(X)*2.0 - N_ELEMENTS(PARMS) ; deg of freedom
  chisq = BESTNORM/DOF
  ;PCERROR = PERROR * SQRT(BESTNORM / DOF)   ; scaled uncertainties
  ;err = err*SQRT(BESTNORM / DOF)

mx = max(20.0*alog10(y))
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A)
;T= (Tstart + Tend)/2.0

;if( r EQ 0 ) then resnum = z else resnum = 2*z+1
;resnum = 2*z + r
;plot,x/1.0d9,20.0*alog10(y) - mx,/xstyle,psym=8,xtitle='Frequency (GHz)',ytitle='Transmission (dB)',title=strcompress('Resonance '+string(resnum)+', T='+string(T)),xtickformat='(F6.4)',symsize=.3
;plot,double(y),imaginary(y),/xstyle,psym=3,xr=[-32000,32000],yr=[-32000,32000],/ystyle

!p.multi=[0,1,2]
plot,double(y),imaginary(y),psym=8,title=strcompress('Resonator' + string(fix(resnum)) + ', Atten = ' + string(fix(atten)) +', T = '+string(Tave*1000.0) + ' mK'),symsize=.2,/ynozero;,xr=[xrc1-10000,xrc1+10000],yr=[yrc1-10000],yrc1+10000],/xstyle,/ystyle
residx = where( min( (x-p[1])^2 ) EQ (x-p[1])^2 ) 
plots,double(y[residx]),imaginary(y[residx]),psym=8,color=200

    Q = p[0]        ;  Q
    f0 = p[1]   ;  resonance frequency
    aleak = p[2]   ;  amplitude of leakage
    ph1 = p[3]     ;  phase shift of leakage
    da = p[4]   ;  variation of carrier amplitude
    ang1 = p[5]    ;  Rotation angle of data
    Igain = p[6]   ;  Gain of I channel
    Qgain = p[7]   ;  Gain of Q channel
    Ioff = p[8]       ;  Offset of I channel
    Qoff = p[9]       ;  Offset of Q channel
    db = p[10]

    dx = (x - f0) / f0

    ; resonance dip function
    s21a = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    s21a = s21a - dcomplex(.5,0)
    s21b = dcomplex(da*dx + db*dx*dx,0) + s21a + aleak*dcomplex(1.0-cos(dx*ph1),-sin(dx*ph1))

    ; scale and rotate
    Ix1 = double(s21b)*Igain
    Qx1 = imaginary(s21b)*Qgain
    nI1 = ((Ix1*cos(ang1) + Qx1*sin(ang1)))[*]
    nQ1 = ((-Ix1*sin(ang1) + Qx1*cos(ang1)))[*]

    ;scale and offset
    nI1 = nI1 + Ioff
    nQ1 = nQ1 + Qoff

    s21 = dcomplex(nI1,nQ1)

oplot,double(s21),imaginary(s21),color=150,thick=1
plots,p[8],p[9],psym=1,color=100

;dip = ((p[6] + p[7])/2.0)/(sqrt(p[8]^2 + p[9]^2) + (p[6] + p[7])/4.0)
;dipdb = 20.0*alog10(1.0-dip)

; fit center to on-res point distance
;radius = sqrt( (p[8]-double(y[residx]))^2 + (p[9]-imaginary(y[residx]))^2 )
; size of the loop from fit
radius = (p[6]+p[7])/4.0

; diam is the normalized diameter of the loop (off resonance = 1)
diam = (2.0*radius) / (sqrt(p[8]^2 + p[9]^2) +  radius)
;mag = sqrt(I1^2 + Q1^2)
;norm = (mean(mag[0:5]) + mean(mag[N-6:N-1]))/2.0
;norm = max(mag)
;diam = 2.0*radius/norm

Qc = p[0]/diam
Qi = p[0]/(1.0-diam)

dip = 1.0 - 2.0*radius/(sqrt(p[8]^2 + p[9]^2) +  radius)
dipdb = 20.0*alog10(dip)
;Qc = Q*(1.0/(1.0/dip + 1.0) + 1.0)
;Qi = Qc*(1.0/dip - 1.0)

;legend,/top,/right,[strcompress('Q = ' + string(p[0],format='(F8.0)')) $
;,strcompress('f!L0!N = ' + string(p[1]/1e9,format='(F9.6)') + ' GHz'), $
;strcompress('S!L21!N = ' + string(dipdb,format='(F6.2)') + ' dB')]

mag = sqrt(double(y)^2 + imaginary(y)^2)
mag = mag/max(mag)
mag = 20.0*alog10(mag)

fitmag = sqrt(double(s21)^2 + imaginary(s21)^2)

plot,x/1d9,mag,psym=8,/ynozero,/xstyle,symsize=.2,xtitle='Frequency (GHz)',ytitle='S!L21!N(dB)'
oplot,x/1d9,20.0*alog10(fitmag/max(fitmag)),color=150
plots,x[residx]/1d9,mag[residx],psym=8,color=200

al_legend,/bottom,/right,[strcompress('Q = ' + string(p[0],format='(F9.0)')),strcompress('Q!Lc!N = ' + string(Qc,format='(F9.0)')),strcompress('Q!Li!N = ' + string(Qi,format='(F9.0)'))  $
,strcompress('f!L0!N = ' + string(p[1]/1d9,format='(F9.6)') + ' GHz'), strcompress('S!L21!N = ' +  string(dipdb,format='(F6.2)') + ' dB'),strcompress( 'X!U2!N = ' + string(sqrt(bestchisq/DOF),format='(F9.2)') ) ],SPACING=1.5

openw,2,strcompress(outpath+'series-ps.dat',/remove_all),/APPEND
;openw,2,strcompress(outpath+ string(Tave)+'-'+string(atten)+'.dat',/remove_all),/APPEND
printf,2,resnum,Tave,atten,p[0],perror[0],p[1],perror[1],dipdb,Qc,Qi,p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],format='(I,19E)'
close,2
  
return,[radius,p[8],p[9],Izero,Qzero,p[0],Qc,Qi,p[1],atten,sqrt(bestchisq/DOF)]

end