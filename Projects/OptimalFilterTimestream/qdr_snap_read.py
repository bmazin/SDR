import numpy as np
import corr
import time
import struct
import matplotlib.pyplot as plt
import binascii


roach = corr.katcp_wrapper.FpgaClient('10.0.0.10',7147)
time.sleep(2)

L=2**19/4

#start firmware writing to qdr
roach.write_int('startSnap',0)
time.sleep(0.1)
roach.write_int('startSnap',1)
time.sleep(0.01)
roach.write_int('startSnap',0)
time.sleep(5)
#read out what was written
data_str0 = roach.read('qdr0_memory',L*4)
data_str1 = roach.read('qdr1_memory',L*4)
#convert to hex and then to binary strings
values0 = struct.unpack('>%dH'%(L*2),data_str0)
values1 = struct.unpack('>%dH'%(L*2),data_str1)
values = np.zeros(len(values0)+len(values1))
values[0::4]=values0[0::2]
values[1::4]=values0[1::2]
values[2::4]=values1[0::2]
values[3::4]=values1[1::2]
for v in values:   
    print v
