import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools

#Use this program to view the overall histogram of photons seen by a single roach.  From that plot, pick a time interval to plug into FindGoodPix.py to find the best pixels.  Use that plot to tell you about when the first peak starts (since the first peak is typically too small to be detected by this program).
#This program outputs a matrix of indices along with peakw and troughw. Use this information to input the initial start value (ini), peakw (pk), and troughw (tr) into qeplotforpixels.py

qeDataFilename= '/home/sean/data/20121010/obs_20121010-215637.h5'
qeObsTime=1349906199

NPixels=253
NSec=1800
ncutoff=100    
# This is the value of the derivative that defines a pulse.  The horizontal lines in the plot of the derivative are set at this height

roach=4

def peakfit(y1,y2,y3):
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

def binToDeg_12_9(binOffset12_9):
	x = binOffset12_9/2.0**9-4.0
	return x*180.0/np.pi

photonSec=[]

pulseMask = int(12*'1',2)#bitmask of 12 ones

fid = tables.openFile(qeDataFilename,mode='r')
pulseh=[[] for x in xrange(NSec)]

#for pix in xrange(0,NPixels):
for pix in [16]:
      dataset=fid.getNode('/r%d/p%d/t%d'%(roach,pix,qeObsTime))
      for ind, sec in enumerate(dataset):
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
for t in pulseh:
   photonSec.append(len(t))
	
# photonSec has the total number of photons per second, 
 
plt.plot(photonSec)
plt.xlabel('Time')
plt.ylabel('Number of Photons')
plt.title('# Photons vs. Time')
plt.grid(True)
plt.show()

der=[]
   
for t in xrange(0, len(photonSec)-1):
   der.append(photonSec[t+1]-photonSec[t])

x=[1,NSec/2,NSec]
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
       if abs(indi[x+1]-indi[x]) <= 5 :
            del indi[x+1]
if len(indi)%2 != 0:
	del indi[len(indi)-1]

print 'Peak indices are:' 
print indi
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
print 'peakw = %f'%peakw
print 'troughw = %f'%troughw

fid.close()
