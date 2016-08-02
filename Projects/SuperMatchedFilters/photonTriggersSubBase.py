from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
from baselineIIR import IirFilter
import pickle

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

def calcThreshold(phase,nSigma=2.5,nSamples=5000):
    n,bins= np.histogram(phase[:nSamples],bins=100)
    n = np.array(n,dtype='float32')/np.sum(n)
    tot = np.zeros(len(bins))
    for i in xrange(len(bins)):
        tot[i] = np.sum(n[:i])
    med = bins[np.abs(tot-0.5).argmin()]
    thresh = bins[np.abs(tot-0.05).argmin()]
    threshold = med-nSigma*abs(med-thresh)
    return threshold

def velocityTrigger(data,nSigmaTrig=5.,deadtime=10,bNegativePulses=True):
    #deadtime in ticks (us)

    if bNegativePulses:
        data = -np.array(data) #flip to be positve pulses
    else:
        data = np.array(data)

    derivative = np.diff(data)
    med = np.median(derivative)
    sdev = np.std(derivative)

    trigMask = data > (med + sdev*nSigmaTrig)
    if np.sum(trigMask) > 0:
        peakIndices = np.where(trigMask)[0] #we want the point after the high derivative

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
        
    if bNegativePulses:
        peakHeights = -data[peakIndices] #flip back to negative pulses
    else:
        peakHeights = data[peakIndices] 
    return {'peakIndices':peakIndices,'peakHeights':peakHeights}
        
def sigmaTrigger(data,nSigmaTrig=7.,deadtime=10):
    #deadtime in ticks (us)

    data = np.array(data)
    med = np.median(data)
    trigMask = data > (med + np.std(data)*nSigmaTrig)
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

def detectPulses(data,threshold=None,nSigmaThreshold=None,deadtime=10,nNegDerivChecks=10,negDerivLenience=1,bNegativePulses = True):
    #deadtime in ticks (us)
    if bNegativePulses:
        data = np.array(data)
    else:
        data = -np.array(data) #flip to negative pulses

    if threshold is None:
        threshold = calcThreshold(data,nSigma=nSigmaThreshold)
    derivative = np.diff(data)
    peakHeights = []
    t = 0
    negDeriv = derivative <= 0
    posDeriv = np.logical_not(negDeriv)
   
    triggerBooleans = data[nNegDerivChecks:-2] < threshold

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
        return {'peakIndices':np.array([]),'peakHeights':np.array([])}
        
    if bNegativePulses:
        peakHeights = data[peakIndices]
    else:
        peakHeights = -data[peakIndices] #flip back to positive sign
    return {'peakIndices':peakIndices,'peakHeights':peakHeights}


if __name__=='__main__':


    #identify which pixel and files we want
#    roachNum = 4
#    pixelNum = 102
#    secs=50
#    date = '20121204'
#    label='30tap_slowBase'
    roachNum = 0
    pixelNum = 0
    secs=50
    date = '20160301'
    label='sim_base'

    rootFolder = '/Scratch/filterData/'
    cps=200 #I don't really know. let's check
    folder = os.path.join(rootFolder,date)
    bFiltered = False
    #np.savez('/Scratch/dataProcessing/filterTests/filteredData_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),rawdata=rawdata,wienerFilterCoeffs=wienerFilterCoeffs,template=template,noiseSpectrum=noiseSpectrum,templateFilteredData=templateFilteredData,wienerFilteredData=wienerFilteredData)
    filteredDict = np.load('/Scratch/dataProcessing/filterTests/filteredDataSubBase_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))

    filterTypes = ['unity','template','matched','super matched','wiener']
    filteredDataKeys = ['rawdata','templateFilteredData','matchedFilteredData','superMatchedFilteredData','wienerFilteredData']
    filterColors = ['gray','black','blue','cyan','red']

    bSubtractBaselines = False
    if bSubtractBaselines:
        #create a highpass filter, then apply it to the data to take out the low frequency baseline
        sampleRate=1e6 # samples per second
        criticalFreq = 20 #Hz
        f=2*np.sin(np.pi*criticalFreq/sampleRate)
        Q=.7
        q=1./Q
        hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
        data = hpSvf.filterData(rawdata)

    #data = scipy.signal.lfilter(filter,1,rawdata)

    nSigmaTrig = 6.
    deadtime = 10.
    trigDict = {}
    for filterType,dataKey in zip(filterTypes,filteredDataKeys):
        print filterType
        if filterType == 'unity':
            trigDict[filterType] = velocityTrigger(filteredDict[dataKey].real,deadtime=deadtime,bNegativePulses=False,nSigmaTrig=11.)
        elif filterType == 'matched' or filterType == 'super matched':
            trigDict[filterType] = detectPulses(filteredDict[dataKey].real,deadtime=deadtime,nSigmaThreshold=5.,bNegativePulses=False,negDerivLenience=3)
        else:
            trigDict[filterType] = detectPulses(filteredDict[dataKey].real,deadtime=deadtime,nSigmaThreshold=5.,bNegativePulses=False)
        print '{}: {} peaks detected'.format(filterType,len(trigDict[filterType]['peakIndices']))

    nBins = 300
    bPlotPeakHist = True
    if bPlotPeakHist:
        figHist,axHist = plt.subplots(1,1)
        for filterType,filterColor in zip(filterTypes,filterColors):
            peakHist,peakHistBins = np.histogram(trigDict[filterType]['peakHeights'],bins=nBins,density=True)
            axHist.plot(peakHistBins[0:-1],peakHist,color=filterColor,label=filterType)
        axHist.legend(loc='best')

    print 'saving'
    np.savez('/Scratch/dataProcessing/filterTests/filteredTriggersSubBase_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),
        unityIndices=trigDict['unity']['peakIndices'],
        unityPeaks=trigDict['unity']['peakHeights'],
        templateIndices=trigDict['template']['peakIndices'],
        templatePeaks=trigDict['template']['peakHeights'],
        matchedIndices=trigDict['matched']['peakIndices'],
        matchedPeaks=trigDict['matched']['peakHeights'],
        superMatchedIndices=trigDict['super matched']['peakIndices'],
        superMatchedPeaks=trigDict['super matched']['peakHeights'],
        wienerIndices=trigDict['wiener']['peakIndices'],
        wienerPeaks=trigDict['wiener']['peakHeights'])


    bPlotPeaks = True
    if bPlotPeaks:
        fig,ax = plt.subplots(1,1)
        endIdx = 100000

        for (filterType,dataKey),filterColor in zip(zip(filterTypes,filteredDataKeys),filterColors):
            ax.plot(filteredDict[dataKey][0:endIdx],'.-',color=filterColor,label=filterType)
            endPeakIdx = np.searchsorted(trigDict[filterType]['peakIndices'],endIdx)
            ax.plot(trigDict[filterType]['peakIndices'][0:endPeakIdx],trigDict[filterType]['peakHeights'][0:endPeakIdx],'gd')

        ax.set_xlabel('time (us)')
        ax.set_ylabel('phase (${}^{\circ}$)')
        #ax.set_xlim([5000,15000])
        ax.legend(loc='best')
        #ax.set_title('detected peaks and baseline for ~%d cps, pixel /r%d/p%d'%(cps,roachNum,pixelNum))
        #ax.legend(loc='lower right')

    plt.show()

