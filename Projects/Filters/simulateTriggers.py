import numpy as np
import matplotlib.pyplot as plt
import os
import struct

def calcThreshold(phase,Nsigma=2.5):
    n,bins= np.histogram(phase,bins=100)
    n = np.array(n,dtype='float32')/np.sum(n)
    tot = np.zeros(len(bins))
    for i in xrange(len(bins)):
        tot[i] = np.sum(n[:i])
    med = bins[np.abs(tot-0.5).argmin()]
    thresh = bins[np.abs(tot-0.05).argmin()]
    threshold = int(med-Nsigma*abs(med-thresh))
    return threshold

def IIR(x,t,iters=0):
    if t < 30 or iters > 50:
        return x[t]
    else:
        return 0.08*x[t-30]+0.92*IIR(x,t-10,iters=iters+1)

def tryFilter(filter,sample,fig=None,NAxes=1,iAxes=1,label=''):
    filtered = np.correlate(filter,sample,mode='same')[::-1]
    baselines=np.array([IIR(filtered,t) for t in xrange(len(filtered))])
    thresholdLength = 2000
    threshold = calcThreshold(filtered[0:thresholdLength])
    if fig != None:
        ax=fig.add_subplot(NAxes,1,iAxes)
        ax.plot(filtered-baselines)
        #ax.plot(baselines+template26Threshold)
        ax.plot([0,len(sample)-1],[threshold,threshold])
        ax.set_title(label)

def detectPulses(sample,threshold):
    filtered = np.array(sample)

    #threshold = calcThreshold(filtered[0:2000])
    baselines=np.array([IIR(filtered,t) for t in xrange(len(filtered))])
    filtered -= baselines
    derivative = np.diff(filtered)
    peakHeights = []
    t = 0
    negDeriv = derivative <= 0
    posDeriv = np.logical_not(negDeriv)
   
    triggerBooleans = filtered[1:-2] < threshold
    peakCondition1 = np.logical_and(negDeriv[0:-2],posDeriv[1:-1])
    peakCondition2 = np.logical_and(triggerBooleans,posDeriv[2:])
    peakBooleans = np.logical_and(peakCondition1,peakCondition2)
    peakIndices = np.where(peakBooleans)[0]+1
    i = 0
    p = peakIndices[i]
    while p < peakIndices[-1]:
        peakIndices = peakIndices[np.logical_or(peakIndices-p > 100 , peakIndices-p <= 0)]
        i+=1
        if i < len(peakIndices):
            p = peakIndices[i]
        else:
            p = peakIndices[-1]
        
        
    peakHeights = filtered[peakIndices]
    peakBaselines = baselines[peakIndices]
    return peakIndices,peakHeights,peakBaselines

roachNum = 4
pixelNum = 102
steps=50
folder = '/Scratch/filterData/20121204/'
cps=300


phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs.dat'%(roachNum,pixelNum,steps))
phaseFile = open(phaseFilename,'r')
phase = phaseFile.read()
numQDRSamples=2**19
numBytesPerSample=4
nLongsnapSamples = numQDRSamples*2*steps
qdr_values = struct.unpack('>%dh'%(nLongsnapSamples),phase)
qdr_phase_values = np.array(qdr_values,dtype=np.float32)*360./2**16*4/np.pi

fig = plt.figure()
NAxes = 1
iAxes = 1
size=26
offset = 3

sampleStart = 0
nSamples = 80000
thresholdLength = 2000
thresholdSigma = 2.5

filter= np.loadtxt('/Scratch/filterData/fir/template20121207r4.txt')[pixelNum,:]
print filter
sample=qdr_values[sampleStart:nSamples]
#filtered = np.array(sample)
filtered = np.correlate(filter,sample,mode='same')[::-1]
baselines=np.array([IIR(filtered,t) for t in xrange(len(filtered))])
threshold = calcThreshold(filtered[0:thresholdLength],Nsigma=thresholdSigma)
ax=fig.add_subplot(NAxes,1,iAxes)
ax.plot(filtered,'b',label='phase')
ax.plot(baselines,'y',label='lpf baseline')
#ax.plot(baselines+template26Threshold)
#ax.plot([0,len(filtered)-1],[threshold,threshold])
idx,peaks,bases = detectPulses(filtered,threshold)
idx+=sampleStart
ax.plot(idx,peaks+bases,'ro',label='detected peak')
ax.plot(idx,bases,'go',label='detected baseline')
ax.set_xlabel('time (us)')
ax.set_ylabel('phase (16-bit adu)')
#ax.set_title('detected peaks and baseline for ~%d cps, pixel /r%d/p%d'%(cps,roachNum,pixelNum))
ax.legend(loc='lower left')
iAxes+=1
outFilename = os.path.splitext(phaseFilename)[0]+'.png'
#plt.savefig(outFilename)

plt.show()

