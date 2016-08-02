;***************************************************************************
;  autofit.pro             Ben Mazin, March, 2011
;
;     This program is designed to do an autmatic analysis of widesweep 
; data to get resonance fit data.  This program fits the resonators.
;
;Made some changes here to account for new GUI format -R Dodkins
;***************************************************************************


fname='Ukko_DARKNESS_FL1-1'
outlabel = '-good'
filename = fname + '.txt'
datapath = '/Scratch/labData/20160706/'
outpath = '/Scratch/labData/20160706/'

swpname = fname + '.txt'
resloc = fname + outlabel+'.txt'
;outpath = '/Users/bmazin/Data/ResData/Archive/'
width = 50 ; base width of fit
atten=75

; postscript output setup
set_plot,'ps'
device,/color,encapsulated=0
loadct,4
!p.multi=[0,1,1]
!P.FONT = 0
device,/helv,/isolatin1      
device,font_size=12,/inches,xsize=7.5,ysize=9,xoffset=.5,yoffset=1

stridx = strsplit(datapath,'/')
device,filename = strcompress(outpath + fname + outlabel+'-fits.ps',/remove_all)

;load resonance locations
res = read_ascii(outpath+resloc)
res = res.field1
n = n_elements(res[0,*])
;stop
;load widesweep data
resfile = strcompress(datapath+swpname,/remove_all)
lines = file_lines(resfile) - 7
if( lines LE 100 ) then begin
  print,'File' + datapath + 'is missing or corrupt.'
  stop
endif

openr,1,resfile
;readf,1,fr1,fspan1,fsteps1,atten1
;readf,1,fr2,fspan2,fsteps2,atten2
;readf,1,ts,te
;readf,1,Iz1,Izsd1
;readf,1,Qz1,Qzsd1
;readf,1,Iz2,Izsd2
;readf,1,Qz2,Qzsd2

header = STRARR(3) 
readf,1,header

;readf,1,power, power_val
;readf,1,if_b, if_b_val
;readf,1,ave, ave_val

ts = 0.100
te = 0.100
Iz1 =0.000
Izsd1 =0.000
Qz1 =0.000
Qzsd1 =0.000
Iz2= 0.000
Izsd2=0.000
Qz2= 0.000
Qzsd2=0.000

data1 = dblarr(3,lines)
readf,1,data1
close,1

;stop

m = lines/2-1

; work ok if data sweep taken in the reverse direction
if( data1[0,0] GT data1[0,10] ) then begin
  data1[0,0:m] = reverse(data1[0,0:m],2)
  data1[1,0:m] = reverse(data1[1,0:m],2)
  data1[2,0:m] = reverse(data1[2,0:m],2)
  ;data1[3,0:m] = reverse(data1[3,0:m],2)
  ;data1[4,0:m] = reverse(data1[4,0:m],2)

  data1[0,m+1:lines-1] = reverse(data1[0,m+1:lines-1],2)
  data1[1,m+1:lines-1] = reverse(data1[1,m+1:lines-1],2)
  data1[2,m+1:lines-1] = reverse(data1[2,m+1:lines-1],2)
  ;data1[3,m+1:lines-1] = reverse(data1[3,m+1:lines-1],2)
  ;data1[4,m+1:lines-1] = reverse(data1[4,m+1:lines-1],2)    
endif
    
;data1a = dblarr(5,lines)
;data1a[*,*] = 0.0

; get rid of any zeros in errors
;if(where(data1[2,*] LT 1d-6) NE -1 ) then data1[2, where(data1[2,*] LT 1d-6) ] = 1d-6
;if(where(data1[4,*] LT 1d-6) NE -1 ) then data1[4, where(data1[4,*] LT 1d-6) ] = 1d-6
;data1[2, * ] = 1d-6
;data1[4, * ] = 1d-6

data1a = dblarr(3,lines)
data1a[*,*] = 0.0

;set_plot,'X'
;!p.multi=[0,1,0]
;loadct,2
;device,decomposed=0
;A = FINDGEN(17) * (!PI*2/16.)
;USERSYM, COS(A), SIN(A), /FILL

openw,1, strcompress(outpath + fname + outlabel+'-fits.txt',/remove_all)
;print,n_elements(data1[0,*])
;loop over all the resonators
print,n-1
for j=0,n-1 do begin
;for j=0,2 do begin
  ;stop
  ;print,'res[1,'+STRTRIM(j,2)+']: ' +STRING(res[1,j])
  indStart = res[1,j]-width
  indEnd = res[1,j]+width+1
  
  ;indStart=indStart+10
  indEnd=indEnd-10
  
  if indStart LT 0 then begin
    print, 'Error: resonator too close to begining of data collection'
    indStart = 0
  endif
  
  if indEnd GE n_elements(data1[0,*]) then begin
    print, 'Error: resonator too close to end of data collection'
    indEnd = n_elements(data1[0,*])-1
  endif
  
  
  f = data1[0, indStart:indEnd ]
  I = data1[1, indStart:indEnd ]
  Q = data1[2, indStart:indEnd ]  

  ;plot,I,Q,psym=8
  cent = findel( res[1,j]/1d9, data1[0,*] )
  ;print,cent
  ;if( cent LT m ) then r1 = ResFit(data1[*,res[1,j]-width:res[1,j]+width+1],Iz1,Qz1,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,res[1,j]-width:res[1,j]+width+1],Iz1a,Qz1a,0)
  ;if( cent GE m ) then r1 = ResFit(data1[*,res[1,j]-width:res[1,j]+width+1],Iz2,Qz2,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,res[1,j]-width:res[1,j]+width+1],Iz2a,Qz2a,0)
  if( cent LT m ) then r1 = ResFit(data1[*,indStart:indEnd],Iz1,Qz1,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,indStart:indEnd],Iz1a,Qz1a,0)
  if( cent GE m ) then r1 = ResFit(data1[*,indStart:indEnd],Iz2,Qz2,fix(1000.0*((ts+te)/2.0)),j,atten,outpath,data1a[*,indStart:indEnd],Iz2a,Qz2a,0)
  
 
 
 
  ;return,[radius,p[8],p[9],Izero,Qzero,p[0],Qc,Qi,p[1],atten,sqrt(bestchisq/DOF)]
  Q = r1[5]
  Qi = r1[7] 
  Qc = r1[6]
  f0 = r1[8]/1d9
  chisq = r1[10]
 
  print,j,f0,Q,Qc,Qi,chisq,format='(i4,F17.6,4F17.2)'
  printf,1,j,f0,Q,Qc,Qi,chisq,format='(i4,F17.6,4F17.2)'
   
  ;ch = get_kbrd()
  ;if (ch EQ 'q') then break
endfor

close,1
device,/close

end