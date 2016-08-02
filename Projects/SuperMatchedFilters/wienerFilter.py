from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
from baselineIIR import IirFilter

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

        
def sigmaTrigger(data,nSigmaTrig=5.,deadtime=1000):
    #deadtime in ticks (us)

    data = np.array(data)
    med = np.median(data)
    print 'sdev',np.std(data),'med',med,'max',np.max(data)
    trigMask = data > (med + np.std(data)*nSigmaTrig)
    print np.sum(trigMask)
    if np.sum(trigMask) > 0:
        peakIndices = np.where(trigMask)[0]

        i = 0
        p = peakIndices[i]
        while p < peakIndices[-1]:
            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadtime , peakIndices-p <= 0)]#apply deadtime
            i+=1
            if i < len(peakIndices):
                p = peakIndices[i]
            else:
                p = peakIndices[-1]
    else:
        return {'peakIndices':np.array([]),'peakHeights':np.array([])}
        
        
    peakHeights = data[peakIndices]
    return {'peakIndices':peakIndices,'peakHeights':peakHeights}

def detectPulses(sample,threshold,baselines,deadtime=10,nNegDerivChecks=10,negDerivLenience=1):
    #deadtime in ticks (us)
    data = np.array(sample)

    #threshold = calcThreshold(data[0:2000])
    dataSubBase = data - baselines
    derivative = np.diff(data)
    peakHeights = []
    t = 0
    negDeriv = derivative <= 0
    posDeriv = np.logical_not(negDeriv)
   
    triggerBooleans = dataSubBase[nNegDerivChecks:-2] < threshold

    negDerivChecksSum = np.zeros(len(negDeriv[0:-nNegDerivChecks-1]))
    for i in range(nNegDerivChecks):
        negDerivChecksSum += negDeriv[i:i-nNegDerivChecks-1]
    peakCondition0 = negDerivChecksSum >= nNegDerivChecks-negDerivLenience
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
        
        
    peakHeights = data[peakIndices]
    peakBaselines = baselines[peakIndices]
    return peakIndices,peakHeights,peakBaselines


if __name__=='__main__':


    #identify which pixel and files we want
    roachNum = 0
    pixelNum = 0
    secs=50
    rootFolder = '/Scratch/filterData/'
    cps=1000 #I don't really know. let's check
    date = '20160301'
    label='sim_high'
    labelIn ='{}cps_sim_high'.format(cps)
    folder = os.path.join(rootFolder,date)
    bFiltered = False
    phaseFilename = os.path.join(folder,'ch_snap_r{}p{}_{}.dat'.format(roachNum,pixelNum,labelIn))
    #missing quiet file, so use another

    bPlotPeaks = True
    deadtime=10

    phaseFile = open(phaseFilename,'r')
    phase = phaseFile.read()
    numQDRSamples=2**19 #for firmware with  qdr longsnap
    numBytesPerSample=4 #bytes in each qdr row/word
    nLongsnapSamples = numQDRSamples*2*secs
    qdrValues = struct.unpack('>%dh'%(nLongsnapSamples),phase)

    qdrPhaseValues = np.array(qdrValues,dtype=np.float32)*360./2**16*4/np.pi #convert from adc units to degrees

    nPhaseValues=len(qdrValues)
    print nPhaseValues,'us'

    rawdata = np.array(qdrPhaseValues)* -np.pi/180. #in radians, and flip sign

    #create a highpass filter, then apply it to the data to take out the low frequency baseline

    sampleRate=1e6 # samples per second
    criticalFreq = 20 #Hz
    f=2*np.sin(np.pi*criticalFreq/sampleRate)
    Q=.7
    q=1./Q
    hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
    data = hpSvf.filterData(rawdata)

    #data = scipy.signal.lfilter(filter,1,rawdata)

    trigDict = sigmaTrigger(data)
    peakIndices = trigDict['peakIndices']
    peaks = trigDict['peakHeights']

    nPeaksDetected = len(peaks)
    print len(peaks),'peaks detected'
    print 1.*nPeaksDetected/secs, 'cps'

    bPlotPeakHist = False
    if bPlotPeakHist:
        figHist,axHist = plt.subplots(1,1)
        peakHist,peakHistBins = np.histogram(peaks,bins=200,density=True)
        axHist.plot(peakHistBins[0:-1],peakHist)

    #collect records of several rawdata points before and after each peak
    nPointsBefore = 100
    nPointsAfter = 700
    nPointsTotal = nPointsBefore+nPointsAfter
    roughTemplate = np.zeros(nPointsBefore+nPointsAfter)
    nFftPoints = 800
    noiseOffsetFromPeak = 200
    noiseSpectra = np.zeros((nPeaksDetected,nFftPoints))
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex > nPointsBefore and peakIndex < len(data)-nPointsAfter:
            maxIndex = np.argmax(data[peakIndex-100:peakIndex+100])+(peakIndex-100)
            peakRecord = data[maxIndex-nPointsBefore:maxIndex+nPointsAfter]
            peakRecord = peakRecord / np.max(peakRecord)
            roughTemplate += peakRecord
            noiseSpectra[iPeak] = np.abs(np.fft.fft(data[maxIndex-nFftPoints-noiseOffsetFromPeak:maxIndex-noiseOffsetFromPeak])/nFftPoints)**2

    #only take the points for positive frequencies
    noiseFreqs = np.fft.fftfreq(nFftPoints,1./sampleRate)
    noiseSpectrum = np.median(noiseSpectra,axis=0)
    noiseSpectrum[0] = 2.*noiseSpectrum[1]
    noiseSpectrumDb = 20 * np.log10(noiseSpectrum)

    roughTemplate = roughTemplate / np.max(roughTemplate)
    roughTemplateSpectrum = np.abs(np.fft.fft(roughTemplate)/nPointsTotal)**2 
    roughTemplateSpectrumDb = 20.*np.log10(roughTemplateSpectrum)
    roughTemplateSpectrumFreqs = np.fft.fftfreq(nPointsTotal,1./sampleRate)

    #only plot the points for positive frequencies
    fig,[ax,ax2] = plt.subplots(2,1)
    ax.plot(roughTemplate,'.-',color='gray',label='initial template')
    ax.set_xlabel('time (us)')
    ax.set_title('Templates')
    ax2.step(roughTemplateSpectrumFreqs[0:nPointsTotal/2],roughTemplateSpectrumDb[0:nPointsTotal/2],color='r',label='template psd')
    ax2.step(noiseFreqs[0:nFftPoints/2],noiseSpectrumDb[0:nFftPoints/2],label='noise psd',color='k')
    ax2.set_xscale('log')
    ax2.set_ylabel('phase noise (dB/Hz)')

    roughTemplateFft = np.fft.fft(roughTemplate)/nPointsTotal
    firstWienerFilter = np.conj(roughTemplateFft)/noiseSpectrum #in freq space
    filterNorm = np.sum(np.abs(roughTemplateFft)**2/noiseSpectrum)

    offsets = np.arange(-20,21)
    nOffsets = len(offsets)
    #make a set of filters with time offsets
    print 'time shifts'
    filterSet = np.zeros((nOffsets,nPointsTotal),dtype=np.complex64)
    for iOffset,offset in enumerate(offsets):
        templateFft = np.fft.fft(np.roll(roughTemplate,offset))/nPointsTotal
        filterSet[iOffset] = np.conj(templateFft)/noiseSpectrum

    #run through the peak phase records again
    finalTemplate = np.zeros(nPointsBefore+nPointsAfter,dtype=np.complex64)
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex > nPointsBefore+np.max(offsets) and peakIndex < len(data)-(nPointsAfter+np.max(offsets)):
            peakRecord = data[peakIndex-nPointsBefore:peakIndex+nPointsAfter]
            peakRecord = peakRecord / np.max(peakRecord)
            #check which time shifted filter results in the biggest signal
            peakRecordFft = np.fft.fft(peakRecord)/nPointsTotal
            convSums = np.abs(np.sum(filterSet*peakRecordFft,axis=1)/filterNorm)
            bestOffsetIndex = np.argmax(convSums)
            bestConvSum = convSums[bestOffsetIndex]
            bestOffset = offsets[bestOffsetIndex]
            newPeakRecord = data[peakIndex-nPointsBefore+bestOffset:peakIndex+nPointsAfter+bestOffset]
            finalTemplate += newPeakRecord/bestConvSum
    finalTemplate = finalTemplate / np.max(finalTemplate)
    print 'time shifts done'

    ax.plot(finalTemplate,'r.-',label='final template')

    finalTemplateFft = np.fft.fft(finalTemplate)/nPointsTotal
    finalWienerFilter = np.conj(finalTemplateFft)**2/noiseSpectrum #in freq space
    finalFilterCoeffs = np.fft.ifft(finalWienerFilter).real #throw away the imag, it should be practically zero
    finalFilterCoeffs = finalFilterCoeffs / np.max(finalFilterCoeffs)

    #for some reason the coeffs are time reversed, so flip it back
    finalFilterCoeffs = finalFilterCoeffs[::-1]
    ax.plot(finalFilterCoeffs,'c.-',label='wiener')
    ax.legend()

    print 'saving'
    np.savez('/Scratch/dataProcessing/filterTests/wiener_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),finalFilterCoeffs=finalFilterCoeffs,finalTemplate=finalTemplate,roughTemplate=roughTemplate,noiseSpectrum=noiseSpectrum,rawdata=rawdata,rawdataMinusBase=data)

    plt.show()

