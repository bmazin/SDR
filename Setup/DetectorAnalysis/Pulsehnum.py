import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools

def peakfit(y1,y2,y3):
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

def binToDeg_12_9(binOffset12_9):
	x = binOffset12_9/2.0**9-4.0
	return x*180.0/np.pi

#allpulseh(
filename='/media/disk2/20120814/obs_20120814-143639.h5'
timesig= 1344980199
rlen=1
plen=256
nrows=3600
ncutoff=1500


histv=[]

pulseMask = int(12*'1',2)#bitmask of 12 ones

fid = tables.openFile(filename,mode='r')
pulseh=[[] for x in xrange(nrows)]
for n in xrange(0,rlen):
   for m in xrange(0,plen):
      a=fid.getNode('/r%d/p%d/t%d'%(n,m,timesig))
      for ind, sec in enumerate(a):
          for packet in sec:
               packet = int(packet)
               beforePeak = binToDeg_12_9(packet>>44 & pulseMask)
               atPeak = binToDeg_12_9(packet>>32 & pulseMask)
               afterPeak = binToDeg_12_9(packet >> 20 & pulseMask)
               if beforePeak+afterPeak-2*atPeak != 0:
                    peak = peakfit(beforePeak,atPeak,afterPeak)
                    peak = atPeak
                    pulseh[ind].append(peak)               
# the peaks for all photons in each second is in its own row of pulseh
for q in pulseh:
   histv.append(len(q))
# histv has the total number of photons per second, we need to identify what
# time intervals correlate to a single wavelength   
plt.plot(histv)
plt.xlabel('Time')
plt.ylabel('Number of Photons')
plt.title('# Photons vs. Time')
plt.grid(True)
plt.show()

der=[]
   
for t in xrange(0, len(histv)-1):
   der.append(histv[t+1]-histv[t])

x=[1,nrows/2,nrows]
y1=[ncutoff,ncutoff,ncutoff]
y2=[-1*ncutoff,-1*ncutoff,-1*ncutoff]
plt.plot(der, 'k', x,y1,'b',x,y2,'b')
plt.xlabel('Time')
plt.ylabel('Derivative of the Number of Photons')
plt.title('Derivative of # Photons vs. Time')
plt.grid(True)
plt.show()

indi = []

for g in xrange(0, len(der)):
   if abs(der[g]) >= ncutoff :
        indi.append(g)
   #remove close indices that correspond to the same peak
for i in indi:
   x = indi.index(i)
   if x+1 != len(indi) :
       if abs(indi[x+1]-indi[x]) <= 75 :
            del indi[x]

   # +- 3 so we don't average the first or last 3 sec in each peak
   initial = indi[0] + 3
   numon = len(indi)//2
   
spw = []
stw = []

for j in xrange(0,numon):
   pw = indi[2*j+1]-indi[2*j]
   spw.append(pw)
for k in xrange(0,numon-1):
   tw = indi[2*(k+1)]-indi[2*k+1]
   stw.append(tw)
peakw = np.average(spw) - 2*3
troughw = np.average(stw) + 2*3

PeakV=[]
PulseH=[]
Names=[]
for f in xrange(0, numon):
   ini = int(math.floor(initial + (peakw+troughw)*f))
   fin = ini + int(math.floor(peakw))
   PeakV=list(itertools.chain.from_iterable(pulseh[ini:fin]))
   PulseH.append([PeakV])
   Names.append('%d WVL'%(f+1))
plt.hist(PulseH, bins=50, histtype='step', label= Names)
plt.xlabel('Pulse Heights')
plt.ylabel('Number of Photons')
plt.title('Pulse Height Histogram all resonators')
plt.grid(True)
plt.legend()
plt.legend(bbox_to_anchor=(1.2, 1.05))

plt.show()
