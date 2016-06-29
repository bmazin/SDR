"""
File:      qdrSnapCheck.py
Author:    Matt Strader
Date:      Apr 21, 2016
Firmware:  a2g_snp_2016_Apr_20_1828.fpg

This script tests the adcdac_2g yellow blocks for the fnal 2GHz adc/dac baord.  The outputs of the adc block are written to qdr in a block that operates like a snap block.
"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import sys

def snapZdok(fpga):
    snapshotNames = fpga.snapshots.names()

    fpga.write_int('trig',0)#initialize trigger
    for name in snapshotNames:
        fpga.snapshots[name].arm(man_valid=False,man_trig=False)

    time.sleep(.1)
    fpga.write_int('trig',1)#trigger snapshots
    time.sleep(.1) #wait for other trigger conditions to be met, and fill buffers
    fpga.write_int('trig',0)#release trigger

    adcData0 = fpga.snapshots['snp0_ss'].read(timeout=5,arm=False)['data']
    adcData1 = fpga.snapshots['snp1_ss'].read(timeout=5,arm=False)['data']
    adcData2 = fpga.snapshots['snp2_ss'].read(timeout=5,arm=False)['data']
    adcData3 = fpga.snapshots['snp3_ss'].read(timeout=5,arm=False)['data']
    bus0 = np.array([adcData0['data_i0'],adcData0['data_i1'],adcData1['data_i2'],adcData1['data_i3']]).flatten('F')
    bus1 = np.array([adcData2['data_i4'],adcData2['data_i5'],adcData3['data_i6'],adcData3['data_i7']]).flatten('F')
    bus2 = np.array([adcData0['data_q0'],adcData0['data_q1'],adcData1['data_q2'],adcData1['data_q3']]).flatten('F')
    bus3 = np.array([adcData2['data_q4'],adcData2['data_q5'],adcData3['data_q6'],adcData3['data_q7']]).flatten('F')
    return {'bus0':bus0,'bus1':bus1,'bus2':bus2,'bus3':bus3,'adcData0':adcData0,'adcData1':adcData1,'adcData2':adcData2,'adcData3':adcData3}

def checkCurrentGlitches(fpga,xarr,nBits=12,bPlot=False,bSigned=True,bStopIfNoMatch=True):
    startIndex = 0
    foundGoodStart = False
    maxRampVal = 2**(nBits)
    if bSigned:
        verticalOffset = 2**(nBits-1)
    else:
        verticalOffset = 0

    deriv = np.diff(xarr)
    while not foundGoodStart:
        #assuming a ramp that increases by one each clock cycle
        startRelVal = 0
        stepSize = 1
        try:
            initialVal = xarr[startIndex]+verticalOffset #We'll subtract off the offset again soon
        except IndexError:
            print 'couldn\'t find a good start to match ramp!'
            if bStopIfNoMatch:
                x = np.arange(len(xarr))
                fig,(ax,ax2) = plt.subplots(2,1)
                ax.step(x,xarr)
                ax.step(x,rampModel)
                ax2.step(x,xarr-rampModel)
                plt.show()
                exit(1)
            else:
                startIndex = 0
                initialVal = xarr[startIndex]+verticalOffset #We'll subtract off the offset again soon
                foundGoodStart = True
        rampModel = initialVal-startIndex+np.arange(0,len(xarr),stepSize)
        rampModel = np.array(rampModel,dtype=np.int) % maxRampVal
        rampModel -= verticalOffset


        if np.median(rampModel - xarr) != 0:
            startIndex += 1
#            print 'started on a glitch, continuing'
            continue
        else:
            foundGoodStart = True

    #mark bits that don't match between the model and snapshot, these are the glitches
    individualGlitchBitPatterns = np.bitwise_xor(rampModel,xarr) 
    #we want to know what bits ever fail with this delay setting
    failPattern = np.bitwise_or.reduce(individualGlitchBitPatterns)
    failPatternStr = np.binary_repr(failPattern,width=nBits)

    if bPlot:
        print 'startIndex',startIndex,failPatternStr
        x = np.arange(len(xarr))
        fig,(ax,ax2) = plt.subplots(2,1)
        ax.step(x,xarr)
        ax.step(x,rampModel)
        ax.set_title(failPatternStr)
        ax2.step(x,xarr-rampModel)
        plt.show()

    return {'failPattern':failPattern,'failPatternStr':failPatternStr,'rampModel':rampModel,'xarr':xarr}


def loadDelayCal(fpga,delayLut):
    nLoadDlyRegBits = 6
    notLoadVal = int('1'*nLoadDlyRegBits,2) #when load_dly is this val, no bit delays are loaded
    fpga.write_int('load_dly',notLoadVal)
    for iRow,(bit,delay) in enumerate(delayLut):
        fpga.write_int('dly_val',delay)
        fpga.write_int('load_dly',bit)
        time.sleep(.01)
        fpga.write_int('load_dly',notLoadVal)
        

def findCalPattern(fpga,nBits=12,busName='bus2',bPlot=False,nSnaps=1):
    loadAllBitsCmd = 2**(nBits+1)-1 #all bits are 1

    failPatterns = []
    for delay in np.arange(0,32):

        #set all IODELAYs to the current delay
        fpga.write_int('dly_val',delay)
        for iBit in range(0,56):
            fpga.write_int('load_dly',iBit)
            time.sleep(.01)
        time.sleep(.1)

        #take a few snapshots of the ramp signal with this delay
        #and take note of which bits show glitches
        snapFailPatterns = []
        for iSnap in xrange(nSnaps):
            snapDict = snapZdok(fpga)
            glitchDict = checkCurrentGlitches(fpga,snapDict[busName],nBits=nBits,bPlot=bPlot)
            failPattern = glitchDict['failPattern']
            snapFailPatterns.append(failPattern)
        failPattern = np.bitwise_or.reduce(snapFailPatterns)
        failPatternStr = np.binary_repr(failPattern,width=nBits)

        print '{0:02d}'.format(delay),':',failPatternStr
        #plt.show()
        failPatterns.append(failPattern)
    #totalFailPattern = np.bitwise_and.reduce(failPatterns)
    #print (nBits+5)*'_'
    #print 'TT',':',np.binary_repr(totalFailPattern,width=nBits)

if __name__=='__main__':
    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.111'
    print ip
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware, and calibrate qdr first!'
        exit(0)

    fpga.get_system_information()
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()

    fpga.write_int('run_adc',1)#send ready signals
    time.sleep(.1)

#    print 'bus0'
#    findCalPattern(fpga,busName='bus0')
#    print 'bus1'
#    findCalPattern(fpga,busName='bus1')
#    print 'bus2'
#    findCalPattern(fpga,busName='bus2')
#    print 'bus3'
#    findCalPattern(fpga,busName='bus3')

    delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
    delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
    delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
    delayLut3 = zip(np.arange(42,54),np.ones(12)*13)

    loadDelayCal(fpga,delayLut0)
    loadDelayCal(fpga,delayLut1)
    loadDelayCal(fpga,delayLut2)
    loadDelayCal(fpga,delayLut3)

    snapDict = snapZdok(fpga)
    print 'With best cal:'
    print 'bus0',checkCurrentGlitches(fpga,xarr=snapDict['bus0'],nBits=12)['failPatternStr']
    print 'bus1',checkCurrentGlitches(fpga,xarr=snapDict['bus1'],nBits=12)['failPatternStr']
    print 'bus2',checkCurrentGlitches(fpga,xarr=snapDict['bus2'],nBits=12)['failPatternStr']
    print 'bus3',checkCurrentGlitches(fpga,xarr=snapDict['bus3'],nBits=12)['failPatternStr']
    fig,ax = plt.subplots(1,1)
    x = np.arange(len(snapDict['bus0']))
    ax.step(x,snapDict['bus0'],color='b')
    ax.step(x,snapDict['bus1']+.1,color='g')
    ax.step(x,snapDict['bus2']+.2,color='k')
    ax.step(x,snapDict['bus3']+.3,color='r')
    plt.show()


    print 'done!'

