import adcSnapCheck as adcSnap
from Roach2Controls import Roach2Controls
import numpy as np
import time, struct, sys, os
import matplotlib.pyplot as plt
import random
import scipy.optimize as spo

class SBOptimizer:
    def __init__(self, ip='10.0.0.112', params='/mnt/data0/neelay/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param', loFreq=5.e9, 
        adcAtten=26.75, toneAtten=35, globalDacAtten=30, freq=None):
        '''
        INPUTS:
            ip: ROACH2 IP Address
            params: Roach2Controls parameter file
            loFreq: LO Frequency in Hz
            adcAtten: attenuation value (dB) of IF board ADC attenuator
            toneAtten: total resonator attenuation
            global Dac Atten: physical DAC attenuation
            frequencty: tone frequency (optional)
        '''
        self.roach = Roach2Controls(ip, params, True, False)
        self.loFreq = loFreq
        self.adcAtten = adcAtten
        self.toneAtten = toneAtten
        self.globalDacAtten = globalDacAtten
        self.curFreq = freq

    def initRoach(self):
        '''
        Initializes the ROACH2: connects, initializes the UART, loads the LO and physical attenuations
        '''
        self.roach.connect()
        self.roach.setLOFreq(self.loFreq)
        self.roach.initializeV7UART(waitForV7Ready=False)
        self.roach.loadLOFreq()
        self.roach.changeAtten(1,np.floor(self.globalDacAtten/31.75)*31.75)
        self.roach.changeAtten(2,self.globalDacAtten%31.75)
        self.roach.changeAtten(3,self.adcAtten)

    def loadLUT(self, freqList=None, phaseList=None, iqRatioList=None):
        '''
        Loads DAC LUT
        INPUTS:
            freq: tone frequency in Hz
            phaseDelay: IQ phase offset (degrees)
            iqRatio: IAmp/QAmp
        '''
        if freqList is None:
            if self.curFreq==None:
                raise ValueError('Must specify a frequency!')
            freqList = np.asarray([self.curFreq])
        attenList = self.toneAtten*np.ones(len(freqList))
        print 'attenList', attenList
        print 'freqList', freqList
        self.roach.generateResonatorChannels(freqList)
        self.roach.generateFftChanSelection()
        #self.roach.generateDacComb(resAttenList=attenList,globalDacAtten=9)
        print 'Generating DDS Tones...'
        self.roach.generateDdsTones()
        self.roach.debug=False
        self.roach.generateDacComb(freqList=freqList, resAttenList=attenList, globalDacAtten=self.globalDacAtten, iqRatioList=iqRatioList, 
            iqPhaseOffsList=phaseList)
        self.roach.loadDacLUT()
        self.roach.fpga.write_int('run',1)#send ready signals
        time.sleep(1)
    
    def takeAdcSnap(self):
        '''
        Takes an ADC Snap
        OUTPUTS:
            snapDict: Dictionary w/ I and Q values (see adcSnapCheck.py)
        '''
        delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
        delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
        delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
        delayLut3 = zip(np.arange(42,54),np.ones(12)*13)
        adcSnap.loadDelayCal(self.roach.fpga,delayLut0)
        adcSnap.loadDelayCal(self.roach.fpga,delayLut1)
        adcSnap.loadDelayCal(self.roach.fpga,delayLut2)
        adcSnap.loadDelayCal(self.roach.fpga,delayLut3)

        snapDict = adcSnap.snapZdok(self.roach.fpga,nRolls=0)
        
        return snapDict

    def phaseDelOptimizer(self, phaseStart=-30, phaseStop=30, frequency=None):
        '''
        Finds the maximum sideband suppression over phase delay at a given frequency
        
        INPUTS:
            phaseStart, phaseStop: start and stop values of phase delay search space
            frequency: tone frequency
        
        OUTPUTS:
            optPhase: optimal phase delay
            lastSBSuppression: SB suppression achieved at optPhase
        '''
        foundMax = False
        optPhase = None
        lastSBSuppression = -np.inf
        while(not foundMax):
            phase = int((phaseStart+phaseStop)/2)
            phases = [phase, phase+1]
            sbSuppressions = []
            for curPhase in phases:
                self.loadLUT(np.asarray([frequency]), curPhase)
                snapDict = self.takeAdcSnap()
                adjIVals, adjQVals = adcSnap.adjust(snapDict['iVals'], snapDict['qVals'], 0, adjAmp=False)
                specDict = adcSnap.streamSpectrum(adjIVals, adjQVals)
                sbSup = specDict['peakFreqPower'] - specDict['sidebandFreqPower']
                sbSuppressions.append(sbSup)
                if (np.sign(sbSup-lastSBSuppression)<0):
                    grad = -grad
                    break
                
            lastSBSuppression = max(sbSuppressions)
            if len(sbSuppressions)>1:
                grad = np.diff(sbSuppressions)[0]
            if np.sign(grad)==-1:
                phaseStop = phase
            
            elif np.sign(grad)==1:
                phaseStart = phase
                
            else:
                raise ValueError('...')    
            
            print 'phaseStart', phaseStart
            print 'phaseStop', phaseStop

            if phaseStop-phaseStart==1:
                optPhase = phaseStop
                foundMax = True
        
        return optPhase, lastSBSuppression

    def gridSearchOptimizer(self, freqs, phaseStart, phaseStop, iqRatioStart, iqRatioStop, iqRatioStride=0.02, saveData=True):
        iqRatioStarts = iqRatioStart*np.ones(len(freqs))
        iqRatioStops = iqRatioStop*np.ones(len(freqs))
        phaseStarts = phaseStart*np.ones(len(freqs))
        phaseStops = phaseStop*np.ones(len(freqs))
        foundMaxArr = np.zeros(len(freqs), dtype=bool) #array indicating whether max SB suppression found at each frequency
        optPhases = np.zeros(len(freqs)) #optimal phase at each frequency
        optIQRatios = np.zeros(len(freqs)) #optimal I/Q at each frequency
        grads = np.zeros((len(freqs), 2)) #current gradient at each frequency
        maxSBSuppressions = np.zeros(len(freqs))

        nSamples = 4096.
        sampleRate = 2000. #MHz
        quantFreqsMHz = np.array(freqs/1.e6-self.loFreq/1.e6)
        quantFreqsMHz = np.round(quantFreqsMHz*nSamples/sampleRate)*sampleRate/nSamples
        snapDict = self.takeAdcSnap()
        specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])        
        findFreq = lambda freq: np.where(specDict['freqsMHz']==freq)[0][0]
        print 'quantFreqsMHz', quantFreqsMHz
        print 'spectDictFreqs', specDict['freqsMHz']
        print 'nSamples', specDict['nSamples']
        freqLocs = np.asarray(map(findFreq, quantFreqsMHz))
        sbLocs = -1*freqLocs + len(specDict['freqsMHz'])

        while(np.any(foundMaxArr==False)):
            phases = (phaseStarts+phaseStops)/2
            phases = np.transpose(np.stack((phases, phases+1)))
            iqRatios = (iqRatioStarts+iqRatioStops)/2
            iqRatios = np.transpose(np.stack((iqRatios, iqRatios+iqRatioStride)))
            
            print 'corr list len', len(phases[:,0]), len(iqRatios[:,0])
            self.loadLUT(freqs, phases[:,0], iqRatios[:,0])
            snapDict = self.takeAdcSnap()
            specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
            sbSuppressions = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]
            
            self.loadLUT(freqs, phases[:,1], iqRatios[:,0])
            snapDict = self.takeAdcSnap()
            specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
            sbSuppressionsdPh = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]

            self.loadLUT(freqs, phases[:,0], iqRatios[:,1])
            snapDict = self.takeAdcSnap()
            specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
            sbSuppressionsdIQ = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]

            grads[:,0] = np.sign(sbSuppressionsdPh - sbSuppressions)
            grads[:,1] = np.sign(sbSuppressionsdIQ - sbSuppressions)
            
            posPhaseGrads = np.where(grads[:,0]==1)[0]
            negPhaseGrads = np.where(grads[:,0]==-1)[0]
            zeroPhaseGrads = np.where(grads[:,0]==0)[0]
            
            posIQGrads = np.where(grads[:,1]==1)[0]
            negIQGrads = np.where(grads[:,1]==-1)[0]
            zeroIQGrads = np.where(grads[:,1]==0)[0]

            phaseStarts[posPhaseGrads] = phases[posPhaseGrads,0]
            phaseStops[negPhaseGrads] = phases[negPhaseGrads,0]
            phaseStarts[zeroPhaseGrads] -=1

            iqRatioStarts[posIQGrads] = iqRatios[posIQGrads,0]
            iqRatioStops[negIQGrads] = iqRatios[negIQGrads,0]
            iqRatioStarts[zeroIQGrads] -=1

            print 'phase range', phaseStarts, phaseStops
            print 'iqRatioRange', iqRatioStarts, iqRatioStops
            print 'sbSuppressions', sbSuppressions, sbSuppressionsdPh, sbSuppressionsdIQ
            print 'grads', grads

            foundMaxArr = ((phaseStops-phaseStarts)<=1) & ((iqRatioStops-iqRatioStarts)<=iqRatioStride)
        
        optPhases = phaseStops
        optIQRatios = iqRatioStops
        maxSBSuppressions = sbSuppressions
        
        if(saveData):
            np.savez('grid_search_opt_vals_'+str(len(freqs))+'_freqs_'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqs, 
                optPhases=optPhases, optIQRatios=optIQRatios, maxSBSuppressions=maxSBSuppressions, toneAtten=self.toneAtten, 
                globalDacAtten=self.globalDacAtten, adcAtten=self.adcAtten)
        
        return optPhases, optIQRatios, maxSBSuppressions
        
    def gridSearchOptimizerFit(self, freqList, phases=np.arange(-25, 10), iqRatios=np.arange(0.65, 1.35, 0.02), threshold=45, weightDecayDist=1):
        sampledSBSups = np.zeros((len(freqList), len(phases), len(iqRatios)))
        sampledSBSups[:] = np.nan
        
        nSamples = 4096.
        sampleRate = 2000. #MHz
        quantFreqsMHz = np.array(freqList/1.e6-self.loFreq/1.e6)
        quantFreqsMHz = np.round(quantFreqsMHz*nSamples/sampleRate)*sampleRate/nSamples
        snapDict = self.takeAdcSnap()
        specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])        
        findFreq = lambda freq: np.where(specDict['freqsMHz']==freq)[0][0]
        print 'quantFreqsMHz', quantFreqsMHz
        print 'spectDictFreqs', specDict['freqsMHz']
        print 'nSamples', specDict['nSamples']
        freqLocs = np.asarray(map(findFreq, quantFreqsMHz))
        sbLocs = -1*freqLocs + len(specDict['freqsMHz'])

        weights = np.ones((len(freqList), len(phases), len(iqRatios)))
        print 'weightShape', np.shape(weights)
        normWeights = np.transpose(np.transpose(np.reshape(weights,(len(freqList),-1)))/np.sum(weights, axis=(1,2)))
        normWeights = np.reshape(normWeights, np.shape(weights))
        
        sbSupIndList = np.zeros((len(freqList), 2))
        flatInds = np.arange(len(phases)*len(iqRatios))
        curSupList = np.zeros(len(freqList))
        phaseList = np.zeros(len(freqList))
        iqRatioList = np.ones(len(freqList))
        finalPhaseList = np.zeros(len(freqList))
        finalIQRatioList = np.ones(len(freqList))
        finalSBSupList = np.zeros(len(freqList))
        foundMaxList = np.zeros(len(freqList))
        counter = 0

        def gaussian(x, x0r, x0c, scale, width):
            return scale*np.exp(-((x[0]-x0r)**2+(x[1]-x0c)**2)/width**2)

        def expDecay(x, x0r, x0c, scale, width):
            return scale*np.exp(-np.sqrt((x[0]-x0r)**2+(x[1]-x0c)**2)/width)

        #sample initial points
        for i in range(4):
            for j in range(len(freqList)):
                flatInd = np.random.choice(flatInds, p=normWeights[j,:].flatten())
                sbSupInd = np.unravel_index(flatInd, np.shape(sampledSBSups[j]))
                phaseList[j] = phases[sbSupInd[0]]
                iqRatioList[j] = iqRatios[sbSupInd[1]]
                sbSupIndList[j] = np.asarray(sbSupInd)
                
            self.loadLUT(freqList, phaseList, iqRatioList)
            snapDict = self.takeAdcSnap()
            specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
            curSupList = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]
            
            for j in range(len(freqList)):
                sampledSBSups[j, sbSupIndList[j,0], sbSupIndList[j,1]] = curSupList[j]
                weights[j, sbSupIndList[j,0], sbSupIndList[j,1]] = 0
                    
            normWeights = np.transpose(np.transpose(np.reshape(weights,(len(freqList),-1)))/np.sum(weights, axis=(1,2)))
            normWeights = np.reshape(normWeights, np.shape(weights))
            


        fitParams = [10, 10, 40, 15]
        rowCoords = np.tile(np.arange(np.shape(sampledSBSups[0])[0]),(np.shape(sampledSBSups[0])[1],1))
        rowCoords = np.transpose(rowCoords)
        colCoords = np.tile(np.arange(np.shape(sampledSBSups[0])[1]),(np.shape(sampledSBSups[0])[0],1))

        while np.any(foundMaxList==0):
            nFailedFits = 0
            for j in range(len(freqList)):
                flatInd = np.random.choice(flatInds, p=normWeights[j,:].flatten())
                sbSupInd = np.unravel_index(flatInd, np.shape(sampledSBSups[j]))
                phaseList[j] = phases[sbSupInd[0]]
                iqRatioList[j] = iqRatios[sbSupInd[1]]
                sbSupIndList[j] = np.asarray(sbSupInd)

                
            self.loadLUT(freqList, phaseList, iqRatioList)
            snapDict = self.takeAdcSnap()
            specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
            curSupList = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]
            
            for j in range(len(freqList)):
                sampledSBSups[j, sbSupIndList[j,0], sbSupIndList[j,1]] = curSupList[j]
                
                if(np.any(sampledSBSups[j]>=threshold)):
                    foundMaxList[j]=1
                    optSBSupIndFlat = np.nanargmax(sampledSBSups[j])
                    optSBSupInd = np.unravel_index(optSBSupIndFlat, np.shape(sampledSBSups[j]))
                    finalPhaseList[j] = phases[optSBSupInd[0]]
                    finalIQRatioList[j] = iqRatios[optSBSupInd[1]]
                    finalSBSupList[j] = sampledSBSups[j, optSBSupInd[0], optSBSupInd[1]]
                
                #calculate new weights

                validSBLocs = np.where(np.isnan(sampledSBSups[j])==0) #coordinates of sampled points
                xdata = np.array([validSBLocs[0],validSBLocs[1]])
                ydata = np.array(sampledSBSups[j,validSBLocs[0],validSBLocs[1]])
                print 'xdata', xdata
                print 'ydata', ydata
                
                try:
                    fitParams, pcov = spo.curve_fit(expDecay, xdata, ydata, fitParams, 
                        bounds=([0, 0, 30, 2], [np.shape(sampledSBSups[0])[0], np.shape(sampledSBSups[0])[1], 50, 20]), method='trf')
                
                    print 'fitParams', fitParams
                    print 'fitting errors', np.sqrt(np.diag(pcov))

                    rowDist = rowCoords - fitParams[0]
                    colDist = colCoords - fitParams[1]
                    weightDecay = np.random.choice([25,weightDecayDist])
                    weights[j] = np.exp(-(rowDist**2+colDist**2)/weightDecay**2)

                except RuntimeError:
                    nFailedFits += 1
                    pass
                
                weights[j, validSBLocs]=0
            
            normWeights = np.transpose(np.transpose(np.reshape(weights,(len(freqList),-1)))/np.sum(weights, axis=(1,2)))
            normWeights = np.reshape(normWeights, np.shape(weights))
            
            counter += 1
            
            threshold -= 1

            print 'Number of Failed Fits', nFailedFits
            print 'Number past threshold', sum(foundMaxList)
            print 'threshold', threshold
            print counter, 'iterations'
            print 'curSupList', curSupList
            #plt.imshow(normWeights)
            #plt.colorbar()
            #plt.show()

        np.savez('grid_search_opt_vals_'+str(len(freqList))+'_freqs_'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqList,
                        optPhases=finalPhaseList, optIQRatios=finalIQRatioList, maxSBSuppressions=finalSBSupList, toneAtten=self.toneAtten,
                                        globalDacAtten=self.globalDacAtten, adcAtten=self.adcAtten)

        
        
    
    def ampScalePlotter(self, freq, phase, scaleRange=np.arange(0.5,1.5,0.02)):
        '''
        Plot sideband suprression as a function of ADC amplitude scaling
        
        INPUTS:
            freq: tone frequency (Hz)
            phase: phase delay
            scaleRange: range of ADC scalings to check
        '''
        self.loadLUT(np.asarray([freq]), phase)
        snapDict = self.takeAdcSnap()
        sbSuppressions = np.zeros(len(scaleRange))
        for i,scale in enumerate(scaleRange):
            iVals = scale*snapDict['iVals']
            qVals = snapDict['qVals']
            specDict = adcSnap.streamSpectrum(iVals, qVals)
            sbSuppressions[i] = specDict['peakFreqPower'] - specDict['sidebandFreqPower']

        plt.plot(scaleRange, sbSuppressions)
        plt.show()
        return sbSuppressions

    def makeGridPlot(self, freqs, phases=np.arange(-15,15), iqRatios=np.arange(0.5,1.5,0.02), saveData=True):
        '''
        Plots sideband suppression as a function of tone phase offset and I/Q. Takes forever...
        
        INPUTS:
            freqs: list of tone frequencies
            phases: list of phase values to check.
            iqRatios: list of IAmp/QAmp values to check
            saveData: if True, save all collected data
        '''
        sbSuppressions = np.zeros((len(freqs), len(phases), len(iqRatios)))
        
        nSamples = 4096.
        sampleRate = 2000. #MHz
        quantFreqsMHz = np.array(freqs/1.e6-self.loFreq/1.e6)
        quantFreqsMHz = np.round(quantFreqsMHz*nSamples/sampleRate)*sampleRate/nSamples
        snapDict = self.takeAdcSnap()
        specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])        
        findFreq = lambda freq: np.where(specDict['freqsMHz']==freq)[0][0]
        print 'quantFreqsMHz', quantFreqsMHz
        print 'spectDictFreqs', specDict['freqsMHz']
        print 'nSamples', specDict['nSamples']
        freqLocs = np.asarray(map(findFreq, quantFreqsMHz))
        sbLocs = -1*freqLocs + len(specDict['freqsMHz'])
        
        for i,phase in enumerate(phases):
            for j,iqRatio in enumerate(iqRatios):
                phaseList = phase*np.ones(len(freqs))
                iqRatioList = iqRatio*np.ones(len(freqs))
                self.loadLUT(freqs, phaseList, iqRatioList)
                snapDict = self.takeAdcSnap()
                specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
                sbSuppressions[:,i,j] = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]
        
        np.savez('grid_search_data_'+str(len(freqs))+'freqs'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqs, phases=phases, iqRatios=iqRatios, sbSuppressions=sbSuppressions, 
            adcAtten=self.adcAtten, globalDacAtten=self.globalDacAtten, toneAtten=self.toneAtten)

    def setGlobalDacAtten(self, globalDacAtten):
        self.globalDacAtten=globalDacAtten 
        self.roach.changeAtten(1,np.floor(self.globalDacAtten/31.75)*31.75)
        self.roach.changeAtten(2,self.globalDacAtten%31.75)

    def checkLinearity(self, freqList): 
        iValList = np.zeros((len(freqList), 4096))
        qValList = np.zeros((len(freqList), 4096))
        for i,freq in enumerate(freqList):
            self.loadLUT(np.asarray([freq]), np.asarray([0]), np.asarray([1]))
            snapDict = self.takeAdcSnap()
            iValList[i,:] = snapDict['iVals']
            qValList[i,:] = snapDict['qVals']

        np.savez('linearity_data_'+str(len(freqList))+'freqs'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqList, iValList=iValList, qValList=qValList, toneAtten=self.toneAtten,
            globalDacAtten=self.globalDacAtten, adcAtten=self.adcAtten)
        
        self.loadLUT(freqList, np.zeros(len(freqList)), np.ones(len(freqList)))
        snapDict = self.takeAdcSnap()
        totIVals = np.sum(iValList, axis=0)
        totQVals = np.sum(qValList, axis=0)
        residIVals = snapDict['iVals']-totIVals
        residQVals = snapDict['qVals']-totQVals
        residSpecDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])
        adcSnap.plotSpec(residSpecDict, 'Residual IQ Spectrum')
                

def makePhaseDelLUT(freqs, loFreq=5.e9):
    optPhaseDelay = np.zeros(len(freqs))
    maxSBSuppression = np.zeros(len(freqs))
    sbo = SBOptimizer(loFreq=loFreq)
    sbo.initRoach()
    for i,freq in enumerate(freqs):
        optPhaseDelay[i], maxSBSuppression[i] = sbo.phaseDelOptimizer(frequency = freq)

    np.savez('opt_phase_delays_'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqs, optPhaseDelay=optPhaseDelay, maxSBSuppression=maxSBSuppression)
    plt.plot(freqs, optPhaseDelay)     
    plt.show()

def plotOffsVSDacAtten(freq, loFreq=5.e9, globalDacAttens=np.arange(20,30), saveData=True):
    sbo = SBOptimizer(loFreq=5.e9)
    sbo.initRoach()
    optIQRatios = np.zeros(len(globalDacAttens))
    optPhaseDelays = np.zeros(len(globalDacAttens))
    maxSBSuppressions = np.zeros(len(globalDacAttens))
    for i, atten in enumerate(globalDacAttens):
        sbo.setGlobalDacAtten(atten)
        optPhase, optIQRatio, maxSBSuppression = sbo.gridSearchOptimizer(np.asarray([freq]), -30, 30, 0.5, 2.0, saveData=False)
        #print 'optPhaseShape', np.shape(optPhase)
        #print 'optIQRatioShape', np.shape(optIQRatio)
        optPhaseDelays[i] = optPhase[0]
        optIQRatios[i] = optIQRatio[0]
        maxSBSuppressions[i] = maxSBSuppression[0]

    if saveData:
        np.savez('opt_vals_vs_dac_att_'+str(freq/1.e9)+'_GHz_'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), globalDacAttens=globalDacAttens, 
            optPhaseDelays=optPhaseDelays, optIQRatios=optIQRatios, maxSBSuppressions=maxSBSuppressions)

    plt.plot(globalDacAttens, optPhaseDelays)
    plt.plot(globalDacAttens, optIQRatios)
    plt.show()

def loadGridTable(fileName):
    '''
    Loads exhaustive grid search data (made by makeGridPlot), finds optimal phase/iq ratio locations and loads
    them into DAC LUT. Then takes adcSnap and finds SB suppression at each frequency
    '''
    data = np.load(fileName)
    sbSupFlat = np.reshape(data['sbSuppressions'],(np.shape(data['sbSuppressions'])[0],-1))
    sbMaxInds = np.argmax(sbSupFlat, axis=1)
    sbMaxLocs = np.asarray([np.unravel_index(index, (len(data['phases']), len(data['iqRatios']))) for index in sbMaxInds])
    phaseList = data['phases'][sbMaxLocs[:,0]]
    iqRatioList = data['iqRatios'][sbMaxLocs[:,1]]

    # plt.plot(data['freqs'], phaseList)
    # plt.show()
    # plt.plot(data['freqs'], iqRatioList)
    # plt.show()
     
    sbo = SBOptimizer(globalDacAtten=11, toneAtten=45, adcAtten=31.75)
    sbo.initRoach()
    # phaseList = np.zeros(len(data['freqs'])) # uncomment these lines if you don't want to load in optimal phases, just frequencies
    # iqRatioList = np.ones(len(data['freqs']))
    sbo.loadLUT(freqList=data['freqs'], phaseList=phaseList, iqRatioList=iqRatioList)
    
    print 'phases', phaseList
    print 'iqRatios', iqRatioList

    nSamples = 4096.
    sampleRate = 2000. #MHz
    freqs = data['freqs']
    quantFreqsMHz = np.array(freqs/1.e6-sbo.loFreq/1.e6)
    quantFreqsMHz = np.round(quantFreqsMHz*nSamples/sampleRate)*sampleRate/nSamples
    snapDict = sbo.takeAdcSnap()
    specDict = adcSnap.streamSpectrum(snapDict['iVals'], snapDict['qVals'])        
    findFreq = lambda freq: np.where(specDict['freqsMHz']==freq)[0][0]
    print 'quantFreqsMHz', quantFreqsMHz
    print 'spectDictFreqs', specDict['freqsMHz']
    print 'nSamples', specDict['nSamples']
    freqLocs = np.asarray(map(findFreq, quantFreqsMHz))
    sbLocs = -1*freqLocs + len(specDict['freqsMHz'])
    sbSuppressions = specDict['spectrumDb'][freqLocs]-specDict['spectrumDb'][sbLocs]
    print sbSuppressions

def optRawGridData(filename, freqInd=10, corrLen=20, threshold=40, sbSupScale=5, sbSupIncThresh=20):
    data = np.load(filename)
    sbSups = data['sbSuppressions'][freqInd]
    sampledSBSups = np.zeros(np.shape(sbSups))

    weights = np.ones(np.shape(sbSups))
    print 'weightShape', np.shape(weights)
    normWeights = weights/np.sum(weights)
    flatInds = np.arange(len(weights.flatten()))
    curSup = 0
    counter = 0

    baseRowCoords = np.tile(np.arange(np.shape(sbSups)[0]),(np.shape(sbSups)[1],1))
    baseRowCoords = np.transpose(baseRowCoords)
    baseColCoords = np.tile(np.arange(np.shape(sbSups)[1]),(np.shape(sbSups)[0],1))
    while curSup<threshold:
        print np.shape(flatInds)
        print np.shape(normWeights.flatten())
        print np.sum(normWeights.flatten())
        flatInd = np.random.choice(flatInds, p=normWeights.flatten())
        sbSupInd = np.unravel_index(flatInd, np.shape(sbSups))
        sampledSBSups[sbSupInd] = sbSups[sbSupInd]
        curSup = sbSups[sbSupInd]
        weights[sbSupInd] = 0

        #calculate addition to weights
        if(curSup > sbSupIncThresh):
            rowCoords = baseRowCoords - sbSupInd[0]
            colCoords = baseColCoords - sbSupInd[1]
            distMatrix = np.sqrt(rowCoords**2+colCoords**2) #compute the distance from each point to current point
            weightAdditions = (curSup-sbSupIncThresh)/sbSupScale*np.exp(-distMatrix**2/corrLen**2)
            weights *= weightAdditions
            normWeights = weights/np.sum(weights)

        counter += 1

        print counter, 'iterations'
        print 'sampledSBSups'
        print 'curSup', curSup
        print 'position', sbSupInd
        #plt.imshow(normWeights)
        #plt.colorbar()
        #plt.show()
    
    plt.imshow(normWeights)
    plt.colorbar()
    plt.show()

    plt.imshow(sampledSBSups)
    plt.colorbar()
    plt.show()
      
def optRawGridDataGrad(filename, freqInd=10, threshold=40, gradScale=5):
    data = np.load(filename)
    sbSups = data['sbSuppressions'][freqInd] #exhaustive grid search array of SB suppressions
    sampledSBSups = np.zeros(np.shape(sbSups))
    sampledSBSups[:] = np.nan

    weights = np.ones(np.shape(sbSups))
    print 'weightShape', np.shape(weights)
    normWeights = weights/np.sum(weights)
    flatInds = np.arange(len(weights.flatten()))
    curSup = 0
    counter = 0

    #sample initial points
    for i in range(4):
        flatInd = np.random.choice(flatInds, p=normWeights.flatten())
        sbSupInd = np.unravel_index(flatInd, np.shape(sbSups))
        sampledSBSups[sbSupInd] = sbSups[sbSupInd]
        curSup = sbSups[sbSupInd]
        weights[sbSupInd] = 0
        normWeights = weights/np.sum(weights)

    while curSup<threshold:
        flatInd = np.random.choice(flatInds, p=normWeights.flatten())
        sbSupInd = np.unravel_index(flatInd, np.shape(sbSups))
        sampledSBSups[sbSupInd] = sbSups[sbSupInd]
        curSup = sbSups[sbSupInd]
        weights[sbSupInd] = 0

        #calculate addition to weights

        validSBLocs = np.where(np.isnan(sampledSBSups)==0)
        rowVals = np.nanmean(sampledSBSups, axis=1)
        colVals = np.nanmean(sampledSBSups, axis=0)

        validRowLocs = np.where(np.isnan(rowVals)==0)[0]
        validColLocs = np.where(np.isnan(colVals)==0)[0]
        rowVals = rowVals[validRowLocs]
        colVals = colVals[validColLocs]
        
        rowGrads = np.divide(np.diff(rowVals), np.diff(validRowLocs))
        colGrads = np.divide(np.diff(colVals), np.diff(validColLocs))
        validRowGradLocs = validRowLocs[:-1]
        validColGradLocs = validColLocs[:-1]

        for r in range(np.shape(weights)[0]):
            for c in range(np.shape(weights)[1]):
                if weights[r,c] != 0:
                    posRowGradInds = np.where(validRowGradLocs<r)[0]
                    posColGradInds = np.where(validColGradLocs<c)[0]
                    negRowGradInds = np.where(validRowGradLocs>=r)[0]
                    negColGradInds = np.where(validColGradLocs>=c)[0]
                    #print 'posRowGrads', posRowGradInds
                    #print 'negRowGrads', negRowGradInds
                    #print 'rowGrads', rowGrads

                    rowGradSum = (np.sum(rowGrads[posRowGradInds])-np.sum(rowGrads[negRowGradInds]))/len(rowGrads)
                    colGradSum = (np.sum(colGrads[posColGradInds])-np.sum(colGrads[negColGradInds]))/len(colGrads)
                    weights[r,c] = np.exp(gradScale*(rowGradSum+colGradSum))

        normWeights = weights/np.sum(weights)
        
        counter += 1

        print counter, 'iterations'
        print 'sampledSBSups'
        print 'curSup', curSup
        print 'position', sbSupInd
        #plt.imshow(normWeights)
        #plt.colorbar()
        #plt.show()
    
    plt.imshow(normWeights)
    plt.colorbar()
    plt.show()

    plt.imshow(sampledSBSups)
    plt.colorbar()
    plt.show()

def loadOptimizedLUT(filename):
    data = np.load(filename)
    sbo = SBOptimizer(ip='10.0.0.112', toneAtten=data['toneAtten'], globalDacAtten=data['globalDacAtten'], adcAtten=data['adcAtten'])
    sbo.initRoach()
    sbo.loadLUT(data['freqs'], phaseList=data['optPhases'], iqRatioList=data['optIQRatios'])
        
        
def optRawGridDataFit(filename, freqInd=40, threshold=32, weightDecayDist=1):
    data = np.load(filename)
    sbSups = data['sbSuppressions'][freqInd] #exhaustive grid search array of SB suppressions
    sampledSBSups = np.zeros(np.shape(sbSups))
    sampledSBSups[:] = np.nan

    weights = np.ones(np.shape(sbSups))
    print 'weightShape', np.shape(weights)
    normWeights = weights/np.sum(weights)
    flatInds = np.arange(len(weights.flatten()))
    curSup = 0
    counter = 0

    def gaussian(x, x0r, x0c, scale, width):
        return scale*np.exp(-((x[0]-x0r)**2+(x[1]-x0c)**2)/width**2)

    def expDecay(x, x0r, x0c, scale, width):
        return scale*np.exp(-np.sqrt((x[0]-x0r)**2+(x[1]-x0c)**2)/width)

    #sample initial points
    for i in range(5):
        flatInd = np.random.choice(flatInds, p=normWeights.flatten())
        sbSupInd = np.unravel_index(flatInd, np.shape(sbSups))
        sampledSBSups[sbSupInd] = sbSups[sbSupInd]
        curSup = sbSups[sbSupInd]
        weights[sbSupInd] = 0
        normWeights = weights/np.sum(weights)

    fitParams = [10, 10, 40, 15]
    rowCoords = np.tile(np.arange(np.shape(sbSups)[0]),(np.shape(sbSups)[1],1))
    rowCoords = np.transpose(rowCoords)
    colCoords = np.tile(np.arange(np.shape(sbSups)[1]),(np.shape(sbSups)[0],1))

    while curSup<threshold:
        flatInd = np.random.choice(flatInds, p=normWeights.flatten())
        sbSupInd = np.unravel_index(flatInd, np.shape(sbSups))
        sampledSBSups[sbSupInd] = sbSups[sbSupInd]
        curSup = sbSups[sbSupInd]
        weights[sbSupInd] = 0

        #calculate new weights

        validSBLocs = np.where(np.isnan(sampledSBSups)==0)
        xdata = np.array([validSBLocs[0],validSBLocs[1]])
        ydata = np.array(sampledSBSups[validSBLocs])
        #print 'xdata', xdata
        #print 'ydata', ydata

        fitParams, pcov = spo.curve_fit(expDecay, xdata, ydata, fitParams, 
            bounds=([0, 0, 30, 2], [np.shape(sampledSBSups)[0], np.shape(sampledSBSups)[1], 50, 20]), method='trf')
        
        print 'fitParams', fitParams

        rowDist = rowCoords - fitParams[0]
        colDist = colCoords - fitParams[1]
        weights = np.exp(-(rowDist**2+colDist**2)/weightDecayDist**2)
        
        weights[validSBLocs]=0

        normWeights = weights/np.sum(weights)
        
        counter += 1

        print counter, 'iterations'
        print 'sampledSBSups'
        print 'curSup', curSup
        print 'position', sbSupInd
        #plt.imshow(normWeights)
        #plt.colorbar()
        #plt.show()
    
    plt.imshow(normWeights)
    plt.colorbar()
    plt.show()

    plt.imshow(sampledSBSups)
    plt.colorbar()
    plt.show()


if __name__=='__main__':
    sbo = SBOptimizer(ip='10.0.0.112', globalDacAtten=0, toneAtten=45, adcAtten=31.75)
    sbo.initRoach()
    # sbo.checkLinearity(np.arange(5.05e9,6.e9,1.e7)+5.e6*np.random.rand(95))
    # sbo.loadLUT(np.asarray([5.55e9]), phaseList=np.asarray([0]), iqRatioList=np.asarray([1]))
    # sbo.loadLUT(np.arange(5.05e9,6.e9,1.e7)+5.e6*np.random.rand(95), phaseList=np.zeros(95), iqRatioList=np.ones(95))
    # sbo.loadLUT(freqList=np.arange(5.05e9, 5.5e9, 1.e7)+1.e7*np.random.rand(45)-5.e6, phaseList=np.zeros(45), iqRatioList=np.ones(45))
    # sbo.loadLUT(freqList=np.asarray([5.264e9]), phaseList=np.asarray([0]), iqRatioList=np.asarray([1]))
    # optPhase = sbo.phaseDelOptimizer(frequency=5.2638e9)
    # makePhaseDelLUT(np.arange(5.05e9, 6.e9, 5.e7))
    # sbo.ampScalePlotter(5.65e9, 5, np.arange(1,2.5,0.02))
    # print 'optPhase', optPhase
    # sbo.makeGridPlot(np.arange(5.05e9,5.5e9,1.e7), phases=np.arange(-15,5), iqRatios=np.arange(1.0,1.5,0.02))
    # sbo.gridSearchOptimizer(np.asarray([5.5e9]), -30, 30, 0.5, 2.0)
    # sbo.makeGridPlot(np.arange(5.05e9, 5.5e9, 1.e7)+1.e7*np.random.rand(45)-5.e6, phases=np.arange(-15,5), iqRatios=np.arange(0.85,1.25,0.02))
    # plotOffsVSDacAtten(5.2638e9)
    # loadGridTable('grid_search_data_45freqs20170213-163003.npz')
    # optRawGridDataFit('grid_search_data_45freqs20170213-163003.npz')
    # sbo.gridSearchOptimizerFit(np.arange(5.05e9, 6.e9, 1.e7)+1.e7*np.random.rand(95)-5.e6)
    # sbo.gridSearchOptimizerFit(np.asarray([5.55e9]))
    loadOptimizedLUT('grid_search_opt_vals_95_freqs_20170222-124402.npz')

        


            
