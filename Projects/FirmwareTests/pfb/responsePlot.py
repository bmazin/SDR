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
from loadQdrWave import loadWaveToQdr

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
        dynamicRange = .01
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    nQdrRowsToUse = 2**15
    nSamples=nSamplesPerCycle*nQdrRowsToUse
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    fftSize = nBins
    binSpacing = sampleRate/fftSize

    binIndexToSweep = 50
    fpga.write_int('bin',binIndexToSweep+8) # there's sometimes an n bin/cycle offset I don't understand
    centerFreq = binIndexToSweep * binSpacing

    freqSweepWidth = 20.e6
    nFreqs = 300

    freqList = np.linspace(centerFreq - freqSweepWidth/2.,centerFreq + freqSweepWidth/2., nFreqs)
    snapshotBin = fpga.snapshots['selected_bin']

    avgs = []
    for iFreq,freq in enumerate(freqList):
        #if iFreq % 25 == 0:
        print iFreq
        loadWaveToQdr(fpga,waveFreqs=[freq],phases=[0.],sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nSamples=nSamples,nBytesPerQdrSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,qdrMemNames = qdrMemNames,dynamicRange=dynamicRange)
        time.sleep(.1)

        snapshotBin.arm()
        fpga.write_int('snap_fft',1)#trigger snapshots
        time.sleep(.05)

        binData = np.array(snapshotBin.read(timeout=10)['data']['data'],dtype=object)

        fpga.write_int('snap_fft',0)#trigger snapshots
        parsedBin = parseBinData(binData)
        absBin = np.abs(parsedBin)
        avgs.append(np.mean(absBin))

    freqListMHz = freqList/1.e6
    plt.plot(freqListMHz,np.array(avgs))
    np.savez('freqResponse2.npz',freqList=freqList,sampleRate=sampleRate,binIndexToSweep=binIndexToSweep,centerFreq=centerFreq,responseList=np.array(avgs))
    plt.show()


    print 'done!'







