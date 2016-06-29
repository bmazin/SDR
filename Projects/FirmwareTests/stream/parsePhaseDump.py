"""
File:      parsePhaseDump.py
Author:    Matt Strader
Date:      Feb 19, 2016
Firmware:  pgbe0.slx

The pgbe0 firmware sends a stream of phase data points over 1Gbit ethernet (gbe). recv_dump_64b.c catches the frames of phase data and dumps them to a file phaseDump.bin. This script parses the dump file.  Each 64 bit word contains 5 12_9fix phase data points.
"""

import matplotlib, time, struct
import matplotlib.pyplot as plt
import numpy as np

path = 'phaseDump.bin'

with open(path,'r') as dumpFile:
    data = dumpFile.read()

nBytes = len(data)
nWords = nBytes/8 #64 bit words
#break into 64 bit words
words = np.array(struct.unpack('>{:d}Q'.format(nWords), data))
nBitsPerPhase = 12
binPtPhase = 9
nPhasesPerWord = 5
#to parse out the 5 12-bit values, we'll shift down the bits we don't want for each value, then apply a bitmask to take out
#bits higher than the 12 we want
#The least significant bits in the word should be the earliest phase, so the first column should have zero bitshift
bitmask = int('1'*nBitsPerPhase,2)
bitshifts = nBitsPerPhase*np.arange(nPhasesPerWord)

#add an axis so we can broadcast
#and shift away the bits we don't keep for each row
phases = (words[:,np.newaxis]) >> bitshifts
phases = phases & bitmask

#now we have a nWords x nPhasesPerWord array

#flatten so that the phases are in order
phases = phases.flatten(order='C')
phases = np.array(phases,dtype=np.uint64)
signBits = np.array(phases / (2**(nBitsPerPhase-1)),dtype=np.bool)

#check the sign bits to see what values should be negative
#for the ones that should be negative undo the 2's complement, and flip the sign
phases[signBits] = ((~phases[signBits]) & bitmask)+1
phases = np.array(phases,dtype=np.double)
phases[signBits] = -phases[signBits]
#now shift down to the binary point
phases = phases / 2**binPtPhase

#convert from radians to degrees
phases = 180./np.pi * phases
plt.plot(phases[0:2**15],'.-')

photonPeriod = 4096 #timesteps (us)

#fold it and make sure we have the same phases every time
nPhotons = len(phases)//photonPeriod
phases = phases[0:(nPhotons*photonPeriod)].reshape((-1,photonPeriod))
disagreement = (phases[1:] - phases[0])
print 'discrepancies:',np.sum(disagreement)

np.save

plt.show()
