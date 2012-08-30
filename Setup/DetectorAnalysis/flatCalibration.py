import tables
import numpy as np
import random
import shlex

def peakfit(y1,y2,y3):
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

def binToDeg_12_9(binOffset12_9):
    x = binOffset12_9/2.0**9-4.0
    return x*180.0/np.pi

NSec=3600
nroach = 1
obsFilename = '/media/disk2/20120814/obs_20120814-164612.h5'
qeObsTime = 1344987972

qeperpixfile = 'SDR/Setup/DetectorAnalysis/qeforpix.h5'

obsfid = tables.openFile(obsFilename)
qefid = tables.openFile(qeperpixfile)
wvls=qefid.root.header.Wavelengths[0][0]

pulseMask = int(12*'1',2)#bitmask of 12 ones

for roach in xrange(0,nroach):
    for group in qefid.getNode('/r%d'%roach):
        pulseh=[[] for x in xrange(NSec)]
        roachpix = shlex.split(str(group))[0]
        print roachpix
        obsdataset=obsfid.getNode('%s/t%d'%(roachpix,qeObsTime))
        for ind, sec in enumerate(obsdataset):
            for packet in sec:
                packet = int(packet)
                beforePeak = binToDeg_12_9(packet>>44 & pulseMask)
                atPeak = binToDeg_12_9(packet>>32 & pulseMask)
                afterPeak = binToDeg_12_9(packet >> 20 & pulseMask)                if beforePeak+afterPeak-2*atPeak != 0:
                    peak = peakfit(beforePeak,atPeak,afterPeak)
                    pulseh[ind].append(peak) 
                    wvl = random.randrange(300,1200,1) #This will be wvl(pulseh)
                    wvlsindex = min((abs(wvl-wvls[i]),i) for i in range(len(wvls)))[1]
                    qeForWvl=qefid.getNode('%s/pixtable'%roachpix)[0][2][wvlsindex]

#do something...

obsfid.close()
qefid.close()

print 'done'


