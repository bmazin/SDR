import matplotlib.pyplot as plt
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
import makeNoiseSpectrum as noise
import makeArtificialData as mAD

def makeMatchedFilter(template, noiseCov, nTaps=50, tempOffs=90):
    '''
    Make a matched filter using a template and noise PSD
    INPUTS:
    template - array containing pulse template
    noiseSpectrum - noise PSD
    nTaps - number of filter coefficients
    tempOffs - offset of template subset to use for filter
    '''
    #noiseCov = noise.covFromPsd(noiseSpectrum, nTaps)
    noiseCovInv = np.linalg.inv(noiseCov)    
    print 'noiseCov', noiseCov
    print 'noiseCovInv', noiseCovInv
    print 'noiseCovDiag', np.diag(noiseCov)
    print 'noiseCovInvDiag', np.diag(noiseCovInv)
    template = template[tempOffs:tempOffs+nTaps]  #shorten template to length nTaps
    print np.dot(template, np.dot(noiseCovInv, template))
    filterNorm = np.sqrt(np.dot(template, np.dot(noiseCovInv, template)))
    matchedFilt = np.dot(noiseCovInv, template)/filterNorm
    matchedFiltRev = np.dot(template, noiseCovInv)/filterNorm
    print 'filterNorm', filterNorm
    print 'matchedFilt', matchedFilt
    return matchedFilt, matchedFiltRev

if __name__=='__main__':
    #test makeMatchedFilter    
    template = np.zeros(800)
    template[100:800] = 10.*np.exp(-np.arange(0,700)/30.)
    data,time = mAD.makePoissonData(totalTime=1000.e-3, maxSignalToNoise=0.0)
    noiseCov = noise.covFromData(data-np.mean(data), 100)['covMatrix']

    filt, filtRev = makeMatchedFilter(template, noiseCov, 100)
    plt.plot(template)
    plt.plot(10*filt)
    plt.plot(10*filtRev)
    plt.show()
