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

def parseComplexBinArray(binData,nBitsPerSampleComponent=18,nBitsAfterBinPt=17):
    componentMask = int('1'*nBitsPerSampleComponent,2)
    #data in array is [Re(pt[0]),Im(pt[0])],[Re(pt[1]),Im(pt[1])],...
    shifts = np.array([nBitsPerSampleComponent,0])*nBitsPerSampleComponent

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
    parsedBin = np.reshape(parsedBin,(-1,2))
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
    memType = 'qdr'
    startRegisterName = 'run'
    if instrument == 'arcons':
        sampleRate = 512.e6
        nSamplesPerCycle = 2
        nBins = 512
        snapshotNames = ['bin0','bin1']
        qdrMemNames = ['qdr0_memory'] 
        dynamicRange = .001
    elif instrument == 'darkness':
        sampleRate = 2.e9
        nSamplesPerCycle = 8
        nBins = 2048
        snapshotNames = ['bin0','bin1','bin2','bin3','bin4','bin5','bin6','bin7']
        if memType == 'qdr':
            memNames = ['qdr0_memory','qdr1_memory','qdr2_memory'] 
        elif memType == 'bram':
            memNames = ['dds_lut_mem0','dds_lut_mem1','dds_lut_mem2']
        dynamicRange = .05
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    nQdrRowsToUse = 2**10
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    nSamples=nSamplesPerCycle*nQdrRowsToUse

    binSpacing = sampleRate/nBins
    #waveFreqs = np.arange(0.,1000,5)*binSpacing
    waveFreqs = [50.*binSpacing]
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()
    if memType == 'qdr':
        fpga.write_int(startRegisterName,0) #halt reading from mem while writing
    elif memType == 'bram':
        fpga.write_int(startRegisterName,1) #halt firmware writing from mem while writing
    loadDict = loadWaveToMem(fpga,waveFreqs=waveFreqs,phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,memType=memType,dynamicRange=dynamicRange)
    fpga.write_int(startRegisterName,1) #start reading from mem 

    snapshotList = [fpga.snapshots[name] for name in snapshotNames]
    #overSnapshot = fpga.snapshots['over']

    for snap in snapshotList:
        snap.arm()
    #overSnapshot.arm()

    fpga.write_int('snap_fft',1)#trigger snapshots
    #fpga.write_int('PFB_snap',1)#trigger snapshots
    time.sleep(.1)
    #overflowData = fpga.snapshots['PFB_of'].read(timeout=10)['data']['data']

    parsedData = [parseBinData(np.array(snap.read(timeout=10)['data']['data'],dtype=object)) for snap in snapshotList]
    parsedData = np.array(parsedData)
    parsedData = parsedData.flatten('F') #read down a column, then the next column to put fft bins in order
    #fpga.write_int('PFB_snap',0)#trigger snapshots
    #overData = overSnapshot.read(timeout=10)['data']['data']
    fpga.write_int('snap_fft',0)#trigger snapshots

    absData = np.abs(parsedData)
    fig,ax = plt.subplots(1,1)
    ax.plot(absData)

    selectBinIndex = 50
    fig,ax = plt.subplots(1,1)
    ax.plot(np.real(parsedData[selectBinIndex::nBins]))
    ax.plot(np.imag(parsedData[selectBinIndex::nBins]))

#    fig,ax = plt.subplots(1,1)
#    #ax.plot(overData)
#    ax.set_title('overflow')
    plt.show()

    print 'done!'







