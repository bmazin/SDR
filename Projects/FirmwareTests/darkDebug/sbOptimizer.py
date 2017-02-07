import adcSnapCheck as adcSnap
from Roach2Controls import Roach2Controls
import numpy as np
import time, struct, sys, os
import matplotlib.pyplot as plt
import random

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
        
        np.savez('grid_search_data_'+str(len(freqs))+'freqs'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqs, phases=phases, iqRatios=iqRatios, sbSuppressions=sbSuppressions)

    def setGlobalDacAtten(self, globalDacAtten):
        self.globalDacAtten=globalDacAtten 
        self.roach.changeAtten(1,np.floor(self.globalDacAtten/31.75)*31.75)
        self.roach.changeAtten(2,self.globalDacAtten%31.75)
                

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

        
        
if __name__=='__main__':
    sbo = SBOptimizer(globalDacAtten=20, toneAtten=40, adcAtten=31.75)
    sbo.initRoach()
    # optPhase = sbo.phaseDelOptimizer(frequency=5.2638e9)
    # makePhaseDelLUT(np.arange(5.05e9, 6.e9, 5.e7))
    # sbo.ampScalePlotter(5.65e9, 5, np.arange(1,2.5,0.02))
    # print 'optPhase', optPhase
    sbo.makeGridPlot(np.arange(5.05e9,5.5e9,5.e7), phases=np.arange(-15,5), iqRatios=np.arange(1.0,1.5,0.02))
    # sbo.gridSearchOptimizer(np.arange(5.05e9,5.5e9,5.e7), -30, 30, 0.5, 2.0)
    # sbo.gridSearchOptimizer(np.asarray([5.2638e9]), -30, 30, 0.5, 2.0)
    # plotOffsVSDacAtten(5.2638e9)
        

        


            
