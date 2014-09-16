import numpy as np
import pylab as plt
import sys
import os
import argparse
"""
Read the list of frequencies (data01-good.txt by default) and write 
local oscillator frequencies (FL1-lofreqs.txt) for each roach.
"""
parser = argparse.ArgumentParser(description="Distribute frequencies to roach boards")
parser.add_argument('feedline',help='one-based index of the feed line',
                    type=int)
parser.add_argument('-fileName',
                    help='file of frequencies, located in MKID_DATA_DIR',
                    default='data01-good.txt')

args = parser.parse_args()
fileName = args.fileName
feedline = args.feedline
print "begin with fileName=",fileName,"  feedline=",feedline

NRoaches = int(os.environ['MKID_NROACHES'])
roachBandwidth = float(os.environ['MKID_ROACH_BANDWIDTH'])
#resonant frequency list for the feedline
dir = os.environ['MKID_DATA_DIR']
datafilename=os.path.join(dir,fileName)
table = np.loadtxt(datafilename)

freqs = table[:,2]
#freqs = table[:,1]
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

#roachFreqStart = np.array([fStart]*NRoaches)
#roachLOFreq = np.array([fStart]*NRoaches)
#if feedline == 1:
#    roachLOFreq[0] = fStart+roachBandwidth/2.0+.08
#    roachLOFreq[1] = roachLOFreq[0]+roachBandwidth+.15
#    roachLOFreq[2] = roachLOFreq[1]+roachBandwidth+.1
#    roachLOFreq[3] = roachLOFreq[2]+roachBandwidth+.05
#else:
#    roachLOFreq[0] = fStart+roachBandwidth/2.0
#    roachLOFreq[1] = roachLOFreq[0]+roachBandwidth+.08
#    roachLOFreq[2] = roachLOFreq[1]+roachBandwidth+.11
#    roachLOFreq[3] = roachLOFreq[2]+roachBandwidth+.11

# Chris S. version that only does MKID_NROACHES
# what is the logic of the small offsets?  I'll just use 0.1 everywhere
roachLOFreq = np.zeros(NRoaches)
roachLOFreq[0] = fStart+roachBandwidth/2.0
for iRoach in range(1,NRoaches):
    roachLOFreq[iRoach] = roachLOFreq[iRoach-1] + roachBandwidh + 0.10

print "roachLOFreq=",roachLOFreq
roachFreqEnd = roachLOFreq+roachBandwidth/2.0
roachFreqStart = roachLOFreq-roachBandwidth/2.0
roachFreqList=[[]]*NRoaches
outputTable=[[]]*NRoaches
excludedFreqs = freqs

for iRoach in np.arange(0,NRoaches):
    r = iRoach+4*(feedline-1)
    print "begin iRoach=",iRoach,' r=',r," start=",roachFreqStart[iRoach],' end=',roachFreqEnd[iRoach]
    roachFreqList[iRoach] = freqs[np.logical_and(roachFreqStart[iRoach] <= freqs,freqs < roachFreqEnd[iRoach])]
    excludedFreqs = excludedFreqs[np.logical_or(excludedFreqs < roachFreqStart[iRoach],roachFreqEnd[iRoach] < excludedFreqs)]
    print 'roach ',r, ' covers ',len(roachFreqList[iRoach]),' freqs'
    if len(roachFreqList[iRoach]>0):
        ax.hist(roachFreqList[iRoach],bins=20)
print '%d freqs excluded'%len(excludedFreqs)
if len(excludedFreqs) > 0:
    ax.hist(excludedFreqs,bins=100,color='black')
    plt.show()
lo_fid=open(os.path.join(dir,'FL%d-lofreqs.txt'%feedline),'w')
for iRoach in np.arange(0,NRoaches):
    r = iRoach+4*(feedline-1)
    roachFreqList[iRoach] = freqs[np.logical_and(roachFreqStart[iRoach] <= freqs,freqs < roachFreqEnd[iRoach])]
    excludedFreqs = excludedFreqs[np.logical_or(excludedFreqs < roachFreqStart[iRoach],roachFreqEnd[iRoach] < excludedFreqs)]
    print 'roach ',r, ' covers ',len(roachFreqList[iRoach]),' freqs, ',
    roachFreqMin = roachFreqList[iRoach].min()
    roachFreqMax = roachFreqList[iRoach].max()
    print 'from %.3f to %.3f'%(roachFreqMin,roachFreqMax),
    roachFreqLO=roachFreqMin+(roachFreqMax-roachFreqMin)/2.0
    print ' with LO freq at %.3f'%roachLOFreq[iRoach]
    lo_fid.write('%.5f\n'%roachLOFreq[iRoach])
    ax.hist(roachFreqList[iRoach],bins=20)
    fid = open(os.path.join(dir,'freq%d.txt'%r),'w')
    fid.write('1\t1\t1\t1\n')
    for freq in roachFreqList[iRoach]:
        fid.write('%.7f\t0\t0\t1\n'%freq)
    fid.close()

#ax.hist(excludedFreqs,bins=100,color='black')
print '%d freqs excluded'%len(excludedFreqs)
lo_fid.close()





