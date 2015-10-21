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

    startRegisterName = 'run'
    nQdrRowsToUse = 2**12
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

    freqSweepWidth = 10.e6
    nFreqs = 1000

    freqList = np.linspace(centerFreq - freqSweepWidth/2.,centerFreq + freqSweepWidth/2., nFreqs)
    snapshotBin = fpga.snapshots['selected_bin']

    print 'bin',binIndexToSweep
    print 'center freq',centerFreq/1.e6,'MHz'
    print freqList
#    print 'freq range',freqList[0]/1.e6,freqList[-1]/1.e6
#    print 'freq step',(freqList[1]-freqList[0])/1.e6

    avgs = []
    for iFreq,freq in enumerate(freqList):
        if iFreq % 25 == 0:
            print iFreq
        fpga.write_int(startRegisterName,0) #halt reading from mem while writing
        loadWaveToMem(fpga,waveFreqs=[freq],phases=[0.],sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nSamples=nSamples,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = qdrMemNames,dynamicRange=dynamicRange,memType=memType)
        time.sleep(.1)
        fpga.write_int(startRegisterName,1) #halt reading from mem while writing
        time.sleep(.1)

        snapshotBin.arm()
        fpga.write_int('snap_fft',1)#trigger snapshots
        time.sleep(.05)

        binData = np.array(snapshotBin.read(timeout=10)['data']['data'],dtype=object)

        fpga.write_int('snap_fft',0)#trigger snapshots
        parsedBin = parseBinData(binData)

        print 'freq',freq
        absBin = np.abs(parsedBin)
        avgs.append(np.mean(absBin))

        plt.show()

    freqListMHz = freqList/1.e6

    fig,ax = plt.subplots(1,1)
    responseList = np.array(avgs)
    dbResponse = 20.*np.log10(responseList)
    ax.plot(freqListMHz,dbResponse)
    np.savez('freqResponse3.npz',freqList=freqList,sampleRate=sampleRate,binIndexToSweep=binIndexToSweep,centerFreq=centerFreq,responseList=np.array(avgs),dbResponse=dbResponse)
    plt.show()


    print 'done!'







