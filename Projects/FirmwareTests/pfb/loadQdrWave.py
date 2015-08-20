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

def loadQdrInFirmware(fpga,loadChoice=0,blockPrefix='dds_lut_',nQdrRows=2**20):
    """
    load the qdr with values within the fpga
    loadChoice can be 0 for loading all zeros
     1 for loading all ones
     2 for loading all twos
     3 for loading a sequence that matches the row number
     4 to set 32 bits to 1
     5 to load 36 bits to 1
     6 to set every other bit in 32 bits to 1, starting with a 1
     7 to set every other bit in 36 bits to 1,
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
    """
    read a byte string from a bram or qdr, and parse it into an array
    """
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

def writeQdr(fpga,memName,valuesToWrite,start=0,bQdrFlip=True,nQdrRows=2**20):
    nBytesPerSample = 8
    formatChar = 'Q'
    memValues = np.array(valuesToWrite,dtype=np.uint64) #cast signed values
    nValues = len(valuesToWrite)
#    if nValues < nQdrRows:
#        memValues = np.append(memValues,np.zeros(nQdrRows-nValues,dtype=np.uint64))
#        nValues = nQdrRows
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

def generateTones(freqs,nSamples=2**23,amplitudes=None,phases=None,sampleRate=2e9,nBitsPerSampleComponent=12,dynamicRange=1.):
    freqs = np.array(freqs)
    nFreqs = len(freqs)

    freqResolution = 1.*sampleRate / nSamples

    #make a list of frequencies that we can generate with our limited frequency resolution that are closest
    # to the requested frequencies
    quantFreqs = freqResolution * np.round(freqs/freqResolution)

    maxValue = int(np.round(dynamicRange*2**(nBitsPerSampleComponent - 1)-1)) #1 bit for sign

    if phases is None:
        phases = np.random.uniform(0,2.*np.pi,nFreqs)

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
    iValues = np.sum(iValList,axis=0)
    qValues = np.sum(qValList,axis=0)

    highestVal = np.max((np.abs(iValues).max(),np.abs(qValues).max()))

    iValues = np.array(np.round(maxValue / highestVal * iValues),dtype=np.int)
    qValues = np.array(np.round(maxValue / highestVal * qValues),dtype=np.int)

    return {'I':iValues,'Q':qValues,'quantizedFreqs':quantFreqs}

def formatWaveForQdr(iVals,qVals,nBitsPerSamplePair=24,nSamplesPerCycle=8,nQdrs=3,nBitsPerQdrRow=64):
    nBitsPerSampleComponent = nBitsPerSamplePair / 2
    #I vals and Q vals are 12 bits, combine them into 24 bit vals
    iqVals = (iVals << nBitsPerSampleComponent) + qVals
    iqRows = np.reshape(iqVals,(-1,nSamplesPerCycle))
    #shift earlier (leftmost columns) the most
    #we need to set dtype to object to use python's native long type
    colBitShifts = nBitsPerSamplePair*(np.arange(nSamplesPerCycle,dtype=object)[::-1])
    iqRowVals = np.sum(iqRows<<colBitShifts,axis=1) #shift each col by specified amount, and sum each row
    #Now we have 2**20 row values, each is 192 bits and contain 8 IQ pairs 
    #next we have divide these 192 bit rows into three 64-bit qdr rows

    #Qdr0 has the most significant bits
    qdrRowBitmask = int('1'*nBitsPerQdrRow,2)
    qdrMaskShifts = nBitsPerQdrRow*np.arange(nQdrs,dtype=object)[::-1]
    #now do bitwise_and each value with the mask, and shift back down
    qdrRowVals = (iqRowVals[:,np.newaxis] >> qdrMaskShifts) & qdrRowBitmask

    #now each column contains the 64-bit qdr values to be sent to a particular qdr
    return qdrRowVals

def loadWaveToQdr(fpga,waveFreqs=[10.4e6],phases=None,sampleRate=2.e9,nSamplesPerCycle=8,nSamples=2**23,nBytesPerQdrSample=8,nBitsPerSamplePair=24,qdrMemNames = ['qdr0_memory','qdr1_memory','qdr2_memory'],dynamicRange=1.):
    #define some globals
    startRegisterName = 'run'
    #startRegisterName = 'test_load_qdr'
    nBitsPerQdrRow = nBytesPerQdrSample*8 #64
    nBitsPerSampleComponent = nBitsPerSamplePair/2
    nQdrs = len(qdrMemNames)
    nQdrRowsToUse = nSamples/nSamplesPerCycle

    tone = generateTones(waveFreqs,phases=phases,nSamples=nSamples,sampleRate=sampleRate,dynamicRange=dynamicRange)
    complexTone = tone['I'] + 1j*tone['Q']
    iVals,qVals = tone['I'],tone['Q']
    qdrVals = formatWaveForQdr(iVals,qVals,nQdrs=nQdrs,nBitsPerSamplePair=nBitsPerSamplePair,nSamplesPerCycle=nSamplesPerCycle,nBitsPerQdrRow=nBitsPerQdrRow)
    fpga.write_int(startRegisterName,0) #halt reading from qdr while writing
    time.sleep(.1)
    loadQdrInFirmware(fpga,loadChoice=0) #clear qdr
    fpga.write_int('dds_lut_n_qdr_rows',nQdrRowsToUse)
    for iQdr in xrange(nQdrs):
        writeQdr(fpga,memName=qdrMemNames[iQdr],valuesToWrite=qdrVals[:,iQdr],bQdrFlip=True)
    time.sleep(.5)
    fpga.write_int(startRegisterName,1) #start reading from qdr in firmware
    #np.savez('tone.npz',complexTone=complexTone,tone=tone,sampleRate=sampleRate,qdrVals=qdrVals,waveFreqs=waveFreqs,quantFreqs=tone['quantizedFreqs'])

    return {'tone':complexTone,'qdrVals':qdrVals,'quantFreqs':tone['quantizedFreqs']}


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

    instrument = 'darkness'
    if instrument == 'arcons':
        sampleRate = 512.e6
        nSamplesPerCycle = 2
        nBins = 512
        snapshotNames = ['bin0','bin1']
        qdrMemNames = ['qdr0_memory']
        startRegisterName = 'run'
    elif instrument == 'darkness':
        sampleRate = 2.e9
        nSamplesPerCycle = 8
        nBins = 2048
        snapshotNames = ['bin0','bin1','bin2','bin3','bin4','bin5','bin6','bin7']
        qdrMemNames = ['qdr0_memory','qdr1_memory','qdr2_memory']
        startRegisterName = 'test_load_qdr'
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    
    nQdrRowsToUse = 2**9
    nQdrRows = 2**20
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    nSamples = nSamplesPerCycle*nQdrRowsToUse

    binSpacing = sampleRate/nBins
    freq = 10.*binSpacing
    loadDict = loadWaveToQdr(fpga,waveFreqs=[freq],phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerQdrSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,qdrMemNames = qdrMemNames,nSamples=nSamples)
    #should be running

#    fill = np.zeros(1024)
#    fpga.write_int(startRegisterName,0)
#    writeQdr(fpga,memNames=qdrMemNames,valuesToWrite=fill,start=8*len(fill),bQdrFlip=True,nQdrRows=2**20)
#    fpga.write_int(startRegisterName,1)
    

    qdrVals = loadDict['qdrVals']

    snapNames = ['dds_lut_dataOut0','dds_lut_dataOut1','dds_lut_dataOut2','dds_lut_addr']
    snaps = [fpga.snapshots[name] for name in snapNames]
    fpga.write_int('dds_lut_addrTrig',0) #set the address to first trigger on

    for snap in snaps:
        snap.arm()
    time.sleep(.1)
    fpga.write_int('dds_lut_snap',1)#trigger snapshots
    snapData = [np.array(snap.read(timeout=10)['data']['data'],dtype=object) for snap in snaps]
    snapData = np.array(snapData)
    snapData = snapData.T
    fpga.write_int('dds_lut_snap',0)#trigger snapshots
    
    readQ = readMemory(fpga,'qdr0_memory',nSamples=nQdrRowsToUse,nBytesPerSample=8,bQdrFlip=True)
    readQ = np.array(readQ,dtype=object)
    readQ = readQ[:,np.newaxis]

    print 'snap','qdrOut','katcpRead'
    print snapData[0,:],qdrVals[0,:],readQ[0,:]



    print '%X'%qdrVals[0,0],'is',qdrVals[0,0]
    
    np.savetxt('qdrVals.txt',qdrVals,fmt='%X')
    np.savetxt('snapData.txt',snapData,fmt='%X')

    print 'Error Count:',np.sum(snapData[:nQdrRowsToUse,:-1] != qdrVals[:,:])

    print 'done!'







