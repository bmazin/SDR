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
from fftContent import parseBinData as parseBinData2

def parseBinData(binData,nBitsPerSampleComponent=18,nBitsAfterBinPt=17):
    componentMask = int('1'*nBitsPerSampleComponent,2)
    #data in mask is Re(pt[0]),Im(pt[0]),Re(pt[1]),Im(pt[1])
    #where each component is 18 bits
    shifts = (np.arange(4)[::-1])*nBitsPerSampleComponent

    parsedBin = (binData[:,np.newaxis] >> shifts) & componentMask
    parsedBin.reshape((-1,2))
    signBits = np.array(parsedBin >> nBitsPerSampleComponent-1,dtype=np.bool)

    #convert 2's complement binary to floats
    parsedBin[signBits] = -(((~parsedBin[signBits]) & componentMask)+1)
    parsedBin = np.array(parsedBin,dtype=np.float)
    parsedBin = parsedBin / 2.**nBitsAfterBinPt

    parsedBin = parsedBin[:,0]+1.j*parsedBin[:,1]
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

    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()

    instrument = 'darkness'
    if instrument == 'arcons':
        sampleRate = 512.e6
        nSamplesPerCycle = 2 
        nBins = 512 
        snapshotNames = ['bin0','bin1']
        qdrMemNames = ['qdr0_memory'] 
        dynamicRange = .01
    elif instrument == 'darkness':
        sampleRate = 2.e9
        nSamplesPerCycle = 8 
        nBins = 2048
        snapshotNames = ['bin0','bin1','bin2','bin3','bin4','bin5','bin6','bin7']
        qdrMemNames = ['qdr0_memory','qdr1_memory','qdr2_memory'] 
        memType = 'qdr'
        dynamicRange = .05
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    bUsePfb = 1
    fpga.write_int('use_pfb',bUsePfb)
    startRegisterName = 'run'
    nQdrRowsToUse = 2**14
    nSamples=nSamplesPerCycle*nQdrRowsToUse
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    fftSize = nBins
    binSpacing = sampleRate/fftSize
    lutFreqResolution = sampleRate / (nQdrRowsToUse*nSamplesPerCycle)
    print 'freq resolution',lutFreqResolution/1.e6,'MHz'

    binIndexToSweep = 8
    fpga.write_int('bin',binIndexToSweep) 
    centerFreq = binIndexToSweep * binSpacing

    freqSweepWidth = 6.e6
    nFreqs = 300

    freqList = np.linspace(centerFreq - freqSweepWidth/2.,centerFreq + freqSweepWidth/2., nFreqs)
    snapshotBin = fpga.snapshots['snp1_sel_bin']
    snapshotOverflow = fpga.snapshots['snp1_over']

    print 'bin',binIndexToSweep
    print 'center freq',centerFreq/1.e6,'MHz'
    #print freqList
#    print 'freq range',freqList[0]/1.e6,freqList[-1]/1.e6
#    print 'freq step',(freqList[1]-freqList[0])/1.e6

    avgs = []
    responseVals = []
    oflws = []
    for iFreq,freq in enumerate(freqList):
        if iFreq % 25 == 0:
            print iFreq
        fpga.write_int(startRegisterName,0) #halt reading from mem while writing
        loadWaveToMem(fpga,waveFreqs=[freq],phases=[0.],sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nSamples=nSamples,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = qdrMemNames,dynamicRange=dynamicRange,memType=memType)
        time.sleep(.1)
        fpga.write_int(startRegisterName,1) #halt reading from mem while writing
        time.sleep(.1)

        snapshotBin.arm()
        snapshotOverflow.arm()
        fpga.write_int('snap_fft',1)#trigger snapshots
        time.sleep(.05)

        binData = np.array(snapshotBin.read(timeout=10)['data']['data'],dtype=object)
        oflwData = np.array(snapshotBin.read(timeout=10)['data']['data'],dtype=object)

        fpga.write_int('snap_fft',0)#trigger snapshots
        parsedBin = parseBinData(binData)

        absBin = np.abs(parsedBin)
        avgs.append(np.mean(absBin))
        responseVals.append(absBin[0])
        oflws.append(np.sum(oflwData))

        plt.show()

    freqListMHz = freqList/1.e6

    responseList = np.array(responseVals)
    avgResponseList = np.array(avgs)
    overflowList = np.array(oflws)
    dbResponse = 20.*np.log10(responseList)
    dbAvgResponse = 20.*np.log10(avgResponseList)
    fig,ax = plt.subplots(1,1)
    ax.plot(freqListMHz,dbResponse)
    ax.plot(freqListMHz,dbAvgResponse)
    fig,ax = plt.subplots(1,1)
    ax.plot(freqListMHz,responseList)
    ax.plot(freqListMHz,avgResponseList)
    fig,ax = plt.subplots(1,1)
    ax.plot(freqListMHz,overflowList)
    np.savez('freqResponse_dr0.05_pfb.npz',freqList=freqList,sampleRate=sampleRate,binIndexToSweep=binIndexToSweep,centerFreq=centerFreq,responseList=responseList,dbResponse=dbResponse,avgResponseList=avgResponseList,dbAvgResponse=dbAvgResponse,overflows=overflowList)
    plt.show()


    print 'done!'







