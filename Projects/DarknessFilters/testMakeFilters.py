from matplotlib import rcParams, rc
import matplotlib.pyplot as plt
import numpy as np
import scipy.optimize as opt
from baselineIIR import IirFilter
import makeNoiseSpectrum as mNS
import makeArtificialData as mAD
import makeTemplate as mT
import makeFilters as mF
import struct

import extractRawData as eRD
import triggerPhotons as tP
import os

reload(mNS)
reload(mAD)
reload(mT)
reload(mF)
reload(tP)

##### Test on real data #####
if True:
    isPlot=False
    isVerbose=True
    #get data        
    rawData = eRD.parseQDRPhaseSnap(os.path.join(os.getcwd(),'TestData/20140915/redLaser'),pixelNum=0,roachNum=0,steps=30)
    #make fake data
    #rawData, rawTime = mAD.makePoissonData(totalTime=10*131.072e-3,amplitudes='random',maxSignalToNoise=10,isVerbose=isVerbose)
    #rawData*=2
    print "data extracted"
    
    #make template
    template, time, noiseSpectrumDict, _, _ = mT.makeTemplate(rawData,nSigmaTrig=5.,numOffsCorrIters=3,isVerbose=isVerbose,isPlot=isPlot, sigPass=.5)
    print "template made"
    
    #noiseSpectrumDict['noiseSpectrum']=np.ones(len(noiseSpectrumDict['noiseSpectrum']))
    #noiseSpectrumDict['noiseSpectrum']=np.ones(len(noiseSpectrumDict['noiseSpectrum']))*3e3/np.abs(noiseSpectrumDict['noiseFreqs'])
    #noiseSpectrumDict['noiseSpectrum'][0]=2*noiseSpectrumDict['noiseSpectrum'][1]
    #noiseSpectrumDict['noiseSpectrum'][np.abs(noiseSpectrumDict['noiseFreqs'])>210000]=5e-5
   
    #make matched filter
    matchedFilter=mF.makeMatchedFilter(template, noiseSpectrumDict['noiseSpectrum'], nTaps=50, tempOffs=75)
    coef, _ = opt.curve_fit(lambda x, a, t0 : a*exp(-x/t0), time[len(time)*1/5:len(time)*4/5],template[len(time)*1/5:len(time)*4/5], [-1 , 30e-6])
    fallFit=coef[1]
    superMatchedFilter=mF.makeSuperMatchedFilter(template, noiseSpectrumDict['noiseSpectrum'], fallFit, nTaps=50, tempOffs=75)
    print "filters made"
    
    #convolve with filter
    filteredData=np.convolve(rawData,matchedFilter,mode='same') 
    superFilteredData=np.convolve(rawData,superMatchedFilter,mode='same')
    print "data filtered" 
    
    #find peak indices
    peakDict=tP.detectPulses(filteredData, nSigmaThreshold = 3., negDerivLenience = 1, bNegativePulses=False)
    superPeakDict=tP.detectPulses(superFilteredData, nSigmaThreshold = 3., negDerivLenience = 1, bNegativePulses=False)
    print "peaks found"
    
    #find peak amplitudes
    amps=filteredData[peakDict['peakIndices']]
    superAmps=superFilteredData[superPeakDict['peakIndices']]
    print "amplitudes extracted"
    
    #fig=plt.figure()
    #plt.plot(template)
    #plt.hist(amps,100,alpha=.7)
    #plt.hist(superAmps,100,alpha=.7)
    #plt.show()
    
##### Find expected energy resolution of different filters #####
if False:
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
    pulses=mT.hpFilter(pulses)
    filteredData=np.convolve(pulses,matchedFilter,mode='same') 
    superFilteredData=np.convolve(pulses,superMatchedFilter,mode='same')
    
    fig=plt.figure()
    plt.plot(time,pulses,label='piled-up pulses')
    plt.show()
    
    fig=plt.figure()
    plt.plot(time,filteredData ,label = 'matched filter')
    plt.plot(time,superFilteredData, label= 'pre-pulse robust matched filter')
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
    
#####Test energy resolution with real data.  Assumes constant photon energy#####    
if False:
    isPlot=False
    isVerbose=False
    
    #extract raw data
    rawData = eRD.parseQDRPhaseSnap(os.path.join(os.getcwd(),'20140915/redLaser'),pixelNum=0,steps=30)
    rawTemplateData = rawData[0:1000000]
    rawTestData = rawData[1000000:2000000]
    #make template
    finalTemplate, time , noiseSpectrumDict, _ , tempPeakIndices = mT.makeTemplate(rawTemplateData,nSigmaTrig=4.,numOffsCorrIters=2,isVerbose=isVerbose,isPlot=isPlot)
    #fit to arbitrary pulse shape
    fittedTemplate, startFit, riseFit, fallFit = mT.makeFittedTemplate(finalTemplate,time,riseGuess=3.e-6,fallGuess=55.e-6)
    noiseSpectrumDictCovMat = mNS.makeWienerNoiseSpectrum(rawTemplateData, tempPeakIndices, 8000, 1000)
    #make matched filter
    matchedFilter=mF.makeMatchedFilter(finalTemplate, noiseSpectrumDictCovMat['noiseSpectrum'], nTaps=50, tempOffs=75)
    superMatchedFilter=mF.makeSuperMatchedFilter(finalTemplate, noiseSpectrumDictCovMat['noiseSpectrum'], fallFit, nTaps=50, tempOffs=75)

    #plot templates
    plt.plot(time,finalTemplate)
    plt.plot(time,fittedTemplate)
    plt.show()

    #filter data
    #data=mT.hpFilter(rawTestData) 
    data = rawTestData 
    #convolve with filter
    filteredData=np.convolve(data,matchedFilter,mode='same') 
    superFilteredData=np.convolve(data,superMatchedFilter,mode='same')

    #plot filtered data
    fig=plt.figure()
    plt.plot(filteredData[0:10000])
    plt.plot(superFilteredData[0:10000])
    plt.plot(rawTestData[0:10000])
    plt.show()
     
    #find peak indices
    peakDict=tP.detectPulses(filteredData, nSigmaThreshold = 3., negDerivLenience = 1, bNegativePulses=False)
    superPeakDict=tP.detectPulses(superFilteredData, nSigmaThreshold = 3., negDerivLenience = 1, bNegativePulses=False)
    
    #find peak amplitudes
    amps=filteredData[peakDict['peakIndices']]
    superAmps=superFilteredData[superPeakDict['peakIndices']]
    
    print 'default sigma:', np.std(amps)

    #plot histogram
    fig=plt.figure()
    #plt.hist(amplitudes[np.logical_and(amplitudes<1.04 , amplitudes >.96)])
    plt.hist(amps)
    plt.hist(superAmps)
    plt.show()
 
    pulseHist, pulseHistBins = np.histogram(amps, bins='auto')
    pulseHistS, pulseHistBinsS = np.histogram(superAmps, bins='auto')
    plt.plot(pulseHistBins[:-1],pulseHist)
    plt.plot(pulseHistBinsS[:-1],pulseHistS)
    plt.show()

    #optimize trigger conditions
    #optSigmaThresh, optNNegDerivThresh, optNNegDerivLenience, minSigma, peakDict = tP.optimizeTrigCond(filteredData, 100, np.arange(3,10,0.5), np.arange(10,30,1), np.arange(1,4,1), False)    
    #optSigmaThreshS, optNNegDerivThreshS, optNNegDerivLenienceS, minSigmaS, superPeakDict = tP.optimizeTrigCond(superFilteredData, 100, np.arange(3,10,0.5), np.arange(10,30,1), np.arange(1,4,1), False)

    #find optimal sigma threshold
    thresh, sigmaThresh = tP.findSigmaThresh(filteredData)
    threshS, sigmaThreshS = tP.findSigmaThresh(filteredData)
    
    print 'Threshold:', thresh
    print 'Sigma Thresh:', sigmaThresh
    print 'Super Threshold:', threshS
    print 'Super Matched Sigma Thresh:', sigmaThreshS

    #find peak indices
    peakDict=tP.detectPulses(filteredData, nSigmaThreshold = sigmaThresh, negDerivLenience = 1, bNegativePulses=False)
    superPeakDict=tP.detectPulses(superFilteredData, nSigmaThreshold = sigmaThreshS, negDerivLenience = 1, bNegativePulses=False)

    amps=filteredData[peakDict['peakIndices']]
    superAmps=superFilteredData[superPeakDict['peakIndices']]

    #print 'Sigma Thresh:', optSigmaThresh
    #print 'N Neg Derivative Checks:', optNNegDerivThresh
    #print 'N Neg Derivative Lenience:', optNNegDerivLenience
    #print 'minSigma:', minSigma
    #print ''
    #print 'Super Matched Filter:'
    #print 'Sigma Thresh:', optSigmaThreshS
    #print 'N Neg Derivative Checks:', optNNegDerivThreshS
    #print 'N Neg Derivative Lenience:', optNNegDerivLenienceS
    #print 'minSigma:', minSigmaS
    
    pulseHist, pulseHistBins = np.histogram(amps, bins='auto')
    pulseHistS, pulseHistBinsS = np.histogram(superAmps, bins='auto')
    plt.plot(pulseHistBins[:-1],pulseHist)
    plt.plot(pulseHistBinsS[:-1],pulseHistS)
    plt.show()
