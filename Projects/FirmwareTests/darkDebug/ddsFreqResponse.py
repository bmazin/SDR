"""
File:      ddsFreqResponse.py
Author:    Matt Strader
Date:      Nov 24, 2015
Firmware:  ddc0_2015_Nov_21_1801.fpg

 This script sweeps the frequency of a tone input into the DARKNESS channelizer 
firmware. For each frequency it records the amplitude of the signal exiting the
the first stage of channelization (PFB/FFT) and then the second stage (DDC - mix
with DDS signal, low pass filter, and downsampling).
The response values are saved in an npz, so they can then be compared by the 
theoretical values generated by channelizerSimPlots.py (comparison done by compareTheory.py)
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
import functools
from loadWaveLut import loadWaveToMem,loadDdsToMem

def snapDdc(bSnapAll=False,bPlot=False,selBinIndex=0,selChanIndex=0,selChanStream=0,ddsAddrTrig=0):
    """trigger and read snapshots of aligned input and data values in the firmware

    INPUTS:
        bSnapAll: If True, snapshot will record values for all channels, not just one
        bPlot: If True, will popup a plot of snapped values
        selBinIndex: the fft bin to be inspected
        selChanIndex: the channel within a stream (after channel selection) to be inspected
        selChanStream: which of the four simultaneous streams of channels to inspect
        ddsAddrTrig: trigger when the address for the DDS look up table reaches this value (out of 2**20)
    OUTPUT:
        dict with keys:
        'bin': complex values seen in a chosen fft bin 
        'chan': complex values in a chosen channel
        'dds': complex values coming from the QDR look-up table
        'mix': complex values after the dds mixer but before the low pass filter
        'ddcOut': complex values after the DDC low pass filter and downsampling
        'chanCtr': the channel numbers associated with values in 'chan','dds','mix','ddcOut'.
            If bSnapAll=False, these should all equal selChanIndex
        'expectedMix': the values of 'chan' multiplied by 'dds'. Hopefully this matches the values in 
            'mix'.
    """
    #set up the snapshots to record the selected bin/channel
    fpga.write_int('sel_bin',selBinIndex)
    fpga.write_int('sel_bch',selChanIndex)
    fpga.write_int('sel_stream',selChanStream)
    fpga.write_int('sel_ctr',ddsAddrTrig)

    snapshotNames = ['snp2_bin_ss','snp2_ch_ss','snp2_dds_ss','snp2_mix_ss','snp2_ctr_ss','snp3_ddc_ss']
    for name in snapshotNames:
        fpga.snapshots[name].arm(man_valid=bSnapAll)

    time.sleep(.1)
    fpga.write_int('trig_buf',1)#trigger snapshots
    time.sleep(.1) #wait for other trigger conditions to be met
    fpga.write_int('trig_buf',0)#release trigger

    #in most of the snapshots, we get two IQ values per cycle (I[t=0],Q[t=0]) and (I[t=1],Q[t=1])
    #Retrieve them separately and then interleave them
    binData = fpga.snapshots['snp2_bin_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    i0 = np.array(binData['i0'])
    i1 = np.array(binData['i1'])
    q0 = np.array(binData['q0'])
    q1 = np.array(binData['q1'])
    #interleave values from alternating cycles (I0,Q0) and (I1,Q1)
    bi = np.vstack((i0,i1)).flatten('F')
    bq = np.vstack((q0,q1)).flatten('F')

    chanData = fpga.snapshots['snp2_ch_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    ci0 = np.array(chanData['i0'])
    ci1 = np.array(chanData['i1'])
    cq0 = np.array(chanData['q0'])
    cq1 = np.array(chanData['q1'])
    ci = np.vstack((ci0,ci1)).flatten('F')
    cq = np.vstack((cq0,cq1)).flatten('F')

    ddsData = fpga.snapshots['snp2_dds_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    di0 = np.array(ddsData['i0'])
    di1 = np.array(ddsData['i1'])
    dq0 = np.array(ddsData['q0'])
    dq1 = np.array(ddsData['q1'])
    #interleave i0 and i1 values
    di = np.vstack((di0,di1)).flatten('F')
    dq = np.vstack((dq0,dq1)).flatten('F')

    expectedMix = (ci+1.j*cq)*(di-1.j*dq)

    mixerData = fpga.snapshots['snp2_mix_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    mi0 = np.array(mixerData['i0'])
    mi1 = np.array(mixerData['i1'])
    mq0 = np.array(mixerData['q0'])
    mq1 = np.array(mixerData['q1'])
    #interleave i0 and i1 values
    mi = np.vstack((mi0,mi1)).flatten('F')
    mq = np.vstack((mq0,mq1)).flatten('F')

    #The low-pass filter in the DDC stage downsamples by 2, so we only get one sample per cycle here
    ddcData = fpga.snapshots['snp3_ddc_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    li = np.array(ddcData['i0'])
    lq = np.array(ddcData['q0'])

    ctrData = fpga.snapshots['snp2_ctr_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    ctr = np.array(ctrData['ctr']) #the channel counter (0-256)
    dctr = np.array(ctrData['dctr']) #the dds lut address counter (0-2**20)

    if bPlot:
        #we have the same number of samples from the lpf/downsample as everything else, but the each one
        #corresponds to every other timesample in the others. So leave off the second half of lpf samples
        #so the samples we have correspond to the same time period as the others, at least when plotting.
        liSample = li[0:len(mi)/2]

        fig,ax = plt.subplots(1,1)
        ax.plot(di,'r.-')
        ax.plot(bi,'bv-')
        ax.plot(ci,'g.-')
        ax.plot(mi,'mo-')
        ddcTimes = 2.*np.arange(0,len(liSample))
        ax.plot(ddcTimes,liSample,'k.-')
        ax.set_title('I')
        plt.show()

    return {'bin':(bi+1.j*bq),'chan':(ci+1.j*cq),'dds':(di+1.j*dq),'mix':(mi+1.j*mq),'ddcOut':(li+1.j*lq),'chanCtr':ctr,'ddsCtr':dctr,'expectedMix':expectedMix}

def setSingleChanSelection(selBinNums=[0,0,0,0],chanNum=0):
    """assigns bin numbers to a single channel (in each stream), to configure chan_sel block

    INPUTS:
        selBinNums: 4 bin numbers (for 4 streams) to be assigned to chanNum
        chanNum: the channel number to be assigned
    """
    nStreams = 4
    if len(selBinNums) != nStreams:
        raise TypeError,'selBinNums must have number of elements matching number of streams in firmware'

    fpga.write_int('chan_sel_load',0) #set to zero so nothing loads while we set other registers.

    #assign the bin number to be loaded to each stream
    fpga.write_int('chan_sel_ch_bin0',selBinNums[0])
    fpga.write_int('chan_sel_ch_bin1',selBinNums[1])
    fpga.write_int('chan_sel_ch_bin2',selBinNums[2])
    fpga.write_int('chan_sel_ch_bin3',selBinNums[3])
    time.sleep(.1)

    #in the register chan_sel_load, the lsb initiates the loading of the above bin numbers into memory
    #the 8 bits above the lsb indicate which channel is being loaded (for all streams)
    loadVal = (chanNum << 1) + 1
    fpga.write_int('chan_sel_load',loadVal)
    time.sleep(.1) #give it a chance to load

    fpga.write_int('chan_sel_load',0) #stop loading


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
    startRegisterName = 'run'
    memNames = ['dac_lut_mem0','dac_lut_mem1','dac_lut_mem2']
    memType='bram'
    nBins = 2048
    nChannels = 1024
    nChannelsPerStream = 256
    MHz = 1.e6

    #parameters for dac look-up table (lut)
    sampleRate = 2.e9
    nSamplesPerCycle = 8
    nLutRowsToUse = 2**11
    nBytesPerMemSample = 8
    nBitsPerSamplePair = 24
    dynamicRange = .05

    nSamples=nSamplesPerCycle*nLutRowsToUse
    binSpacing = sampleRate/nBins
    dacFreqResolution = sampleRate/nSamples

    #set the frequency of what the resonator would be. We will set the ddc to target this frequency
    resFreq = 7.32421875e6 #already quantized
    quantizedResFreq = np.round(resFreq/dacFreqResolution)*dacFreqResolution

    genBinIndex = resFreq/binSpacing
    selBinIndex = np.round(genBinIndex)
    selChanIndex = 0
    selChanStream = 0
    ddsAddrTrig = 0 
    binCenterFreq = selBinIndex*binSpacing

    #parameters for dds look-up table (lut)
    nDdsSamplesPerCycle = 2
    fpgaClockRate = 250.e6
    nCyclesToLoopToSameChannel = nChannelsPerStream
    nQdrRows = 2**20
    nBytesPerQdrSample = 8
    nBitsPerDdsSamplePair = 32

    ddsSampleRate = nDdsSamplesPerCycle * fpgaClockRate / nCyclesToLoopToSameChannel
    nDdsSamples = nDdsSamplesPerCycle*nQdrRows/nCyclesToLoopToSameChannel
    ddsFreqResolution = 1.*ddsSampleRate/nDdsSamples

    ddsFreq = quantizedResFreq - binCenterFreq
    print 'unrounded dds freq',ddsFreq/MHz
    #quantize the dds freq according to its resolution
    ddsFreq = np.round(ddsFreq/ddsFreqResolution)*ddsFreqResolution
    ddsFreqs = np.zeros(nChannels)
    ddsFreqs[selChanIndex] = ddsFreq
    ddsPhases = np.zeros(nChannels)
    print 'dac freq resoluton',dacFreqResolution
    print 'resonator freq',resFreq/MHz
    print 'quantized resonator freq',quantizedResFreq/MHz
    print 'bin center freq',binCenterFreq/MHz
    print 'dds sampleRate',ddsSampleRate/MHz,'MHz. res',ddsFreqResolution/MHz,'MHz'
    print 'dds freq',ddsFreq

    print 'gen bin index',genBinIndex
    print 'bin index',selBinIndex
    print 'channel',selChanIndex

    #set the delay between the dds lut and the end of the fft block (firmware dependent)
    ddsShift = 109+256
    fpga.write_int('dds_shift',ddsShift)

    #set list of bins to save in the channel selection block


    bLoadAddr = True
    if bLoadAddr:
        setSingleChanSelection(selBinNums=[selBinIndex,0,0,0],chanNum=selChanIndex)
    
    bLoadDds = True
    if bLoadDds:
        print 'loading dds freqs'
        fpga.write_int(startRegisterName,0) #do not read from qdr while writing
        loadDict = loadDdsToMem(fpga,waveFreqs=ddsFreqs,phases=ddsPhases,sampleRate=ddsSampleRate,nSamplesPerCycle=nDdsSamplesPerCycle,nBitsPerSamplePair=nBitsPerDdsSamplePair,nSamples=nDdsSamples)
        print 'dds quant freq',loadDict['quantizedFreqs'][0]
    fpga.write_int(startRegisterName,1) 

    #set parameters for the frequencies to sweep
    freqSweepWidth = 6.e6
    startFreq = binCenterFreq - freqSweepWidth/2.
    endFreq = binCenterFreq +freqSweepWidth/2.
    #quantize the start/end freqs
    startFreq = np.round(startFreq/dacFreqResolution)*dacFreqResolution
    endFreq = np.round(endFreq/dacFreqResolution)*dacFreqResolution
    
    #the space between frequencies should be the tone freq resolution
    freqList = np.arange(startFreq,endFreq+dacFreqResolution, dacFreqResolution)
    nFreqs = len(freqList)
    freqListMHz = freqList/MHz
    
    fftResponses = np.zeros(nFreqs)
    ddcResponses = np.zeros(nFreqs)
    rawFftResponses = np.zeros(nFreqs)
    rawDdcResponses = np.zeros(nFreqs)
    quantFreqList = np.zeros(nFreqs)
    for iFreq,freq in enumerate(freqList):
        print 'freq {} of {}: {} MHz'.format(iFreq,nFreqs,freq/1.e6)
        waveFreqs = [freq]
        #next load up the signal LUT for the given frequency
        loadDict = loadWaveToMem(fpga,waveFreqs=waveFreqs,phases=None,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerMemSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,memType=memType,dynamicRange=dynamicRange)
        quantFreqList[iFreq] = loadDict['quantizedFreqs'][0]

        fpga.write_int('sel_bch',selChanIndex)
        snapDict = snapDdc(bSnapAll=False,selBinIndex=selBinIndex,selChanIndex=selChanIndex,selChanStream=selChanStream,ddsAddrTrig=ddsAddrTrig)
        ddcResponses[iFreq] = np.mean(np.abs(snapDict['ddcOut']))
        rawDdcResponses[iFreq] = np.abs(snapDict['ddcOut'])[0]

        fftResponses[iFreq] = np.mean(np.abs(snapDict['bin']))
        rawFftResponses[iFreq] = np.abs(snapDict['bin'])[0]

    dbFftResponse = 20.*np.log10(fftResponses)
    dbRawFftResponse = 20.*np.log10(rawFftResponses)
    dbDdcResponse = 20.*np.log10(ddcResponses)
    dbRawDdcResponse = 20.*np.log10(rawDdcResponses)

    print 'diff freqList',freqList-quantFreqList
    quantFreqListMHz = quantFreqList/MHz

    fig,ax = plt.subplots(1,1)
    ax.plot(quantFreqListMHz,dbFftResponse,color='b',label='fft')
    ax.plot(quantFreqListMHz,dbDdcResponse,color='g',label='ddc')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.set_xlabel('Frequency (MHz)')
    ax.set_ylabel('Response (dB)')
    ax.legend(loc='best')

    np.savez('freqResponses_dr{}_{}.npz'.format(dynamicRange,'ddc3'),freqResponseFftDb=dbFftResponse,freqResponseDdcDb=dbDdcResponse,freqResponseFft=fftResponses, freqResponseDdc=ddcResponses,freqListMHz=freqListMHz,quantFreqListMHz=quantFreqListMHz,resFreq=resFreq,quantResFreq=quantizedResFreq)

    print 'done!'
    plt.show()

