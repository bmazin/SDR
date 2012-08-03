#!/bin/usr/python

import numpy as np
import matplotlib.pyplot as plt
import struct
import sys

def binToDeg_12_9(binOffset12_9):
    x = binOffset12_9/2.0**9-4.0
    return x*180.0/np.pi

def peakfit(y1,y2,y3):
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

bin_data_0=str(np.load('bin_data_0.npy'))

bin_data_1=str(np.load('bin_data_1.npy'))
phase_timestream=np.loadtxt('phase_timestream.txt')

addr0=11204
addr1=11249
median = -43.7104130426
threshold = -55.7011215872
pulseMask = int(12*'1',2) #bitmask of 12 ones
timeMask = int(20*'1',2)#bitmask of 20 ones
N_pts = len(phase_timestream)
total_counts = addr1-addr0
phase_peaks = []
time_vals=[]
sec=0

n=addr0
elapsed = 0
initial_time = 0
#while elapsed < 4048:
for n in range(addr0,addr1):
    raw_data_1 = int(struct.unpack('>L', bin_data_1[n*4:n*4+4])[0])
    raw_data_0 = int(struct.unpack('>L', bin_data_0[n*4:n*4+4])[0])
    packet = (np.int64(raw_data_1)<<32)+np.int64(raw_data_0)
    channel = np.int64(packet)>>56
    if channel == 0:
        beforePeak = binToDeg_12_9(packet>>44 & pulseMask)
        atPeak = binToDeg_12_9(packet>>32 & pulseMask)
        afterPeak = binToDeg_12_9(packet>>20 & pulseMask)
        peak = peakfit(beforePeak, atPeak, afterPeak)
        time = packet & timeMask
        if initial_time == 0:
            initial_time = time
        elapsed = time - initial_time
        phase_peaks.append(atPeak)
        timestamp=elapsed*1e-6
        time_vals.append(timestamp)
        print beforePeak,atPeak,afterPeak,peak
    else:
        #packet is EOS (0xfffffffff)
        sec+=1
    n+=1

print len(time_vals)

last_peak = -1
beforePeakList=[]
atPeakList=[]
afterPeakList=[]
paraPeakList=[]
timeList = []
for iPt,pt in enumerate(phase_timestream):
   if pt < threshold and pt > phase_timestream[iPt-1] and (last_peak == -1 or iPt - last_peak > 100): 
       last_peak = iPt
       beforePeak = phase_timestream[iPt-2]
       atPeak = phase_timestream[iPt-1]
       afterPeak = phase_timestream[iPt]
       para=peakfit(beforePeak,atPeak,afterPeak)
       time=(iPt-1)*1e-6
       beforePeakList.append(beforePeak)
       atPeakList.append(atPeak)
       afterPeakList.append(afterPeak)
       paraPeakList.append(para)
       timeList.append(time)
       print beforePeak,atPeak,afterPeak,para


total_timestream_counts = len(paraPeakList)
print total_timestream_counts
