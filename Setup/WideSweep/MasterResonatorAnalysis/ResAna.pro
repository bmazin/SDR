;***************************************************************************
;  ResAna.Pro             Ben Mazin, April, 2009
;
;     This program is designed to do a complete analysis of a resonator
; using discrete modules for the analysis. 
;
;***************************************************************************

;  Load the file containing the instructions for how to proceed
path = '/Users/bmazin/Data/Projects/MasterResonatorAnalysis/'

masterfile = 'resparms2.txt'

line=string(80)
openr,1,strcompress(path+masterfile,/remove_all)
; data path
readf,1,line & datapath = (strsplit(line,/EXTRACT))[0]
; output path
readf,1,line & outpath = (strsplit(line,/EXTRACT))[0]
; resonator Ids
readf,1,line & temp = (strsplit(line,'resnum=',/EXTRACT))[0] & reads,temp,StartRes,EndRes
; attenuator settings
readf,1,line & temp = (strsplit(line,'atten=',/EXTRACT))[0] & reads,temp,StartAtten,EndAtten,StepAtten
; temperature settings
readf,1,line & temp = (strsplit(line,'T=',/EXTRACT))[0] & reads,temp,StartT,EndT,StepT
if (StepT LE 0) then StepT = 1
; background subtraction
readf,1,line & temp = (strsplit(line,'sub=',/EXTRACT))[0] & reads,temp,bg
; skip
readf,1,line & temp = (strsplit(line,'skip=',/EXTRACT))[0] & reads,temp,skip
readf,1,line & temp = (strsplit(line,'Tc=',/EXTRACT))[0] & reads,temp,Tc
readf,1,line & temp = (strsplit(line,'V=',/EXTRACT))[0] & reads,temp,V
readf,1,line & temp = (strsplit(line,'tauqp=',/EXTRACT))[0] & reads,temp,tau
; loss
readf,1,line & temp = (strsplit(line,'loss=',/EXTRACT))[0] & reads,temp,loss
close,1

; print parameters
print,strcompress('Analyzing resonators in groups ' + string(fix(StartRes)) + ' to ' + string(fix(EndRes)))
print,strcompress('At attenuator setting ' + string(fix(StartAtten)) + ' to ' + string(fix(EndAtten)) + ' from ' + string(fix(StartT)) + ' to ' + string(fix(EndT)) + ' mK' )

set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1
;device,filename=strcompress(outpath + 'Series-ps.ps',/remove_all)
      
if( skip EQ 1 ) then goto,TempAna     
      
; set up main loops
for t=StartT,EndT,StepT do begin
  for atten=StartAtten,EndAtten,StepAtten do begin
    for res=StartRes,EndRes do begin
    
      ; Load up the resonator sweep data
      resfile = strcompress(datapath+string(fix(t)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
      
      ; make sure datafile is present and see how many points are in the sweep
      lines = file_lines(resfile) - 7
      if( lines LE 100 ) then begin
        print,'File' + datapath + 'is missing or corrupt.'
        continue
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
     
      if( bg GT 10 ) then begin
        resfile1 = strcompress(datapath+string(fix(bg)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
        openr,1,resfile1
        readf,1,fr1a,fspan1a,fsteps1a,atten1a
        readf,1,fr2a,fspan2a,fsteps2a,atten2a
        readf,1,tsa,tea
        readf,1,Iz1a,Izsd1a
        readf,1,Qz1a,Qzsd1a
        readf,1,Iz2a,Izsd2a
        readf,1,Qz2a,Qzsd2a
        data1a = dblarr(5,lines)
        readf,1,data1a
        close,1   
      endif else begin
        data1a = dblarr(5,lines)
        data1a[*,*] = 0.0
      endelse
      
      ; Set up output postscript file
      device,filename=strcompress(outpath + string(fix(t)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.ps',/remove_all)
      
      r1 = ResFit(data1[*,0:lines/2-1],Iz1,Qz1,(ts+te)/2.0,res*2-1,atten,outpath,data1a[*,0:lines/2-1],Iz1a,Qz1a,bg)
      r2 = ResFit(data1[*,lines/2:lines-1],Iz2,Qz2,(ts+te)/2.0,res*2,atten,outpath,data1a[*,lines/2:lines-1],Iz2a,Qz2a,bg)
     
      ; noise analysis
      noisefile = strcompress(datapath+string(fix(t)) +'-'+ string(fix(res)) +'a-'+ string(fix(atten)) +'.ns',/remove_all) 
      s1 = NoiseAna(0,noisefile,0,r1,data1[*,0:lines/2-1],loss)
      s2 = NoiseAna(1,noisefile,1,r2,data1[*,lines/2:lines-1],loss)     

      device,/close
     
    endfor
  endfor
endfor

TempAna:
; if we swept over temperature, use the data products we just made for further analysis

atten = StartAtten
if( EndT-StartT GT 2 ) then begin
  data = read_ascii(strcompress(outpath+'series-ps.dat',/remove_all))
  data = data.field01

  for res=StartRes,EndRes do begin
    ;Fitf0Q,data,res,atten

    ; Find responsivities
    FitDphiDNqp,data,fix(res),atten,outpath,datapath,StartT,EndT,StepT,Tc,V
   
    ; Compute NEPs
    PlotNEP,data,fix(res),atten,outpath,StartT,tau,Tc 
  endfor


; if power sweep done, plot Q,Qi as a function of readout power
    
endif

end
