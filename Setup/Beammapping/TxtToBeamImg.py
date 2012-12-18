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

#path = '/home/sean/data/20121202/'
path='/home/sean/SDR/Projects/BestBeammap/'
outfile = path + 'sci4_beammap_palomar.h5'
placeUnbeammappedPixels = 0

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
posList = np.recfromtxt(path+'freq_atten_x_y_swap-Sorted.txt')
posListRefined = np.loadtxt(path+'freq_atten_x_y-PalSwap.txt')
#posList = posList[np.logical_or(np.array([name[2] for name in pixelNames])=='0', np.array([name[2] for name in pixelNames])=='1')]#pick out positions for roach 4
#posFreqList = posList['f0']
#posAttenList = posList['f1']
#xList = np.round(posList['f2'])
#yList = np.round(posList['f3'])
posFreqList = posListRefined[:,0]
posAttenList = posListRefined[:,1]
xList = posListRefined[:,2]
yList = posListRefined[:,3]
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
print len(noloc),'Unplaced pixels'
print overlaps, 'Overlapping pixels'
    
#iEmptyPix = 0
#for row in xrange(nRow):
#    for col in xrange(nCol):
#        if ca[row,col] == '':
#            ca[row,col] = noloc[iEmptyPix]
#            iEmptyPix += 1

#smartfill = False
#if smartfill == True:
#    xOnlyPosList = np.recfromtxt(path+'good_x_right.txt')
#    xOnlyFreqList = xOnlyPosList['f0']
#    xOnlyAttenList = xOnlyPosList['f1']
#    xOnlyXList = xOnlyPosList['f2']
#    xOnlyPixelNames = xOnlyPosList['f4']
#
#    yOnlyPosList = np.recfromtxt(path+'good_y_right.txt')
#    yOnlyFreqList = yOnlyPosList['f0']
#    yOnlyAttenList = yOnlyPosList['f1']
#    yOnlyYList = yOnlyPosList['f3']
#    yOnlyPixelNames = yOnlyPosList['f4']
#
#print ''
#print 'now x only pixels'
#for iPos,pixelName in enumerate(xOnlyPixelNames):
#    x = xOnlyXList[iPos]
#    freq = xOnlyFreqList[iPos]
#    attenval = xOnlyFreqList[iPos]
#    print x,pixelName,
#    if x >=0 and x < nCol:
#        possibleY = np.where(ca[:,x] == '')[0]
#        if len(possibleY) > 0:
#            y = possibleY[0]
#            ca[y,x] = pixelName
#            atten[y,x] = attenval
#            resfreq[y,x] = freq
#            h5file.flush()
#            print 'placed at ',y
#        else:
#            print ''
#            print 'Nowhere at x to place it'
#            overlaps += 1
#            noloc.append(pixelName)
#    else:
#        print ''
#        print 'Pixel location out of bounds'
#        noloc.append(pixelName)
#
#
#print 'now y only pixels'
#for iPos,pixelName in enumerate(yOnlyPixelNames):
#    y = yOnlyYList[iPos]
#    freq = yOnlyFreqList[iPos]
#    attenval = yOnlyFreqList[iPos]
#    print y,pixelName,
#    if y >=0 and y < nRow:
#        possibleX = np.where(ca[y,:] == '')[0]
#        if len(possibleX) > 0:
#            x = possibleX[0]
#            ca[y,x] = pixelName
#            atten[y,x] = attenval
#            resfreq[y,x] = freq
#            h5file.flush()
#            print 'placed at ',x
#        else:
#            print ''
#            print 'Nowhere at y to place it'
#            overlaps += 1
#            noloc.append(pixelName)
#    else:
#        print ''
#        print 'Pixel location out of bounds'
#        noloc.append(pixelName)
##fill the rest in randomly
#for iEmptyPix,pixelName in enumerate(noloc):
#    row = random.randint(0,45)
#    col = random.randint(0,43)
#    while (ca[row,col] != ''):
#        row = random.randint(0,45)
#        col = random.randint(0,43)
#    if placeUnbeammappedPixels == 0:
#        pixelName = '/r0/p250/'
#    ca[row,col] = pixelName
#
#h5file.flush()
#h5file.close()
#print len(pixelNames),'good pixels'
#print len(xOnlyPixelNames),'x only pixels'
#print len(yOnlyPixelNames),'y only pixels'
#print len(noloc),'Unbeammpped pixels'
#print overlaps, 'Overlapping pixels'
