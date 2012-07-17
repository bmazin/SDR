;***************************************************************************
;  WideAna-Compare.Pro             Ben Mazin, July, 2011
;
;     This program is designed to do an interactive analysis of widesweep 
; data to check for missing resonators in the ROACH lists.
;
;***************************************************************************

filename = 'FL1-20110723.txt'
datapath = '/Users/bmazin/Data/ResData/20110723adr/fl1/'
outpath = '/Users/bmazin/Data/ResData/20110723adr/fl1/'
;outpath = '/Users/bmazin/Data/ResData/Archive/'

; postscript output setuparr
set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1

stridx = strsplit(datapath,'/')
outfn = strmid(datapath,stridx[4],stridx[5]-stridx[4]-1)
device,filename = strcompress(outpath + outfn + '-ws.ps',/remove_all)

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

; load up list of resonators
;reslist = read_ascii(datapath+'fl1-low-final.txt')
reslist = read_ascii(datapath+'20110723adr-ws.txt')
reslist = reslist.field1
reslist = reslist[2,*]

openw,1, strcompress(outpath + outfn + '-good.txt',/remove_all)
openw,2, strcompress(outpath + outfn + '-bad.txt',/remove_all)
bf=0

set_plot,'X'
!p.multi=[0,1,0]
device,decomposed=0
loadct,2

seed = 10212

for i=0,79 do begin  ; 0,79 should be!
  m = mag[fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  f = data1[0,fsteps1*i/40 : fsteps1*(i+1)/40 - 1]
  v1 = -30.0 + 30.0*v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1] /max(v[fsteps1*i/40 : fsteps1*(i+1)/40 - 1])
  
  ; median subtract baseline
  m1 = m - median(m)
  
  plot,f,m1,yr=[-30,10],/ystyle,/xstyle
  oplot,f,v1,line=1
  
  idx = where( reslist GT f[0] AND reslist LT f[n_elements(f)-1] )
    
  ;for j=0,n_elements(idx)-1 do begin
  ;  plots,[reslist[idx[j]] ,reslist[idx[j]]] ,[-30,10],line=2,color=150
  ;endfor
  
  tmplist = reslist[idx]
     
  ; draw 500 kHz wide box around detected resonator
  for j=0,n_elements(idx)-1 do begin
    tvbox,[0.0005,40.0],tmplist[j],-10,color=fix(50.0+randomu(seed)*200.0),/DATA
  endfor
   
  while 1 do begin
  print,'Press: r to remove, a to add, c to continue.  Left click to add/remove, right to return.'
  ch = get_kbrd()
  if( ch EQ 'c' ) then break
  if( ch EQ 'q' ) then begin
    bf=1
    break
  endif
   
  if( ch EQ 'r' ) then begin   ; add to bad list
  while 1 do begin
    cursor,x,y,/data,/down
    if( !MOUSE.button EQ 1 ) then begin
      plots,[x,x] ,[-30,10],line=0,color=100      
      printf,2,x
    endif
    if( !MOUSE.button EQ 4 ) then break 
  endwhile  
  endif
  
  if( ch EQ 'a' ) then begin    ; add to good list
   while 1 do begin
    cursor,x,y,/data,/down
    if( !MOUSE.button EQ 1 ) then begin
      plots,[x,x] ,[-30,10],line=0,color=50   
      printf,1,x
    endif
    if( !MOUSE.button EQ 4 ) then break 
  endwhile  
  endif
  
  endwhile
  
  if bf EQ 1 then break

endfor

close,1
close,2

print,'Detected Resonators: ',rescount

end