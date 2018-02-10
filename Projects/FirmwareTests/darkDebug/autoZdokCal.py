"""
Author:    Matt Strader

"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import sys
import scipy.ndimage
from Roach2Controls import Roach2Controls

def incrementMmcmPhase(fpga,stepSize=2):

    for i in xrange(stepSize):
        fpga.write_int('adc_in_inc_phs',1)
        fpga.write_int('adc_in_inc_phs',0)
    
def snapZdok(fpga,nRolls=0):
    snapshotNames = fpga.snapshots.names()

    fpga.write_int('adc_in_trig',0)#initialize trigger
    for name in snapshotNames:
        fpga.snapshots[name].arm(man_valid=False,man_trig=False)

    time.sleep(.01)
    fpga.write_int('adc_in_trig',1)#trigger snapshots
    time.sleep(.01) #wait for other trigger conditions to be met, and fill buffers
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

def checkRamp(rampVals,nBits=12,bPlot=False):
    foundGoodStart = False
    maxRampVal = 2**(nBits)
    offset = 2**(nBits-1)
    deriv = np.diff(rampVals)
    rampStep = 1
    rampModel = offset+rampVals[0]+np.arange(0,len(rampVals),rampStep)
    rampModel = (np.array(rampModel,dtype=np.int) % maxRampVal)-offset
    rampErrors = rampVals - rampModel
    errorsFound = np.any(rampErrors != 0)

    if bPlot:
        fig,(ax,ax2) = plt.subplots(2,1)
        x = np.arange(len(rampVals))
        ax.step(x,rampVals)
        ax.step(x,rampModel)
        ax2.step(x,rampVals-rampModel)
        plt.show()

    return errorsFound

def loadDelayCal(fpga,delayLut):
    nLoadDlyRegBits = 6
    notLoadVal = int('1'*nLoadDlyRegBits,2) #when load_dly is this val, no bit delays are loaded
    fpga.write_int('adc_in_load_dly',notLoadVal)
    for iRow,(bit,delay) in enumerate(delayLut):
        fpga.write_int('adc_in_dly_val',delay)
        fpga.write_int('adc_in_load_dly',bit)
        time.sleep(.01)
        fpga.write_int('adc_in_load_dly',notLoadVal)
        
def findCal(fpga,bPlot=False):
    snapDict = snapZdok(fpga)
    errorInI = checkRamp(snapDict['iVals'],bPlot=bPlot)
    errorInQ = checkRamp(snapDict['qVals'],bPlot=bPlot)
    initialError = errorInI | errorInQ
    if initialError == False:
        print 'keep initial state'
        #started at valid solution, so return index 0
        return {'solutionFound':True,'solution':0}
    else:
        nSteps = 60
        stepSize = 4
        failPattern = findCalPattern(fpga,nSteps=nSteps,stepSize=stepSize)['failPattern']
        print 'fail pat',failPattern
        passPattern = (failPattern == 0.)
        print 'pass pat',passPattern
        try:
            firstRegionSlice = scipy.ndimage.find_objects(scipy.ndimage.label(passPattern)[0])[0][0]
            print firstRegionSlice
            regionIndices = np.arange(len(passPattern))[firstRegionSlice]
            print regionIndices
            solutionIndex = regionIndices[0]+(len(regionIndices)-1)//2
            print solutionIndex
            incrementMmcmPhase(fpga,solutionIndex*stepSize)
            print 'solution found',solutionIndex*stepSize
            return {'solutionFound':True,'solution':solutionIndex*stepSize}
        except IndexError:
            return {'solutionFound':False}

def findCalPattern(fpga,bPlot=False,nSteps=60,stepSize=4):
    failPattern = np.zeros(nSteps)
    stepIndices = np.arange(0,nSteps*stepSize,stepSize)

    totalChange = 0
    for iStep in xrange(nSteps):
        incrementMmcmPhase(fpga,stepSize=stepSize)
        totalChange += stepSize

        snapDict = snapZdok(fpga)
        errorInI = checkRamp(snapDict['iVals'],bPlot=bPlot)
        errorInQ = checkRamp(snapDict['qVals'],bPlot=bPlot)
        failPattern[iStep] = errorInI | errorInQ

    fpga.write_int('adc_in_pos_phs',1)
    incrementMmcmPhase(fpga,stepSize=totalChange)
    fpga.write_int('adc_in_pos_phs',0)

    return {'failPattern':failPattern,'stepIndices':stepIndices}


if __name__=='__main__':
    if len(sys.argv) > 1:
        ip = '10.0.0.'+sys.argv[1]
    else:
        print 'Usage:',sys.argv[0],'roachNum'
    print ip

    roach = Roach2Controls(ip, '/mnt/data0/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param', True, False)
    roach.connect()
    roach.initializeV7UART()
    roach.sendUARTCommand(0x4)
    time.sleep(15)

    time.sleep(.01)
    if not roach.fpga.is_running():
        print 'Firmware is not running. Start firmware, and calibrate qdr first!'
        exit(0)
    roach.fpga.get_system_information()
    print 'Fpga Clock Rate:',roach.fpga.estimate_fpga_clock()
    roach.fpga.write_int('run',1)


    busDelays = [14,18,14,13]
    busStarts = [0,14,28,42]
    busBitLength = 12
    for iBus in xrange(len(busDelays)):
        delayLut = zip(np.arange(busStarts[iBus],busStarts[iBus]+busBitLength), 
            busDelays[iBus] * np.ones(busBitLength))
        loadDelayCal(roach.fpga,delayLut)

    calDict = findCal(roach.fpga,True)
    print calDict

    roach.sendUARTCommand(0x5)


    print 'DONE!'

