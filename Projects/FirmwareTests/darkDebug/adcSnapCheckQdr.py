"""
Author:    Matt Strader
"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import sys
import os
from loadWavePulseLut import readMemory
from Utils.binTools import reinterpretBin

def readQdrSnap(fpga):
    #(roach,memName,nSamples,nBytesPerSample=4,bQdrFlip=False)
    nQdrSamples = 2**20
    nBytesPerQdrSample = 8
    nBitsPerQdrSample = nBytesPerQdrSample*8
    qdr0Vals = np.array(readMemory(fpga,'qdr0_memory',nQdrSamples,nBytesPerQdrSample,bQdrFlip=True,dtype=np.object),dtype=object)
    qdr1Vals = np.array(readMemory(fpga,'qdr1_memory',nQdrSamples,nBytesPerQdrSample,bQdrFlip=True,dtype=np.object),dtype=object)
    qdr2Vals = np.array(readMemory(fpga,'qdr2_memory',nQdrSamples,nBytesPerQdrSample,bQdrFlip=True,dtype=np.object),dtype=object)
    #qdr0 has the most significant 64 bits, followed by qdr1, and last qdr2
    #smush them all toghether into 192 bit words
    wholeQdrWords = (qdr0Vals<<(nBitsPerQdrSample*2))+(qdr1Vals<<(nBitsPerQdrSample))+qdr2Vals

    nBitsPerSample = 12 #I or Q sample
    nSamplesPerWholeWord = 16 # 8 IQ pairs per clock cycle
    bitmask = int('1'*nBitsPerSample,2)
    bitshifts = nBitsPerSample*np.arange(nSamplesPerWholeWord)[::-1]
    samples = (wholeQdrWords[:,np.newaxis]) >> bitshifts
    samples = samples & bitmask
    samples = reinterpretBin(samples,nBits=nBitsPerSample,binaryPoint=0)
    samples = samples.flatten(order='C')
    iVals = samples[::2]
    qVals = samples[1::2]


    return {'iVals':iVals,'qVals':qVals}

def snapZdok(fpga,nRolls=0):
    snapshotNames = fpga.snapshots.names()

    fpga.write_int('trig_qdr',0)#initialize trigger
    for name in snapshotNames:
        fpga.snapshots[name].arm(man_valid=False,man_trig=False)

    time.sleep(.1)
    fpga.write_int('trig_qdr',1)#trigger snapshots
    time.sleep(.1) #wait for other trigger conditions to be met, and fill buffers
    fpga.write_int('trig_qdr',0)#release trigger

    adcData0 = fpga.snapshots['adc_in_snp_cal0_ss'].read(timeout=5,arm=False)['data']
    adcData1 = fpga.snapshots['adc_in_snp_cal1_ss'].read(timeout=5,arm=False)['data']
    adcData2 = fpga.snapshots['adc_in_snp_cal2_ss'].read(timeout=5,arm=False)['data']
    adcData3 = fpga.snapshots['adc_in_snp_cal3_ss'].read(timeout=5,arm=False)['data']
    bus0 = np.array([adcData0['data_i0'],adcData0['data_i1'],adcData1['data_i2'],adcData1['data_i3']]).flatten('F')
    bus1 = np.array([adcData2['data_i4'],adcData2['data_i5'],adcData3['data_i6'],adcData3['data_i7']]).flatten('F')
    bus2 = np.array([adcData0['data_q0'],adcData0['data_q1'],adcData1['data_q2'],adcData1['data_q3']]).flatten('F')
    bus3 = np.array([adcData2['data_q4'],adcData2['data_q5'],adcData3['data_q6'],adcData3['data_q7']]).flatten('F')

    adcData = dict()
    adcData.update(adcData0)
    adcData.update(adcData1)
    adcData.update(adcData2)
    adcData.update(adcData3)
    iDataKeys = ['data_i0','data_i1','data_i2','data_i3','data_i4','data_i5','data_i6','data_i7']
    iDataKeys = np.roll(iDataKeys,nRolls)
    #collate
    iValList = np.array([adcData[key] for key in iDataKeys])
    iVals = iValList.flatten('F')
    qDataKeys = ['data_q0','data_q1','data_q2','data_q3','data_q4','data_q5','data_q6','data_q7']
    qDataKeys = np.roll(qDataKeys,nRolls)
    #collate
    qValList = np.array([adcData[key] for key in qDataKeys])
    qVals = qValList.flatten('F')

    return {'bus0':bus0,'bus1':bus1,'bus2':bus2,'bus3':bus3,'adcData':adcData,'iVals':iVals,'qVals':qVals}



def loadDelayCal(fpga,delayLut):
    nLoadDlyRegBits = 6
    notLoadVal = int('1'*nLoadDlyRegBits,2) #when load_dly is this val, no bit delays are loaded
    fpga.write_int('adc_in_load_dly',notLoadVal)
    for iRow,(bit,delay) in enumerate(delayLut):
        fpga.write_int('adc_in_dly_val',delay)
        fpga.write_int('adc_in_load_dly',bit)
        time.sleep(.01)
        fpga.write_int('adc_in_load_dly',notLoadVal)
        
def plotSpec(specDict,titleLabel=''):
    timeLabel = time.strftime("%Y%m%d-%H%M%S",time.localtime())
    print timeLabel

    spectrumDb = specDict['spectrumDb']
    freqsMHz = specDict['freqsMHz']
    nSamples = specDict['nSamples']
    signal = specDict['signal']

    plotFloor = np.percentile(spectrumDb,45)
    fig,ax = plt.subplots(1,1)
    ax.plot(freqsMHz*1.e3,spectrumDb)
    ax.set_ylim([plotFloor,ax.get_ylim()[1]])
    ax.set_xlabel('freq (kHz)')
    ax.set_ylabel('strength (dB)')
    ax.set_title('spectrum of IQ timestream'+titleLabel)

def rms(a):
    return np.sqrt(np.mean(np.square(a)))


def streamSpectrum(iVals,qVals,nBins=None):
    #np.reshape(data[:nFftAvg*fftlen],(nFftAvg,fftlen))
    sampleRate = 2.e9 # 2GHz
    MHz = 1.e6
    adcFullScale = 2.**11 #12 bit values, 1 sign bit

    signal = iVals+1.j*qVals
    signal = signal / adcFullScale
    nSamples = len(signal)
    
    if not (nBins is None):
        nAvgs = nSamples // nBins
        nSamplesToUse = nBins*nAvgs
        nSamplesPerFft = nBins
        foldedSignal = np.reshape(signal[:nSamplesToUse],(nAvgs,nBins))
    else:
        nAvgs = 1
        nSamplesToUse = nSamples
        nBins = nSamples
        nSamplesPerFft = nSamples
        foldedSignal = signal

    spectrum = np.fft.fft(foldedSignal)
    spectrum = 1.*spectrum / nSamplesPerFft
    if nAvgs > 1:
        spectrum = np.average(spectrum,axis=0)

    freqsMHz = np.fft.fftfreq(nSamplesPerFft)*sampleRate/MHz
    freqsMHz = np.fft.fftshift(freqsMHz)
    spectrum = np.fft.fftshift(spectrum)

    spectrumDb = 20*np.log10(np.abs(spectrum))

    return {'spectrumDb':spectrumDb,'freqsMHz':freqsMHz,'spectrum':spectrum,'signal':signal,'nSamples':nSamplesPerFft}

def plotSpec(specDict):
    spectrumDb = specDict['spectrumDb']
    freqsMHz = specDict['freqsMHz']
    signal = specDict['signal']

    plotFloor = np.percentile(spectrumDb,45)
    fig,ax = plt.subplots(1,1)
    ax.plot(freqsMHz,spectrumDb)
    ax.set_ylim([plotFloor,ax.get_ylim()[1]])
    ax.set_xlabel('freq (MHz)')
    ax.set_ylabel('strength (dB)')
    ax.set_title('spectrum of IQ timestream')
    return {'fig':fig,'ax':ax}


if __name__=='__main__':
    if len(sys.argv) > 1:
        ip = '10.0.0.'+sys.argv[1]
    else:
        ip='10.0.0.112'
    print ip
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware, and calibrate qdr first!'
        exit(0)

    fpga.get_system_information()
    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()

    fpga.write_int('run',1)#send ready signals
    time.sleep(1)

    delayLut0 = zip(np.arange(0,12),np.ones(12)*14)
    delayLut1 = zip(np.arange(14,26),np.ones(12)*18)
    delayLut2 = zip(np.arange(28,40),np.ones(12)*14)
    delayLut3 = zip(np.arange(42,54),np.ones(12)*13)
    loadDelayCal(fpga,delayLut0)
    loadDelayCal(fpga,delayLut1)
    loadDelayCal(fpga,delayLut2)
    loadDelayCal(fpga,delayLut3)

    snapDict = snapZdok(fpga,nRolls=0)
    specDict = streamSpectrum(iVals=snapDict['iVals'],qVals=snapDict['qVals'],nBins=None)
    qdrDict = readQdrSnap(fpga)
    nBins = 2**21 #out of 2**23
    specDict2 = streamSpectrum(iVals=qdrDict['iVals'],qVals=qdrDict['qVals'],nBins=nBins)
    plotSpec(specDict)
    plotSpec(specDict2)
    snapDict.update(specDict2)

#    ax.step(x,snapDict['iVals'],label='I')
#    ax.step(x,snapDict['qVals'],label='Q')
#    ax.legend(loc='best')
#    ax.set_title('IQ')
    path = '/mnt/data0/plots/iqsnaps/'
    timeLabel = time.strftime("%Y%m%d-%H%M%S",time.localtime())

    fig2,ax2 = plt.subplots(1,1)
    #times in us
    signal = specDict['signal']
    sampleRate = 2.e9 # 2GHz
    MHz = 1.e6
    times = np.arange(len(signal))/sampleRate * MHz
    ax2.plot(times,signal.real,color='b',label='I')
    ax2.plot(times,signal.imag,color='g',label='Q')
    ax2.set_xlim([0,.5])
    ax2.set_title('IQ stream')
    ax2.set_xlabel('time (us)')
    ax2.legend()

    np.savez(os.path.join(path,'adcDataLong_{}.npz'.format(timeLabel)),**snapDict)
#    fig.savefig(os.path.join(path,'iqSpec_{}_{}.png'.format(timeLabel,freqLabel)))
#    fig2.savefig(os.path.join(path,'iq_{}_{}.png'.format(timeLabel,freqLabel)))
    plt.show()


    print 'done!'

