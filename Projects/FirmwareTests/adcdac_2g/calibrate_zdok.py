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
    return {'bus0':bus0,'bus1':bus1,'bus2':bus2,'bus3':bus3}

def checkCurrentGlitches(fpga,xarr,nBits=12,bPlot=False):
    startIndex = 0
    foundGoodStart = False
    maxRampVal = 2**(nBits)
    deriv = np.diff(xarr)
    while not foundGoodStart:
        if ((deriv[startIndex] == 1) and (startIndex % 2 == 0)) or ((deriv[startIndex] == 0) and (startIndex % 2 == 1)):
            startRelVal = 0.5
        elif ((deriv[startIndex] == 0) and (startIndex % 2 == 0)) or ((deriv[startIndex] == 1) and (startIndex % 2 == 1)):
            startRelVal = 0.
        else:
            startIndex += 1
            continue
        stepSize = 0.5
        rampModel = xarr[startIndex]-np.ceil(startIndex/2.)+np.floor(np.arange(startRelVal,len(xarr)/2.+startRelVal,stepSize))
        rampModel = np.array(rampModel,dtype=np.int) % maxRampVal

        x = np.arange(len(xarr))
        fig,(ax,ax2) = plt.subplots(2,1)
        ax.step(x,xarr)
        ax.step(x,rampModel)
        ax2.step(x,xarr-rampModel)
        plt.show()

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
        

def findCalPattern(fpga,nBits=12,busName='bus2',bPlot=False):
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
        nSnaps = 2
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

    print 'bus0'
    findCalPattern(fpga,busName='bus0')
    print 'bus1'
    findCalPattern(fpga,busName='bus1')
    print 'bus2'
    findCalPattern(fpga,busName='bus2')
    print 'bus3'
    findCalPattern(fpga,busName='bus3')

    delayLut = np.array([[0,10],[1,9],[2,7],[3,5],[4,9],[5,6],[6,4],[7,8],[8,14],[9,14],[10,10],[11,13],
                          [14,22],[15,22],[16,20],[17,21],[18,21],[19,21],[20,21],[21,21],[22,23],[23,24],[24,23],[25,23],
                          [28,18],[29,15],[30,14],[31,14],[32,9],[33,22],[34,15],[35,26],[36,22],[37,10],[38,19],[39,19],
                          [42,17],[43,17],[44,17],[45,19],[46,17],[47,17],[48,15],[49,17],[50,17],[51,18],[52,18],[53,18]])
    loadDelayCal(fpga,delayLut)
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

