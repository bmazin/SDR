
; sort pixels onto a better grid

outfile = '/Users/bmazin/Data/Projects/BeamMap/2013BnewSCI4/freq_atten_x_y-fixed.txt'
data0 = read_ascii(  '/Users/bmazin/Data/Projects/BeamMap/2013BnewSCI4/freq_atten_x_y.txt' ,/DOUBLE)
data0 = data0.field1

pix = dblarr(44,46)
pix[*,*] = 0.0

extra = dblarr(5,2000)
count = 0
unplaced = dblarr(5,2000)
upcount = 0

for i=0.0,43 do begin
  for j=0.0,45 do begin
    Xidx = where( data0[2,*] GE i AND data0[2,*] LT i+1.0)
    Yidx = where( data0[3,*] GE j AND data0[3,*] LT j+1.0)
    if( Xidx[0] GT -1 and Yidx[0] GT -1) then begin
      idx = cmset_op(Xidx, 'AND', Yidx)
    
      ;idx = where( Xidx EQ Yidx)
      ;print,idx,Xidx,Yidx
      ;print,idx[0],data0[0,idx[0]]
      if( idx[0] EQ -1 ) then continue
      if( n_elements(idx) EQ 1 ) then begin
        pix[i,j] = data0[0,idx[0]]
        continue
      endif else begin  
        ; if more than one resonator in this location put closest to the center in the pixel, then store the rest in a list
        ; determine closest
        d = sqrt( (i+0.5 - data0[2,idx])^2 + (j+0.5 - data0[3,idx])^2 )
        sv = where( d EQ min(d) )
        pix[i,j] = data0[0,idx[sv]]
        
        ; rest go into list
        for k=0,n_elements(idx)-1 do begin
          if( k EQ sv ) then continue
          extra[*,count] = data0[*,idx[k]]
          count+=1
        endfor        
      endelse
    endif
  endfor
endfor

print,extra[*,0:count-1]
print,'Number of Overlaps = ',count
remain = count

; find an empty pixel nearby real location to drop pixel into
d = dblarr(9)
for i=0,count-1 do begin
  ; calculate distance to all empty nearest neighbors
  placed=0
  xc = extra[2,i]
  yc = extra[3,i]
  xcr = double(round(xc))
  ycr = double(round(yc))

  d[0] = sqrt( (xc - xcr-1.0)^2 + (yc - ycr-1.0)^2 )
  d[1] = sqrt( (xc - xcr-0.0)^2 + (yc - ycr-1.0)^2 )
  d[2] = sqrt( (xc - xcr+1.0)^2 + (yc - ycr-1.0)^2 )
  d[3] = sqrt( (xc - xcr-1.0)^2 + (yc - ycr-0.0)^2 )
  d[4] = 10.0; sqrt( (xc - xcr-0.0)^2 + (yc - ycr-0.0)^2 )
  d[5] = sqrt( (xc - xcr+1.0)^2 + (yc - ycr-0.0)^2 )
  d[6] = sqrt( (xc - xcr-1.0)^2 + (yc - ycr+1.0)^2 )
  d[7] = sqrt( (xc - xcr-0.0)^2 + (yc - ycr+1.0)^2 )
  d[8] = sqrt( (xc - xcr+1.0)^2 + (yc - ycr+1.0)^2 )

  ;print,min(d)
  idx = sort(d)
  ;print,d[idx]

  for j=0,7 do begin
    
    case idx[j] of
      0: begin
          xc1 = xcr-1.0
          yc1 = ycr-1.0
         end
      1: begin
          xc1 = xcr-0.0
          yc1 = ycr-1.0
         end
      2: begin
          xc1 = xcr+1.0
          yc1 = ycr-1.0
         end
      3: begin
          xc1 = xcr-1.0
          yc1 = ycr-0.0
         end
      5: begin
          xc1 = xcr+1.0
          yc1 = ycr-0.0
         end
      6: begin
          xc1 = xcr-1.0
          yc1 = ycr+1.0
         end
      7: begin
          xc1 = xcr-0.0
          yc1 = ycr+1.0
         end
      8: begin
          xc1 = xcr+1.0
          yc1 = ycr+1.0
         end
    endcase
    
    ; is closest pixel occupied?
    if( xc1 LT 0.0 OR xc1 GT 43.0 ) then continue
    if( yc1 LT 0.0 OR yc1 GT 45.0 ) then continue 
    if( pix[xc1,yc1] GT 0.0 ) then continue
    
    pix[xc1,yc1] = extra[0,i]
    placed = 1
    remain -= 1
    ;print,'X'
    break
    
  endfor  
  
  if (placed EQ 0) then begin
    unplaced[*,upcount] = extra[*,i]
    upcount += 1
  endif

endfor

print,'Unplaced = ',remain

print,unplaced[*,0:upcount-1] 

; Output file

outlist = dblarr(5,2000)
outcount = 0
for i=0.0,43 do begin
  for j=0.0,45 do begin
    if( pix[i,j] GT 0.0) then begin
      idx = findel(pix[i,j],data0[0,*])
      outlist[*,outcount] = data0[*,idx]
      outlist[2,outcount] = i
      outlist[3,outcount] = j
      outcount +=1
    endif  
  endfor
endfor

sidx = sort((outlist[0,0:outcount-1])[*])

openw,1,outfile
for i=0,outcount-1 do printf,1,outlist[*,sidx[i]]
close,1

; plot it!
plt = dblarr(44,46)
for i=0.0,43 do begin
  for j=0.0,45 do begin
    if( pix[i,j] GT 0.0 ) then plt[i,j] = 1.0
  endfor
endfor

set_plot,'X'
tvscl,rebin(plt,440,460,/sample)
;device,/close
  
end