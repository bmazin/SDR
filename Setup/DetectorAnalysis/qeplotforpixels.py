import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools
from qeforpixelsfunc import *

#This program looks at specific pixels (picked by using FindGoodPix.py) and plots the photon histogram and qe for each. Use qeroughplot.py to figure out peakw,troughw, and ini. dectv is the values (x10^7) seen in the comparison detector (not arcons).

qeDataFilename= '/media/disk2/sci3gamma/qe_20120824-230828.h5' 
qeObsTime=1345874908

roach=7
pixlist=[37,68,30,43,28]

ini=100
peakw=14.7
troughw=61

#saveFilename='data/qePlots/qe20120824-r7.pdf'
dectv=[0.149,.497,1.156,2.305,3.820,4.762,5.014,5.746,5.232,5.056,6.466,8.5,10.513,11.783]

NSec=1800

wvl=range(400,1100,50)

NPulses = NumPhotonInWVLPulses(qeDataFilename, qeObsTime, roach, pixlist, ini, peakw, troughw,  dectv, NSec, nwvl=len(wvl), plotYorN = 'Y')

fig=plt.figure()
ax=fig.add_subplot(111)

qeresults=[]

for j in xrange(0,len(pixlist)):
    qepix=[]
    for i in xrange(0,len(dectv)):
        qewvl=1/(dectv[i]*10**7/NPulses[j][i]*.0007096896)
        qepix.append(qewvl)
    ax.plot(wvl,qepix,label='r%dp%d'%(roach,pixlist[j]))
    qeresults.append(qepix)
ax.set_xlabel('Frequency (nm)')
ax.set_ylabel('QE')
ax.set_title('QE of %s in r%d'%(qeDataFilename,roach))
ax.grid(True)
ax.legend()
#plt.savefig(saveFilename)
plt.show()
plt.close()
#print 'The decimal quantum efficiency of the ADR for 400-1050 wvls are:'
#print qeresults
