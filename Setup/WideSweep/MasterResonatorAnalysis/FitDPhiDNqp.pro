
PRO FitDphiDNqp,data,res,atten,outpath,datapath,StartT,EndT,StepT,Tc,V

device,filename=strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'-dphi.ps',/remove_all)
A = FINDGEN(17) * (!PI*2/16.)
USERSYM, COS(A), SIN(A), /FILL

N = (EndT-StartT)/StepT+2
ang = dblarr(N)
mag = dblarr(N)
temp = dblarr(N)

; fit for dPhi/dNqp in both resonators
for j=0,1 do begin
  for t=StartT,EndT,StepT do begin

    nidx = (t-StartT)/StepT
    sweepfile = strcompress( datapath +string(fix(t)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
    lines = file_lines(sweepfile) - 7
    if( lines LE 100 ) then begin
      print,'File' + sweepfile + 'is missing or corrupt.'
      return
    endif
    openr,1,sweepfile
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
 
    if( j EQ 0 ) then begin
      resnum = 2*res-1
      f = data1[0,0:lines/2-1]
      I1 = data1[1,0:lines/2-1] - Iz1
      Q1 = data1[3,0:lines/2-1] - Qz1
      dataidx = (where( data[0,*] EQ resnum and data[2,*] EQ atten ))[0]
      f0 = data[5,dataidx]/1d9
      xc = data[16,dataidx]
      yc = data[17,dataidx]
    endif else begin
      resnum = 2*res
      f = data1[0,lines/2:lines-1] 
      I1 = data1[1,lines/2:lines-1] - Iz2
      Q1 = data1[3,lines/2:lines-1] - Qz2
      dataidx = (where( data[0,*] EQ resnum and data[2,*] EQ atten ))[0]
      f0 = data[5,dataidx]/1d9
      xc = data[16,dataidx]
      yc = data[17,dataidx]
    endelse
    
    ; figure out idx of resonant frequency
    residx = where( min( (f-f0)^2 ) EQ (f-f0)^2 )     
    
    if( t EQ StartT) then begin
      plot,I1,Q1,/xstyle,/ystyle,xr=[-0.04,0.04],yr=[-0.04,0.04],title=strcompress('Resonator ' + string(resnum))
      plots,xc,yc,psym=1,color=0
    endif
    
    oplot,I1,Q1,color=(t-StartT+10)*4.0
    plots,I1[residx],Q1[residx],psym=8,color=0,symsize=0.5
    
    ; calculate angle and dphidnqp
    ang[nidx] = atan(Q1[residx]-yc,I1[residx]-xc)
    mag[nidx] = sqrt( (Q1[residx]-yc)^2 + (I1[residx]-xc)^2 )
    temp[nidx] = data[1,(where( data[0,*] EQ resnum and data[2,*] EQ atten ))[nidx]]
        
  endfor
  
  ang1 = fixang(ang,/RADIANS)
  ang1 = -(ang1 - ang1[0])*180.0/!Pi
  mag1 = -mag/mag[0] + 1.0
 
   ; figure out where BCS starts to matter -> Tc/10.0
  minidx = (where( temp GT Tc/10.0 ))[0] - 1 
  minidx = 0
  ;if( minidx LT 0 ) then continue
 
  ;if( j EQ 1 ) then stop
 
  ; subtract off the TLS effects
  ;tls = linfit(temp[0:minidx],ang1[0:minidx])
  ;ang2 = ang1 - ( tls[0] + temp*tls[1] )
  ang2=ang1
  
  ;tls1 = linfit(temp[0:minidx],mag1[0:minidx])
  ;mag2 = mag1 - ( tls1[0] + temp*tls1[1] )  
  mag2=mag1
     
  ; change temp into Nqp
  h = 4.13566733d-15
  N0 = 8.7d9 ; per ev^-1 um^-3 for TiN
  kb = 8.617e-5
  delta = 1.72 * kb * Tc
  Nqp = 2.0*V*N0*sqrt(2.0*!Pi*kb*temp*delta)*exp(-delta/(kb*temp)) 
  
  ; figure out what temp give 100 degree phase change
  maxidx = (where( ang2 GT 60.0 ))[0]-1

  ;if( maxidx LT 4 ) then continue
if ( maxidx GT 4 and minidx GE 0 ) then begin 
  plot,Nqp,ang2,/xstyle,xr=[0,Nqp[maxidx]*1.5],xtitle='N!Lqp!N',ytitle='Phase (degrees)',psym=8,symsize=0.5
  oplot,Nqp,mag2*180.0/!Pi,color=100,psym=1
 
  ; fit it 
  dphi = linfit(Nqp[minidx:maxidx],ang2[minidx:maxidx],yf=yfit)
  oplot,Nqp[minidx:maxidx],yfit,line=1

  yf=0
  damp = linfit(Nqp[minidx:maxidx],mag2[minidx:maxidx],yf=yfit)
  oplot,Nqp[minidx:maxidx],yfit*180.0/!Pi,line=1,color=100
 
  legend,/top,/left,[strcompress('dPhi/dNqp (rad/qp) = '+string(dphi[1]*!Pi/180.0)),strcompress('dAmp/dNqp (rad equiv/qp) = '+string(damp[1]))]
  
  endif else begin
    dphi=[0.0,0.0]
    damp=[0.0,0.0]
  endelse
  
  if( damp[1] LT 0.0 ) then damp[1]=dphi[1]/4.0
  
  ; output data
  openw,2,strcompress(outpath+'dphi.dat',/remove_all),/APPEND
  printf,2,resnum,dphi[1]*!Pi/180.0,damp[1],format='(I,2E)'
  close,2

endfor

device,/close

end