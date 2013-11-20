import numpy as np
import matplotlib.pyplot as plt
import os
import struct

def calcThreshold(phase,Nsigma=1.5):
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

def detectPulses(filter,sample):
    filtered = np.correlate(filter,sample,mode='same')[::-1]
    threshold = calcThreshold(filtered[0:2000])
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
    return peakIndices,peakHeights

roachNum = 4
pixelNum = 0
steps=20
folder = '/Scratch/filterData/'
noisefile = '/Scratch/filterData/20121123/r%dp%dNoiseSpectra.dat'%(roachNum,pixelNum)


phaseFilename = os.path.join(folder,'20121123/ch_snap_r%dp%d_%dsecs.dat'%(roachNum,pixelNum,steps))
phaseFile = open(phaseFilename,'r')
phase = phaseFile.read()
numQDRSamples=2**19
numBytesPerSample=4
nLongsnapSamples = numQDRSamples*2*steps
qdr_values = struct.unpack('>%dh'%(nLongsnapSamples),phase)
#qdr_phase_values = np.array(qdr_values,dtype=np.float32)*360./2**16*4/np.pi


fig = plt.figure()
fig.canvas.manager.set_window_title('r%dp%d'%(roachNum,pixelNum)) 
NAxes = 5
iAxes = 1
size=26
offset = 3

sample=qdr_values[0:10000]
tryFilter(np.array([1]),sample,fig,NAxes,iAxes,label='raw phase')
iAxes+=1

lpf = np.loadtxt(os.path.join(folder,'fir/lpf_250kHz.txt'))
tryFilter(lpf,sample,fig,NAxes,iAxes,label='26pt lpf 250kHz')
iAxes+=1

oldMatched26 = np.loadtxt(os.path.join(folder,'fir/matched_r4p46.txt'))
oldMatched26/=np.sum(oldMatched26)
tryFilter(oldMatched26,sample,fig,NAxes,iAxes,label='26pt old matched')
iAxes+=1

optimal800 = np.loadtxt(os.path.join(folder,'fir/matched20121123.txt'))

matched26 = optimal800[100-offset:100-offset+size]
matched26/=np.sum(matched26)
tryFilter(matched26,sample,fig,NAxes,iAxes,label='26pt custom matched')
iAxes+=1

template800 = np.loadtxt(os.path.join(folder,'20121123/r%dp%dTemplate-2pass-new.dat'%(roachNum,pixelNum)))[:,1]
template26 = template800[1000-offset:1000-offset+size]
tryFilter(template26,sample,fig,NAxes,iAxes,label='26pt custom template')
iAxes+=1

idx,peaks=detectPulses(oldMatched26,sample)
print len(peaks)

plt.show()

fig = plt.figure()
idx,peaks=detectPulses(oldMatched26,qdr_values)
print 'oldMatch26 count',len(peaks)
counts,bins = np.histogram(peaks,bins=100)
plt.plot(bins[0:-1],counts,label='26pt old match')

idx,peaks=detectPulses(optimal800,qdr_values)
print 'optimal800 count',len(peaks)
counts,bins = np.histogram(peaks,bins=100)
print counts
plt.plot(bins[0:-1],counts,label='800pt custom match')

plt.title('old vs custom matched filter, energy hist')
fig.savefig('r%dp%d_oldVsOptimal800.png'%(roachNum,pixelNum))
plt.show()
