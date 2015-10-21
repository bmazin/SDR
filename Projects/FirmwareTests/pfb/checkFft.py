"""
name:   checkFft.py
author: Matt Strader
date:   Aug 2015
This script goes with the firmware arcons_fft_test.slx.
It creates a look up table containing a specified tone,
loads it onto qdr, and has the firmware read the qdr and send it to the PFB/FFT.
Then it looks at snap blocks at the output of the fft, to check if the output is
as expected.
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
from loadWaveLut import loadWaveToMem

def signedValue(binData,nBits):
    componentMask = int('1'*nBits,2)
    parsedBin = np.array(binData,dtype=object)
    signBits = np.array(parsedBin >> nBits-1,dtype=np.bool)
    #convert 2's complement binary to floats
    parsedBin[signBits] = -(((~binData[signBits]) & componentMask)+1)
    parsedBin = np.array(parsedBin,dtype=np.float)
    return parsedBin


def parseComplexBinArray(binData,nBitsPerSampleComponent=18,nBitsAfterBinPt=17):
    componentMask = int('1'*nBitsPerSampleComponent,2)
    #data in array is [Re(pt[0]),Im(pt[0])],[Re(pt[1]),Im(pt[1])],...
    shifts = np.array([nBitsPerSampleComponent,0])

    parsedBin = (binData[:,np.newaxis] >> shifts) & componentMask
    #separate real and imaginary parts into columns
    signBits = np.array(parsedBin >> nBitsPerSampleComponent-1,dtype=np.bool)

    #convert 2's complement binary to floats
    parsedBin[signBits] = -(((~parsedBin[signBits]) & componentMask)+1)
    parsedBin = np.array(parsedBin,dtype=np.float)
    parsedBin = parsedBin / 2.**nBitsAfterBinPt

    #combine real and imaginary columns into one complex column
    parsedBin = parsedBin[:,0]+1.j*parsedBin[:,1]

    return parsedBin

def parseBinData(binData,nBitsPerSampleComponent=18,nBitsAfterBinPt=17,nBinsInData=256):
    componentMask = int('1'*nBitsPerSampleComponent,2)
    #data in mask is Re(pt[0]),Im(pt[0]),Re(pt[1]),Im(pt[1])
    #where each component is 18 bits
    shifts = (np.arange(4)[::-1])*nBitsPerSampleComponent

    parsedBin = (binData[:,np.newaxis] >> shifts) & componentMask
    #separate real and imaginary parts into columns
    parsedBin.reshape((-1,2))
    signBits = np.array(parsedBin >> nBitsPerSampleComponent-1,dtype=np.bool)

    #convert 2's complement binary to floats
    parsedBin[signBits] = -(((~parsedBin[signBits]) & componentMask)+1)
    parsedBin = np.array(parsedBin,dtype=np.float)
    parsedBin = parsedBin / 2.**nBitsAfterBinPt

    #combine real and imaginary columns into one complex column
    parsedBin = parsedBin[:,0]+1.j*parsedBin[:,1]

    #move things around so that each row has the same bin, but different points of time, in order
    parsedBin.reshape(-1,nBinsInData,2)
    parsedBin = np.swapaxes(parsedBin,0,1)
    parsedBin.reshape(-1,nBinsInData)

    return parsedBin


if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.112'
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware, calibrate, and load wave into qdr first!'
        exit(0)
    
    fpga.get_system_information()

    instrument = 'darkness'
    memType = 'bram'
    startRegisterName = 'run'
    if instrument == 'arcons':
        sampleRate = 512.e6
        nSamplesPerCycle = 2
        nBins = 512
        memNames = ['qdr0_memory'] 
    elif instrument == 'darkness':
        sampleRate = 2.e9
        nSamplesPerCycle = 8
        nBins = 2048
        snapshotNames = ['bin0','bin1','bin2','bin3','bin4','bin5','bin6','bin7']
        if memType == 'qdr':
            memNames = ['qdr0_memory','qdr1_memory','qdr2_memory'] 
        elif memType == 'bram':
            memNames = ['dds_lut_mem0','dds_lut_mem1','dds_lut_mem2']
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    nQdrRowsToUse = 2**10
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    nSamples=nSamplesPerCycle*nQdrRowsToUse

    fpga.write_int('dds_lut_addrTrig',0) #set the address to first trigger on

    binSpacing = sampleRate/nBins
    freq = 10.*binSpacing
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()
    #waveFreqs = np.random.uniform(0,512,nFreqs)*binSpacing
    nFreqs = 100
    waveFreqs = np.linspace(10,nBins-10,nFreqs)*binSpacing

    if memType == 'qdr':
        fpga.write_int(startRegisterName,0) #halt firmware from writing to qdr while writing
    elif memType == 'bram':
        fpga.write_int(startRegisterName,1) #halt reading from mem while writing

    loadDict = loadWaveToMem(fpga,waveFreqs=waveFreqs,phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,dynamicRange=1.,memType=memType)
    fpga.write_int(startRegisterName,1) #start firmware reading from mem

    originalTone = loadDict['tone'][0:2**11]
    qdrVals = loadDict['memVals'][0:2**11,:]

    snapshotNames = ['PFB_I00','PFB_Q00','PFB_I01','PFB_Q01','PFB_outI00','PFB_outQ00','PFB_outI01','PFB_outQ01']
    snapshotList = [fpga.snapshots[name] for name in snapshotNames]
    snapshotList2 = [fpga.snapshots[name] for name in ['PFB_in00','PFB_in01']]

    for snap in snapshotList:
        snap.arm()
    for snap in snapshotList2:
        snap.arm()
    
    time.sleep(.1)
    fpga.write_int('dds_lut_snap',1)#trigger snapshots
    fpga.write_int('PFB_snap',1)#trigger snapshots
    time.sleep(.1)
    snapData = [np.array(snap.read(timeout=10)['data']['data'],dtype=object) for snap in snapshotList]
    snapData2 = [np.array(fpga.snapshots[name].read(timeout=10)['data']['data'],dtype=object) for name in ['PFB_in00','PFB_in01']]
    snapData3 = fpga.snapshots['PFB_of'].read(timeout=10)['data']['data']
    fpga.write_int('dds_lut_snap',0)#trigger snapshots
    fpga.write_int('PFB_snap',0)#trigger snapshots

    print 'I0 Q0 I1 Q1'
    print '%03X%03X%03X%03X'%(snapData[0][0],snapData[1][0],snapData[2][0],snapData[3][0])
    print '%X'%qdrVals[0]
    mask = int('1'*12,2)
    inHex = ['%03X%03X%03X%03X'%(snapData[0][i] & mask,snapData[1][i] & mask,snapData[2][i] & mask,snapData[3][i] & mask) for i in range(len(snapData[0]))]


    parsedData = [signedValue(s,nBits=32) for s in snapData]
    in00 = parseComplexBinArray(snapData2[0],nBitsPerSampleComponent=18,nBitsAfterBinPt=17)
    in01 = parseComplexBinArray(snapData2[1],nBitsPerSampleComponent=18,nBitsAfterBinPt=17)

    out0 = parsedData[4]+1j*parsedData[5]
    out1 = parsedData[6]+1j*parsedData[7]

    outFft = np.append(out0,out1)
    outFft[::2] = out0
    outFft[1::2] = out1

    inTone = np.append(in00,in01) #make an array of the same type but with len = len(in00)+len(in01)
    inTone[::2] = in00
    inTone[1::2] = in01

    fig,ax = plt.subplots(1,1)
    ax.plot(inTone.real)
    ax.plot(inTone.imag)
    ax.set_title('in')

    fig,ax = plt.subplots(1,1)
    ax.plot(snapData3)
    ax.set_title('of')

    fig,ax = plt.subplots(1,1)
    ax.plot(outFft.real)
    ax.plot(outFft.imag)
    ax.set_title('fft out')

    fig,ax = plt.subplots(1,1)
    ax.plot(originalTone.real)
    ax.plot(originalTone.imag)
    ax.set_title('original')


    fftIn = np.fft.fft(inTone,n=nBins)/nBins
    fig,ax = plt.subplots(1,1)
    ax.plot(fftIn.real)
    ax.plot(fftIn.imag)
    ax.set_title('fft of in')

    snapNames = ['dds_lut_dataOut0','dds_lut_addr']
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
    print '%X'%snapData[0,0]

    print 'done!'
    plt.show()

