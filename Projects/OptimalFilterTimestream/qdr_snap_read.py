import numpy as np
import corr
import time
import struct
import matplotlib.pyplot as plt
import binascii
import sys


roach = corr.katcp_wrapper.FpgaClient('10.0.0.10',7147)
time.sleep(2)

L=2**20/4
trigger = 1
snapL = 2**10

snapaddr = 0
if snapaddr == 1:
    roach.write_int('snapQDR_snapAddr_ctrl',0)
    time.sleep(0.1)
    roach.write_int('snapQDR_snapAddr_ctrl',1)
    time.sleep(0.1)
    roach.write_int('snapQDR_snapAddr_ctrl',0)
    time.sleep(0.1)
#start firmware writing to qdr
if trigger == 1:
    roach.write_int('startSnap',0)
    time.sleep(0.1)
    roach.write_int('startSnap',1)
    time.sleep(0.01)
    roach.write_int('startSnap',0)
    time.sleep(10)
#read out what was written
data_str0 = roach.read('qdr0_memory',L*4)
#convert to hex and then to binary strings
values0 = struct.unpack('>%dH'%(L*2),data_str0)
if snapaddr == 1:
    addr = roach.read('snapQDR_snapAddr_bram',snapL*4)
    addrs = struct.unpack('>%dL'%(snapL),addr)
    for a in addrs:
        print >> sys.stderr, str(a)
for v in values0:
    print v
