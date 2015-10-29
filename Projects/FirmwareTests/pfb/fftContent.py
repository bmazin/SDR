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
        if memType == 'qdr':
            memNames = ['qdr0_memory','qdr1_memory','qdr2_memory'] 
        elif memType == 'bram':
            memNames = ['dds_lut_mem0','dds_lut_mem1','dds_lut_mem2']
        dynamicRange = .05
    else:
        print 'unrecognized instrument',instrument
        exit(1)

    nQdrRowsToUse = 2**18
    nBytesPerQdrSample = 8
    nBitsPerSamplePair = 24
    nSamples=nSamplesPerCycle*nQdrRowsToUse

    bUsePfb = 0
    fpga.write_int('skip_pfb',bUsePfb)

    binSpacing = sampleRate/nBins
    #waveFreqs = np.arange(0.,1000,5)*binSpacing
    binIndex = 8
    fpga.write_int('snap_fft_sel_bin',binIndex)

    waveFreqs = [1.002*binIndex*binSpacing]
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()
    if memType == 'qdr':
        fpga.write_int(startRegisterName,0) #halt reading from mem while writing
    elif memType == 'bram':
        fpga.write_int(startRegisterName,1) #halt firmware writing from mem while writing
    loadDict = loadWaveToMem(fpga,waveFreqs=waveFreqs,phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerQdrSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,memType=memType,dynamicRange=dynamicRange)
    fpga.write_int(startRegisterName,1) #start reading from mem 

    snapshotNames = ['snap_fft_snp1_b02_ss','snap_fft_snp1_b35_ss','snap_fft_snp1_b67_ss','snap_fft_snp1_sel_bin_ss']
    for name in snapshotNames:
        fpga.snapshots[name].arm()

    coSnapshot = fpga.snapshots['snap_fft_snp1_co_ss']
    coSnapshot.arm()
    time.sleep(.1)

    fpga.write_int('snap_fft_trig',1)#trigger snapshots
    #fpga.write_int('PFB_snap',1)#trigger snapshots
    time.sleep(.1)
    #coData = coSnapshot.read(timeout=10,man_valid=True)['data']
    coData = coSnapshot.read(timeout=5)['data']
    overflowData = coData['over']
    binCtr = coData['ctr']

    fftVals = []
    data = fpga.snapshots['snap_fft_snp1_b02_ss'].read(timeout=10)['data']
    fftVals.append(np.array(data['i0'])+1.j*np.array(data['q0']))
    fftVals.append(np.array(data['i1'])+1.j*np.array(data['q1']))
    fftVals.append(np.array(data['i2'])+1.j*np.array(data['q2']))
    data = fpga.snapshots['snap_fft_snp1_b35_ss'].read(timeout=10)['data']
    fftVals.append(np.array(data['i3'])+1.j*np.array(data['q3']))
    fftVals.append(np.array(data['i4'])+1.j*np.array(data['q4']))
    fftVals.append(np.array(data['i5'])+1.j*np.array(data['q5']))
    data = fpga.snapshots['snap_fft_snp1_b67_ss'].read(timeout=10)['data']
    fftVals.append(np.array(data['i6'])+1.j*np.array(data['q6']))
    fftVals.append(np.array(data['i7'])+1.j*np.array(data['q7']))
    fftVals = np.array(fftVals).flatten('F')

    selBinData = fpga.snapshots['snap_fft_snp1_sel_bin_ss'].read(timeout=10)['data']
    i0 = np.array(selBinData['i0'])
    i1 = np.array(selBinData['i1'])
    q0 = np.array(selBinData['q0'])
    q1 = np.array(selBinData['q1'])
    #interleave t=0 and t=1
    selBinVals = np.vstack((i0+1.j*q0,i1+1.j*q1)).flatten('F')

    

#    for snap in snapshotList:
#        binData = snap.read(timeout=10)['data']
#        binVals = np.array(binData['i0'])+1.j*np.array(binData['q0'])
#        fftVals.append(binVals)
    #read down a column, then the next column to put fft bins in order
        
    fpga.write_int('snap_fft_trig',0)#reset trigger for next time

    absData = np.abs(fftVals)
    fig,ax = plt.subplots(1,1)
    ax.plot(absData)

    fig,ax = plt.subplots(1,1)
    ax.plot(np.real(fftVals))
    ax.plot(np.imag(fftVals))

    fig,ax = plt.subplots(1,1)
    ax.plot(np.real(selBinVals))
    ax.plot(np.imag(selBinVals))
    ax.plot(np.abs(selBinVals))

   # fig,ax = plt.subplots(1,1)
   # ax.plot(overflowData)
   # ax.set_title('overflow')
   # fig,ax = plt.subplots(1,1)
   # ax.plot(binCtr,'o-')
   # ax.set_title('bin counter')

    plt.show()

    print 'done!'







