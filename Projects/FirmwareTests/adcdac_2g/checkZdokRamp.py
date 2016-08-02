"""
File:      qdrSnapCheck.py
Author:    Matt Strader
Date:      Jun 29, 2016
Firmware:  darksc2_2016_Jun_28_1925.fpg

This script tests the adcdac_2g yellow blocks for the fnal 2GHz adc/dac baord.  The outputs of the adc block are written to qdr in a block that operates like a snap block.
"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import sys

def snapZdok(fpga,nRolls=0):
    snapshotNames = fpga.snapshots.names()

    fpga.write_int('adc_in_trig',0)#initialize trigger
    for name in snapshotNames:
        fpga.snapshots[name].arm(man_valid=False,man_trig=False)

    time.sleep(.1)
    fpga.write_int('adc_in_trig',1)#trigger snapshots
    time.sleep(.1) #wait for other trigger conditions to be met, and fill buffers
    fpga.write_int('adc_in_trig',0)#release trigger

    adcData0 = fpga.snapshots['adc_in_snp_cal0_ss'].read(timeout=5,arm=False)['data']
    adcData1 = fpga.snapshots['adc_in_snp_cal1_ss'].read(timeout=5,arm=False)['data']
    adcData2 = fpga.snapshots['adc_in_snp_cal2_ss'].read(timeout=5,arm=False)['data']
    adcData3 = fpga.snapshots['adc_in_snp_cal3_ss'].read(timeout=5,arm=False)['data']
    bus0 = np.array([adcData0['data_i0'],adcData0['data_i1'],adcData1['data_i2'],adcData1['data_i3']]).flatten('F')
    bus1 = np.array([adcData2['data_i4'],adcData2['data_i5'],adcData3['data_i6'],adcData3['data_i7']]).flatten('F')
    bus2 = np.array([adcData0['data_q0'],adcData0['data_q1'],adcData1['data_q2'],adcData1['data_q3']]).flatten('F')
    bus3 = np.array([adcData2['data_q4'],adcData2['data_q5'],adcData3['data_q6'],adcData3['data_q7']]).flatten('F')

    adcData = dict()
    adcData.update(adcData0)
    adcData.update(adcData1)
    adcData.update(adcData2)
    adcData.update(adcData3)
    iDataKeys = ['data_i0','data_i1','data_i2','data_i3','data_i4','data_i5','data_i6','data_i7']
    iDataKeys = np.roll(iDataKeys,nRolls)
    #collate
    iValList = np.array([adcData[key] for key in iDataKeys])
    iVals = iValList.flatten('F')
    qDataKeys = ['data_q0','data_q1','data_q2','data_q3','data_q4','data_q5','data_q6','data_q7']
    qDataKeys = np.roll(qDataKeys,nRolls)
    #collate
    qValList = np.array([adcData[key] for key in qDataKeys])
    qVals = qValList.flatten('F')

    return {'bus0':bus0,'bus1':bus1,'bus2':bus2,'bus3':bus3,'adcData':adcData,'iVals':iVals,'qVals':qVals}

def checkCurrentGlitches(fpga,xarr,nBits=12,bPlot=False):
    startIndex = 0
    foundGoodStart = False
    maxRampVal = 2**(nBits)
    deriv = np.diff(xarr)
    while not foundGoodStart:
        #assuming a ramp that increases by one each clock cycle
        startRelVal = 0
        stepSize = 1
        rampModel = xarr[startIndex]-startIndex+np.arange(0,len(xarr),stepSize)
        rampModel = np.array(rampModel,dtype=np.int) % maxRampVal
#        print len(xarr),len(rampModel)

#        x = np.arange(len(xarr))
#        fig,(ax,ax2) = plt.subplots(2,1)
#        ax.step(x,xarr)
#        ax.step(x,rampModel)
#        ax2.step(x,xarr-rampModel)
#        plt.show()

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
    fpga.write_int('adc_in_load_dly',notLoadVal)
    for iRow,(bit,delay) in enumerate(delayLut):
        fpga.write_int('adc_in_dly_val',delay)
        fpga.write_int('adc_in_load_dly',bit)
        time.sleep(.01)
        fpga.write_int('adc_in_load_dly',notLoadVal)
        

def findCalPattern(fpga,nBits=12,busName='bus2',bPlot=False):
    loadAllBitsCmd = 2**(nBits+1)-1 #all bits are 1

    failPatterns = []
    for delay in np.arange(0,32):

        #set all IODELAYs to the current delay
        fpga.write_int('dly_val',delay)
        for iBit in range(0,56):
            fpga.write_int('adc_in_load_dly',iBit)
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
        ip = '10.0.0.'+sys.argv[1]
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

    fpga.write_int('run',1)#send ready signals
    time.sleep(1)

    delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
    delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
    delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
    delayLut3 = zip(np.arange(42,54),np.ones(12)*13)
    loadDelayCal(fpga,delayLut0)
    loadDelayCal(fpga,delayLut1)
    loadDelayCal(fpga,delayLut2)
    loadDelayCal(fpga,delayLut3)

    snapDict = snapZdok(fpga,nRolls=0)
#    fig,ax = plt.subplots(1,1)
#    x = np.arange(len(snapDict['bus0']))
#    ax.step(x,snapDict['bus0'],color='b')
#    ax.step(x,snapDict['bus1']+.1,color='g')
#    ax.step(x,snapDict['bus2']+.2,color='k')
#    ax.step(x,snapDict['bus3']+.3,color='r')
#    ax.set_title('buses')
#    fig,ax = plt.subplots(1,1)
#    x = np.arange(len(snapDict['adcData']['data_i0']))
#    ax.step(x,snapDict['adcData']['data_i0'],label='0')
#    ax.step(x,snapDict['adcData']['data_i1'],label='1')
#    ax.step(x,snapDict['adcData']['data_i2'],label='2')
#    ax.step(x,snapDict['adcData']['data_i3'],label='3')
#    ax.step(x,snapDict['adcData']['data_i4'],label='4')
#    ax.step(x,snapDict['adcData']['data_i5'],label='5')
#    ax.step(x,snapDict['adcData']['data_i6'],label='6')
#    ax.step(x,snapDict['adcData']['data_i7'],label='7',color='gray')
#    ax.set_title('I individuals')
#    ax.legend(loc='best')
#    fig,ax = plt.subplots(1,1)
#    x = np.arange(len(snapDict['adcData']['data_q0']))
#    ax.step(x,snapDict['adcData']['data_q0'],label='0')
#    ax.step(x,snapDict['adcData']['data_q1'],label='1')
#    ax.step(x,snapDict['adcData']['data_q2'],label='2')
#    ax.step(x,snapDict['adcData']['data_q3'],label='3')
#    ax.step(x,snapDict['adcData']['data_q4'],label='4')
#    ax.step(x,snapDict['adcData']['data_q5'],label='5')
#    ax.step(x,snapDict['adcData']['data_q6'],label='6')
#    ax.step(x,snapDict['adcData']['data_q7'],label='7',color='gray')
#    ax.set_title('Q individuals')
#    ax.legend(loc='best')
    fig,ax = plt.subplots(1,1)
    x = np.arange(len(snapDict['iVals']))
    ax.step(x,snapDict['iVals'],label='I')
    ax.step(x,snapDict['qVals'],label='Q')
    ax.legend(loc='best')
    ax.set_title('IQ')
    np.savez('adcData',**snapDict)
    plt.show()


    print 'done!'

