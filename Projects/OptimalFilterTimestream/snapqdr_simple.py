import numpy as np
import corr
import time
import struct
import matplotlib.pyplot as plt
import binascii
import sys


roach = corr.katcp_wrapper.FpgaClient('10.0.0.10',7147)
time.sleep(2)

L=2**19
trigger = 1
primesnap = 1

#prime the snap block
if primesnap == 1:
    roach.write_int('snapqdr_ctrl',0)
    time.sleep(0.1)
    roach.write_int('snapqdr_ctrl',1)
    time.sleep(0.1)
#start firmware writing to qdr
if trigger == 1:
    roach.write_int('startSnap',0)
    time.sleep(0.1)
    roach.write_int('startSnap',1)
    time.sleep(2)
#read out what was written
data_str0 = roach.read('qdr0_memory',L*4)
#convert to hex and then to binary strings
values0 = struct.unpack('>%dH'%(L*2),data_str0)
if trigger == 1:
    time.sleep(0.1)
    roach.write_int('startSnap',0)
for v in values0:
    print v
