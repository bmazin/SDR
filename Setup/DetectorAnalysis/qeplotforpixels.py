import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools
from qeforpixelsfunc import *

#This program looks at specific pixels (picked by using FindGoodPix.py) and plots the photon histogram and qe for each. 
#Use qeroughplot.py to figure out peakw,troughw, and ini. dectv is the values (x10^7) seen in the comparison detector (not arcons).

qeDataFilename= '/home/sean/data/20121010/obs_20121010-215637.h5'
#qeDataFilename= '/home/sean/data/20121018/obs_20121019-044657.h5'
qeObsTime=1349906199
#qeObsTime=1350622020
roach=5


#pixlist=[11, 133, 21, 109, 31, 57, 92, 3, 129, 117, 96, 16, 105, 37, 25, 102, 75, 123, 124, 38, 46, 113, 150, 70, 149, 103, 28, 34, 120, 99, 49, 93, 104, 55, 134, 80, 119, 95, 24, 64, 82, 61, 60, 138, 53, 8, 89, 141, 27, 91, 130, 54, 145, 30, 45, 97, 32, 108, 106, 146, 72, 139, 116, 77, 94, 140, 58, 107, 66, 112, 73, 41, 48, 122, 84, 128, 148, 78, 20, 36, 127, 137, 87, 76, 23, 35, 83, 98, 39, 63, 68, 115, 135, 67, 52, 71, 26, 79, 85, 59, 151, 6, 22, 100, 88, 118, 143, 111, 19, 125, 81, 50]
pixlist=[100,115,84,57]
#pixlist=[148,24,85,130,26]

initial=109
#initial=104
peakw=14.6
#peakw=14.6
troughw=54
#troughw=54

#saveFilename='data/qePlots/qe20120824-r7.pdf'
#dectv=[0.149,.497,1.156,2.305,3.820,4.762,5.014,5.746,5.232,5.056,6.466,8.5,10.513,11.783]
#wvl=range(400,1100,50)
testbedFile = np.loadtxt('/home/sean/data/QEmeas/SCI4-nomicrolens-1.txt')
#testbedFile = np.loadtxt('/home/sean/data/QEmeas/SCI4-microlens-20121019-044657.txt')
wvl = testbedFile[:,0]
dectv=testbedFile[:,-1]

NSec=1800

NPulses = NumPhotonInWVLPulses(qeDataFilename, qeObsTime, roach, pixlist, initial, peakw, troughw,  dectv, NSec, nwvl=len(wvl), plotYorN = 'Y', pause= 'N', pauseInitial=0, pausePeak=1)
print NPulses[0]
fig=plt.figure()
ax=fig.add_subplot(111)

noMicrolensFactor = 30
#noMicrolensFactor = 1
magnification = 1.2
#magnification = 1.45
areaARCONS = 222*10**-6
areaDetector = 1*10**-2

qeresults=[]
medianQeResults=[]
for j in xrange(0,len(pixlist)):
    qepix=[]
    for i in xrange(0,len(dectv)):
        qewvl=NPulses[j][i]/(dectv[i]*10**7)*areaDetector**2/(magnification*areaARCONS)**2*noMicrolensFactor
        qepix.append(qewvl)
    ax.plot(wvl,qepix,label='r%dp%d'%(roach,pixlist[j]))
    qeresults.append(qepix)
qeresults = np.array(qeresults)
for wl in xrange(0,len(qeresults[0])):
    medianQeResults.append(np.median(qeresults[:,wl]))
print medianQeResults

ax.set_xlabel('Frequency (nm)')
ax.set_ylabel('QE')
ax.set_title('QE of %s in r%d'%(qeDataFilename,roach))
ax.grid(True)
ax.legend()
plt.show()
plt.close()
print 'The decimal quantum efficiency of the ADR for 400-1050 wvls are:'
print qeresults

fig2=plt.figure()
ax2=fig2.add_subplot(111)
ax2.plot(wvl,medianQeResults)
ax2.set_xlabel('Frequency (nm)')
ax2.set_ylabel('QE')
ax2.set_title('Median QE of %s in r%d'%(qeDataFilename,roach))
ax2.grid(True)
#plt.savefig(saveFilename)
plt.show()
plt.close()
