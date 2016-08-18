import matplotlib.pyplot as plt
import numpy as np
import sys
import scipy as sp
import makeNoiseSpectrum as noise
import makeArtificialData as mAD

def makeMatchedFilter(template, noiseSpectrum, nTaps=50, tempOffs=90):
    '''
    Make a matched filter using a template and noise PSD
    INPUTS:
    template - array containing pulse template
    noiseSpectrum - noise PSD
    nTaps - number of filter coefficients
    tempOffs - offset of template subset to use for filter
    '''
    noiseCovInv = noise.covFromPsd(noiseSpectrum, nTaps)['covMatrixInv']    
    template = template[tempOffs:tempOffs+nTaps]  #shorten template to length nTaps
    filterNorm = np.sqrt(np.dot(template, np.dot(noiseCovInv, template)))
    matchedFilt = np.dot(noiseCovInv, template)/filterNorm
    return matchedFilt

def makeCausalWiener(template, rawPulse, nTaps=50, tempOffs=90):
    template = template[tempOffs:tempOffs+nTaps*2]
    rawPulse = rawPulse[tempOffs:tempOffs+nTaps*2]
    crossCorr = np.correlate(template, rawPulse[0:nTaps])
    autoCorr = np.correlate(rawPulse, rawPulse[0:nTaps])
    firCoeffs = sp.solve_toeplitz(autoCorr, crossCorr)
    return firCoeffs

def makeAvgCausalWiener(template, rawdata, peakIndices, nTaps=50, tempOffs=90):
    pass
    return

if __name__=='__main__':
    #test makeMatchedFilter    
    template = np.zeros(800)
    template[100:800] = 10.*np.exp(-np.arange(0,700)/30.)
    data,time = mAD.makePoissonData(totalTime=1000.e-3, maxSignalToNoise=0.0)
    noiseCov = noise.covFromData(data-np.mean(data), 100)['covMatrix']

    plt.show()
