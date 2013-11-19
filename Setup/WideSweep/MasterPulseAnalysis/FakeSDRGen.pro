
; generate fake data to test the SDR template gen

N = 256*1000L
outfile = '/Users/bmazin/Data/Projects/MasterPulseAnalysis/fakeSDR.dat'

chan = uint(0)
phase = uintarr(2000)

openw,1,outfile

for i=0,N-1 do begin
  chan = uint( (randomu(seed)*256) )
  phase = uint(2000.0 + randomn(seed,2000)*20.0)
  loc = fix(randomn(seed)*10.0)
  phase[1000-loc:1900-loc] -= uint( 400.0 * randomu(seed) * exp(-indgen(1000)/20.0) ) 

  writeu,1,chan
  writeu,1,phase

endfor

close,1

end