'''
sbSuppressDebug.py
Set of routines to debug sideband suppression problems on gen2 readout
'''

import numpy as np
import adcSnapCheck as adcSnap
import sys
import os
import casperfpga
import matplotlib.pyplot as plt
import time, struct
from Roach2ControlsSB import Roach2Controls

def checkIQOffs(iVals,qVals,delays=np.arange(-8,2,1)):
    '''
    Loops through a range of delays between i and q to determine the optimal offset.
    Should load a LUT with a single frequency.

    INPUTS:
    iVals,qVals - lists of i and q values
    delays - list of delays to check

    OUTPUTS:
    iqOffset - optimal delay, in ticks
    '''
    minProd = np.abs(np.dot(iVals,qVals)/len(iVals))
    print 'minProd', minProd
    bestDelay = 0
    for delay in delays:
        qValsOffs = np.roll(qVals,delay)
        if delay>=0:
            delProd = np.abs(np.dot(iVals[delay:],qValsOffs[delay:])/len(iVals[delay:]))
        else:
            delProd = np.abs(np.dot(iVals[:delay],qValsOffs[:delay])/len(iVals[:delay]))
            
        if(delProd<minProd):
            minProd=delProd
            bestDelay = delay
            print 'delProd', delProd

    return bestDelay

def checkIQFineOffs(ip, params, phaseDelays=np.arange(-10,10,1), freq=5.2638e9, loFreq=5.e9):
    loFreq = np.asarray([loFreq])
    freqList=np.asarray([freq])
    attenList=np.asarray([35])
    globalDacAtten=30
    
    #attenList = attenList[np.where(freqList > loFreq)]
    #freqList = freqList[np.where(freqList > loFreq)]
    
    roach_0 = Roach2Controls(ip, params, True, False)
    roach_0.connect()
    roach_0.setLOFreq(loFreq)
    roach_0.generateResonatorChannels(freqList)
    roach_0.generateFftChanSelection()
    #roach_0.generateDacComb(resAttenList=attenList,globalDacAtten=9)
    print 'Generating DDS Tones...'
    roach_0.generateDdsTones()
    roach_0.debug=False
    #for i in range(10000):
        
    #    roach_0.generateDacComb(resAttenList=attenList,globalDacAtten=9)
    
    print 'Loading DDS LUT...'
    #roach_0.loadDdsLUT()
    print 'Checking DDS Shift...'
    #DdsShift = roach_0.checkDdsShift()
    #print DdsShift
    #roach_0.loadDdsShift(DdsShift)
    print 'Loading ChanSel...'
    #roach_0.loadChanSelection()
    print 'Init V7'
    roach_0.initializeV7UART(waitForV7Ready=False)
    #roach_0.initV7MB()
    roach_0.loadLOFreq()
    roach_0.changeAtten(1,np.floor(globalDacAtten/31.75)*31.75)
    roach_0.changeAtten(2,globalDacAtten%31.75)
    roach_0.changeAtten(3,26.75)
    sbSuppressions = []
    maxSBSuppression = 0
    optPhaseDelay = 0
    for delay in phaseDelays:
        print 'Generating DAC Comb...'
        roach_0.generateDacComb(freqList=freqList, resAttenList=attenList, globalDacAtten=globalDacAtten, iqRatio=1, iqPhaseOffs=delay, useLUTZeros=False)
        roach_0.loadDacLUT()
        roach_0.fpga.write_int('run',1)#send ready signals
        time.sleep(1)
        
        print 'Taking ADC snap...'
        delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
        delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
        delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
        delayLut3 = zip(np.arange(42,54),np.ones(12)*13)
        adcSnap.loadDelayCal(roach_0.fpga,delayLut0)
        adcSnap.loadDelayCal(roach_0.fpga,delayLut1)
        adcSnap.loadDelayCal(roach_0.fpga,delayLut2)
        adcSnap.loadDelayCal(roach_0.fpga,delayLut3)

        snapDict = adcSnap.snapZdok(roach_0.fpga,nRolls=0)
        adjIVals, adjQVals = adcSnap.adjust(iVals=snapDict['iVals'], qVals=snapDict['qVals'], qOffs=0, adjAmp=True)
        specDict = adcSnap.streamSpectrum(iVals=adjIVals,qVals=adjQVals)
        sbSuppression = specDict['peakFreqPower'] - specDict['sidebandFreqPower']
        sbSuppressions.append(sbSuppression)
        if sbSuppression > maxSBSuppression:
            maxSBSuppression = sbSuppression
            optPhaseDelay = delay
        
    print maxSBSuppression, 'dB of sideband suppression using', optPhaseDelay, 'degrees of phase delay'
    plt.plot(phaseDelays, sbSuppressions)
    plt.show()
    return optPhaseDelay, maxSBSuppression

def makePhaseDelLUT(ip, params, phaseDelays, freqs, loFreq=5.e9):
    optPhaseDelay = np.zeros(len(freqs))
    maxSBSuppression = np.zeros(len(freqs))
    for i,freq in enumerate(freqs):
        optPhaseDelay[i], maxSBSuppression[i] = checkIQFineOffs(ip, params, phaseDelays, freq, loFreq)

    np.savez('opt_phase_delays_'+time.strftime("%Y%m%d-%H%M%S",time.localtime()), freqs=freqs, optPhaseDelay=optPhaseDelay, maxSBSuppression=maxSBSuppression)
    plt.plot(freqs, optPhaseDelay)     
    plt.show()


if __name__=='__main__':
    if len(sys.argv) > 1:
        ip = '10.0.0.'+sys.argv[1]
    else:
        ip='10.0.0.112'
    print ip
    checkIQFineOffs(ip, '/mnt/data0/neelay/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param', np.arange(-15,5,1))

'''
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware, and calibrate qdr first!'
        exit(0)

    fpga.get_system_information()
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()

    fpga.write_int('run',1)#send ready signals
    time.sleep(1)

    delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
    delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
    delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
    delayLut3 = zip(np.arange(42,54),np.ones(12)*13)
    adcSnap.loadDelayCal(fpga,delayLut0)
    adcSnap.loadDelayCal(fpga,delayLut1)
    adcSnap.loadDelayCal(fpga,delayLut2)
    adcSnap.loadDelayCal(fpga,delayLut3)

    snapDict = adcSnap.snapZdok(fpga,nRolls=0)
    specDict = adcSnap.streamSpectrum(iVals=snapDict['iVals'],qVals=snapDict['qVals'])

    qDelay = checkIQOffs(snapDict['iVals'], snapDict['qVals'])
    print 'Q Delay', qDelay, 'ticks'

    adjIVals, adjQVals = adcSnap.adjust(snapDict['iVals'],snapDict['qVals'],qDelay,True)

    fig2,ax2 = plt.subplots(1,1)
    #times in us
    times = specDict['times']
    ax2.plot(times,adjIVals,color='b',label='I')
    ax2.plot(times,adjQVals,color='g',label='Q')
    ax2.set_xlim([0,.5])
    ax2.set_title('Adjusted IQ stream')
    ax2.set_xlabel('time (us)')
    ax2.legend()
    plt.show()
'''

