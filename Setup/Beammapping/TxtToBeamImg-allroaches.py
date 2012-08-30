#!/usr/bin/env python
# encoding: utf-8
"""
TxtToBeamImg.py

Converts a text file to a beamimage h5 file

Created by Ben Mazin on 2011-07-17.
Copyright (c) 2011 . All rights reserved.
"""

import numpy as np
from tables import *

path = '/home/sean/data/20120828/beam/'
outfile = path + 'beamimage2.h5'
outfilePosKnown = path + 'posknownbeamimage.h5'

'''
#txtfile0 = path + 'pos_freq0.txt'
#txtfile1 = path + 'pos_freq1.txt'
#txtfile2 = path + 'pos_freq2.txt'
#txtfile3 = path + 'pos_freq3.txt'
'''

#numpy.fromfile(txtfile,dtype='float32',count=-1,sep=' ')

# make beamap group 
h5file = openFile(outfile, mode = "w")
bgroup = h5file.createGroup('/','beammap','Beam Map of Array')

Knownh5file = openFile(outfilePosKnown, mode = "w")
kbgroup = Knownh5file.createGroup('/','beammap','Beam Map of Array')

# make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
filt1 = Filters(complevel=0, complib='zlib', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (46,44), filters=filt1)  
resfreq = h5file.createCArray(bgroup, 'resfreq', Float32Atom(), (46,44), filters=filt1)  
atten = h5file.createCArray(bgroup, 'atten', Float32Atom(), (46,44), filters=filt1)  

kca = Knownh5file.createCArray(kbgroup, 'beamimage', StringAtom(itemsize=40), (46,44), filters=filt1)  
kresfreq = Knownh5file.createCArray(kbgroup, 'resfreq', Float32Atom(), (46,44), filters=filt1)  
katten = Knownh5file.createCArray(kbgroup, 'atten', Float32Atom(), (46,44), filters=filt1) 
# load of the text file with resonator data in it and use it to make the beamimage

noloc = []
overlaps = 0
for roachno in xrange(8):
    feedline=roachno/4+1
    count = 0
    f = open(path + 'r%d.pos'%roachno)
    
    for lines in f:
        numbers = lines.split()
        print numbers
        f0 = float(numbers[0])
        attenval = int(numbers[1])
        x = int(numbers[2])
        y = int(numbers[3])   

        if feedline == 2:
            x += 22
        pixelName = 'r%d/p%d/'%(roachno,count)
        print x,y,pixelName
        
        # if the pixel has a location put it in ca
        if x >= 0 and y >= 0 and x < 44 and y <46:
            if ca[y,x] != '':
                print 'overlapping pixels!'
                overlaps += 1
                noloc.append(pixelName)
            else:
                kca[y,x] = ca[y,x] = pixelName
                kresfreq[y,x] = resfreq[y,x] = f0
                katten[y,x] = atten[y,x] = attenval
                h5file.flush()
                Knownh5file.flush()
        else:
            noloc.append(pixelName)
        # if no location put it in the list of no locs
        count +=1        
    for i in xrange(count,253):
        pixelName = 'r%d/p%d/'%(roachno,count)
        noloc.append(pixelName)
        count += 1
        
    f.close()

# roach0: 16 <= x <= 31,  0 <= y <= 15
# roach1: 16 <= x <= 31, 16 <= y <= 31
# roach2:  0 <= x <= 15,  0 <= y <= 15
# roach3:  0 <= x <= 15, 16 <= y <= 31
    
    # now slot the ones with no location in randomly
#    print len(noloc),' resonators without a location.'
#    for i in xrange(len(noloc)):
#        bf=0
#        for j in xrange(16):
#            for k in xrange(16):
#                if ca[31-j-16*(roachno/2),k+16*(roachno%2)] == '':
#                    ca[31-j-16*(roachno/2),k+16*(roachno%2)] = '/r%d/p%d/' % (roachno,noloc[i])
##                    resfreq[x,y] = f0
##                    atten[x,y] = attenval
#                    h5file.flush()
#                    bf=1
#                    break
#            if bf==1:
#                break      
    # now go though and point the remaining empty slots at the first open slow

Knownh5file.flush()
Knownh5file.close()
    
print len(noloc),'Empty pixels'
print overlaps, 'Overlapping pixels'
print 46*44-len(noloc), 'Good pixels'
iEmptyPix = 0

for row in xrange(46):
    for col in xrange(44):
        if ca[row,col] == '':
            ca[row,col] = noloc[iEmptyPix]
            iEmptyPix += 1
h5file.flush()
h5file.close()
