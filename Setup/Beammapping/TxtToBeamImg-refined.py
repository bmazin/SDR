#!/usr/bin/env python
# encoding: utf-8
"""
TxtToBeamImg.py

Converts a text file to a beamimage h5 file
"""

import numpy as np
import random
from tables import *

path = '/media/disk2/sci3gamma/20120904/'
freqpath = path
outfile = path + 'PositionKnownOnlybeamimage_double_refined_20120904.h5'

# make beamap group 
h5file = openFile(outfile, mode = "w")
bgroup = h5file.createGroup('/','beammap','Beam Map of Array')


# make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
filt1 = Filters(complevel=0, complib='zlib', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (46,44), filters=filt1)  
resfreq = h5file.createCArray(bgroup, 'resfreq', Float32Atom(), (46,44), filters=filt1)  
atten = h5file.createCArray(bgroup, 'atten', Float32Atom(), (46,44), filters=filt1)  

# load of the text file with resonator data in it and use it to make the beamimage

noloc = []
overlaps = 0
nPixelsPerRoach = 253
fThreshold = 0.000001
posList = np.loadtxt(path+'New-refined-median-all.txt')
posFreqList = posList[:,0]
posAttenList = posList[:,1]
xList = np.round(posList[:,2])
yList = np.round(posList[:,3])

for roachno in xrange(8):
    feedline=roachno/4+1
    count = 0
    completeFreqList = np.loadtxt(freqpath + 'ps_freq%d.txt'%roachno,skiprows=1,usecols=[0])
    nFreqs = len(completeFreqList)

    for iFreq,freq in enumerate(completeFreqList):
        pixelName = '/r%d/p%d/'%(roachno,iFreq)
        iPos = np.where(abs(posFreqList-freq) < fThreshold)
        sizePos = np.size(iPos)
        if sizePos > 1:
            print iPos,posFreqList[iPos],freq,fThreshold,posFreqList[iPos]-freq
            print 'fThreshold too high'
            if feedline == 1:
                iPos = iPos[0][0]
                print iPos
                sizePos = 1
            else:
                print len(iPos)
                iPos = iPos[0][1]
                print iPos
                sizePos = 1

            #exit(-1)
        if sizePos == 0:
            noloc.append(pixelName)
        if sizePos == 1:
            x = xList[iPos]
            y = yList[iPos]
            #if feedline == 2:
                #x += 22
            attenval = posAttenList[iPos]
            print x,y,pixelName
            if x >= 0 and y >= 0 and x < 44 and y <46:
                if ca[y,x] != '':
                    print 'overlapping pixel!'
                    overlaps += 1
                    noloc.append(pixelName)
                else:
                    ca[y,x] = pixelName
                    atten[y,x] = attenval
                    resfreq[y,x] = freq
                    h5file.flush()
            else:
                print 'Pixel location out of bounds'
                noloc.append(pixelName)
    for iFreq in range(nFreqs,nPixelsPerRoach):
        pixelName = '/r%d/p%d/'%(roachno,iFreq)
        noloc.append(pixelName)
        
        
        
print len(noloc),'Randomly placed pixels'
print overlaps, 'Overlapping pixels'
print 46*44-len(noloc), 'Good pixels'

#fill the rest in randomly
for iEmptyPix,pixelName in enumerate(noloc):
    row = random.randint(0,45)
    col = random.randint(0,43)
    while (ca[row,col] != ''):
        row = random.randint(0,45)
        col = random.randint(0,43)
    ca[row,col] = pixelName
        
    
#iEmptyPix = 0
#for row in xrange(46):
#    for col in xrange(44):
#        if ca[row,col] == '':
#            ca[row,col] = noloc[iEmptyPix]
#            iEmptyPix += 1
#h5file.flush()
h5file.close()
