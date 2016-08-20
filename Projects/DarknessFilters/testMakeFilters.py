from matplotlib import rcParams, rc
import matplotlib.pyplot as plt
import numpy as np
import scipy.optimize as opt
from baselineIIR import IirFilter
import makeNoiseSpectrum as mNS
import makeArtificialData as mAD
import makeTemplate as mT
import makeFilters as mF

reload(mNS)
reload(mAD)
reload(mT)
reload(mF)

##### Find expected energy resolution of different filters #####
if True:
    isPlot=False
    isVerbose=False
    
    #make fake data
    rawData, rawTime = mAD.makePoissonData(totalTime=2*131.072e-3,amplitudes='random',maxSignalToNoise=10,isVerbose=isVerbose)
    rawData*=2
    #make template
    finalTemplate, time , noiseSpectrumDict, _ , _ = mT.makeTemplate(rawData,nSigmaTrig=4.,numOffsCorrIters=2,isVerbose=isVerbose,isPlot=isPlot)
    #fit to arbitrary pulse shape
    fittedTemplate, startFit, riseFit, fallFit = mT.makeFittedTemplate(finalTemplate,time,riseGuess=3.e-6,fallGuess=55.e-6)
    #make matched filter
    matchedFilter=mF.makeMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=90)
    superMatchedFilter=mF.makeSuperMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=90)

    #make more fake data
    rawData, rawTime = mAD.makePoissonData(totalTime=2*131.072e-3, rate =1./5e-3, amplitudes='constant',maxSignalToNoise=10,isVerbose=isVerbose)  
    #filter data
    data=mT.hpFilter(rawData) 
    #convolve with filter
    filteredData=np.convolve(data,matchedFilter,mode='same') 
    superFilteredData=np.convolve(data,superMatchedFilter,mode='same')
     
    #find peak indices
    peakDict=mT.sigmaTrigger(filteredData,nSigmaTrig=3.)
    superPeakDict=mT.sigmaTrigger(superFilteredData,nSigmaTrig=3.)
    
    #find peak amplitudes
    amps=filteredData[peakDict['peakMaxIndices']]
    superAmps=superFilteredData[superPeakDict['peakMaxIndices']]
    
    #plot histogram
    fig=plt.figure()
    #plt.hist(amplitudes[np.logical_and(amplitudes<1.04 , amplitudes >.96)])
    plt.hist(amps,int(np.max(amps)/0.01))
    plt.hist(superAmps,int(np.max(superAmps)/0.01))
    plt.show()
