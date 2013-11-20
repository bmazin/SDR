;***************************************************************************
;  PulseAna.Pro             Ben Mazin, May, 2010
;
;     This program is designed to do a complete analysis of pulses from
; MKIDs.  The analysis is done in interchangeable modules for flexibity.
;
;***************************************************************************

;  Load the file containing the instructions for how to proceed
path = '/Users/bmazin/Data/Projects/MasterPulseAnalysis/'
cd,path
masterfile = 'pulse.txt'

line=string(200)
openr,1,strcompress(path+masterfile,/remove_all)

; data path
readf,1,line & datapath = (strsplit(line,/EXTRACT))[0]
; output path
readf,1,line & outpath = (strsplit(line,/EXTRACT))[0]
; archive path
readf,1,line & arpath = (strsplit(line,/EXTRACT))[0]

; pulse data file name
readf,1,line & pulsename = (strsplit(line,/EXTRACT))[0]
; resonator Ids
readf,1,line & temp = (strsplit(line,'resnum=',/EXTRACT))[0] & reads,temp,StartRes
; attenuator settings
readf,1,line & temp = (strsplit(line,'atten=',/EXTRACT))[0] & reads,temp,StartAtten
; temperature settings
readf,1,line & temp = (strsplit(line,'T=',/EXTRACT))[0] & reads,temp,StartT
; background subtraction
readf,1,line & temp = (strsplit(line,'sub=',/EXTRACT))[0] & reads,temp,bg
; loss
readf,1,line & temp = (strsplit(line,'loss=',/EXTRACT))[0] & reads,temp,loss
; template
readf,1,line & template = (strsplit(line,/EXTRACT))[0] ;& reads,temp,template
; loss
readf,1,line & noise = (strsplit(line,/EXTRACT))[0] ;& reads,temp,noise
close,1

; postscript output setup
set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,2]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1

; set up main loops
atten=StartAtten
res=StartRes

; fit sweep data if not done already    
if ((FILE_INFO(strcompress(datapath+string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.ps',/remove_all))).EXISTS EQ 0) then begin
; Load up the resonator sweep data
resfile = strcompress(datapath+string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.swp',/remove_all)
      
; make sure datafile is present and see how many points are in the sweep
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
      
; Set up output postscript file
fitname = strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.ps',/remove_all)
device,filename=fitname
r1 = ResFit(data1[*,0:lines/2-1],Iz1,Qz1,(ts+te)/2.0,res*2-1,atten,outpath,data1a[*,0:lines/2-1],Iz1a,Qz1a,bg)
r2 = ResFit(data1[*,lines/2:lines-1],Iz2,Qz2,(ts+te)/2.0,res*2,atten,outpath,data1a[*,lines/2:lines-1],Iz2a,Qz2a,bg)
     
; noise analysis
noisefile = strcompress(datapath+string(fix(StartT)) +'-'+ string(fix(res)) +'a-'+ string(fix(atten)) +'.ns',/remove_all) 
s1 = NoiseAna(0,noisefile,0,r1,data1[*,0:lines/2-1],loss)
s2 = NoiseAna(1,noisefile,1,r2,data1[*,lines/2:lines-1],loss)     

device,/close
endif
      
; generate quick initial template, return median, sd of distributions
if (template EQ '0') then begin
  print,'Initial Template Generation'
  pm = QuickTemplateGen(datapath,outpath,pulsename,StartT,atten,res)
  
  ; cheat
  ;pm = [80.0,20.0,80.0,20.0,pm[4]*5.0,pm[5]*5.0]
  ;pm = [100.0,15.0,100.0,15.0,pm[4]*1.5,pm[5]*1.5]
  
  ; generate final template
  life=dblarr(6)
  print,'Final Template Generation'
  FinalTemplateGen,datapath,outpath,pulsename,StartT,atten,res,pm,life
endif else begin
  ; use quicktemplategen to make pm
  pm = QuickTemplateGen(datapath,outpath,pulsename,StartT,atten,res)
  ; copy template and noise files to conventional places
  FILE_COPY,template,datapath+'Template-2pass.dat',/OVERWRITE
  FILE_COPY,noise,datapath+'NoiseSpectra-2pass.dat',/OVERWRITE
endelse

; optimal filter pulses
print,'Optimal Pulse Filtering'
OptimalPulseFilter,datapath,outpath,pulsename,StartT,atten,res,pm

; generate histograms
print,'Fitting Histograms'      
phr = dblarr(4)
HistoFit,datapath,outpath,pulsename,t,atten,res,pm,phr

; estimate device performance from template and noise spectra
ResEstimates,datapath,outpath,pulsename,t,atten,res,pm,life,phr,loss
     
; merge all files into one data file
fitname = strcompress(outpath + string(fix(StartT)) +'-'+ string(fix(res)) +'-'+ string(fix(atten)) +'.ps',/remove_all)
merge = strcompress(fitname + ' ' + outpath+'template.ps ' + outpath + 'template-secondpass.ps ' + outpath + 'strip.ps ' + outpath + 'histfit.ps ' + outpath + 'ResEstimates.ps' ) 
cmd = strcompress('/usr/local/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=' +outpath+ 'MergedAnalysis.pdf ' + merge)
SPAWN,cmd

; generate merged file name for archive
dirs = strsplit(datapath,'/',/EXTRACT)
outname = strcompress(arpath + dirs[4] + '-' +  dirs[5] + '.pdf',/remove_all)

; copy merged file to archive
cmd = strcompress('cp ' + outpath + 'MergedAnalysis.pdf' + ' ' + outname )
SPAWN,cmd
     
end