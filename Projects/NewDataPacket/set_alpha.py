import numpy as np
import corr
import time
import struct

def castBin(value,nBits=12,binaryPoint=9,quantization='Truncate',format='uint'):
    if format == 'deg':
        value = value*np.pi/180.0
    value = value * 2**binaryPoint
    if quantization == 'Truncate':
        value = int(value)
    else:
        value = int(round(value))
    bitMask = int('1' * nBits,2)
    if value < 0:
        value = -value
        value = ((~value) & bitMask) + 1 
    value = value & bitMask
    if format != 'uint':
        value = extractBin(value,nBits=nBits,binaryPoint=binaryPoint)
        if format == 'deg':
            value = value*180.0/np.pi
    return value

def extractBin(value,nBits=12,binaryPoint=9,nBitsAfterEnd=0):
    value = value >> nBitsAfterEnd#take out bits after needed string
    bitMask = int('1' * nBits,2)
    value = value & bitMask #take out bits before beginning of string
    signBit = int(value)/2**(nBits-1)
    if signBit != 0:
        value = ((~value)&bitMask)+1 #apply 2's complement in nBits
        value = -value #Add sign
    value = float(value) / 2.0**binaryPoint
    return value

roach = []
alpha = 0.002
out=castBin(alpha,quantization='Round')
print castBin(alpha,format='rad')
for i in xrange(8):
    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%i,7147)
    time.sleep(.2)
    roach.write_int('capture_Baseline1_alpha',out)
print "done"
