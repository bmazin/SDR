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
    matchedFilter=mF.makeMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=75)
    superMatchedFilter=mF.makeSuperMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=75)

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
    plt.hist(amps,int(np.max(amps)/0.1))
    plt.hist(superAmps,int(np.max(superAmps)/0.1))
    plt.show()
    
##### Test exponential tail robustness of super matched filter #####
if False:
    isPlot=False
    isVerbose=False
    
    #make Template
    rawData, rawTime = mAD.makePoissonData(totalTime=2*131.072e-3,amplitudes='random',maxSignalToNoise=10,isVerbose=isVerbose)
    rawData*=2 #make data distributed around amplitude =1 
    finalTemplate, time , noiseSpectrumDict, _ , _ = mT.makeTemplate(rawData,nSigmaTrig=4.,numOffsCorrIters=2,isVerbose=isVerbose,isPlot=isPlot)
    fittedTemplate, startFit, riseFit, fallFit = mT.makeFittedTemplate(finalTemplate,time,riseGuess=3.e-6,fallGuess=55.e-6)
    matchedFilter=mF.makeMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=75)
    superMatchedFilter=mF.makeSuperMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=75)

    #test filters on piled up pulses
    time=np.arange(0,400e-6,1e-6)
    pulses=np.zeros(len(time))
    pulses+=mAD.makePulse(time,50e-6,2e-6,50e-6)
    pulses+=mAD.makePulse(time,140e-6,2e-6,50e-6)
    pulses+=.6*(np.random.rand(len(pulses))-0.5)
    pulse=mT.hpFilter(pulse)
    filteredData=np.convolve(pulses,matchedFilter,mode='same') 
    superFilteredData=np.convolve(pulses,superMatchedFilter,mode='same')
    
    fig=plt.figure()
    plt.plot(time,pulses,label='piled-up pulses')
    plt.show()
    
    fig=plt.figure()
    plt.plot(time,filteredData ,label = 'matched filter')
    plt.plot(time,superFilteredData, label= 'super matched filter')
    plt.legend()
    plt.show()
 
##### Find optimal tempOffs for filter #####
if False:
    isPlot=False
    isVerbose=False
    
    #make fitted template
    rawData, rawTime = mAD.makePoissonData(totalTime=2*131.072e-3,amplitudes='random',maxSignalToNoise=100,isVerbose=isVerbose)
    rawData*=2 #make data distributed around amplitude =1 
    finalTemplate, time , noiseSpectrumDict, _ , _ = mT.makeTemplate(rawData,nSigmaTrig=4.,numOffsCorrIters=2,isVerbose=isVerbose,isPlot=isPlot)
    fittedTemplate, startFit, riseFit, fallFit = mT.makeFittedTemplate(finalTemplate,time,riseGuess=3.e-6,fallGuess=55.e-6)

    #make a single pulse
    time=np.arange(0,500e-6,1e-6)
    pulse=mAD.makePulse(time,250e-6,2e-6,50e-6)
    pulse=mT.hpFilter(pulse)
        
    #make a bunch of filters
    tempOffs=arange(40,100)
    maximums=np.zeros(len(tempOffs))
    superMaximums=np.zeros(len(tempOffs))
    for i,offset in enumerate(tempOffs):
        matchedFilter=mF.makeMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=offset)
        superMatchedFilter=mF.makeSuperMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=offset)
        maximums[i]=np.max(np.convolve(pulse,matchedFilter))
        superMaximums[i]=np.max(np.convolve(pulse,superMatchedFilter))
    
    
    fig=plt.figure()
    plt.plot(tempOffs,superMaximums-1.)
    #plt.plot(tempOffs,maximums-1.)
    plt.show()
    #print 'matched filter best offset:', tempOffs[np.argmin(np.abs(maximums-1.))] #75
    #print 'super matched filter best offset:', tempOffs[np.argmin(np.abs(superMaximums-1.))]
    

    
##### Test filters on a single pulse #####
if False:
    isPlot=False
    isVerbose=False
    
    #make Template
    rawData, rawTime = mAD.makePoissonData(totalTime=2*131.072e-3,amplitudes='random',maxSignalToNoise=10,isVerbose=isVerbose)
    rawData*=2
    finalTemplate, time , noiseSpectrumDict, _ , _ = mT.makeTemplate(rawData,nSigmaTrig=4.,numOffsCorrIters=2,isVerbose=isVerbose,isPlot=isPlot)
    fittedTemplate, startFit, riseFit, fallFit = mT.makeFittedTemplate(finalTemplate,time,riseGuess=3.e-6,fallGuess=55.e-6)
    matchedFilter=mF.makeMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=75)
    superMatchedFilter=mF.makeSuperMatchedFilter(fittedTemplate, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=75)

    #test filters on a single pulse
    time=np.arange(0,500e-6,1e-6)
    pulses=np.zeros(len(time))
    pulses+=mAD.makePulse(time,250e-6,2e-6,50e-6)
    pulse=mT.hpFilter(pulse)
    filteredData=np.convolve(pulses,matchedFilter,mode='same') 
    superFilteredData=np.convolve(pulses,superMatchedFilter,mode='same')   
    
    fig=plt.figure()
    #plt.plot(time,-pulses,label='piled-up pulses')
    plt.plot(time,filteredData ,label = 'matched filter')
    plt.plot(time,superFilteredData, label= 'super matched filter')
    plt.legend()
    plt.show()
    
    
    