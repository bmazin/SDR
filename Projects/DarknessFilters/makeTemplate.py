from matplotlib import rcParams, rc
import matplotlib.pyplot as plt
import numpy as np
from baselineIIR import IirFilter
import makeNoiseSpectrum as mNS
import makeArtificialData as mAD

reload(mNS)
reload(mAD)

def makeTemplate(rawdata, numOffsCorrIters=1):
    '''
    Make a matched filter template using a raw phase timestream
    INPUTS:
    rawdata - noisy phase timestream with photon pulses
    numOffsCorrIters - number of pulse offset corrections to perform

    OUTPUTS:
    finalTemplate - template of pulse shape
    time - use as x-axis when plotting template
    noiseSpectDict - dictionary containing noise spectrum and corresponding frequencies
    '''

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
    filterList = []
    for i in range(numOffsCorrIters):
        peakIndices = correctPeakOffs(data, peakIndices, noiseSpectDict, roughTemplate, 'wiener')
        roughTemplate, time = averagePulses(data, peakIndices,isoffset=True) #calculate a new corrected template
        filterList.append(roughTemplate)
    
    finalTemplate = roughTemplate

    return finalTemplate, time, noiseSpectDict, filterList

def hpFilter(rawdata, criticalFreq=20, sampleRate = 1e6):
    '''
    High pass filters the raw phase timestream
    INPUTS:
    rawdata - data to be filtered
    criticalFreq - cutoff frequency of filter (in Hz)
    sampleRate - sample rate of rawdata

    OUTPUTS:
    data - filtered data
    '''
    f=2*np.sin(np.pi*criticalFreq/sampleRate)
    Q=.7
    q=1./Q
    hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
    data = hpSvf.filterData(rawdata)
    return data

def sigmaTrigger(data,nSigmaTrig=5.,deadTime=200,decayTime=30):
    '''
    Detects pulses in raw phase timestream
    INPUTS:
    data - phase timestream
    nSigmaTrig - threshold to detect pulse in terms of standard deviation of data
    deadTime - minimum amount of time between any two pulses (units: ticks (1 us assuming 1 MHz sample rate))
    decayTime - expected pulse decay time (units: ticks)
    '''
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
    '''
    Removes any pulses that have another pulse within 'window' (in ticks) This is
    to ensure that template data is not contaminated by extraneous pulses.
    
    INPUTS:
    peakIndices - list of pulse positions
    window - size of pulse removal window (in ticks (us))

    OUTPUS:
    newPeakIndices - list of pulse positions, with unwanted pulses deleted
    '''
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
    '''
    Average together pulse data to make a template
    
    INPUTS:
    data - raw phase timestream
    peakIndices - list of pulse positions
    isoffset - true if peakIndices are the locations of peak maxima
    nPointsBefore - number of points before peakIndex to include in template
    nPointsAfter - number of points after peakIndex to include in template
    decayTime - expected pulse decay time (in ticks (us))
    sampleRate - sample rate of 'data'

    OUTPUTS:
    template - caluculated pulse template
    time - time markers indexing data points in 'template'
           (use as x-axis when plotting)
    '''
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
    '''
    Calculate acausal Wiener Filter coefficients in the frequency domain
    
    INPUTS:
    noiseSpectDict - Dictionary containing noise spectrum and list of corresponding frequencies
    template - template of pulse shape
    
    OUTPUTS:
    wienerFilter - list of Wiener Filter coefficients
    '''
    template /= np.max(np.abs(template)) #should be redundant
    noiseSpectrum = noiseSpectDict['noiseSpectrum']
    templateFft = np.fft.fft(template)/len(template)
    wienerFilter = np.conj(templateFft)/noiseSpectrum
    filterNorm = np.sum(np.abs(templateFft)**2/noiseSpectrum)
    wienerFilter /= filterNorm
    return wienerFilter

def correctPeakOffs(data, peakIndices, noiseSpectDict, template, filterType, offsets=np.arange(-20,21), nPointsBefore=100, nPointsAfter=700):
    '''
    Correct the list of peak indices to improve the alignment of photon pulses.  

    INPUTS:
    data - raw phase timestream
    peakIndices - list of photon pulse indices
    noiseSpectDict - dictionary containing noise spectrum and corresponding frequencies
    template - template of pulse to use for filter
    filterType - string specifying the type of filter to use
    offsets - list of peak index offsets to check
    nPointsBefore - number of points before peakIndex to include in pulse
    nPointsAfter - number of points after peakIndex to include in pulse

    OUTPUTS:
    newPeakIndices - list of corrected peak indices
    '''
    
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
    
    #find which peak index offset is the best for each pulse:
    #   apply each offset to the pulse, then determine which offset 
    #   maximizes the pulse amplitude after application of the filter
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
    
    #calculate templates    
    finalTemplate, time , _ = makeTemplate(rawdata)
    roughTemplate, time, _ = makeTemplate(rawdata,0)
    
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
        
    
