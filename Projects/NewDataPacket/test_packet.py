#!/bin/usr/python

import numpy as np
import matplotlib.pyplot as plt
import struct
import sys
from bin import *

bin_data_0=str(np.load('bin_data_0.npy'))

bin_data_1=str(np.load('bin_data_1.npy'))
phase_timestream=np.loadtxt('phase_timestream.txt')
bin_max=len(bin_data_1)/4

addr0=12802
addr1=15860
median =  -0.31893158518
threshold = -44.9301864736
pulseMask = int(12*'1',2) #bitmask of 12 ones
timeMask = int(20*'1',2)#bitmask of 20 ones
N_pts = len(phase_timestream)
total_counts = addr1-addr0
phase_peaks = []
time_vals=[]
sec=0

print 'total_counts ',total_counts
n=addr0
elapsed = 0
initial_time = 0
#while elapsed < 4048:
for n in range(addr0,addr1):#range(addr1,bin_max)+range(0,addr0):
    raw_data_1 = int(struct.unpack('>L', bin_data_1[n*4:n*4+4])[0])
    raw_data_0 = int(struct.unpack('>L', bin_data_0[n*4:n*4+4])[0])
    packet = (np.int64(raw_data_1)<<32)+np.int64(raw_data_0)
    channel = np.int64(packet)>>56
    if channel == 51:
        beforePeak = bin12_9ToDeg(packet>>44 & pulseMask)
        atPeak = bin12_9ToDeg(packet>>32 & pulseMask)
        afterPeak = bin12_9ToDeg(packet>>20 & pulseMask)
        peak = peakfit(beforePeak, atPeak, afterPeak)
        time = packet & timeMask
        if initial_time == 0:
            initial_time = time
        elapsed = time - initial_time
        phase_peaks.append(atPeak)
        timestamp=elapsed*1e-6
        time_vals.append(timestamp)
        print beforePeak,atPeak,afterPeak
    else:
        #packet is End of second (0xfffffffff)
        sec+=1

print len(time_vals)

last_peak = -1
beforePeakList=[]
atPeakList=[]
afterPeakList=[]
paraPeakList=[]
timeList = []
baseList = []
alpha = 0.1
for iPt,pt in enumerate(phase_timestream):
   if pt < threshold and pt > phase_timestream[iPt-1] and (last_peak == -1 or iPt - last_peak > 100): 
       last_peak = iPt
       beforePeak = phase_timestream[iPt-2]
       atPeak = phase_timestream[iPt-1]
       afterPeak = phase_timestream[iPt]
       para=peakfit(beforePeak,atPeak,afterPeak)
       para = castBin(para,format='deg')
       time=(iPt-1)*1e-6
       startBase = (iPt/2048)*2048
       lpf = phase_timestream[startBase]
       alpha = castBin(alpha,format='rad')
       alphaC = castBin(1-alpha,format='rad')
       for jPt in np.arange(startBase,iPt-5):
           lpf0 = castBin(alphaC * lpf,format='deg',nBits=16,binaryPoint=12)
           lpf1 = castBin(alpha * phase_timestream[jPt],format='deg',nBits=16,binaryPoint=12)
           lpf = lpf0+lpf1

           lpf = castBin(lpf0+lpf1,format='deg')
       baseList.append(lpf)
       beforePeakList.append(beforePeak)
       atPeakList.append(atPeak)
       afterPeakList.append(afterPeak)
       paraPeakList.append(para)
       timeList.append(time)
       print iPt,para,beforePeak,atPeak,afterPeak,lpf


total_timestream_counts = len(paraPeakList)
print total_timestream_counts
