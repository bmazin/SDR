from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
from baselineIIR import IirFilter


def makeWienerNoiseSpectrum(data, peakIndices=[], numBefore=100, numAfter=700, noiseOffsetFromPeak=200, sampleRate=1e6, prePulseDetect=True):
    nFftPoints = numBefore + numAfter
    noiseSpectra = np.zeros((len(peakIndices), nFftPoints))
    sigma = np.zeros(len(peakIndices))    
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex > nFftPoints-noiseOffsetFromPeak and peakIndex < len(data)-numAfter:
            noiseData = data[peakIndex-nFftPoints-noiseOffsetFromPeak:peakIndex-noiseOffsetFromPeak]
            sigma[iPeak] = np.std(noiseData)
            noiseSpectra[iPeak] = np.abs(np.fft.fft(data[peakIndex-nFftPoints-noiseOffsetFromPeak:peakIndex-noiseOffsetFromPeak])/nFftPoints)**2 

    if prePulseDetect:    
        sigmaMask = (sigma-np.mean(sigma))>2*np.std(sigma)
        sigmaRejectInd = np.where(sigmaMask)
        noiseSpectra = np.delete(noiseSpectra, sigmaRejectInd, axis=0)
    noiseFreqs = np.fft.fftfreq(nFftPoints,1./sampleRate)    
    noiseSpectrum = np.median(noiseSpectra,axis=0)
    noiseSpectrum[0] = 2.*noiseSpectrum[1] #look into this later 8/15/16
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
