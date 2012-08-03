
;choose LO
filename = '20110723adr-ws.txt'
datapath = '/Users/bmazin/Data/ResData/20110723adr/fl2/'
outpath = '/Users/bmazin/Data/ResData/20110723adr/fl2/'

data = read_ascii(datapath+filename)
data = data.field1
f = data[2,*]

set_plot,'X'

plot,f,psym=3,/ynozero

LO = 4.10+.256
span = 0.256

n = dblarr(101)
loidx = dblarr(101)
for i=0d,100 do begin
  idx = where(f GT LO-span+i/1000.0 AND f LT LO+span+i/1000.0)
  lohole = where(f GT LO-.003+i/1000.0 AND f LT LO+.003+i/1000.0)
  n[i] = n_elements(idx) - n_elements(lohole)   
  loidx[i] = LO+i/1000.0 
endfor

plot,loidx,n,/ynozero
;cursor,x,y,/data,/down
;print,x
;stop

; sort f
idx = sort(f)

LO = 4.383

outfile = 'fl2-low-final.txt'
openw,1,outpath+outfile

t = 0.0d
count = 0
while 1 do begin
  if (f[count] LT LO + 0.256) then begin
    printf,1, strcompress(string(f[idx[count]]),/remove_all) + '    0.0    0.0    0.0'
    count = count+1 
  endif else break
endwhile
close,1

end