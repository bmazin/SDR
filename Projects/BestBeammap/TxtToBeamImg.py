#!/usr/bin/env python
# encoding: utf-8
"""
TxtToBeamImg.py

Converts a text file to a beamimage h5 file
"""

import numpy as np
import random
from tables import *
import os

path = '/home/sean/data/20121115/'
outfile = path + 'sci4_beammap_left_good.h5'

# make beamap group 
h5file = openFile(outfile, mode = "w")
bgroup = h5file.createGroup('/','beammap','Beam Map of Array')

nRow = 46
nCol = 44

# make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
filt1 = Filters(complevel=0, complib='zlib', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (nRow,nCol), filters=filt1)  
resfreq = h5file.createCArray(bgroup, 'resfreq', Float32Atom(), (nRow,nCol), filters=filt1)  
atten = h5file.createCArray(bgroup, 'atten', Float32Atom(), (nRow,nCol), filters=filt1)  

# load of the text file with resonator data in it and use it to make the beamimage

noloc = []
overlaps = 0
nRoach = 8
nPixel = 253
nPixelsPerRoach = 253
posList = np.recfromtxt(path+'freq_atten_x_y-refined.txt')
posFreqList = posList['f0']
posAttenList = posList['f1']
xList = np.round(posList['f2'])
yList = np.round(posList['f3'])
pixelNames = posList['f4']

completePixelList = ['/r%d/p%d/'%(iRoach,iPixel) for iRoach in range(nRoach) for iPixel in range(nPixel)]
noloc = [pixel for pixel in completePixelList if not pixel in pixelNames]
for iPos,pixelName in enumerate(pixelNames):
    x = xList[iPos]
    y = yList[iPos]
    freq = posFreqList[iPos]
    attenval = posAttenList[iPos]
    print x,y,pixelName
    if x >= 0 and y >= 0 and x < nCol and y <nRow:
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
        
ca.flush()

placeUnbeammappedPixels = 0
#fill the rest in randomly
print len(pixelNames),'good pixels'

for iEmptyPix,pixelName in enumerate(noloc):
    row = random.randint(0,45)
    col = random.randint(0,43)
    while (ca[row,col] != ''):
        row = random.randint(0,45)
        col = random.randint(0,43)
    if placeUnbeammappedPixels == 0:
        pixelName = '/r0/p250/'
    ca[row,col] = pixelName
        
h5file.flush()
h5file.close()
print len(noloc),'Randomly placed pixels'
print overlaps, 'Overlapping pixels'
    
#iEmptyPix = 0
#for row in xrange(nRow):
#    for col in xrange(nCol):
#        if ca[row,col] == '':
#            ca[row,col] = noloc[iEmptyPix]
#            iEmptyPix += 1
