import numpy as np
import pylab as plt
import sys

if len(sys.argv) != 2:
    print 'Usage: ',sys.argv[0],' feedlineNo'
    exit(1)

NRoaches=4 #number of roaches per feedline
roachBandwidth=0.512 #GHz, bandwidth that each roach can cover, depends on dac clockrate

#resonant frequency list for the feedline
dir = '/Scratch/wideAna/20130916adr/'
feedline=int(sys.argv[1])
datafilename=dir+'trenchedSCI4widesweep-FL%d-right.txt'%feedline
table = np.loadtxt(datafilename)

#freqs = table[:,2]
freqs = table[:,2]
freqs.sort()
fig = plt.figure()
ax=fig.add_subplot(111)

fStart=freqs.min()
fLast=freqs.max()
print ''
print len(freqs), ' total frequencies'
print 'f_min = ',freqs.min()
print 'f_max = ',freqs.max()
totalSpread=fLast-fStart
#totalBinsOverSpread=200.0
#binWidth=totalSpread/totalBinsOverSpread

#set default freq ranges for each roach or manually tweak them
roachFreqStart = np.array([fStart]*NRoaches)
roachLOFreq = np.array([fStart]*NRoaches)

if feedline == 1:
#    roachLOFreq[0] = fStart+roachBandwidth/2.0
#    roachLOFreq[1] = roachLOFreq[0]+roachBandwidth+.02
#    roachLOFreq[2] = roachLOFreq[1]+roachBandwidth+.13
#    roachLOFreq[3] = roachLOFreq[2]+roachBandwidth+.25
    roachLOFreq[0] = 3.3912227
    roachLOFreq[1] = 3.9309845
    roachLOFreq[2] = 4.5944910
    roachLOFreq[3] = 5.3860378
else:
    roachLOFreq[0] = fStart+roachBandwidth/2.0
    roachLOFreq[1] = roachLOFreq[0]+roachBandwidth+.02
    roachLOFreq[2] = roachLOFreq[1]+roachBandwidth+.02
    roachLOFreq[3] = roachLOFreq[2]+roachBandwidth+.02
#    roachLOFreq[0] = 3.2354908
#    roachLOFreq[1] = 3.9260192
#    roachLOFreq[2] = 4.4389467
#    roachLOFreq[3] = 5.1086125
    
roachFreqEnd = roachLOFreq+roachBandwidth/2.0
roachFreqStart = roachLOFreq-roachBandwidth/2.0
roachFreqList=[[]]*NRoaches
outputTable=[[]]*NRoaches
excludedFreqs = freqs

for iRoach in np.arange(0,NRoaches):
    r = iRoach+4*(feedline-1)
    roachFreqList[iRoach] = freqs[np.logical_and(roachFreqStart[iRoach] <= freqs,freqs < roachFreqEnd[iRoach])]
    excludedFreqs = excludedFreqs[np.logical_or(excludedFreqs < roachFreqStart[iRoach],roachFreqEnd[iRoach] < excludedFreqs)]
    print 'roach ',r, ' covers ',len(roachFreqList[iRoach]),' freqs'
    if len(roachFreqList[iRoach]>0):
        ax.hist(roachFreqList[iRoach],bins=20)
print '%d freqs excluded'%len(excludedFreqs)
ax.hist(excludedFreqs,bins=100,color='black')
plt.show()
lo_fid=open(dir+'FL%d-lofreqs.txt'%feedline,'w')
for iRoach in np.arange(0,NRoaches):
    r = iRoach+4*(feedline-1)
    roachFreqList[iRoach] = freqs[np.logical_and(roachFreqStart[iRoach] <= freqs,freqs < roachFreqEnd[iRoach])]
    excludedFreqs = excludedFreqs[np.logical_or(excludedFreqs < roachFreqStart[iRoach],roachFreqEnd[iRoach] < excludedFreqs)]
    print 'roach ',r, ' covers ',len(roachFreqList[iRoach]),' freqs'
    roachFreqMin = roachFreqList[iRoach].min()
    roachFreqMax = roachFreqList[iRoach].max()
    print 'from %.3f to %.3f'%(roachFreqMin,roachFreqMax)
    roachFreqLO=roachFreqMin+(roachFreqMax-roachFreqMin)/2.0
    print 'with LO freq at %.3f'%roachLOFreq[iRoach]
    lo_fid.write('%.5f\n'%roachLOFreq[iRoach])
    fid = open(dir+'freq%d.txt'%r,'w')
    fid.write('1\t1\t1\t1\n')
    for freq in roachFreqList[iRoach]:
        fid.write('%.7f\t0\t0\t1\n'%freq)
    fid.close()

print '%d freqs excluded'%len(excludedFreqs)
lo_fid.close()





