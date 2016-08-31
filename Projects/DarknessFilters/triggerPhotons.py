from matplotlib import rcParams, rc
import numpy as np
import sys
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

def detectPulses(data,threshold=None,nSigmaThreshold=3.,deadtime=10,nNegDerivChecks=10,negDerivLenience=1,bNegativePulses = True):
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
    peakIndices=peakIndices.astype(int)    
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
                if(len(peakDict['peakIndices']>=nPeaks)):
                    sigma = np.std(peakDict['peakHeights'])
                    if(sigma<minSigma):
                        minSigma = sigma
                        optSigmaThresh = sigmaThresh
                        optNNegDerivChecks = nNegDerivChecks
                        optNegDerivLenience = negDerivLenience
                        optPeakDict = peakDict

    return optSigmaThresh, optNNegDerivChecks, optNegDerivLenience, minSigma, optPeakDict 
