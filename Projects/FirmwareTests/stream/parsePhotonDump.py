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
from Utils import binTools

path = 'photonDump.bin'

with open(path,'r') as dumpFile:
    data = dumpFile.read()

nBytes = len(data)
nWords = nBytes/8 #64 bit words
#break into 64 bit words
words = np.array(struct.unpack('>{:d}Q'.format(nWords), data),dtype=object)
fakePhotonWord = 2**63-1
headerFirstByte = 0xff

firstBytes = words >> (64-8)
print nWords,' words parsed'
print firstBytes[0:20]

headerIdx = np.where(firstBytes == headerFirstByte)[0]
headers = words[firstBytes == headerFirstByte]
print len(headerIdx),'headers'
for i in range(10):
    print '{:016X}'.format(headers[i])

fakeIdx = np.where(words == fakePhotonWord)[0]
print len(fakeIdx),'fake photons'

#header format: 8 bits all ones, 8 bits roach num, 12 bits frame num, ufix36_1 bit timestamp
nBitsHdrTstamp = 36
binPtHdrTstamp = 1
nBitsHdrNum = 12
nBitsHdrRoach = 8
realIdx = np.where(np.logical_and(firstBytes != headerFirstByte, words != fakePhotonWord))[0]
realPhotons = words[realIdx]
#photon format: 20 bits id, 9 bits ts, fix18_15 phase, fix17_14 base
nBitsPhtId = 20
nBitsPhtTstamp = 9
nBitsPhtPhase = 18
binPtPhtPhase = 15
nBitsPhtBase = 17
binPtPhtBase = 14
for i in range(10):
    print '{:016X}'.format(realPhotons[i])

#find each photon's corresponding header
photonIdMask = binTools.bitmask(nBitsPhtId)
photonIds = (realPhotons >> (nBitsPhtTstamp+nBitsPhtPhase+nBitsPhtBase)) & photonIdMask
#selectId = 34
#selectMask = photonIds==selectId
#realIdx = realIdx[selectMask]
#realPhotons = realPhotons[selectMask]

photonsHeaderIdx = np.searchsorted(headerIdx,realIdx)-1

photonsHeader = headers[photonsHeaderIdx]
#now get the timestamp from this
headerTimestampBitmask = int('1'*nBitsHdrTstamp,2)
headerTimestamps = ((headerTimestampBitmask & photonsHeader)/2.)

headerFrameNumBitmask = int('1'*nBitsHdrNum,2)
headerFrameNums = headerFrameNumBitmask & (photonsHeader>>nBitsHdrTstamp)

photonTimestampMask = binTools.bitmask(nBitsPhtTstamp)
photonTimestamps = (realPhotons >> (nBitsPhtPhase+nBitsPhtBase)) & photonTimestampMask

print 'photon ts',photonTimestamps[0:5]
photonTimestamps = photonTimestamps*1.e-3 + headerTimestamps #convert us to ms
print 'header ts',headerTimestamps[0:5]
print 'ts',photonTimestamps[0:5]
dt = np.diff(photonTimestamps)
print 'diff ts',dt[0:5]
fig,ax = plt.subplots(1,1)
ax.plot(dt)

phtPhaseMask = int('1'*nBitsPhtPhase,2)
phases = (realPhotons >> nBitsPhtBase) & phtPhaseMask
phasesDeg = 180./np.pi * binTools.reinterpretBin(phases,nBits=nBitsPhtPhase,binaryPoint=binPtPhtPhase)
phtBaseMask = int('1'*nBitsPhtBase,2)
bases = (realPhotons) & phtPhaseMask
basesDeg = 180./np.pi * binTools.reinterpretBin(bases,nBits=nBitsPhtBase,binaryPoint=binPtPhtBase)
print 'phase',phasesDeg[0:10]
print 'base',basesDeg[0:10]
print 'IDs',photonIds[0:10]
#print 'phase bin',phases[0:10]
#print 'base bin',bases[0:10]
fig,ax = plt.subplots(1,1)
ax.plot(phasesDeg)
ax.plot(basesDeg)
#ax.plot(photonIds)


plt.show()
