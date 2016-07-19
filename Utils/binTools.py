import numpy as np
def bitmask(nBits):
    return int('1'*nBits,2)

def bin12_9ToDeg(binOffset12_9):
    x = binOffset12_9/2.0**9-4.0
    return x*180.0/np.pi

def bin12_9ToRad(binOffset12_9):
    x = binOffset12_9/2.0**9-4.0
    return x
def peakfit(y1,y2,y3):
    if y3+y1-2*y2 == 0:
        return y2
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

def extractBin(value,nBits=12,binaryPoint=9,nBitsAfterEnd=0,format='rad'):
    value = value >> nBitsAfterEnd#take out bits after needed string
    bitMask = int('1' * nBits,2)
    value = value & bitMask #take out bits before beginning of string
    signBit = int(value)/2**(nBits-1)
    if signBit != 0:
        value = ((~value)&bitMask)+1 #apply 2's complement in nBits
        value = -value #Add sign
    value = float(value) / 2.0**binaryPoint
    if format == 'deg':
        value=value*180.0/np.pi
    return value

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

def reinterpretBin(values,nBits=12,binaryPoint=9):
    bitmask = int('1' * nBits,2)
    values = values & bitmask #take out bits before beginning of string
    values = np.array(values,dtype=np.uint64)
    #extract the first bit, to find which values are negative
    signBits = np.array(values // (2**(nBits-1)),dtype=np.bool)
    #for the negative values, apply 2's complement to find it's positive magnitude
    values[signBits] = ((~values[signBits]) & bitmask)+1
    #change data type to handle sign and fraction
    values = np.array(values,dtype=np.double)
    #make the ones that should be negative into negatives
    values[signBits] = -values[signBits]
    #now shift down to the binary point
    values = values / 2.**binaryPoint
    return values
