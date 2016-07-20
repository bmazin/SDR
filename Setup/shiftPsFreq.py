import numpy as np
import sys

oldFreqPath = '/mnt/data0/Darkness/20160718_ps/freq_FL3_a_neg.txt'
psFreqPath = '/mnt/data0/Darkness/20160718_ps/ps_FL3_a_neg.txt'
fixedPsFreqPath = '/mnt/data0/Darkness/20160718_ps/ps2_FL3_a_neg.txt'

oldFreqTable = np.loadtxt(oldFreqPath)
psFreqTable = np.loadtxt(psFreqPath)

keptIndices = []
keptFreqs = []
for iFreq,freq in enumerate(oldFreqTable[:,0]):
    print iFreq,freq,
    closestPsFreqIdx = np.argmin(np.abs(psFreqTable[:,0]-freq))
    closestFreq = psFreqTable[closestPsFreqIdx,0]
    distFromClosest = closestFreq-freq
    print closestFreq,distFromClosest
    if np.abs(distFromClosest) < 512e3:
        keptIndices.append(iFreq)
        keptFreqs.append(freq)

keptFreqs = np.array(keptFreqs)
print 'kept',len(keptIndices),'of',len(oldFreqTable[:,0])
print 'num ps freqs',len(psFreqTable[:,0])
print np.shape(oldFreqTable[keptIndices,0])

if len(keptIndices) != len(psFreqTable[:,0]):
    print 'ERROR: Couldn\'t match all ps freqs with old freq'
    sys.exit(1)

freqDiffs = psFreqTable[:,0] - keptFreqs
print np.shape(freqDiffs)

print 'diff',freqDiffs[0:2]
print 'old',oldFreqTable[0:2,0]
print 'clicked',psFreqTable[0:2,0]

fixedOldFreqs = np.roll(keptFreqs,2)
fixedPsFreqs = fixedOldFreqs + freqDiffs

print 'fixed',fixedPsFreqs[0:2]

fixedPsFreqTable = np.array(psFreqTable)
fixedPsFreqTable[:,0] = fixedPsFreqs

np.savetxt(fixedPsFreqPath,fixedPsFreqTable,fmt=['%.9e','%d'])

