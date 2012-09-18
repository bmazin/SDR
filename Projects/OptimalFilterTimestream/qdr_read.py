import numpy as np
import corr
import time
import struct
import matplotlib.pyplot as plt
import binascii


roach = corr.katcp_wrapper.FpgaClient('10.0.0.10',7147)
time.sleep(2)
print 'connection established'

wordSize = 32
L=2**20
nWords = L*8/wordSize

print '\n'
#start firmware writing to qdr
roach.write_int('startSnap',0)
time.sleep(0.1)
roach.write_int('startSnap',1)
time.sleep(0.01)
roach.write_int('startSnap',0)
time.sleep(5)
#read out what was written
data = roach.read('qdr0_memory',L)
#convert to hex and then to binary strings
binstr = bin(int(binascii.hexlify(data),16))[2:]
#print in groups of 32 bits, with four groups in a row
for i in range(nWords):
    print binstr[i*wordSize:i*wordSize+wordSize],
    if i%4 == 3:
        print ''
