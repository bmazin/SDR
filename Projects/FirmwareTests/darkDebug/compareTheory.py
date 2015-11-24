"""
File: compareTheory.py
Date: Nov 24, 2015
Author: Matt Strader

This script plots the response in dB at various stages of the channelizer firmware
as a function of frequency.  It uses values previously computed or measured for theoretical response
(using SDR/Projects/ChannelizerSim/channelizerSimPlots.py)
and actual values from firmware (using SDR/Projects/FirmwareTests/darkDebug/ddsFreqResponse.py).
"""
import matplotlib.pyplot as plt
import numpy as np

#load theory values
suffix = 'ddc'
dynamicRange = '0.05'
theoryData = np.load('responseTheory.npz')
freqListMHz = theoryData['freqListMHz']
freqResponseFft = np.abs(theoryData['freqResponsePfb'])
freqResponseFftDb = 20.*np.log10(freqResponseFft)
freqResponseDdc = np.abs(theoryData['freqResponse'])
freqResponseDdcDb = 20.*np.log10(freqResponseDdc)

#load measured values
expData = np.load('freqResponses_dr{}_{}.npz'.format(dynamicRange,suffix))
expFreqListMHz = expData['freqListMHz']
expFreqResponseFft = expData['freqResponseFft']
expFreqResponseFftDb = 20.*np.log10(expFreqResponseFft)
expFreqResponseDdc = expData['freqResponseDdc']
expFreqResponseDdcDb = 20.*np.log10(expFreqResponseDdc)
#adjust the zero point, due to the limited dynamic range used in the firmware test
# and the normalization in the fft block
expFreqResponseFftDb -= 4.
expFreqResponseDdcDb -= 4.

def f(fig,ax):
    ax.plot(freqListMHz,freqResponseFftDb,color='b',label='theory')
    ax.plot(expFreqListMHz,expFreqResponseFftDb,'o',color='b',label='exp')
    ax.plot(freqListMHz,freqResponseDdcDb,color='g',label='theory')
    ax.plot(expFreqListMHz,expFreqResponseDdcDb,'o',color='g',label='exp')
    ax.set_ylim(-70,0)
    ax.set_ylabel('response (dB)')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='best')
fig,ax = plt.subplots(1,1)
f(fig,ax)

def f(fig,ax):
    ax.plot(freqListMHz,freqResponseFft,color='b',label='theory')
    ax.plot(expFreqListMHz,expFreqResponseFft,'o',color='b',label='exp')
    ax.plot(freqListMHz,freqResponseDdc,color='g',label='theory')
    ax.plot(expFreqListMHz,expFreqResponseDdc,'o',color='g',label='exp')
    ax.set_ylabel('response')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='best')
fig,ax = plt.subplots(1,1)
f(fig,ax)

plt.show()
