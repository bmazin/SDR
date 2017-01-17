import adcSnapCheck as adcSnap
from Roach2ControlsSB import Roach2Controls
import numpy as np
import time, struct, sys, os
import matplotlib.pyplot as plt
import random

class SBOptimizer:
    
    def __init__(ip='10.0.0.112', params='/mnt/data0/neelay/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param', loFreq=5.e9, 
        adcAtten=26.75, toneAtten=35, globalDacAtten=30, freq=None):
        self.roach = Roach2Controls(ip, params, True, False)
        self.loFreq = loFreq
        self.adcAtten = adcAtten
        self.toneAtten = toneAtten
        self.globalDacAtten = globalDacAtten
        self.curFreq = freq

    def initRoach(self):
        self.roach.connect()
        self.roach.setLOFreq(self.loFreq)
        self.roach.initializeV7UART(waitForV7Ready=False)
        self.roach.loadLOFreq()
        self.roach.changeAtten(1,np.floor(self.globalDacAtten/31.75)*31.75)
        self.roach.changeAtten(2,self.globalDacAtten%31.75)
        self.roach.changeAtten(3,self.adcAtten)

    def loadLUT(self, phaseDelay, freq=None):
        if freq==None:
            if self.curFreq==None:
                raise ValueError('Must specify a frequency!')
            freq = self.curFreq
        freqList = np.asarray([freq])
        attenList = np.asarray([self.toneAtten])
        self.roach.generateResonatorChannels(freqList)
        self.roach.generateFftChanSelection()
        #self.roach.generateDacComb(resAttenList=attenList,globalDacAtten=9)
        print 'Generating DDS Tones...'
        self.roach.generateDdsTones()
        self.roach.debug=False
        self.roach.generateDacComb(freqList=freqList, resAttenList=attenList, globalDacAtten=globalDacAtten, iqRatio=1, iqPhaseOffs=phaseDelay, useLUTZeros=False)
        self.roach.loadDacLUT()
        self.roach.fpga.write_int('run',1)#send ready signals
        time.sleep(1)
    
    def takeAdcSnap(self):
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

    def phaseDelOptimizer(self, phaseStart=-20, phaseStop=20, frequency=None):
        initPhases = [phaseStart, phaseStart+1, phaseStop, phaseStop+1]
        initSBSuppressions = []
        
        for phase in initPhases:
            self.loadLUT(phase, frequency)
            snapDict = self.takeAdcSnap()
            adjIVals, adjQVals = adcSnap.adjust(snapDict['iVals'], snapDict['qVals'], 0)
            specDict = adcSnap.streamSpectrum(adjIVals, adjQVals)
            initSBSuppressions.append(specDict['peakFreqPower'] - specDict['sidebandFreqPower'])
        
        initGrads = np.diff(initSBSuppressions)[0:3:2]
        if(np.sign(initGrads[0])==np.sign(initGrads[1])):
            raise ValueError('Expand search boundaries')
        
        foundMax = False
        boundGrads = initGrads
        optPhase = None
        while(!foundMax):
            phase = int((phaseStart+phaseStop)/2)
            phases = [phase, phase+1]
            sbSuppressions = []
            for phase in phases:
                self.loadLUT(phase, frequency)
                snapDict = self.takeAdcSnap()
                adjIVals, adjQVals = adcSnap.adjust(snapDict['iVals'], snapDict['qVals'], 0)
                specDict = adcSnap.streamSpectrum(adjIVals, adjQVals)
                sbSuppressions.append(specDict['peakFreqPower'] - specDict['sidebandFreqPower'])
                
            grad = np.diff(sbSuppressions)[0]
            if np.sign(grad)!=np.sign(boundGrads[0]):
                phaseStop = phase
            
            elif np.sign(grad)!=np.sign(boundGrads[1]):
                phaseStart = phase
                
            else:
                raise ValueError('...')    
            
            if phaseStop-phaseStart==1:
                optPhase = phaseStop
                foundMax = True
        
        return optPhase
        
        
if __name__=='__main__':
    sbo = sbOptimizer()
    sbo.initRoach()
    optPhase = sbo.phaseDelOptimizer(frequency=5.2638e9)
    print 'optPhase', optPhase
                
        
        

        


            
