"""
File: loadWaveLut.py
Date: Nov 24, 2015
Author: Matt Strader

Provides functions to load the DDS and DAC luts in the DARKNESS test firmware
e.g. ddc0_2015_Nov_21_1801.fpg
"""
import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr
import logging
from myQdr import Qdr as myQdr
import types
import sys
from Utils import bin
import functools

def loadQdrInFirmware(fpga,loadChoice=0,blockPrefix='dac_lut_',nQdrRows=2**20):
    """load the qdr with values within the fpga

    INPUTS:
    loadChoice: can be 
     0 for loading all zeros
     1 for loading all ones
     2 for loading all twos
     3 for loading a sequence that matches the row number
     4 to set 32 bits to 1
     5 to load 36 bits to 1
     6 to set every other bit in 32 bits to 1, starting with a 1
     7 to set every other bit in 36 bits to 1,
    blockPrefix: the name of the block in firmware that contains the qdr and control registers
     followd by an '_'
    nQdrRows: the number of rows to use in the qdr (up to 2**20)
    """

    fpga.write_int(blockPrefix+'n_qdr_rows',nQdrRows)
    fpga.write_int(blockPrefix+'test_load_qdr',0)
    fpga.write_int(blockPrefix+'load_data_choice',loadChoice) #2, for all twos
    time.sleep(.2)
    fpga.write_int(blockPrefix+'test_load_qdr',1)
    time.sleep(2)
    fpga.write_int(blockPrefix+'test_load_qdr',0)
    time.sleep(1)

def readMemory(roach,memName,nSamples,nBytesPerSample=4,bQdrFlip=False):
    """read a byte string from a bram or qdr, and parse it into an array"""
    if nBytesPerSample == 4:
        formatChar = 'L'
    elif nBytesPerSample == 8:
        formatChar = 'Q'
    else:
        raise TypeError('nBytesPerSample must be 4 or 8')

    memStr = roach.read(memName,nSamples*nBytesPerSample)
    memValues = np.array(list(struct.unpack('>{}{}'.format(nSamples,formatChar),memStr)),dtype=np.uint64)
    if bQdrFlip:
        memValues = np.right_shift(memValues,32)+np.left_shift(np.bitwise_and(memValues, int('1'*32,2)),32)
        #Unfortunately, with the current qdr calibration, the addresses in katcp and firmware are shifted (rolled) relative to each other
        #so to compensate we roll the values to write here
        #this will work if you are reading the same length vector that you wrote (and rolled) in katcp
        memValues = np.roll(memValues,1)
    return list(memValues)

def writeBram(fpga,memName,valuesToWrite,start=0,nRows=2**10,nBytesPerSample=8):
    """format values and write them to bram"""
    if nBytesPerSample == 4:
        formatChar = 'L'
        memValues = np.array(valuesToWrite,dtype=np.uint32) #cast signed values
    elif nBytesPerSample == 8:
        formatChar = 'Q'
        memValues = np.array(valuesToWrite,dtype=np.uint64) #cast signed values
    else:
        raise TypeError('nBytesPerSample must be 4 or 8')

    nValues = len(valuesToWrite)
    toWriteStr = struct.pack('>{}{}'.format(nValues,formatChar),*memValues)
    fpga.blindwrite(memName,toWriteStr,start)

def writeQdr(fpga,memName,valuesToWrite,start=0,bQdrFlip=True,nQdrRows=2**20):
    """format and write 64 bit values to qdr"""
    nBytesPerSample = 8
    formatChar = 'Q'
    memValues = np.array(valuesToWrite,dtype=np.uint64) #cast signed values
    nValues = len(valuesToWrite)
    if bQdrFlip: #For some reason, on Roach2 with the current qdr calibration, the 64 bit word seen in firmware
        #has the first and second 32 bit chunks swapped compared to the 64 bit word sent by katcp, so to accomadate
        #we swap those chunks here, so they will be in the right order in firmware
        mask32 = int('1'*32,2)
        memValues = (memValues >> 32)+((memValues & mask32) << 32)
        #Unfortunately, with the current qdr calibration, the addresses in katcp and firmware are shifted (rolled) relative to each other
        #so to compensate we roll the values to write here
        memValues = np.roll(memValues,-1)
    toWriteStr = struct.pack('>{}{}'.format(nValues,formatChar),*memValues)
    fpga.blindwrite(memName,toWriteStr,start)

def generateComb(freqs,nSamples=2**23,amplitudes=None,phases=None,sampleRate=2e9,nBitsPerSampleComponent=12,dynamicRange=1.):
    toneDict = generateTones(freqs=freqs,nSamples=nSamples,amplitudes=amplitudes,phases=phases,sampleRate=sampleRate,nBitsPerSampleComponent=nBitsPerSampleComponent,dynamicRange=dynamicRange)
    """Compose a signal of many complex frequencies added together"""
    iValList = toneDict['I']
    qValList = toneDict['Q']

    iValues = np.sum(iValList,axis=0)
    qValues = np.sum(qValList,axis=0)

    maxValue = int(np.round(dynamicRange*2**(nBitsPerSampleComponent - 1)-1)) #1 bit for sign
    highestVal = np.max((np.abs(iValues).max(),np.abs(qValues).max()))

    iValues = np.array(np.round(maxValue / highestVal * iValues),dtype=np.int)
    qValues = np.array(np.round(maxValue / highestVal * qValues),dtype=np.int)
    return {'I':iValues,'Q':qValues,'quantizedFreqs':toneDict['quantizedFreqs']}
    
def generateInterleavedTones(freqs,nSamples=8192,amplitudes=None,phases=None,sampleRate=2e6,nBitsPerSampleComponent=16,dynamicRange=1.,nSamplesPerCycle=2):
    """generate tones of given frequencies and interleave them to be suitable for a DDS LUT"""
    nFreqs = len(freqs)
    toneDict = generateTones(freqs=freqs,nSamples=nSamples,amplitudes=amplitudes,phases=phases,sampleRate=sampleRate,nBitsPerSampleComponent=nBitsPerSampleComponent,dynamicRange=dynamicRange)
    #each row is a different frequency
    iValList = np.array(toneDict['I'])
    qValList = np.array(toneDict['Q'])

    maxValue = int(np.round(dynamicRange*2**(nBitsPerSampleComponent - 1)-1)) #1 bit for sign

    iValList = np.array(np.round(maxValue * iValList),dtype=np.int)
    qValList = np.array(np.round(maxValue * qValList),dtype=np.int)

    #interleave the values such that we have two samples from freq 0 (row 0), two samples from freq 1, ...
    iValList = np.reshape(iValList,(nFreqs,-1,nSamplesPerCycle))
    qValList = np.reshape(qValList,(nFreqs,-1,nSamplesPerCycle))
    iValList = np.swapaxes(iValList,0,1)
    qValList = np.swapaxes(qValList,0,1)
    iValues = iValList.flatten('C')
    qValues = qValList.flatten('C')


    return {'I':iValues,'Q':qValues,'quantizedFreqs':toneDict['quantizedFreqs']}

    
def generateTones(freqs,nSamples=2**23,amplitudes=None,phases=None,sampleRate=2e9,nBitsPerSampleComponent=12,dynamicRange=1.):
    """create a list of sinusoidal signals for a given list of frequencies"""
    freqs = np.array(freqs)
    nFreqs = len(freqs)

    freqResolution = 1.*sampleRate / nSamples

    #make a list of frequencies that we can generate with our limited frequency resolution that are closest
    # to the requested frequencies
    quantFreqs = freqResolution * np.round(freqs/freqResolution)


    if phases is None:
        phases = np.random.uniform(0,2.*np.pi,nFreqs)

    #print 'freq',freqs[0],quantFreqs[0],sampleRate
    dt = 1. / sampleRate
    t = dt*np.arange(nSamples)
    iValList = []
    qValList = []
    for iFreq,freq in enumerate(quantFreqs):
        phi = 2.*np.pi*freq*t
        iValues = np.cos(phi+phases[iFreq])
        qValues = np.sin(phi+phases[iFreq])
        iValList.append(iValues)
        qValList.append(qValues)

    return {'I':iValList,'Q':qValList,'quantizedFreqs':quantFreqs}

def formatWaveForMem(iVals,qVals,nBitsPerSamplePair=24,nSamplesPerCycle=8,nMems=3,nBitsPerMemRow=64,earlierSampleIsMsb=True):
    """put together IQ values from tones to be loaded to a firmware memory LUT"""
    nBitsPerSampleComponent = nBitsPerSamplePair / 2
    #I vals and Q vals are 12 bits, combine them into 24 bit vals
    iqVals = (iVals << nBitsPerSampleComponent) + qVals
    iqRows = np.reshape(iqVals,(-1,nSamplesPerCycle))
    #we need to set dtype to object to use python's native long type
    colBitShifts = nBitsPerSamplePair*(np.arange(nSamplesPerCycle,dtype=object))
    if earlierSampleIsMsb:
        #reverse order so earlier (more left) columns are shifted to more significant bits
        colBitShifts = colBitShifts[::-1]
    iqRowVals = np.sum(iqRows<<colBitShifts,axis=1) #shift each col by specified amount, and sum each row
    #Now we have 2**20 row values, each is 192 bits and contain 8 IQ pairs 
    #next we divide these 192 bit rows into three 64-bit qdr rows

    #Mem0 has the most significant bits
    memRowBitmask = int('1'*nBitsPerMemRow,2)
    memMaskShifts = nBitsPerMemRow*np.arange(nMems,dtype=object)[::-1]
    #now do bitwise_and each value with the mask, and shift back down
    memRowVals = (iqRowVals[:,np.newaxis] >> memMaskShifts) & memRowBitmask

    #now each column contains the 64-bit qdr values to be sent to a particular qdr
    return memRowVals

def loadWaveToMem(fpga,waveFreqs=[10.4e6],phases=None,sampleRate=2.e9,nSamplesPerCycle=8,nSamples=2**23,nBytesPerMemSample=8,nBitsPerSamplePair=24,memNames = ['qdr0_memory','qdr1_memory','qdr2_memory'],memType='qdr',dynamicRange=1.):
    """Given a list of frequencies, make a signal containing all the frequencies and load it to firmware memory"""

    nBitsPerMemRow = nBytesPerMemSample*8 
    nBitsPerSampleComponent = nBitsPerSamplePair/2
    nMems = len(memNames)
    nMemRowsToUse = nSamples/nSamplesPerCycle

    tone = generateComb(waveFreqs,phases=phases,nSamples=nSamples,sampleRate=sampleRate,dynamicRange=dynamicRange)
    complexTone = tone['I'] + 1j*tone['Q']
    iVals,qVals = tone['I'],tone['Q']
    memVals = formatWaveForMem(iVals,qVals,nMems=nMems,nBitsPerSamplePair=nBitsPerSamplePair,nSamplesPerCycle=nSamplesPerCycle,nBitsPerMemRow=nBitsPerMemRow)

    time.sleep(.1)
    fpga.write_int('dac_lut_n_qdr_rows',nMemRowsToUse)
    for iMem in xrange(nMems):
        if memType == 'qdr':
            writeQdr(fpga,memName=memNames[iMem],valuesToWrite=memVals[:,iMem],bQdrFlip=(memType=='qdr'))
        elif memType == 'bram':
            writeBram(fpga,memName=memNames[iMem],valuesToWrite=memVals[:,iMem])
    time.sleep(.5)

    return {'tone':complexTone,'memVals':memVals,'quantizedFreqs':tone['quantizedFreqs']}

def loadDdsToMem(fpga,waveFreqs=np.zeros(1024),phases=None,sampleRate=1.953125e6,nSamplesPerCycle=2,nSamples=2**21,nBytesPerMemSample=8,nBitsPerSamplePair=32,memNames = ['qdr0_memory','qdr1_memory','qdr2_memory','qdr3_memory'],dynamicRange=1.):
    """Form a look-up table of interleaved frequencies and load it to memory"""
    nBitsPerMemRow = nBytesPerMemSample*8 #64
    nBitsPerSampleComponent = nBitsPerSamplePair/2
    nMems = len(memNames)
    nMemRowsToUse = nSamples/nSamplesPerCycle

    #separate freq list by which qdr they'll go to.
    freqsByMem = np.reshape(waveFreqs,(nMems,-1))

    complexTones = []
    allMemVals = []
    quantFreqList = []
    for iMem in xrange(nMems):
        toneDict = generateInterleavedTones(freqsByMem[iMem],phases=phases,nSamples=nSamples,sampleRate=sampleRate,dynamicRange=dynamicRange,nSamplesPerCycle=nSamplesPerCycle)
        complexTone = toneDict['I'] + 1j*toneDict['Q']
        iVals,qVals = toneDict['I'],toneDict['Q']
        memVals = formatWaveForMem(iVals,qVals,nMems=1,nBitsPerSamplePair=nBitsPerSamplePair,nSamplesPerCycle=nSamplesPerCycle,nBitsPerMemRow=nBitsPerMemRow,earlierSampleIsMsb=True)
        time.sleep(.1)
        
        writeQdr(fpga,memName=memNames[iMem],valuesToWrite=memVals[:,0],bQdrFlip=True)
        complexTones.append(complexTone)
        allMemVals.append(memVals[:,0])
        quantFreqList.append(toneDict['quantizedFreqs'])
        np.savez('ddstone{}.npz'.format(iMem),complexTone=complexTone,toneDict=toneDict,sampleRate=sampleRate,memVals=memVals,waveFreqs=waveFreqs,quantFreqs=toneDict['quantizedFreqs'])
    quantFreqList = np.array(quantFreqList)
    time.sleep(.1)
    return {'memVals':allMemVals,'complexTone':complexTones,'quantizedFreqs':quantFreqList}

def test_loadDds(fpga):
    """test function to use and validate loadDdsToMem()"""
    instrument = 'darkness'
    memType = 'qdr'
    #memType = 'qdr'

    #For darkness channelizer
    nSamplesPerCycle = 2 #from a single channel's dds
    nCyclesToLoopToSameChannel = 256
    fpgaClockRate = 250.e6
    sampleRate = nSamplesPerCycle*fpgaClockRate/nCyclesToLoopToSameChannel
    nChannels = 1024
    memNames = ['qdr0_memory','qdr1_memory','qdr2_memory','qdr3_memory']
    
    nQdrRowsToUse = 2**20
    nQdrRows = 2**20
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 32
    nSamples = nSamplesPerCycle*nQdrRowsToUse/nCyclesToLoopToSameChannel

    startRegisterName = 'run'
    fpga.write_int(startRegisterName,0) #halt reading from mem while writing
    #waveFreqs = np.zeros(nChannels)
    #phases = np.zeros(nChannels)
    waveFreqs = np.arange(nChannels)*1e6
    phases = None

    loadDict = loadDdsToMem(fpga,waveFreqs=waveFreqs,phases=phases,nSamples=nSamples,sampleRate=sampleRate)
    time.sleep(.1)
    fpga.write_int(startRegisterName,1) #halt reading from mem while writing
    #should be running

    memVals = np.array(loadDict['memVals'])

    snapNames = ['dds_lut_dataOut0','dds_lut_dataOut1','dds_lut_dataOut2','dds_lut_dataOut3','dds_lut_addr']
    snaps = [fpga.snapshots[name] for name in snapNames]
    fpga.write_int('dds_lut_addrTrig',0) #set the address to first trigger on

    for snap in snaps:
        snap.arm()
    time.sleep(.1)
    fpga.write_int('dds_lut_snap',1)#trigger snapshots
    time.sleep(.1)
    fpga.write_int('dds_lut_snap',0)#trigger snapshots

    snapData = [np.array(snap.read(arm=False,timeout=10)['data']['data'],dtype=object) for snap in snaps]
    snapData = np.array(snapData)
    fpga.write_int('dds_lut_snap',0)#trigger snapshots
    
    readQ = readMemory(fpga,memNames[0],nSamples=nQdrRowsToUse,nBytesPerSample=8,bQdrFlip=True)
    readQ = np.array(readQ,dtype=object)
    readQ = readQ[np.newaxis,:]
    print np.shape(snapData)
    print np.shape(memVals)
    print np.shape(readQ)

    print 'snap','qdrOut','katcpRead'
    print snapData[0,:],memVals[0,:],readQ[0,:]

    nSnapVals = np.shape(snapData)[1]
    print nSnapVals
    print len(memVals[0,:nSnapVals])

    print '%X'%memVals[0,0],'is',memVals[0,0]
    
    np.savetxt('memVals.txt',memVals,fmt='%X')
    np.savetxt('snapData.txt',snapData,fmt='%X')

    print 'Error Count 0:',np.sum(snapData[0,:nSnapVals] != memVals[0,:nSnapVals])
    print 'Error Count 1:',np.sum(snapData[1,:nSnapVals] != memVals[1,:nSnapVals])
    print 'Error Count 2:',np.sum(snapData[2,:nSnapVals] != memVals[2,:nSnapVals])
    print 'Error Count 3:',np.sum(snapData[3,:nSnapVals] != memVals[3,:nSnapVals])

    print 'done!'


def test_loadWave(fpga):
    """test function to use and validate loadWaveToMem()"""
    instrument = 'darkness'
    memType = 'bram'
    #memType = 'qdr'
    if instrument == 'arcons':
        sampleRate = 512.e6
        nSamplesPerCycle = 2
        nBins = 512
        snapshotNames = ['bin0','bin1']
        if memType == 'qdr':
            memNames = ['qdr0_memory']
    elif instrument == 'darkness':
        sampleRate = 2.e9
        nSamplesPerCycle = 8
        nBins = 2048
        snapshotNames = ['bin0','bin1','bin2','bin3','bin4','bin5','bin6','bin7']
        if memType == 'qdr':
            memNames = ['qdr0_memory','qdr1_memory','qdr2_memory']
        elif memType == 'bram':
            memNames = ['dac_lut_mem0','dac_lut_mem1','dac_lut_mem2']
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    
    nQdrRowsToUse = 2**10
    nQdrRows = 2**20
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    nSamples = nSamplesPerCycle*nQdrRowsToUse

    binSpacing = sampleRate/nBins
    freq = 10.*binSpacing
    startRegisterName = 'run'
    if memType == 'qdr':
        fpga.write_int(startRegisterName,0) #halt reading from mem while writing
    elif memType == 'bram':
        fpga.write_int(startRegisterName,1) #halt firmware writing from mem while writing from katcp
    loadDict = loadWaveToMem(fpga,waveFreqs=[freq],phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,memType=memType)
    fpga.write_int(startRegisterName,1) #halt reading from mem while writing
    #should be running

#    fill = np.zeros(1024)
#    fpga.write_int(startRegisterName,0)
#    writeQdr(fpga,memNames=qdrMemNames,valuesToWrite=fill,start=8*len(fill),bQdrFlip=True,nQdrRows=2**20)
#    fpga.write_int(startRegisterName,1)
    
    memVals = loadDict['memVals']

    snapNames = ['dac_lut_dataOut0','dac_lut_dataOut1','dac_lut_dataOut2','dac_lut_addr']
    snaps = [fpga.snapshots[name] for name in snapNames]
    fpga.write_int('dac_lut_addrTrig',0) #set the address to first trigger on

    for snap in snaps:
        snap.arm()
    time.sleep(.1)
    fpga.write_int('dac_lut_snap',1)#trigger snapshots
    snapData = [np.array(snap.read(timeout=10)['data']['data'],dtype=object) for snap in snaps]
    snapData = np.array(snapData)
    snapData = snapData.T
    fpga.write_int('dac_lut_snap',0)#trigger snapshots
    
    readQ = readMemory(fpga,memNames[0],nSamples=nQdrRowsToUse,nBytesPerSample=8,bQdrFlip=(memType=='qdr'))
    readQ = np.array(readQ,dtype=object)
    readQ = readQ[:,np.newaxis]

    print 'snap','qdrOut','katcpRead'
    print snapData[0,:],memVals[0,:],readQ[0,:]

    #print '%X'%memVals[0,0],'is',memVals[0,0]
    
    np.savetxt('memVals.txt',memVals,fmt='%X')
    np.savetxt('snapData.txt',snapData,fmt='%X')

    print 'Error Count:',np.sum(snapData[:nQdrRowsToUse,:-1] != memVals[:,:])

    print 'done!'


if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.112'
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    if not fpga.is_running():
        print 'Firmware is not running, start firmware and calibrate first!'
        exit(0)

    fpga.get_system_information()
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()
    time.sleep(1)
    np.random.seed(0)

    test_loadDds(fpga)








