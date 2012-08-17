import numpy as np
import pylab as plt

NRoaches=4 #number of roaches per feedline
roachBandwidth=0.550 #GHz, bandwidth that each roach can cover, depends on dac clockrate

#resonant frequency list for the feedline
dir = '/home/sean/data/20120812adr/'
table = np.loadtxt(dir+'SCI3-40-FL1-ADR-2-good.txt')

freqs = table[:,2]
freqs.sort()
fig = plt.figure()
ax=fig.add_subplot(111)

fStart=freqs.min()
fLast=freqs.max()
print len(freqs), ' total frequencies'
print 'f_min = ',freqs.min()
print 'f_max = ',freqs.max()

#set default freq ranges for each roach
roachFreqStart = np.array([fStart]*NRoaches)
roachFreqStart[0] = fStart
roachFreqStart[1] = roachFreqStart[0]+roachBandwidth
roachFreqStart[2] = roachFreqStart[1]+roachBandwidth
roachFreqStart[3] = roachFreqStart[2]+roachBandwidth

#manual tweaks to cover more resonators
roachFreqStart[1] = 3.6
roachFreqStart[2] = roachFreqStart[1]+roachBandwidth
roachFreqStart[3] = roachFreqStart[2]+roachBandwidth

roachFreqEnd = roachFreqStart+roachBandwidth


roachFreqList=[[]]*NRoaches
outputTable=[[]]*NRoaches
excludedFreqs = freqs

lo_fid=open(dir+'FL1-lofreqs.txt','w')
for r in np.arange(0,NRoaches):
    roachFreqList[r] = freqs[np.logical_and(roachFreqStart[r] <= freqs,freqs < roachFreqEnd[r])]
    excludedFreqs = excludedFreqs[np.logical_or(excludedFreqs < roachFreqStart[r],roachFreqEnd[r] < excludedFreqs)]
    print 'roach ',r, ' covers ',len(roachFreqList[r]),' freqs'
    roachFreqMin = roachFreqList[r].min()
    roachFreqMax = roachFreqList[r].max()
    print 'from %.3f to %.3f'%(roachFreqMin,roachFreqMax)
    roachFreqLO=roachFreqMin+(roachFreqMax-roachFreqMin)/2.0
    print 'with LO freq at %.3f'%roachFreqLO
    lo_fid.write('%.3f\n'%roachFreqLO)
    ax.hist(roachFreqList[r],bins=20)
    fid = open(dir+'FL1-freqs%d.txt'%r,'w')
    fid.write('1\t1\t1\t1\n')
    for freq in roachFreqList[r]:
        fid.write('%.7f\t0\t0\t1\n'%freq)
    fid.close()

ax.hist(excludedFreqs,bins=100,color='black')
print '%d freqs excluded'%len(excludedFreqs)
lo_fid.close()



plt.show()


