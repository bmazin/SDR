;***************************************************************************
;  WideAna.Pro             Ben Mazin, March, 2011
;
;     This program is designed to do an interactive analysis of widesweep 
; data to get reliable resonance fit data.  This component finds the resonances.
;
;***************************************************************************
;outlabel = '-cmp'
outlabel = '-cmp3'
fname3='fl2_fib_movedsingles'
fname2='fl2_fib_rightsideup_65db'
fname='sci4abeta_after_fib_fingertight_58dbm'
;fname3='fl2-110mk-sci4aBeta'

filename = fname + '.txt'
filename2 = fname2+'.txt'
filename3 = fname3+'.txt'
datapath3 = '/Users/matt/Documents/mazin/widesweepanalysis/20130322/'
datapath2 = '/Users/matt/Documents/mazin/widesweepanalysis/20130308/'
datapath = '/Users/matt/Documents/mazin/widesweepanalysis/20130207/'
;datapath3 = '/Users/matt/Documents/mazin/widesweepanalysis/20130117adr/'
outpath = '/Users/matt/Documents/mazin/widesweepanalysis/20130308/'


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


;Load up the next resfile

resfile2 = strcompress(datapath2+filename2,/remove_all)
lines2 = file_lines(resfile2) - 7
if( lines2 LE 100 ) then begin
  print,'File' + datapath2 + 'is missing or corrupt.'
  stop
endif
      
openr,1,resfile2
readf,1,fr12,fspan12,fsteps12,atten12
readf,1,fr22,fspan22,fsteps22,atten22
readf,1,ts2,te2
readf,1,Iz12,Izsd12
readf,1,Qz12,Qzsd12
readf,1,Iz22,Izsd22
readf,1,Qz22,Qzsd22
data12 = dblarr(5,lines2)
readf,1,data12
close,1

;Now a third file

resfile3 = strcompress(datapath3+filename3,/remove_all)
lines3 = file_lines(resfile3) - 7
if( lines3 LE 100 ) then begin
  print,'File' + datapath3 + 'is missing or corrupt.'
  stop
endif
      
openr,1,resfile3
readf,1,fr13,fspan13,fsteps13,atten13
readf,1,fr23,fspan23,fsteps23,atten23
readf,1,ts3,te3
readf,1,Iz13,Izsd13
readf,1,Qz13,Qzsd13
readf,1,Iz23,Izsd23
readf,1,Qz23,Qzsd23
data13 = dblarr(5,lines3)
readf,1,data13
close,1


;Now both are loaded
;process the first dataset
mag = dblarr(fsteps1*2)
mag[0:fsteps1-1] = sqrt((data1[1,0:fsteps1-1]-Iz1)^2 + (data1[3,0:fsteps1-1]-Qz1)^2)
mag[fsteps1:2*fsteps1-1] = sqrt((data1[1,fsteps1:2*fsteps1-1]-Iz2)^2 + (data1[3,fsteps1:2*fsteps1-1]-Qz2)^2)
mag = 20.0*alog10(mag/max(mag)) ; normalize and go to dB

;Now process the second dataset
mag2 = dblarr(fsteps12*2)
mag2[0:fsteps12-1] = sqrt((data12[1,0:fsteps12-1]-Iz1)^2 + (data12[3,0:fsteps12-1]-Qz12)^2)
mag2[fsteps12:2*fsteps12-1] = sqrt((data12[1,fsteps12:2*fsteps12-1]-Iz22)^2 + (data12[3,fsteps12:2*fsteps12-1]-Qz22)^2)
mag2 = 20.0*alog10(mag2/max(mag2)) ; normalize and go to dB


;Now process the third dataset
mag3 = dblarr(fsteps13*2)
mag3[0:fsteps13-1] = sqrt((data13[1,0:fsteps13-1]-Iz1)^2 + (data13[3,0:fsteps13-1]-Qz13)^2)
mag3[fsteps13:2*fsteps13-1] = sqrt((data13[1,fsteps13:2*fsteps13-1]-Iz23)^2 + (data13[3,fsteps13:2*fsteps13-1]-Qz23)^2)
mag3 = 20.0*alog10(mag3/max(mag3)) ; normalize and go to dB


;Now plot both in the same ps
!p.multi=[0,1,5]
xstretch=80
for i=0,(2*xstretch-1) do begin
  plot,data1[0,fsteps1*i/xstretch : fsteps1*(i+1)/xstretch - 1],mag[fsteps1*i/xstretch : fsteps1*(i+1)/xstretch - 1],xtitle='Frequency (GHz)',ytitle='S21 (dB)',color=100,/xstyle,/ystyle
  ;plots,data12[0,fsteps12*i/10 : fsteps12*(i+1)/10 - 1],mag2[fsteps12*i/10 : fsteps12*(i+1)/10 - 1]-2
  fstart=data1[0,fsteps1*i/xstretch]
  fstop=data1[0,fsteps1*(i+1)/xstretch - 1]
  istart=where(abs(fstart-data12[0,*]) lt 0.00001)
  istart=istart[0]
  istop=where(abs(fstop-data12[0,*]) lt 0.00001)
  istop=istop[0]

  plots,data12[0,istart : istop],mag2[istart : istop]
  
  istart=where(abs(fstart-data13[0,*]) lt 0.00001)
  istart=istart[0]
  istop=where(abs(fstop-data13[0,*]) lt 0.00001)
  istop=istop[0]
  plots,data13[0,istart : istop],mag3[istart : istop],color=50
endfor

; IQ velocity doesn't find low Q resontors well...  Lets try to detrend small segments of the mag data and looks at s21
device,/close

print, 'Resonator list saved in: ', outpath, filename

end