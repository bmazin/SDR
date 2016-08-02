"""
File:      phaseStreamTest.py
Author:    Matt Strader
Date:      Feb 18, 2016
Firmware:  pgbe0_2016_Feb_19_2018.fpg

This script inserts a phase pulse in the qdr dds table and sets up the fake adc lut.  It checks snap blocks for each stage of the channelization process.  In the end the phase pulse should be recovered in the phase timestream of the chosen channel.
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
from loadWavePulseLut import loadWaveToMem,loadDdsToMem
from loadWaveLut import writeBram
from Utils.binTools import castBin

def snapDdc(fpga,bSnapAll=False,bPlot=False,selBinIndex=0,selChanIndex=0,selChanStream=0,ddsAddrTrig=0):
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

    snapshotNames = ['snp2_bin_ss','snp2_ch_ss','snp2_dds_ss','snp2_mix_ss','snp2_ctr_ss','snp3_ddc_ss','snp3_cap_ss']
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
    rawPhase = np.array(ddcData['raw_phase'])

    phaseData = fpga.snapshots['snp3_cap_ss'].read(timeout=5,arm=False,man_valid=bSnapAll)['data']
    filtPhase = np.array(phaseData['phase'])
    basePhase = np.array(phaseData['base'])
    trig = np.array(phaseData['trig'],dtype=np.bool)
    trig2 = np.array(phaseData['trig_raw'],dtype=np.bool)


    ctrData = fpga.snapshots['snp2_ctr_ss'].read(timeout=5,arm=False, man_valid=bSnapAll)['data']
    ctr = np.array(ctrData['ctr']) #the channel counter (0-256)
    dctr = np.array(ctrData['dctr']) #the dds lut address counter (0-2**20)

    if bPlot:
        #we have the same number of samples from the lpf/downsample as everything else, but the each one
        #corresponds to every other timesample in the others. So leave off the second half of lpf samples
        #so the samples we have correspond to the same time period as the others, at least when plotting.
        liSample = li[0:len(mi)/2]

        fig,ax = plt.subplots(1,1)
        ax.plot(di,'r.-',label='dds')
        ax.plot(bi,'bv-',label='bin')
        ax.plot(ci,'g.-',label='channel')
        ax.plot(mi,'mo-',label='mix')
        ddcTimes = 2.*np.arange(0,len(liSample))
        ax.plot(ddcTimes,liSample,'k.-',label='ddcOut')
        ax.set_title('I')
        ax.legend(loc='best')


    return {'bin':(bi+1.j*bq),'chan':(ci+1.j*cq),'dds':(di+1.j*dq),'mix':(mi+1.j*mq),'ddcOut':(li+1.j*lq),'chanCtr':ctr,'ddsCtr':dctr,'expectedMix':expectedMix,'rawPhase':rawPhase,'filtPhase':filtPhase,'trig':trig,'trig2':trig2,'basePhase':basePhase}


def setSingleChanSelection(fpga,selBinNums=[0,0,0,0],chanNum=0):
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

def startStream(fpga,selChanIndex=0):
    """initiates streaming of phase timestream (after prog_fir) to the 1Gbit ethernet

    INPUTS:
        selChanIndex: which channel to stream
    """
    dest_ip  =167772210 #corresponds to IP 10.0.0.50
    fabric_port=50000
    pktsPerFrame = 100 #how many 8byte words to accumulate before sending a frame

    #configure the gbe core, 
    print 'restarting'
    fpga.write_int('stream_phase_gbe64_dest_ip',dest_ip)
    fpga.write_int('stream_phase_gbe64_dest_port',fabric_port)
    fpga.write_int('stream_phase_gbe64_words_per_frame',pktsPerFrame)
    #reset the core to make sure it's in a clean state
    fpga.write_int('stream_phase_gbe64_rst_core',1)
    time.sleep(.1)
    fpga.write_int('stream_phase_gbe64_rst_core',0)

    #choose what channel to stream
    fpga.write_int('stream_phase_ch_we',selChanIndex)
    #reset the counter for how many packets are waiting to send
    fpga.write_int('stream_phase_ctr_rst',1)
    time.sleep(.1)
    fpga.write_int('stream_phase_ctr_rst',0)
    #turn it on
    fpga.write_int('stream_phase_on',1)

def setThresh(fpga,thresholdDeg = -15.):
    """Sets the phase threshold and baseline filter for photon pulse detection triggers in each channel

    INPUTS:
        thresholdDeg: The threshold in degrees.  The phase must drop below this value to trigger a photon
            event
    """
    #convert deg to radians
    thresholdRad = thresholdDeg * np.pi/180.

    #format it as a fix16_13 to be placed in a register
    binThreshold = castBin(thresholdRad,quantization='Round',nBits=16,binaryPoint=13,format='uint')
    sampleRate = 1.e6

    #for the baseline, we apply a second order state variable low pass filter to the phase
    #See http://www.earlevel.com/main/2003/03/02/the-digital-state-variable-filter/
    #The filter takes two parameters based on the desired Q factor and cutoff frequency
    criticalFreq = 200 #Hz
    Q=.7
    baseKf=2*np.sin(np.pi*criticalFreq/sampleRate)
    baseKq=1./Q

    #format these paramters as fix18_16 values to be loaded to registers
    binBaseKf=castBin(baseKf,quantization='Round',nBits=18,binaryPoint=16,format='uint')
    binBaseKq=castBin(baseKq,quantization='Round',nBits=18,binaryPoint=16,format='uint')
    print 'threshold',thresholdDeg,binThreshold
    print 'Kf:',baseKf,binBaseKf
    print 'Kq:',baseKq,binBaseKq
    #load the values in
    fpga.write_int('capture0_base_kf',binBaseKf)
    fpga.write_int('capture0_base_kq',binBaseKq)

    fpga.write_int('capture0_threshold',binThreshold)
    fpga.write_int('capture0_load_thresh',1)
    time.sleep(.1)
    fpga.write_int('capture0_load_thresh',0)

def stopStream(fpga):
    """stops streaming of phase timestream (after prog_fir) to the 1Gbit ethernet

    INPUTS:
        fpga: the casperfpga instance
    """
    fpga.write_int('stream_phase_on',0)

if __name__=='__main__':

    #Get the IP of the casperfpga from the command line
    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.112'
    print ip
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware, calibrate, and load wave into qdr first!'
        exit(0)
    
    fpga.get_system_information()

    bLoadAddr = False #set up chan_sel block
    bLoadDds = False #compute and load dds table into qdr memory
    bLoadFir = False #load fir coefficients into prog_fir block for each channel
    bLoadDac = False #load probe tones into bram for dac/adc simulation block
    bSetThresh = False #set the photon phase trigger threshold in the capture block
    bStreamPhase = False #initiate stream of phase timestream to ethernet for selected channel

    instrument = 'darkness'
    startRegisterName = 'run'

    #collect the names of bram blocks in firmware for the dac/adc simulator block
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
    print 'N dds samples',nDdsSamples
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
    ddsShift = 76+256
    fpga.write_int('dds_shift',ddsShift)

    #set list of bins to save in the channel selection block



    if bLoadAddr:
        setSingleChanSelection(fpga,selBinNums=[selBinIndex,0,0,0],chanNum=selChanIndex)
    

    if bLoadDds:
        pulseDict = {'ampDeg':30.,'arrivalTime':50.e-6}
        otherPulseDict = {'arrivalTime':0}
        pulseDicts = np.append(pulseDict,[otherPulseDict]*(len(ddsFreqs)-1))
        print 'loading dds freqs'
        fpga.write_int(startRegisterName,0) #do not read from qdr while writing
        loadDict = loadDdsToMem(fpga,waveFreqs=ddsFreqs,phases=ddsPhases,sampleRate=ddsSampleRate,nSamplesPerCycle=nDdsSamplesPerCycle,nBitsPerSamplePair=nBitsPerDdsSamplePair,nSamples=nDdsSamples,phasePulseDicts=pulseDicts)

    nTaps = 26
    nFirBits = 12
    firBinPt = 9
    if bLoadFir:
        print 'loading programmable FIR filter coefficients'
        for iChan in xrange(nChannelsPerStream):
            print iChan
            fpga.write_int('prog_fir0_load_chan',0)
            time.sleep(.1)
            fir = np.loadtxt('/home/kids/SDR/Projects/Filters/matched_50us.txt')
            #fir = np.arange(nTaps,dtype=np.uint32)
            #firInts = np.left_shift(fir,5)
            #fir = np.zeros(nTaps)
            #fir = np.ones(nTaps)
            #fir[1] = 1./(1.+iChan)
            #nSmooth=4
            #fir[-nSmooth:] = 1./nSmooth

            firInts = np.array(fir*(2**firBinPt),dtype=np.int32)
            writeBram(fpga,'prog_fir0_single_chan_coeffs',firInts,nRows=nTaps,nBytesPerSample=4)
            time.sleep(.1)
            loadVal = (1<<8) + iChan #first bit indicates we will write, next 8 bits is the chan number
            fpga.write_int('prog_fir0_load_chan',loadVal)
            time.sleep(.1)
            fpga.write_int('prog_fir0_load_chan',0)


    toneFreq = quantizedResFreq #resFreq + dacFreqResolution
    if bLoadDac:
        print 'loading dac lut'
        waveFreqs = [toneFreq]
        phases = [1.39]
        loadDict = loadWaveToMem(fpga,waveFreqs=waveFreqs,phases=phases,sampleRate=sampleRate,nSamplesPerCycle=nSamplesPerCycle,nBytesPerMemSample=nBytesPerMemSample,nBitsPerSamplePair=nBitsPerSamplePair,memNames = memNames,nSamples=nSamples,memType=memType,dynamicRange=dynamicRange)

    if bSetThresh:
        setThresh(fpga)
        

    if bStreamPhase:
        startStream(fpga)

    fpga.write_int(startRegisterName,1) 

    #fpga.write_int('sel_bch',selChanIndex)
    snapDict = snapDdc(fpga,bSnapAll=False,selBinIndex=selBinIndex,selChanIndex=0,selChanStream=selChanStream,ddsAddrTrig=ddsAddrTrig,bPlot=True)

    rawPhase = snapDict['rawPhase']
    mix = snapDict['mix']
    filtPhase = snapDict['filtPhase']
    basePhase = snapDict['basePhase']
    trig = np.roll(snapDict['trig'],-2) #there is an extra 2 cycle delay in firmware between we_out and phase
    trig2 = np.roll(snapDict['trig2'],-2)
    print np.sum(trig),np.sum(trig2)

    mixPhaseDeg = 180./np.pi*np.angle(mix)
    rawPhaseDeg = 180./np.pi*rawPhase
    filtPhaseDeg = 180./np.pi*filtPhase
    basePhaseDeg = 180./np.pi*basePhase
    trigPhases = filtPhaseDeg[trig]
    trig2Phases = filtPhaseDeg[trig2]

    dt = nChannelsPerStream/fpgaClockRate
    t = dt*np.arange(len(rawPhase))
    t2 = (dt/2.)*np.arange(len(mixPhaseDeg)) #two IQ points per cycle are snapped
    t3 = dt*np.arange(len(filtPhase))
    trigTimes = t3[trig]
    trig2Times = t3[trig2]
    fig,ax = plt.subplots(1,1)
    ax.plot(t/1.e-6,rawPhaseDeg,'k.-',label='raw')
    ax.plot(t2/1.e-6,mixPhaseDeg,'r.-',label='mix')
    ax.plot(t3/1.e-6,filtPhaseDeg,'b.-',label='filt')
    ax.plot(t3/1.e-6,basePhaseDeg,'m.--',label='filt')
    ax.plot(trigTimes/1.e-6,trigPhases,'mo',label='trig')
    ax.plot(trig2Times/1.e-6,trig2Phases,'gv')
    ax.set_ylabel('phase ($^{\circ}$)')
    ax.set_xlabel('time ($\mu$s)')
    ax.legend(loc='best')
    plt.show()
    stopStream(fpga)

    print 'done!'

