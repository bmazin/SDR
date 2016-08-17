from matplotlib import rcParams, rc
import matplotlib.pyplot as plt
import numpy as np
from baselineIIR import IirFilter
import makeNoiseSpectrum as mNS
import makeArtificialData as mAD

reload(mNS)
reload(mAD)

def makeTemplate(rawdata):

    #hipass filter data to remove any baseline
    data = hpFilter(rawdata)
    
    #trigger on pulses in data (could work in a Chi2 cut so that we can set the trigger level lower)
    peakDict = sigmaTrigger(data,nSigmaTrig=2.)
    
    #remove pulses with additional triggers in the pulse window
    peakIndices = cleanPulses(peakDict['peakMaxIndices'])
        
    #Create rough template
    roughTemplate, _ = averagePulses(data, peakIndices)
    
    #create noise spectrum from pre-pulse data for filter
    noiseSpectDict = mNS.makeWienerNoiseSpectrum(data,peakIndices)
    
    #Correct for errors in peak offsets due to noise
    peakIndices = correctPeakOffs(data, peakIndices, noiseSpectDict, roughTemplate, 'wiener')
    
    #Calculate final template
    finalTemplate, time = averagePulses(data, peakIndices,isoffset=True)
    
    return finalTemplate, time, roughTemplate, noiseSpectDict

def hpFilter(rawdata, criticalFreq=20, sampleRate = 1e6):

    f=2*np.sin(np.pi*criticalFreq/sampleRate)
    Q=.7
    q=1./Q
    hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
    data = hpSvf.filterData(rawdata)
    return data

def sigmaTrigger(data,nSigmaTrig=5.,deadTime=200,decayTime=30):

    #deadTime in ticks (us)
    #decayTime in tics (us)
    data = np.array(data)
    med = np.median(data)
    #print 'sdev',np.std(data),'med',med,'max',np.max(data)
    trigMask = np.logical_or( data > (med + np.std(data)*nSigmaTrig) , data < (med - np.std(data)*nSigmaTrig) )
    if np.sum(trigMask) > 0:
        peakIndices = np.where(trigMask)[0]
        i = 0
        p = peakIndices[i]
        peakMaxIndices = []
        while p < peakIndices[-1]:
            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadTime , peakIndices-p <= 0)]#apply deadTime
            if p+decayTime<len(data):            
                peakData = data[p:p+decayTime]
            else:
                peakData = data[p:]
            peakMaxIndices = np.append(peakMaxIndices, np.argmax(np.abs(peakData))+p)
                            
            i+=1
            if i < len(peakIndices):
                p = peakIndices[i]
            else:
                p = peakIndices[-1]
         
            
    else:
        raise ValueError('sigmaTrigger: No triggers found in dataset')
    
    print 'triggered on', len(peakIndices), 'pulses'    
    return {'peakIndices':peakIndices, 'peakMaxIndices':peakMaxIndices}

def cleanPulses(peakIndices,window=900):
    peakIndices=np.array(peakIndices)
    newPeakIndices=np.array([])
    #check that no peaks are near current peak and then add to new indices variable
    for iPeak, peakIndex in enumerate(peakIndices):
        if np.min(np.abs(peakIndices[np.arange(len(peakIndices))!=iPeak]-peakIndex))>window:
            newPeakIndices=np.append(newPeakIndices,peakIndex)

    if len(newPeakIndices)==0:
        raise ValueError('cleanPulses: no pulses passed the pileup cut')       
    
    print len(peakIndices)-len(newPeakIndices), 'indices cut due to pileup'
    
    return newPeakIndices
    

def averagePulses(data, peakIndices, isoffset=False, nPointsBefore=100, nPointsAfter=700, decayTime=30, sampleRate=1e6):

    numPeaks = 0
    template=np.zeros(nPointsBefore+nPointsAfter)
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex >= nPointsBefore and peakIndex < len(data)-nPointsAfter:
            peakRecord = data[peakIndex-nPointsBefore:peakIndex+nPointsAfter]
            peakData = data[peakIndex-decayTime:peakIndex+decayTime]
            
            if isoffset:
                peakRecord/=np.abs(data[peakIndex])
            else:
                peakHeight = np.max(np.abs(peakData))
                peakRecord /= peakHeight
            template += peakRecord
            numPeaks += 1
    if numPeaks==0:
        raise ValueError('averagePulses: No valid peaks found')
    
    template /= numPeaks
    time = np.arange(0,nPointsBefore+nPointsAfter)/sampleRate
    return template, time
    

def makeWienerFilter(noiseSpectDict, template):
    template /= np.max(np.abs(template)) #should be redundant
    noiseSpectrum = noiseSpectDict['noiseSpectrum']
    templateFft = np.fft.fft(template)/len(template)
    wienerFilter = np.conj(templateFft)/noiseSpectrum
    filterNorm = np.sum(np.abs(templateFft)**2/noiseSpectrum)
    wienerFilter /= filterNorm
    return wienerFilter

def correctPeakOffs(data, peakIndices, noiseSpectDict, template, filterType, offsets=np.arange(-20,21), nPointsBefore=100, nPointsAfter=700):
    if filterType=='wiener':
        makeFilter = makeWienerFilter
    
    else:
        raise ValueError('makeFilterSet: Filter not defined')
    
    nOffsets = len(offsets)
    nPointsTotal = nPointsBefore + nPointsAfter
    filterSet = np.zeros((nOffsets,nPointsTotal),dtype=np.complex64)
    newPeakIndices = []
    
    #Create a set of filters from different template offsets
    for i,offset in enumerate(offsets):
        templateOffs = np.roll(template, offset)
        filterSet[i] = makeFilter(noiseSpectDict, templateOffs)
    
    #find which template offset is the best    
    for iPeak,peakIndex in enumerate(peakIndices):
        if peakIndex > nPointsBefore+np.min(offsets) and peakIndex < len(data)-(nPointsAfter+np.max(offsets)):
            peakRecord = data[peakIndex-nPointsBefore:peakIndex+nPointsAfter]
            peakRecord = peakRecord / np.max(np.abs(peakRecord))
            #check which time shifted filter results in the biggest signal
            peakRecordFft = np.fft.fft(peakRecord)/nPointsTotal
            convSums = np.abs(np.sum(filterSet*peakRecordFft,axis=1))
            bestOffsetIndex = np.argmax(convSums)
            bestConvSum = convSums[bestOffsetIndex]
            bestOffset = offsets[bestOffsetIndex]
            newPeakIndices=np.append(newPeakIndices, peakIndex+bestOffset)

    return newPeakIndices
    
if __name__=='__main__':
    
    #Turn plotting on or off
    isPlot=True 
    isPlotPoisson=False  
    isTestPlot=False
    
    #Starting template values
    sampleRate=1e6
    nPointsBefore=100.
    riseTime=2e-6
    fallTime=50e-6
    tmax=nPointsBefore/sampleRate
    t0=tmax+riseTime*np.log(riseTime/(riseTime+fallTime)) 
    
    #get fake poissonian distributed pulse data
    rawdata, rawtime = mAD.makePoissonData(totalTime=2*131.072e-3)
    
    if isTestPlot:
      plt.figure()
      plt.plot(rawtime,rawdata)
      plt.show()
      
    if isPlotPoisson:
        fig1=plt.figure(0)
        plt.plot(rawtime,rawdata)
        plt.show()
    
    #calculate template    
    finalTemplate, time , roughTemplate, _ = makeTemplate(rawdata)
    
    #calculate real template
    realTemplate = mAD.makePulse(time,t0,riseTime,fallTime)

    if isPlot:
        fig, (ax0, ax1) = plt.subplots(nrows=2, sharex=True)
        h1, = ax0.plot(time*1e6,roughTemplate,'r',linewidth=2)
        h2, = ax0.plot(time*1e6,finalTemplate,'g',linewidth=2)
        h3, = ax0.plot(time*1e6,realTemplate,'b', linewidth=2)
        
        ax1.plot(time*1e6,realTemplate-roughTemplate,'r',linewidth=2)
        ax1.plot(time*1e6,realTemplate-finalTemplate,'g',linewidth=2)
        
        ax1.set_xlabel('time [$\mu$s]')
        ax0.set_ylabel('normalized pulse height')
        ax1.set_ylabel('residuals')
        print type(h1)
        if np.max(realTemplate)>0:
            ax0.legend((h1,h2,h3),('initial template','offset corrected template','real pulse shape'),'upper right')
        else:
            ax0.legend((h1,h2,h3),('initial template','offset corrected template','real pulse shape'),'lower right')
        plt.show()   
        
    
