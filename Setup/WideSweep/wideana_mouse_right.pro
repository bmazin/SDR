;***************************************************************************
;  WideAna.Pro             Ben Mazin, March, 2011
;
;     This program is designed to do an interactive analysis of widesweep 
; data to get reliable resonance fit data.  This component finds the resonances.
;
;***************************************************************************

;fname='sci4abeta_fib2_68dBm'
;fname2='fl2-110mk-sci4aBeta'
fname='fl1_fib_again_noisy_65dB'
outlabel = '-right'
filename = fname + '.txt'
datapath = '/Users/matt/Documents/mazin/widesweepanalysis/20130228/'
;datapath2 = '/Users/matt/Documents/mazin/widesweepanalysis/20130117adr/'
outpath = '/Users/matt/Documents/mazin/widesweepanalysis/20130228/'
;outpath2 = '/Users/matt/Documents/mazin/widesweepanalysis/20130117adr/'
duplicate_threshold=50; 50 to avoid collisions, 10 to include collisions
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
device,filename = strcompress(outpath + fname + outlabel + '.ps',/remove_all)

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

openw,1, strcompress(outpath + fname+outlabel+'.txt',/remove_all)

set_plot,'X'
!p.multi=[0,1,0]
loadct,2
device,decomposed=0


resonantFreq=make_array(80,/PTR)
resonantLoc=make_array(80,/PTR)
numBreaks = 79  ;should be 79

for i=0,numBreaks do begin  ; 0,79 should be!
  print,'Left-click to add, right-click to remove, scroll-down to continue, scroll-up to go back, click mouse wheel to replot.'
  print, 'frame '
  print, i
  m = mag[fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  f = data1[0,fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  v1 = -30.0 + 30.0*v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1] /max(v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1])
  ;v1 = -30.0 + 15.0*v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1] /mean(v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1])
  
  ; median subtract baseline
  m1 = m - median(m)
  
  plot,f,m1,yr=[-30,10],/ystyle,/xstyle
  oplot,f,v1,line=1
  
  ; first guess at resonators
  auto_peak_sensitivity = 5

  g2 = peaks(v1,auto_peak_sensitivity)
  
  ;eliminate doubles

  n = n_elements(g2)-1
  if( n GT 0 ) then begin
    for j=n,1,-1 do begin
      if( abs(g2[j-1] - g2[j]) LT duplicate_threshold ) then g2[j-1] = -100
      if( n GE 1 AND j GE 2) then if ( abs(g2[j-2] - g2[j]) LT duplicate_threshold ) then g2[j-2] = -100    
      if( n GE 2 AND j GE 3) then if ( abs(g2[j-3] - g2[j]) LT duplicate_threshold ) then g2[j-3] = -100   
      if( n GE 3 AND j GE 4) then if ( abs(g2[j-4] - g2[j]) LT duplicate_threshold ) then g2[j-4] = -100   
      if( n GE 4 AND j GE 5) then if ( abs(g2[j-5] - g2[j]) LT duplicate_threshold ) then g2[j-5] = -100   
      if( n GE 5 AND j GE 6) then if ( abs(g2[j-6] - g2[j]) LT duplicate_threshold ) then g2[j-6] = -100  
      if( n GE 6 AND j GE 7) then if ( abs(g2[j-7] - g2[j]) LT duplicate_threshold ) then g2[j-7] = -100  
    endfor
  endif
 
  g3 = g2[where(g2 GE 0)]
  
  if g3[0] GE 0 then begin
    for j=0,n_elements(g3 )-1 do begin
      plots,[f[g3[j]] ,f[g3[j]]] ,[-30,10],line=2,color=150
      tvbox,[0.0005,38.0],f[g3[j]],-10,color=fix(50.0+randomu(seed)*200.0),/DATA  
    endfor
  endif else begin
    print, 'no peaks found'
  endelse
  
  
  while 1 do begin
    
    ;ch = get_kbrd()
    ;print, g3
    ;print,f[g3]
    
    cursor,x,y,/data,/down
    if( !MOUSE.button EQ 1 ) then begin     ;left mouse click
      idx = findel( x, f  )
      plots,[f[idx],f[idx]] ,[-30,10],line=1,color=150 
      tvbox,[0.0005,38.0],f[idx],-10,color=fix(50.0+randomu(seed)*200.0),/DATA      
      g4 = [g3,idx]
      g3 = g4[sort(g4)]
      g3 = g3[where(g3 GE 0)]
      print,f[g3]   
    endif
    if( !MOUSE.button EQ 4 ) then begin     ;right mouse click
      ;if g3[0] NE -100 then begin
        idx = findel(x,f[g3])
        plots,[f[g3[idx]],f[g3[idx]]] ,[-30,10],line=0,color=0      
        tvbox,[0.0005,38.0],f[g3[idx]],-10,color=0,/DATA 
        g3[idx] = -100
        g3 = g3[where(g3 GE 0)]
        ;print, g3
        ;print, f[g3]
      ;endif
    endif
    
;    if( !MOUSE.button GE 0 ) then begin
;      print, !MOUSE.button
;    endif
    
    if( !MOUSE.button EQ 8 ) then begin       ;scroll up
      if i GT 0 then begin
        resonantFreq[i-1]=PTR_NEW()
        resonantLoc[i-1]=PTR_NEW()
        i=i-2
        print, 'Undone one frame'
        break
      endif
    endif
    
    
    if( !MOUSE.button EQ 16 ) then begin      ;scroll down
      if g3[0] LT 0 then begin
        resonantLoc[i]=PTR_NEW([])
        resonantFreq[i]=PTR_NEW([])
        break
      endif
      
      print,f[g3]
      resonantFreq[i]=PTR_NEW(f[g3])
      resonantLoc[i]=PTR_NEW(g3)
      
      ;for j=0,n_elements(g3)-1 do begin
      ;  printf,1,rescount,long(g3[j]+fsteps1*i/40),f[g3[j]]
      ;  rescount++
      ;endfor
          
      break
    endif
    
    if( !MOUSE.button EQ 2 ) then begin       ;wheel click
      plot,f,m1,yr=[-30,10],/ystyle,/xstyle
      oplot,f,v1,line=1
      if (g3[0] GE 0) then begin
        for j=0,n_elements(g3 )-1 do begin
          plots,[f[g3[j]] ,f[g3[j]]] ,[-30,10],line=2,color=150
          tvbox,[0.0005,38.0],f[g3[j]],-10,color=fix(50.0+randomu(seed)*200.0),/DATA 
        endfor
      endif
      print, f[g3]
    endif
    

  endwhile
  
  ;Uncomment 'read' to prompt end of program
  if i EQ numBreaks then begin
    undo = 1
    ;read,'Press 1 to finish, otherwise 0 to redo this frame: ',undo
    if undo EQ 0 then begin
      resonantFreq[i]=PTR_NEW()
      resonantLoc[i]=PTR_NEW()
      i=i-1
    endif
  endif
  
  ;stop
endfor


;Load data into file
for i=0,numBreaks do begin
  if n_elements(*resonantFreq[i]) GT 0 then begin
    for j=0,n_elements(*resonantFreq[i])-1 do begin
      printf,1,rescount,long((*resonantLoc[i])[j]+fsteps1*i/40),(*resonantFreq[i])[j]
      rescount++
      ;printf,1,rescount,long(g3[j]+fsteps1*i/40),f[g3[j]]
    endfor
  endif
endfor



close, 1
free_lun, 1

print,'Detected Resonators: ',rescount
print, 'Resonator list saved in: ', outpath, filename

end