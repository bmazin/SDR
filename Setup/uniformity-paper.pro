
resloc = 'CombinedPalDeviceFits.txt'
swpname = 'FL1-20110723.txt'
datapath = '/Users/bmazin/Data/ResData/20110723adr/'
outpath = '/Users/bmazin/Data/ResData/20110723adr/'

set_plot,'ps'
device,/color,encapsulated=1
!p.multi=[0,2,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=8,/inches,xsize=6,ysize=4
device,filename=outpath+'fig3.eps'
loadct,2

!y.margin=[4,1]
!x.margin=[8,3]

data = read_ascii(outpath+resloc)
data = data.field1

f = data[1,*]
Q = data[2,*]
s = n_elements(data[1,*])

; filter out bad fits
;idx = where( data[2,*] NE 50000.0 AND data[2,*] GT 2000.0 AND data[2,*] LT 1e6) 
;data = data[*,idx]

; panel 1 - S21 vs freq
;   make sure datafile is present and see how many points are in the sweep
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

; plot magnitude widesweep data in 10 segments
mag = dblarr(fsteps1*2)
mag[0:fsteps1-1] = sqrt((data1[1,0:fsteps1-1]-Iz1)^2 + (data1[3,0:fsteps1-1]-Qz1)^2)
mag[fsteps1:2*fsteps1-1] = sqrt((data1[1,fsteps1:2*fsteps1-1]-Iz2)^2 + (data1[3,fsteps1:2*fsteps1-1]-Qz2)^2)

mag = 20.0*alog10(mag/max(mag)) ; normalize and go to dB

i=2
plot,data1[0,fsteps1*i/10 : fsteps1*(i+1)/10 - 1],mag[fsteps1*i/10 : fsteps1*(i+1)/10 - 1],xtitle='Frequency (GHz)',ytitle='|S!L21!N| (dB)',/xstyle,/ystyle,yr=[-25,0]

; panel 2 - QE

; load up and rebin QE data
QE = read_ascii('/Users/bmazin/Data/Projects/ARCHONS2Sens/QE.txt',data_start=1)
QE = QE.field1
plot,QE[0,*],QE[3,*],/ystyle,xr=[200,3000],/xlog,xtitle='Wavelength (nm)',ytitle='Detector Quantum Efficiency' ,yr=[0.0,0.8],/xstyle
xyouts,185,-.07,'200'
xyouts,480,-.07,'500'
xyouts,2700,-.07,'3000'

; panel 3 - Q hist
hist = histogram( Q, MIN = 0, MAX = 5e5, BINSIZE = 3e3)
hist[0:1] = 0.0 
bins = FINDGEN(N_ELEMENTS(hist))*3e3
plot,bins,hist,psym=10,xtitle='Measured Q',ytitle='Number of Resonators',xr=[5000.0,1.2e5],/xstyle,xtickformat='(I7)',xtickinterval=30000;xticks=4,xtickv=[0.0,30000.0,60000.0,90000.0,120000.0],xtickname=['0','30000','60000','90000','120000']


; panel 4 - nearest neighbors

; calculate distance to nearest neighbor instead of just one sided distance.
d = dblarr(s)
bad = 0
d[0] = f[1] - f[0]
d[s-1] = f[s-1] - f[s-2]
for i=1,s-2 do begin
  d[i] = min( [ f[i] - f[i-1], f[i+1] - f[i] ] ) 
  ;print, data[1,i] - data[1,i-1], data[1,i+1] - data[1,i] 
  if( d[i] LT 0.0005) then bad++
endfor

d = d*1e3
hist = histogram( d, MIN = 0, MAX = 8, BINSIZE = 0.15)
hist[0] = 0
bins = FINDGEN(N_ELEMENTS(hist))*0.15
plot,bins,hist,xtitle='Nearest Neighbor (MHz)',ytitle='Number of Resonators',/ynozero,psym=10,/xstyle,/ystyle,xr=[0,6],yr=[0,100]
plots,[0.5,0.5],[0,100.0],line=1,color=100
;xyouts,1,25,strcompress(string(bad) + ' out of ' + string(s) + ' Resonators Collide') ; (' + string(100.0*float(bad)/float(s),format='(F4.2)') + '%)'        )


device,/close


end