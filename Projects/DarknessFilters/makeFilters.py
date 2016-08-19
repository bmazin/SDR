import matplotlib.pyplot as plt
import numpy as np
import sys
import scipy as sp
import makeNoiseSpectrum as noise
import makeArtificialData as mAD
import makeTemplate as mkt

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

def makeCausalWiener(template, rawPulse, nTaps=50):
    #template = template[tempOffs:tempOffs+nTaps*2]
    #rawPulse = rawPulse[tempOffs:tempOffs+nTaps*2]
    rawPulse = rawPulse/np.max(np.abs(rawPulse))
    crossCorr = np.correlate(template, rawPulse[0:-nTaps+1])
    autoCorr = np.correlate(rawPulse, rawPulse[0:-nTaps+1])
    firCoeffs = sp.linalg.solve_toeplitz(autoCorr, crossCorr) 
    return firCoeffs/np.max(np.abs(firCoeffs))

def makeAvgCausalWiener(template, rawdata, peakIndices, nTaps=50, nPointsBefore=100, nPointsAfter=700):
    firCoeffs = np.zeros(nTaps)
    for peak in peakIndices:
        firCoeffs += makeCausalWiener(template, rawdata[peak-nPointsBefore:peak+nPointsAfter], nTaps)
    
    firCoeffs /= len(peakIndices)
    
    return firCoeffs

if __name__=='__main__':
    testMatched = False
    testWiener = True

    if testMatched:
        #test makeMatchedFilter    
        template = np.zeros(800)
        template[100:800] = 10.*np.exp(-np.arange(0,700)/30.)
        data,time = mAD.makePoissonData(totalTime=1000.e-3, maxSignalToNoise=0.0)
        noiseCov = noise.covFromData(data-np.mean(data), 100)['covMatrix']

        plt.show()

    if testWiener:
        templateData, time = mAD.makePoissonData(totalTime=10*131.072e-3)
        finalTemplate, time, _,_,_ = mkt.makeTemplate(templateData)

        filterData, time = mAD.makePoissonData(totalTime=10*131.072e-3,maxSignalToNoise=10) #new data set for Wiener filter raw pulses
        _,_,_,_,peakIndices = mkt.makeTemplate(filterData)
        wienerFilt = makeAvgCausalWiener(finalTemplate, filterData, peakIndices)
        plt.plot(wienerFilt)
        plt.plot(finalTemplate)
        #plt.plot(filterData[peakIndices[0]-100:peakIndices[0]+800]/5)
        plt.show()
       
