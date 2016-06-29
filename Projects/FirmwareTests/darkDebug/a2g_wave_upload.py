"""
File:      a2g_uart_interface.py
Author:    Neelay Fruitwala
Date:      May 16, 2016
Firmware:  a2g_uart_interface.fpg

Test ROACH2/ADCDAC UART interface.
"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr
import logging
import types
import sys
import functools
from loadWavePulseLut import generateComb,writeBram

def formatWaveForTransfer(iVals,qVals,nBitsPerSamplePair=32,nBuffers=5,nBytesPerBuffer=2**12,nSamplesInBuffers=[10],earlierSampleIsMsb=False):
    """put together IQ values from tones to be loaded to a firmware memory LUT"""
    nBitsPerSampleComponent = nBitsPerSamplePair / 2
    nBitsPerBufferVal = 8
    bufferValBitMask = int('1'*nBitsPerBufferVal,2)
    #I vals and Q vals are 16 bits, combine them into 32 bit vals
    iqVals = np.array((iVals << nBitsPerSampleComponent) + qVals,dtype=np.uint32)
    for i in range(10):
        print hex(iqVals[i])
    buffers = []
    bufferStrs = []

    for iBuffer,nSamplesInBuffer in enumerate(nSamplesInBuffers):
        startIndex = np.sum(nSamplesInBuffers[:iBuffer])
        iqValsInBuffer = iqVals[startIndex:startIndex+nSamplesInBuffer]
        
        #now we'll split into 8 bit values
        #we want the lowest 8 bits first, then the next, and so on
        bufferValShifts = nBitsPerBufferVal*np.arange(nBitsPerSamplePair/nBitsPerBufferVal)
        bufferVals = (iqValsInBuffer[:,np.newaxis] >> bufferValShifts) & bufferValBitMask
        bufferVals = bufferVals.flatten() #unravel by rows
        
        buffers.append(bufferVals)
        bufferStr = struct.pack('>{}B'.format(int(nSamplesInBuffer*nBitsPerSamplePair/nBitsPerBufferVal)),*bufferVals)
        bufferStrs.append(bufferStr)

    return {'buffers':buffers,'bufferStrs':bufferStrs}

def loadWaveToUart(fpga,waveFreqs=[10.4e6],phases=None,sampleRate=2.e9,nSamples=2**23,nBytesPerBuffer=4096,nBitsPerSamplePair=32,memName = 'dac_lut_buffer',dynamicRange=1.,phasePulseDicts=None,baudRate=921600,fabricClock=250e6):
    """Given a list of frequencies, make a signal containing all the frequencies and send it across the UART"""


    nBitsPerSampleComponent = nBitsPerSamplePair/2
    tone = generateComb(waveFreqs,phases=phases,nSamples=nSamples,sampleRate=sampleRate,dynamicRange=dynamicRange,phasePulseDicts=phasePulseDicts,nBitsPerSampleComponent=nBitsPerSampleComponent)
    complexTone = tone['I'] + 1j*tone['Q']
    iVals,qVals = tone['I'],tone['Q']

    maxSamplesPerBuffer = np.floor((nBytesPerBuffer*8.)/nBitsPerSamplePair)
    nBuffersNeed = 1.*nSamples/maxSamplesPerBuffer
    nBuffersToUse = np.int(np.ceil(nBuffersNeed))
    trailingRaggedBuffer = (nBuffersNeed != nBuffersToUse)
    if trailingRaggedBuffer:
        nSamplesInBuffers = (nBuffersToUse-1)*[maxSamplesPerBuffer] + [nSamples-(nBuffersToUse-1)*maxSamplesPerBuffer]
    else:
        nSamplesInBuffers = (nBuffersToUse)*[maxSamplesPerBuffer]

    formatDict = formatWaveForTransfer(iVals,qVals,nBuffers=nBuffersToUse,nBitsPerSamplePair=nBitsPerSamplePair,nBytesPerBuffer=nBytesPerBuffer,nSamplesInBuffers=nSamplesInBuffers)

    buffer_size = 4096
    nBitsPerUartSend = 10 #10 uart bits - 8 bits of data, plus 1 start and 1 stop bit
    data_period = np.int((nBitsPerUartSend*fabricClock)//baudRate + 1 )
    print 'period',data_period
    
    fpga.write_int('rst',1)
    time.sleep(.1)
    fpga.write_int('rst',0)
    fpga.write_int('tx_en',0)

    fpga.write_int('data_period', data_period)

    bSendingData = 1
    bV7IsReady = 0
    for iBuffer in range(nBuffersToUse):
        bufferStr = formatDict['bufferStrs'][iBuffer]
        print 'To Write Str Length: ', len(bufferStr)
        fpga.write_int('buffer_size',len(bufferStr))
        fpga.blindwrite(memName,bufferStr,0)
        while(bV7IsReady == 0):
            bV7IsReady = fpga.read_int('v7_ready')
        fpga.write_int('tx_en',1)
        print 'enable write'
        time.sleep(0.05)
        fpga.write_int('tx_en',0)
        sending_data = 1
        bV7IsReady = 0
        while(bSendingData):
            bSendingData = fpga.read_int('sending_data')


    return {'tone':complexTone,'bufferVals':formatDict['buffers'],'quantizedFreqs':tone['quantizedFreqs']}


if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.111'
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware first!'
        exit(0)

    fpga.get_system_information()


    #list=xrange(buffer_size)
    #toWriteStr = struct.pack('>{}{}'.format(buffer_size,formatChar),*list)
    #fpga.blindwrite('dac_lut_buffer',toWriteStr,0)
    
    fpga.snapshots['snp_in_ss'].arm(man_valid=False, man_trig=True)

    freqs = [13549804.6875,201.e6]
    phases = None
    loadWaveToUart(fpga,freqs,phases=phases,nSamples=2**16)

        
    
    #list=xrange(200,0,-1) 
    #toWriteStr = struct.pack('>{}{}'.format(buffer_size,formatChar),*list)
    #fpga.blindwrite('dac_lut_buffer',toWriteStr,0)
    #fpga.write_int('tx_en',1)

    #snpInData = fpga.snapshots['snp_in_ss'].read(timeout=10, arm=False)['data'] 

    full = fpga.read_int('reg_tx_full')

    time.sleep(1)

    fpga.write_int('tx_en', 0)

    print 'full: ' + str(full)

    #plt.plot(snpInData['t'], snpInData['din'],'.')
    #plt.show()    
