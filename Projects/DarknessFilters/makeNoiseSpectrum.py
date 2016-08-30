from matplotlib import rcParams, rc
import numpy as np
import sys
import scipy.interpolate
import scipy.signal
from baselineIIR import IirFilter
import matplotlib.pyplot as plt


def makeWienerNoiseSpectrum(data, peakIndices=[], numBefore=100, numAfter=700, noiseOffsetFromPeak=200, sampleRate=1e6, prePulseDetect=True, baselineSubtract=True):
    nFftPoints = numBefore + numAfter
    peakIndices=np.array(peakIndices).astype(int)
    
    #If no peaks, choose random indices to make spectrum 
    if len(peakIndices)==0:
        print 'warning: makeWienerNoiseSpectrum was not passed any peakIndices. Generating random indicies now'
        peakIndices=np.array([0])
        rate = len(data)/nFftPoints/10
        while peakIndices[-1]<(len(data)-1):
            prob=np.random.rand()
            currentIndex=peakIndices[-1]
            peakIndices=np.append(peakIndices,currentIndex+np.ceil(-np.log(prob)/rate).astype(int))
        peakIndices=peakIndices[:-2]      
    if len(peakIndices)==0:
        raise ValueError('makeWienerNoiseSpectrum: input data set is too short for the number of FFT points specified')
   
    #Baseline subtract noise data
    if(baselineSubtract):
        noiseStream = np.array([])
        for iPeak,peakIndex in enumerate(peakIndices):
            if peakIndex > nFftPoints+noiseOffsetFromPeak and peakIndex < len(data)-numAfter:
                noiseStream = np.append(noiseStream, data[peakIndex-nFftPoints-noiseOffsetFromPeak:peakIndex-noiseOffsetFromPeak])
        data = data - np.mean(noiseStream)
    
    #Calculate noise spectra for the defined area before each pulse
    noiseSpectra = np.zeros((len(peakIndices), nFftPoints))
    sigma = np.zeros(len(peakIndices))    
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex > nFftPoints+noiseOffsetFromPeak and peakIndex < len(data)-numAfter:
            noiseData = data[peakIndex-nFftPoints-noiseOffsetFromPeak:peakIndex-noiseOffsetFromPeak]
            sigma[iPeak] = np.std(noiseData)
            noiseSpectra[iPeak] = np.abs(np.fft.fft(noiseData)/nFftPoints)**2 

    #Remove indicies with pulses in the area used for noise .. this is rough. Data should be pre-checked for this (use cleanPulses).
    if prePulseDetect:    
        sigmaMask = (sigma-np.mean(sigma))>2*np.std(sigma)
        sigmaRejectInd = np.where(sigmaMask)
        noiseSpectra = np.delete(noiseSpectra, sigmaRejectInd, axis=0)
    noiseFreqs = np.fft.fftfreq(nFftPoints,1./sampleRate)    
    noiseSpectrum = np.median(noiseSpectra,axis=0)
    #noiseSpectrum[0] = 0.01*noiseSpectrum[1] #look into this later 8/15/16
    return {'noiseSpectrum':noiseSpectrum, 'noiseFreqs':noiseFreqs}
    
def covFromData(data,size=800,nTrials=None):
    nSamples = len(data)
    if nTrials is None:
        nTrials = nSamples//size
    data = data[0:nTrials*size]
    data = data.reshape((nTrials,size))
    data = data.T
    
    covMatrix = np.cov(data)
    covMatrixInv = np.linalg.inv(covMatrix)
    return {'covMatrix':covMatrix,'covMatrixInv':covMatrixInv}

def covFromPsd(powerSpectrum,size=None):
    autocovariance = np.abs(np.fft.ifft(powerSpectrum))
    if size is None:
        size = len(autocovariance)
    sampledAutocovariance = autocovariance[0:size]

    shiftingRow = np.concatenate((sampledAutocovariance[:0:-1],sampledAutocovariance))
    covMatrix = []

    for iRow in range(size):
        covMatrix.append(shiftingRow[size-iRow-1:size-iRow-1+size])

    covMatrix = np.array(covMatrix)

    covMatrixInv = np.linalg.inv(covMatrix)
    return {'covMatrix':covMatrix,'covMatrixInv':covMatrixInv,'autocovariance':sampledAutocovariance}
