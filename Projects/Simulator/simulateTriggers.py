from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian

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

def lpfFIR(x,nIters=100):
    firCoeff=0.08
    iirCoeff=1-firCoeff
    neighborJump = 10
    y = np.roll(x,30)
    for i in np.arange(1,nIters):
        y += (iirCoeff**i)*np.roll(x,30+neighborJump*i)
    y = y*firCoeff
    return y
        
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

def detectPulses(sample,threshold,baselines):
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

roachNum = 0
pixelNum = 51
secs=60
folder = '/home/kids/labData/20130925/blue/'
cps=700
bFiltered = False
phaseFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,secs,cps))
quietFilename = os.path.join(folder,'ch_snap_r%dp%d_%dsecs_%dcps.dat'%(roachNum,pixelNum,30,0))

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

baselines=np.array(lpfFIR(filtered),dtype=np.int)
print 'baselines done'
sys.stdout.flush()
#baselines2=np.array([IIR(filtered,t) for t in xrange(len(filtered))])
#print 'baselines2 done'
sys.stdout.flush()
threshold = calcThreshold(quietFiltered,Nsigma=thresholdSigma)
print 'threshold done'
sys.stdout.flush()

endIdx = 1000*thresholdLength
if bPlotPeaks:
    ax=fig.add_subplot(NAxes,1,iAxes)
    ax.plot(filtered[0:endIdx],'k.-',label='optimal filtered phase')
    ax.plot(baselines[0:endIdx],'b',label='lpf baseline')
    ax.plot(baselines[0:endIdx]+threshold,'y--',label='threshold')


idx,peaks,bases = detectPulses(filtered,threshold,baselines)
priorIdx = idx-100
priors = filtered[priorIdx]
idx+=sampleStart
priorIdx+=sampleStart
print len(peaks),'peaks detected'
sys.stdout.flush()


if len(peaks)>0:

    if bPlotPeaks:
        ax.plot(idx-sampleStart,peaks+bases,'r.',label='detected peak')
        ax.plot(idx-sampleStart,bases,'g.',label='detected baseline')
        ax.plot(priorIdx-sampleStart,priors,'m.',label='priors point')
        ax.set_xlabel('time (us)')
        ax.set_ylabel('phase (${}^{\circ}$)')
        #ax.set_xlim([5000,15000])
        #ax.set_title('detected peaks and baseline for ~%d cps, pixel /r%d/p%d'%(cps,roachNum,pixelNum))
        ax.legend(loc='lower right')
        iAxes+=1

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(qdrValues[::100],'.')

    np.savez('detected700Blue.npz',idx=idx,peaks=peaks,bases=bases,energies=energies,baselines=baselines,threshold=threshold,qdrValues=qdrValues,filtered=filtered,priorIdx=priorIdx,priors=priors)
    print 'done'
    sys.stdout.flush()
    plt.show()

