
; frequency optimizer for ARCONS - only looks for negative image beating

function NumGood,freqs,fclk,ifhole,if1
  ; For a given IF, return the number of good resonators
  
  ; find the array indicies nearest to the appropriate frequency cutoffs
  bot = findel(if1-fclk,freqs)
  lmid = findel(if1-ifhole,freqs)
  tmid = findel(if1+ifhole,freqs)
  top = findel(if1+fclk,freqs)
  ;print,bot,lmid,tmid,top
  
  ; adjust the indicies
  if (freqs[bot] LT if1-fclk ) then bot+=1
  if (freqs[lmid] GT if1-ifhole ) then lmid-=1  
  if (freqs[tmid] LT if1+ifhole ) then tmid+=1
  if (freqs[top] GT if1+fclk ) then top-=1
  
  ;print,bot,lmid,tmid,top
  good = (lmid-bot) + (top-tmid)
  
  ; now screen for reflection beating
  ;freqs1 = freqs[bot:top] - if1
  ;badlist = list()
  ;newmid = findel(0.0,freqs1)
  ;if( newmid GT 0.0 ) then newmid -=1
 
  ;for i=0,newmid do begin
  ;  j = findel( -freqs1[i], freqs1)
  ;  if ( abs(-freqs1[i] - freqs1[j]) LT 0.000250 ) then begin
  ;    ;print,'.'
  ;    ;good -=2
  ;    badlist.Add,i
  ;    badlist.Add,j
  ;  endif
  ;endfor
  
  ; combine the two bad lists to get a final count of good resonators
  ;bad = badlist.Count()
  ;for i=0,seclist.Count()-1 do begin
  ;  val = badlist.Count( seclist[i] )
  ;  if ( val EQ 0 ) then bad +=1
  ;endfor 
  
  ;print,good,bad
  return,good
end

function Beat,freqs,fclk,ifhole,filts,if1,if2
  ; if1 is LT if2!
  ; look for negative image interaction 

  if( if2 - if1 GT 2.0*filts ) then return,0
  nbeat=0

  ; IF1 low end interfering with IF2 low end  
  ; Generate list of undesired images
  freqs1 = freqs-if1
  ims = where( freqs1 GE -fclk AND freqs1 LE -fclk+(filts-fclk))  
  if (ims[0] NE -1) then begin
    ;print, freqs1[ims]
    images = 2.0*fclk+freqs1[ims]
    ;print, images
    for i=0,n_elements(images)-1 do begin
      nr = findel(images[i],freqs1)
      ;print, nr,freqs1[nr]
      if( abs(freqs1[nr] - images[i] LE .000300 ) ) then begin
        nbeat += 1
        ;print,'collision!'
      endif
    endfor
  endif

  ; IF2 high end interfering with IF1 high end  
  ; Generate list of undesired images
  freqs1 = freqs-if2
  ims = where( freqs1 LE fclk AND freqs1 GE fclk-(filts-fclk))  
  if (ims[0] NE -1) then begin
    ;print, freqs1[ims]
    images = -2.0*fclk+freqs1[ims]
    ;print, images
    for i=0,n_elements(images)-1 do begin
      nr = findel(images[i],freqs1)
      ;print, nr,freqs1[nr]
      if( abs(freqs1[nr] - images[i] LE .000300 ) ) then begin
        nbeat += 1
        ;print,'collision!'
      endif
    endfor
  endif
 
  return,nbeat
end

; readout parameters
fclk = 0.256      ; A/D bandwidth in GHz (clock/2)
filts = 0.330     ; anti-aliasing cutoff frequency in GHz
ifhole = 0.003    ; half the width of the IF hole in GHz
;datafile = '/Users/bmazin/Data/Projects/MasterWidesweepAnalysis/PickEm/20120823_FL1_100mK_gold0-good.txt'
;datafile = '/Users/bmazin/Data/Projects/MasterWidesweepAnalysis/PickEm/20120823_FL2_100mK_gold0-good.txt'
;datafile = '/Users/bmazin/Data/Projects/MasterWidesweepAnalysis/PickEm/Lick-FL1-good.txt'
datafile = '/Users/bmazin/Data/Projects/MasterWidesweepAnalysis/PickEm/FL2-sci4alpha-tminus3-right.txt'

; load up refined frequency list and plot
data = read_ascii(datafile)
data = data.field1
freqs = data[2,*]

set_plot,'X'
device,Decomposed=0
loadct,2
;plot,data[0,*],freqs,psym=3

bs = 0.02
hist = histogram( freqs, MIN = 0.0, MAX = 6.5, BINSIZE = bs)
bins = FINDGEN(N_ELEMENTS(hist))*bs
plot, bins,hist,psym=10,/ystyle,yr=[0,max(hist)*1.1],xr=[2.8,6.0],/xstyle,xtitle='Offest Frequency (GHz)'

; plot number of good resonators as a function of IF frequency

;idx = 3.0 + dindgen(3000)/1000.0
;ngood = dblarr(3000)

;print,Beat(freqs,fclk,ifhole,filts,3.8,4.27)
;print,NumGood(freqs,fclk,ifhole,3.8)

; Monte Carlo IF freqs to look for best frequency position
p=dblarr(4)
bestp=dblarr(4)
bestcount=0
bestgood=0
bestbeat=0
y = freqs
for i=0L,3e5 do begin
  p[0] = 3.278 - 0.10 + randomu(seed)*0.2
  p[1] = 3.959 - 0.10 + randomu(seed)*0.2
  p[2] = 4.482 - 0.10 + randomu(seed)*0.2
  p[3] = 5.100 - 0.10 + randomu(seed)*0.2 
  
  ;p[0] = 3.38 - 0.15 + randomu(seed)*0.2
  ;p[1] = 3.93 - 0.15 + randomu(seed)*0.2
  ;p[2] = 4.60 - 0.15 + randomu(seed)*0.2
  ;p[3] = 5.35 - 0.15 + randomu(seed)*0.2  
  
  if( abs(p[0]-p[1]) LE 2.0*fclk ) then continue
  if( abs(p[2]-p[1]) LE 2.0*fclk ) then continue
  if( abs(p[3]-p[2]) LE 2.0*fclk ) then continue

  totgood = NumGood(y,fclk,ifhole,p[0]) + NumGood(y,fclk,ifhole,p[1]) + NumGood(y,fclk,ifhole,p[2]) + NumGood(y,fclk,ifhole,p[3])
  totbeat = Beat(y,fclk,ifhole,filts,p[0],p[1]) + Beat(y,fclk,ifhole,filts,p[1],p[2]) +  Beat(y,fclk,ifhole,filts,p[2],p[3])
  tot = totgood-totbeat
  if( tot GT bestcount) then begin
    bestp = p
    bestcount = tot
    bestgood=totgood
    bestbeat=totbeat
  endif
endfor

print,'Best IFs = ',bestp
print,'Clear resonator count (clear, present, bad) = ',bestcount,bestgood,bestbeat

p = bestp
histmax = max(hist)
for j=0,3 do begin
  plots,[p[j],p[j]],[0,histmax],line=1,color=50*(j+1)
  plots,[p[j]-fclk,p[j]-fclk],[0,histmax],line=0,color=50*(j+1)
  plots,[p[j]+fclk,p[j]+fclk],[0,histmax],line=0,color=50*(j+1)
endfor

end