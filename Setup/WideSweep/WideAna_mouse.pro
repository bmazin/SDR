;***************************************************************************
;  WideAna.Pro             Ben Mazin, March, 2011
;
;     This program is designed to do an interactive analysis of widesweep 
; data to get reliable resonance fit data.  This component finds the resonances.
;
;***************************************************************************

filename = 'SCI3-ADR-FL2-73mK.txt'
datapath = '/Users/matt/Documents/mazin/widesweepanalysis/20120730adr/'
outpath = '/Users/matt/Documents/mazin/widesweepanalysis/20120730adr/'
;outpath = '/Users/bmazin/Data/ResData/Archive/'

;have IDL keep responsibility for plot windows because X11 throws BadMatch error
device,retain=2
; postscript output setuparr
set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1

stridx = strsplit(datapath,'/')
outfn = strmid(datapath,stridx[5],11)
device,filename = strcompress(outpath + 'SCI3-ADR-FL2-73mK-ws-good.ps',/remove_all)

; load up the widesweep

;   make sure datafile is present and see how many points are in the sweep
resfile = strcompress(datapath+filename,/remove_all)
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
;if(where(data1[2,*] LT 1d-6) NE -1 ) then data1[2, where(data1[2,*] LT 1d-6) ] = 1d-6
;if(where(data1[4,*] LT 1d-6) NE -1 ) then data1[4, where(data1[4,*] LT 1d-6) ] = 1d-6
data1[2, * ] = 1d-6
data1[4, * ] = 1d-6

; plot magnitude widesweep data in 10 segments
mag = dblarr(fsteps1*2)
mag[0:fsteps1-1] = sqrt((data1[1,0:fsteps1-1]-Iz1)^2 + (data1[3,0:fsteps1-1]-Qz1)^2)
mag[fsteps1:2*fsteps1-1] = sqrt((data1[1,fsteps1:2*fsteps1-1]-Iz2)^2 + (data1[3,fsteps1:2*fsteps1-1]-Qz2)^2)

mag = 20.0*alog10(mag/max(mag)) ; normalize and go to dB
!p.multi=[0,1,5]
for i=0,19 do begin
  plot,data1[0,fsteps1*i/10 : fsteps1*(i+1)/10 - 1],mag[fsteps1*i/10 : fsteps1*(i+1)/10 - 1],xtitle='Frequency (GHz)',ytitle='S21 (dB)',/xstyle,/ystyle
endfor

; preliminary resonator detection using smoothed IQ velocity
v = dblarr(fsteps1*2)
v[*] = 0.0
v[1:2*fsteps1-1] = smooth(sqrt((data1[1,0:2*fsteps1-2] - data1[1,1:2*fsteps1-1])^2 + (data1[3,0:2*fsteps1-2] - data1[3,1:2*fsteps1-1])^2),7)
v[fsteps1] = 0.0 ; midpoint fix

; IQ velocity doesn't find low Q resontors well...  Lets try to detrend small segments of the mag data and looks at s21
device,/close

rescount = 0

openw,1, strcompress(outpath + 'SCI3-ADR-FL2-73mK-ws-good.txt',/remove_all)

set_plot,'X'
!p.multi=[0,1,0]
loadct,2
device,decomposed=0

for i=0,79 do begin  ; 0,79 should be!
  print, 'frame '
  print, i
  m = mag[fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  f = data1[0,fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  v1 = -30.0 + 30.0*v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1] /max(v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1])
  
  ; median subtract baseline
  m1 = m - median(m)
  
  plot,f,m1,yr=[-30,10],/ystyle,/xstyle
  oplot,f,v1,line=1
  
  ; first guess at resonators
  auto_peak_sensitivity = 5
  g2 = peaks(v1,auto_peak_sensitivity)
  
  ;eliminate doubles
  duplicate_threshold=50
  n = n_elements(g2)-2
  if( n GT 0 ) then begin
    for j=0,n do begin
      if( abs(g2[j] - g2[j+1]) LT 50 ) then g2[j+1] = -100
      if( n GE 1 AND j LE n-1) then if ( abs(g2[j] - g2[j+2]) LT duplicate_threshold ) then g2[j+2] = -100    
      if( n GE 2 AND j LE n-2) then if ( abs(g2[j] - g2[j+3]) LT duplicate_threshold ) then g2[j+3] = -100   
      if( n GE 3 AND j LE n-3) then if ( abs(g2[j] - g2[j+4]) LT duplicate_threshold ) then g2[j+4] = -100   
      if( n GE 4 AND j LE n-4) then if ( abs(g2[j] - g2[j+5]) LT duplicate_threshold ) then g2[j+5] = -100   
      if( n GE 5 AND j LE n-5) then if ( abs(g2[j] - g2[j+6]) LT duplicate_threshold ) then g2[j+6] = -100  
      if( n GE 6 AND j LE n-6) then if ( abs(g2[j] - g2[j+7]) LT duplicate_threshold ) then g2[j+7] = -100  
    endfor
  endif
 
  g3 = g2[where(g2 GE 0)]
  
  for j=0,n_elements(g3 )-1 do begin
    plots,[f[g3[j]] ,f[g3[j]]] ,[-30,10],line=2,color=150
    tvbox,[0.0005,38.0],f[g3[j]],-10,color=fix(50.0+randomu(seed)*200.0),/DATA  
  endfor
 

  while 1 do begin
    print,'Left-click to add, right-click to remove, scroll down to continue, click mouse wheel to replot.'
    ;ch = get_kbrd()
    cursor,x,y,/data,/down
    if( !MOUSE.button EQ 1 ) then begin
      idx = findel( x, f  )
      plots,[f[idx],f[idx]] ,[-30,10],line=1,color=150 
      tvbox,[0.0005,38.0],f[idx],-10,color=fix(50.0+randomu(seed)*200.0),/DATA      
      g4 = [g3,idx]
      g3 = g4[sort(g4)]
      print,f[g3]   
    endif
    if( !MOUSE.button EQ 4 ) then begin
      idx = findel(x,f[g3])
      plots,[f[g3[idx]],f[g3[idx]]] ,[-30,10],line=0,color=0      
      tvbox,[0.0005,38.0],f[g3[idx]],-10,color=0,/DATA 
      g3[idx] = -100
      g3 = g3[where(g3 GE 0)]
    endif
    
    if( !MOUSE.button EQ 16 ) then begin
      if g3[0] EQ -100 then break
      print,f[g3]
      for j=0,n_elements(g3)-1 do begin
        printf,1,rescount,long(g3[j]+fsteps1*i/40),f[g3[j]]
        rescount++
      endfor    
      break
    endif
    
    if( !MOUSE.button EQ 2 ) then begin
      plot,f,m1,yr=[-30,10],/ystyle,/xstyle
      oplot,f,v1,line=1
      if (g3[0] NE -100) then begin
        for j=0,n_elements(g3 )-1 do begin
          plots,[f[g3[j]] ,f[g3[j]]] ,[-30,10],line=2,color=150
          tvbox,[0.0005,38.0],f[g3[j]],-10,color=fix(50.0+randomu(seed)*200.0),/DATA 
        endfor
      endif
    endif
    

  endwhile
  

endfor

close,1

print,'Detected Resonators: ',rescount

end