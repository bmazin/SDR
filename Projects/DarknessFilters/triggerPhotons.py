from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
from baselineIIR import IirFilter
import pickle
import smooth

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
    '''
    Calculate the threshold (in phase units) corresponding 
    to a sigma threshold (note: look at this f'n, seems a bit odd
    Appears to define sigma as one-sided lower 95% threshold)
    '''
    n,bins= np.histogram(phase[:nSamples],bins=100)
    n = np.array(n,dtype='float32')/np.sum(n)
    tot = np.zeros(len(bins))
    for i in xrange(len(bins)):
        tot[i] = np.sum(n[:i])
    med = bins[np.abs(tot-0.5).argmin()]
    thresh = bins[np.abs(tot-0.05).argmin()]
    threshold = med-nSigma*abs(med-thresh)
    return threshold

        
def sigmaTrigger(data,nSigmaTrig=7.,deadtime=10):
    '''
    Find photon pulses using a sigma trigger
    INPUTS:
    data - phase timestream (filtered or raw)
    nSigmaTrig - threshold for photon detection, in units sigma from baseline
    deadtime - trigger deadtime in ticks (us)

    OUTPUTS:
    Dictionary with keys:
        peakIndices - indices of detected pulses in phase stream
        peakHeights - heights of detected pulses (in same units as input data)
    '''
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

def detectPulses(data,threshold=None,nSigmaThreshold=3.,deadtime=10,nNegDerivChecks=10,negDerivLenience=1,bNegativePulses = True):
    #deadtime in ticks (us)
    if bNegativePulses:
        data = np.array(data)
    else:
        data = -np.array(data) #flip to negative pulses

    if threshold is None:
        threshold = np.median(data)-nSigmaThreshold*np.std(data)
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

def optimizeTrigCond(data, nPeaks, sigmaThreshList=[3.], nNegDerivChecksList=[10], negDerivLenienceList=[1], bNegativePulses=True):
    minSigma = 1000
    optSigmaThresh = 0
    optNNegDerivChecks = 0
    optNegDerivLenience = 0
    optPeakDict = {'peakIndices':np.array([]), 'peakHeights':np.array([])} 
    for sigmaThresh in sigmaThreshList:
        for nNegDerivChecks in nNegDerivChecksList:
            for negDerivLenience in negDerivLenienceList:
                peakDict = detectPulses(data, nSigmaThreshold=sigmaThresh, nNegDerivChecks=nNegDerivChecks, negDerivLenience=negDerivLenience, bNegativePulses=bNegativePulses)
                if(len(peakDict['peakIndices'])>=nPeaks):
                    sigma = np.std(peakDict['peakHeights'])
                    if(sigma<minSigma):
                        minSigma = sigma
                        optSigmaThresh = sigmaThresh
                        optNNegDerivChecks = nNegDerivChecks
                        optNegDerivLenience = negDerivLenience
                        optPeakDict = peakDict

    return optSigmaThresh, optNNegDerivChecks, optNegDerivLenience, minSigma, optPeakDict

def findSigmaThresh(data, initSigmaThresh=2., tailSlack=0., isPlot=False):
    '''
    Finds the optimal photon trigger threshold by cutting out the  noise tail
    in the pulse height histogram.
    
    INPUTS:
    data - filtered phase timestream data (positive pulses)
    initSigmaThresh - sigma threshold to use when constructing initial
        pulse height histogram
    tailSlack - amount (in same units as data) to relax trigger threshold
    isPlot - make peak height histograms if true

    OUTPUTS:
    threshold - trigger threshold in same units as data
    sigmaThresh - trigger threshold in units sigma from median
    '''
    peakdict = sigmaTrigger(data, nSigmaTrig=initSigmaThresh)
    peaksHist, peaksHistBins = np.histogram(peakdict['peakHeights'], bins='auto')
    if(isPlot):    
        plt.plot(peaksHistBins[:-1], peaksHist)
        plt.title('Unsmoothed Plot')
        plt.show()
    print 'peaksHistLen:', len(peaksHist)
    peaksHist = smooth.smooth(peaksHist,(len(peaksHistBins)/20)*2+1)
    print 'peaksHistSmoothLen:', len(peaksHist)
    if(isPlot):
        plt.plot(peaksHistBins[0:len(peaksHist)], peaksHist)
        plt.title('smoothed plot')
        plt.show()
    
    minima=np.ones(len(peaksHist)) #keeps track of minima locations; element is 1 if minimum exists at that index
    minimaCount = 1
    #while there are multiple local minima, look for the deepest one
    while(np.count_nonzero(minima)>1):      
        minima = np.logical_and(minima, np.logical_and((peaksHist<=np.roll(peaksHist,minimaCount)),(peaksHist<=np.roll(peaksHist,-minimaCount))))
        #print 'minima array:', minima
        minima[minimaCount-1]=0
        minima[len(minima)-minimaCount]=0 #get rid of boundary effects
        minimaCount += 1

    thresholdInd = np.where(minima)[0][0]
    threshold = peaksHistBins[thresholdInd]-tailSlack
    sigmaThresh = (threshold-np.median(data))/np.std(data)
    return threshold, sigmaThresh

