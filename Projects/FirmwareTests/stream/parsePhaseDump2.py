"""
File:      parsePhaseDump2.py
Author:    Matt Strader
Date:      Feb 19, 2016
Firmware:  pgbe0.slx

The pgbe0 firmware sends a stream of phase data points over 1Gbit ethernet (gbe). recv_dump_64b.c catches the frames of phase data and dumps them to a file phaseDump.bin. This script parses the dump file.  Each 64 bit word is just an integer.  The beginning of each frame caught should contain a 64 bit header.
"""

import matplotlib, time, struct
import matplotlib.pyplot as plt
import numpy as np

path = 'packetRecvTest3.bin'

with open(path,'r') as dumpFile:
    data = dumpFile.read()

nBytes = len(data)
nWords = nBytes/8 #64 bit words
#break into 64 bit words
print 'stream length' + str(len(data))
print 'nWords ' + str(nWords)
print 'nBytes ' + str(nBytes)
words = np.array(struct.unpack('>{:d}Q'.format(nWords), data[0:nWords*8]))
print words[0:3]
print words[-3:]
amax = np.argmax(words)
amin = np.argmin(words)
print amax,amin
print words[amax]
print words[amin]
print words[25]
print words[(nWords//100 -1) * 100 + 25]
plt.plot(words[0:2**15],'.-')
plt.show()
