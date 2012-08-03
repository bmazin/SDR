;***************************************************************************
;  ManualFit.Pro             Ben Mazin, March, 2011
;
;     This program is designed to do an interactive analysis of widesweep 
; data to get reliable resonance fit data.  This program fits the resonators.
;
;***************************************************************************


pro PlotFit,x,I,Q1,Q,f0,aleak,ph1,da,ang1,Igain,Qgain,Ioff,Qoff

    !p.multi=[0,1,2]
    plot,I,Q1,psym=8
    residx = where( min( (x-f0)^2 ) EQ (x-f0)^2 ) 
    plots,I[residx],Q[residx],psym=8,color=100
    
    dx = (x - f0) / f0
    db = 0.0

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
    plots,Ioff,Qoff,psym=1,color=100

    mag = sqrt(double(I)^2+double(Q1)^2)
    mag = mag/max(mag)
    plot,x,20.0*alog10(mag),psym=8,/xstyle    
    oplot,x,20.0*alog10(abs(s21)/max(abs(s21))),color=100

    al_legend,/bottom,/right,[strcompress('Q = ' + string(Q,format='(F9.0)')), $
      strcompress('f!L0!N = ' + string(f0,format='(F9.6)') + ' GHz')],SPACING=1.5,charsize=2
    
end

FUNCTION DOUBLEMAGDIFF, p, X=x, Y=y, ERR=err
    Q = p[0]        ;  Q
    f0 = p[1]       ;  resonance frequency
    carrier = p[2]  ;  value of carrier
    depth = p[3]    ;  depth of dip
    slope = p[4]    ;  slope of background
    curve = p[5]    ;  curve of backgroun
    Q1 = p[6]        ;  Q
    f01 = p[7]       ;  resonance frequency
    depth1 = p[8]    ;  depth of dip


    dx = (x - f0) / f0
    dx1 = (x - f01) / f01
    
    ;1
    s21 = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    
    ;2
    as21 = (dcomplex(0,2.0*Q1*dx1)) / (dcomplex(1,0) + dcomplex(0,2.0*Q1*dx1)) 
   
    mag1 = ((abs(s21)-1.0)*depth + (abs(as21)-1.0)*depth1) + carrier + slope*dx + curve*dx*dx
    
    dev = (y - mag1)/err
    return, dev
END

function DoubleQuickFit,mag,freq,x1,x2

x = freq
y = mag
y = y/max(y)
N = (size(x))[1]
width = fix(N/2)-1
err = replicate( 0.001, N)
step = x[1]-x[0]

; Set up parameters
parinfo = replicate({value:0.D, fixed:0, step:0, limited:[1,1], limits:[0.D,0.D],mpmaxstep:0.D}, 9)

Q = 50000.0
parinfo(0).value = Q
parinfo(0).limits  = [5000.0,1000000.0]

parinfo(1).value = x1
parinfo(1).limits  = [ x1-10*step, x1+10*step ]

parinfo(2).value = 1.0
parinfo(2).limits  = [1e-3,1e2]

parinfo(3).value = 0.5
parinfo(3).limits  = [.0001,1.0]

parinfo(4).value = -10.0
parinfo(4).limits  = [-1d4,1d4]

parinfo(5).value = 0.0
parinfo(5).limits  = [-1d7,1d7]

Q = 50000.0
parinfo(6).value = Q
parinfo(6).limits  = [5000.0,1000000.0]

parinfo(7).value = x2
parinfo(7).limits  = [ x2-10*step, x2+10*step ]

parinfo(8).value = 0.5
parinfo(8).limits  = [.0001,1.0]

; Do the optimization
fa = {X:x, Y:y, ERR:err}
bestnorm=0.0
covar=0.0
perror=0.0

parms = mpfit('DOUBLEMAGDIFF',functargs=fa,BESTNORM=bestnorm,COVAR=covar,PARINFO=parinfo,PERROR=perror,AUTODERIVATIVE=1,FTOL=1D-18,XTOL=1D-18,GTOL=1D-18,FASTNORM=0,STATUS=status,QUIET=1)
p=parms

    Q = p[0]        ;  Q
    f0 = p[1]       ;  resonance frequency
    carrier = p[2]  ;  value of carrier
    depth = p[3]    ;  depth of dip
    slope = p[4]    ;  slope of background
    curve = p[5]    ;  curve of backgroun
    Q1 = p[6]        ;  Q
    f01 = p[7]       ;  resonance frequency
    depth1 = p[8]    ;  depth of dip


    dx = (x - f0) / f0
    dx1 = (x - f01) / f01
    
    ;1
    s21 = (dcomplex(0,2.0*Q*dx)) / (dcomplex(1,0) + dcomplex(0,2.0*Q*dx))
    
    ;2
    as21 = (dcomplex(0,2.0*Q1*dx1)) / (dcomplex(1,0) + dcomplex(0,2.0*Q1*dx1)) 
   
    mag1 = ((abs(s21)-1.0)*depth + (abs(as21)-1.0)*depth1) + carrier + slope*dx + curve*dx*dx
    
    !p.multi=[0,1,1]
    plot,x,mag,psym=8,/xstyle
    oplot,x,mag1,color=150

    al_legend,/bottom,/right,[strcompress('Q = ' + string(Q,format='(F9.0)')), strcompress('f!L0!N = ' + string(f0,format='(F9.6)') + ' GHz'), $
      strcompress('Q = ' + string(Q1,format='(F9.0)')), strcompress('f!L0!N = ' + string(f01,format='(F9.6)') + ' GHz')],SPACING=1.5,charsize=2

return,parms

end

resloc = '20110418-fits.txt'
swpfit = 'series-ps.dat'
swpname = '100-1-78.swp'
datapath = '/Users/bmazin/Data/ResData/20110407/widesweep/'
outpath = '/Users/bmazin/Data/ResData/20110407/widesweep/'
width = 75 ; base width of fit
atten = 78

;load resonance locations
res = read_ascii(datapath+resloc)
res = res.field1
n = n_elements(res[0,*])

;load fit data
fitd = read_ascii(datapath+swpfit)
fitd = fitd.field01

;load widesweep data
resfile = strcompress(datapath+swpname,/remove_all)
lines = file_lines(resfile) - 7
if( lines LE 100 ) then begin
  print,'File' + datapath + 'is missing or corrupt.'
  stop
endif
      
openr,1,resfile
readf,1,fr1,fspan1,fsteps1,atten1
readf,1,fr2,fspan2,fsteps2,atten2
readf,1,ts,te
readf,1,Iz1,Izsd1
readf,1,Qz1,Qzsd1
readf,1,Iz2,Izsd2
readf,1,Qz2,Qzsd2
data1 = dblarr(5,lines)
readf,1,data1
close,1

m = lines/2-1

; work ok if data sweep taken in the reverse direction
if( data1[0,0] GT data1[0,10] ) then begin
  data1[0,0:m] = reverse(data1[0,0:m],2)
  data1[1,0:m] = reverse(data1[1,0:m],2)
  data1[2,0:m] = reverse(data1[2,0:m],2)
  data1[3,0:m] = reverse(data1[3,0:m],2)
  data1[4,0:m] = reverse(data1[4,0:m],2)

  data1[0,m+1:lines-1] = reverse(data1[0,m+1:lines-1],2)
  data1[1,m+1:lines-1] = reverse(data1[1,m+1:lines-1],2)
  data1[2,m+1:lines-1] = reverse(data1[2,m+1:lines-1],2)
  data1[3,m+1:lines-1] = reverse(data1[3,m+1:lines-1],2)
  data1[4,m+1:lines-1] = reverse(data1[4,m+1:lines-1],2)    
endif
    
data1a = dblarr(5,lines)
data1a[*,*] = 0.0

; get rid of any zeros in errors
if(where(data1[2,*] LT 1d-6) NE -1 ) then data1[2, where(data1[2,*] LT 1d-6) ] = 1d-6
if(where(data1[4,*] LT 1d-6) NE -1 ) then data1[4, where(data1[4,*] LT 1d-6) ] = 1d-6
;data1[2, * ] = 1d-6
;data1[4, * ] = 1d-6

data1a = dblarr(5,lines)
data1a[*,*] = 0.0

set_plot,'X'
!p.multi=[0,1,0]
loadct,2
device,decomposed=0
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL

stridx = strsplit(resloc,'-')
outfn = strmid(resloc,stridx[0],stridx[1]-1)

openw,1, strcompress(outpath + outfn + '-fits-refined.txt',/remove_all)

;loop over all the resonators
for j=0,n-1 do begin 
;for j=0,2 do begin
  
  ef=0
  cent = findel( res[1,j], data1[0,*] )
  f = (data1[0, cent-width:cent+width-1 ])[*]

  if( cent LT m ) then begin
    I = (data1[1, cent-width:cent+width-1 ])[*]-Iz2  ; bug, fix on next run!
    Q = (data1[3, cent-width:cent+width-1 ])[*]-Qz2  
  endif else begin
    I = (data1[1, cent-width:cent+width-1 ])[*]-Iz2
    Q = (data1[3, cent-width:cent+width-1 ])[*]-Qz2    
  endelse

  Q0 = fitd[3,j]
  f0 = fitd[5,j]/1d9

  ; plot saved fit
  PlotFit,f,I,Q,Q0,f0,fitd[10,j],fitd[11,j],fitd[12,j],fitd[13,j],fitd[14,j],fitd[15,j],fitd[16,j],fitd[17,j]

  print,'(c)ontinue, (r)efit single, fit (d)ouble, (s)kip, (b)ack, (q)uit'
  ch = get_kbrd()
  
  CASE byte(ch) OF
  byte('q'): BEGIN   ; QUIT
      ef = 1
      break 
     END
     
  byte('c'): BEGIN    ; good fit, print params and move on
      print,j,f0,Q0,format='(i4,F17.6,F17.2)'
      printf,1,j,f0,Q0,format='(i4,F17.6,F17.2)'  
     END
 
  byte('r'): BEGIN    ; bad fit of a single resonator, refit
      while 1 do begin
      if( cent LT m ) then r1 = ResFit(data1[*,cent-width:cent+width-1],Iz1,Qz1,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,cent-width:cent+width-1],Iz1a,Qz1a,0)
      if( cent GE m ) then r1 = ResFit(data1[*,cent-width:cent+width-1],Iz2,Qz2,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,cent-width:cent+width-1],Iz2a,Qz2a,0)
      Q0 = r1[5]
      Qi = r1[7] 
      Qc = r1[6]
      f0 = r1[8]/1d9
      chisq = r1[10]     
      PlotFit,f,I,Q,Q0,f0,fitd[10,j],fitd[11,j],fitd[12,j],fitd[13,j],fitd[14,j],fitd[15,j],fitd[16,j],fitd[17,j]
 
      print,'OK refit?  (c)ontinue or (r)efit.'
      ch1 = get_kbrd()
      if( ch1 EQ 'c') then break
      ENDWHILE
 
      print,j,f0,Q0,format='(i4,F17.6,F17.2)'
      printf,1,j,f0,Q0,format='(i4,F17.6,F17.2)'  
     END    

 byte('d'): BEGIN    ; bad fit of a single resonator, refit
     

      while 1 do begin
        PlotFit,f,I,Q,Q0,f0,fitd[10,j],fitd[11,j],fitd[12,j],fitd[13,j],fitd[14,j],fitd[15,j],fitd[16,j],fitd[17,j]
        print,'Click on both resonance minumums!'
        cursor,x1,y1,/data,/down
        cursor,x2,y2,/data,/down      
        print,x1,x2
     
        mag = sqrt(double(I)^2+double(Q)^2)
        mag = mag/max(mag)
        r1 = DoubleQuickFit(mag,f,x1,x2)

        print,'OK refit?  (c)ontinue or (r)efit.'
        ch1 = get_kbrd()
        if( ch1 EQ 'c') then break
      ENDWHILE
       
      print,j,r1[1],r1[0],format='(i4,F17.6,F17.2)'
      print,j,r1[7],r1[6],format='(i4,F17.6,F17.2)'
      
      printf,1,j,r1[1],r1[0],format='(i4,F17.6,F17.2)'
      printf,1,j,r1[7],r1[6],format='(i4,F17.6,F17.2)'
       
     END    

  byte('r'): BEGIN    ; go back one resonator, deleting last line from file
      skip_lun,1,-1,/Lines      
      j=j-2
      if( j LT 0 ) then j=0
     END    
  
  byte('s'): BEGIN    ; skip resonator (usually because we already fit it as a double)
      print,'Skipped!'
    END       
  
  ELSE: BEGIN
      j=j-1
      if( j LT 0 ) then j=0
    END
  ENDCASE
  
  if ( ef EQ 1 ) then break

endfor

close,1
print,'Done!'

end