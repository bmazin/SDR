import numpy as np
import pylab as plt

NRoaches=4 #number of roaches per feedline
roachBandwidth=0.512 #GHz, bandwidth that each roach can cover, depends on dac clockrate

#resonant frequency list for the feedline
dir = '/home/sean/data/LICK2012/20120901/'
feedline=2
datafilename=dir+'Lick-FL%d-good.txt'%feedline
table = np.loadtxt(datafilename)

freqs = table[:,2]
freqs.sort()
fig = plt.figure()
ax=fig.add_subplot(111)

fStart=freqs.min()
fLast=freqs.max()
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
    roachLOFreq[0] = 3.6757238
    roachLOFreq[1] = 4.3383665
    roachLOFreq[2] = 4.9063277
    roachLOFreq[3] = 5.5724130
else:
    roachLOFreq[0] = 3.6536534
    roachLOFreq[1] = 4.3752050
    roachLOFreq[2] = 4.9094138
    roachLOFreq[3] = 5.6137981

    
#roachFreqStart[0] = fStart
#roachFreqStart[1] = roachFreqStart[0]+roachBandwidth
#roachFreqStart[1] = roachFreqStart[0]+roachBandwidth+.05
#roachFreqStart[2] = roachFreqStart[1]+roachBandwidth+.01
#roachFreqStart[3] = roachFreqStart[2]+roachBandwidth+.05

roachFreqEnd = roachLOFreq+roachBandwidth/2.0
roachFreqStart = roachLOFreq-roachBandwidth/2.0

roachFreqList=[[]]*NRoaches
outputTable=[[]]*NRoaches
excludedFreqs = freqs

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
    ax.hist(roachFreqList[iRoach],bins=20)
    fid = open(dir+'freq%d.txt'%(feedline,r),'w')
    fid.write('1\t1\t1\t1\n')
    for freq in roachFreqList[iRoach]:
        fid.write('%.7f\t0\t0\t1\n'%freq)
    fid.close()

ax.hist(excludedFreqs,bins=100,color='black')
print '%d freqs excluded'%len(excludedFreqs)
lo_fid.close()



plt.show()


