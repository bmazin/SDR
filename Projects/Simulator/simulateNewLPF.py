from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate

# common setup for matplotlib
params = {'savefig.dpi': 300, # save figures to 300 dpi
          'axes.labelsize': 14,
          'text.fontsize': 14,
          'legend.fontsize': 14,
          'xtick.labelsize': 14,
          'ytick.major.pad': 6,
          'xtick.major.pad': 6,
          'ytick.labelsize': 14}
# use of Sans Serif also in math mode
rc('text.latex', preamble='\usepackage{sfmath}')

rcParams.update(params)

import matplotlib.pyplot as plt
import numpy as np
import os
import struct

def calcThreshold(phase,Nsigma=2.5,nSamples=5000):
    n,bins= np.histogram(phase[:nSamples],bins=100)
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

def lpfFIR(x,nIters=100,threshold=0,neighborJump=10,neighborLag=30,firCoeff=0.08):
    iirCoeff=1-firCoeff
    y = np.roll(x,neighborLag)
    for i in np.arange(1,nIters):
        y += (iirCoeff**i)*np.roll(x,neighborLag+neighborJump*i)
    y = y*firCoeff
    return y
        
def base(phases,threshold,nAvg=2**12,skipFactor=2**7):
    phase = np.array(phases)
    nPoints = len(phases)
    phases = phases[::skipFactor]
    baselines = np.array(phases)
    includeThreshold=0.25*threshold
    for iPhase,phase in enumerate(phases[1:]):
        oldAvg = baselines[iPhase]
        startIdx = iPhase+1-4*nAvg
        if startIdx < 0:
            startIdx = 0
        segment = phases[startIdx:iPhase+1]
        segment = segment[(segment-oldAvg)>includeThreshold]
        segment = segment[-nAvg:]
        avg = np.mean(segment)
        baselines[iPhase+1]=avg
    baselines=np.repeat(baselines,skipFactor)
    baselines = baselines[0:nPoints]
    return baselines

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

def detectPulses(sample,threshold,baselines,deadtime=10):
    #deadtime in ticks (us)
    filtered = np.array(sample)

    #threshold = calcThreshold(filtered[0:2000])
    filtered -= baselines
    derivative = np.diff(filtered)
    peakHeights = []
    t = 0
    negDeriv = derivative <= 0
    posDeriv = np.logical_not(negDeriv)
    print np.shape(derivative)
    print np.shape(filtered)
    print np.shape(negDeriv)
   
#    triggerBooleans = filtered[9:-2] < threshold
#    peakCondition0 = np.logical_and(negDeriv[0:-10],negDeriv[1:-9])
#    peakCondition1 = np.logical_and(negDeriv[2:-8],negDeriv[3:-7])
#    peakCondition2 = np.logical_and(negDeriv[4:-6],negDeriv[5:-5])
#    peakCondition3 = np.logical_and(negDeriv[6:-4],negDeriv[7:-3])
#    peakCondition4 = np.logical_and(negDeriv[8:-2],posDeriv[9:-1])
#    peakCondition5 = np.logical_and(triggerBooleans,posDeriv[10:])
#    peakCondition01 = np.logical_and(peakCondition0,peakCondition1)
#    peakCondition23 = np.logical_and(peakCondition2,peakCondition3)
#    peakCondition45 = np.logical_and(peakCondition4,peakCondition5)
#    peakBooleans = np.logical_and(peakCondition01,peakCondition23)
#    peakBooleans = np.logical_and(peakBooleans,peakCondition45)

    nNegDerivChecks = 9
    lenience = 1
    triggerBooleans = filtered[nNegDerivChecks:-2] < threshold

    negDerivChecksSum = np.zeros(len(negDeriv[0:-nNegDerivChecks-1]))
    for i in range(nNegDerivChecks):
        negDerivChecksSum += negDeriv[i:i-nNegDerivChecks-1]
    peakCondition0 = negDerivChecksSum >= nNegDerivChecks-lenience
    peakCondition1 = np.logical_and(posDeriv[nNegDerivChecks:-1],posDeriv[nNegDerivChecks+1:])
    peakCondition01 = np.logical_and(peakCondition0,peakCondition1)
    peakBooleans = np.logical_and(triggerBooleans,peakCondition01)
        
    try:
        peakIndices = np.where(peakBooleans)[0]+nNegDerivChecks
        i = 0
        p = peakIndices[i]
        while p < peakIndices[-1]:
            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadtime , peakIndices-p <= 0)]#apply deadtime
            i+=1
            if i < len(peakIndices):
                p = peakIndices[i]
            else:
                p = peakIndices[-1]
    except IndexError:
        return np.array([]),np.array([]),np.array([])
        
        
    peakHeights = filtered[peakIndices]
    peakBaselines = baselines[peakIndices]
    return peakIndices,peakHeights,peakBaselines


def oldDetectPulses(sample,threshold,baselines):
    filtered = np.array(sample)

    #threshold = calcThreshold(filtered[0:2000])
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
    try:
        peakIndices = np.where(peakBooleans)[0]+1
        i = 0
        p = peakIndices[i]
        deadtime=10#us
        while p < peakIndices[-1]:
            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadtime , peakIndices-p <= 0)]#apply deadtime
            i+=1
            if i < len(peakIndices):
                p = peakIndices[i]
            else:
                p = peakIndices[-1]
    except IndexError:
        return np.array([]),np.array([]),np.array([])


    peakHeights = filtered[peakIndices]
    peakBaselines = baselines[peakIndices]
    return peakIndices,peakHeights,peakBaselines

rootFolder = '/home/kids/labData/'
quietFolder = '/home/kids/labData/20130925/blue/'

#roachNum = 0
#pixelNum = 51
#secs=60
#folder = '/home/kids/labData/20130925/blue/'
#cps=700
#bFiltered = False
#phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,secs,cps))
#quietFilename = os.path.join(quietFolder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,30,0))
#label='Blue'

roachNum = 0
pixelNum = 51
secs=60
folder = '/home/kids/labData/20130925/red/'
cps=600
bFiltered = False
phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,secs,cps))
quietFilename = os.path.join(quietFolder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,30,0))
label='Red'

#roachNum = 0
#pixelNum = 134
#secs=5
#folder = '/home/kids/labData/20130220/'
#cps=700
#bFiltered = True
#phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,secs,cps))

#roachNum = 4
#pixelNum = 2
#secs=20
#folder = os.path.join(rootFolder,'20121123/')
#bFiltered = False
#phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs.dat'%(roachNum,pixelNum,secs))

bPlotPeaks = True
deadtime=100

phaseFile = open(phaseFilename,'r')
quietFile = open(quietFilename,'r')
phase = phaseFile.read()
quietPhase = quietFile.read()
numQDRSamples=2**19
numBytesPerSample=4
nLongsnapSamples = numQDRSamples*2*secs
qdrValues = struct.unpack('>%dh'%(nLongsnapSamples),phase)
qdrPhaseValues = np.array(qdrValues,dtype=np.float32)*360./2**16*4/np.pi #convert from adc units to degrees
nPhaseValues=len(qdrValues)
print nPhaseValues,'us'
quietQdrValues = struct.unpack('>%dh'%(numQDRSamples*2*30),quietPhase)
quietQdrPhaseValues = np.array(quietQdrValues,dtype=np.float32)*360./2**16*4/np.pi #convert from adc units to degrees

fig = plt.figure()
NAxes = 1
iAxes = 1
size=26
offset = 3

sampleStart = 5000
nSamples = nPhaseValues-sampleStart
thresholdLength = 2000
thresholdSigma = 2.5

sample=qdrValues[sampleStart:sampleStart+nSamples]
quietSample=quietQdrValues[sampleStart:sampleStart+thresholdLength]
#sample = np.array(qdrPhaseValues)
if bFiltered == False:
    unfiltered = np.array(sample)
    quietUnfiltered = np.array(quietSample)
    filter= np.loadtxt(os.path.join(rootFolder,'fir/template20121207r%d.txt'%roachNum))[pixelNum,:]
    #lpf250kHz= np.loadtxt('/Scratch/filterData/fir/lpf_250kHz.txt')
    matched30= np.loadtxt(os.path.join(rootFolder,'fir/matched_30us.txt'))
    filter=matched30
    filtered = np.correlate(filter,unfiltered,mode='same')[::-1]
    quietFiltered = np.correlate(filter,quietUnfiltered,mode='same')[::-1]
    #lpffiltered = np.correlate(lpf250kHz,unfiltered,mode='same')[::-1]
    print 'filtering done'
    sys.stdout.flush()
else:
    filtered = np.array(sample)
    quietFiltered = np.array(quietSample)

threshold = calcThreshold(quietFiltered,Nsigma=thresholdSigma)
print 'threshold done'
sys.stdout.flush()
baselines=np.array(lpfFIR(filtered),dtype=np.int)
baselines2=np.array(base(filtered,threshold),dtype=np.int)
print 'baselines done'
sys.stdout.flush()
sys.stdout.flush()

endIdx = 1000*thresholdLength
if bPlotPeaks:
    ax=fig.add_subplot(NAxes,1,iAxes)
    ax.plot(filtered[0:endIdx],'k.-',label='optimal filtered phase')
    ax.plot(baselines[0:endIdx],'b',label='lpf baseline')
    ax.plot(baselines[0:endIdx]+threshold,'y--',label='threshold')
    ax.plot(baselines2[0:endIdx]+threshold,'g--',label='threshold')


idx,peaks,bases = detectPulses(filtered,threshold,baselines,deadtime=deadtime)
idx2,peaks2,bases2 = oldDetectPulses(filtered,threshold,baselines)
print len(peaks),'peaks detected'
print len(peaks2),'old peaks detected'
sys.stdout.flush()


if len(peaks)>0:
    if bPlotPeaks:
        
        ax.plot(idx2,peaks2+bases2,'bo',label='detected peak')
        ax.plot(idx,peaks+bases,'r.',label='detected peak')
        ax.plot(idx,bases,'g.',label='detected baseline')
        ax.set_xlabel('time (us)')
        ax.set_ylabel('phase (${}^{\circ}$)')
        #ax.set_xlim([5000,15000])
        #ax.set_title('detected peaks and baseline for ~%d cps, pixel /r%d/p%d'%(cps,roachNum,pixelNum))
        ax.legend(loc='lower right')
        iAxes+=1


    np.savez('sdetected%d%s_dead%d.npz'%(cps,label,deadtime),idx=idx,peaks=peaks,bases=bases,baselines=baselines,threshold=threshold,qdrValues=qdrValues,filtered=filtered)
    print 'done'
    sys.stdout.flush()
    plt.show()

