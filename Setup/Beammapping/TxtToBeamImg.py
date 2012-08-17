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

path = '/Users/Paul/Desktop/Schoolwork/UCSB/Research/Sweep_2012-08-15/'
outfile = path + 'beamimage.h5'

'''
txtfile0 = path + 'pos_freq0.txt'
txtfile1 = path + 'pos_freq1.txt'
txtfile2 = path + 'pos_freq2.txt'
txtfile3 = path + 'pos_freq3.txt'
'''

#numpy.fromfile(txtfile,dtype='float32',count=-1,sep=' ')

# make beamap group 
h5file = openFile(outfile, mode = "w")
bgroup = h5file.createGroup('/','beammap','Beam Map of Array')

# make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
filt1 = Filters(complevel=0, complib='blosc', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (32,32), filters=filt1)  
resfreq = h5file.createCArray(bgroup, 'resfreq', Float32Atom(), (32,32), filters=filt1)  
atten = h5file.createCArray(bgroup, 'atten', Float32Atom(), (32,32), filters=filt1)  

# load of the text file with resonator data in it and use it to make the beamimage

for roachno in xrange(1):
    count = 0
    noloc = []
    f = open(path + 'freq_atten_x_y.txt')
    
    for lines in f:
        numbers = lines.split()
        print numbers
        f0 = float(numbers[0])
        attenval = int(numbers[1])
        x = int(numbers[2])
        y = int(numbers[3])    
        
        # if the pixel has a location put it in ca
        if x >= 0 and y >= 0:
            ca[x,y] = '/r%d/p%d/' % (roachno,count)
            resfreq[x,y] = f0
            atten[x,y] = attenval
            h5file.flush()
        # if no location put it in the list of no locs
        else:
            noloc.append(count)        
        count +=1        
    f.close()

# roach0: 16 <= x <= 31,  0 <= y <= 15
# roach1: 16 <= x <= 31, 16 <= y <= 31
# roach2:  0 <= x <= 15,  0 <= y <= 15
# roach3:  0 <= x <= 15, 16 <= y <= 31
    
    # now slot the ones with no location in randomly
    print len(noloc),' resonators without a location.'
    for i in xrange(len(noloc)):
        bf=0
        for j in xrange(16):
            for k in xrange(16):
                if ca[31-j-16*(roachno/2),k+16*(roachno%2)] == '':
                    ca[31-j-16*(roachno/2),k+16*(roachno%2)] = '/r%d/p%d/' % (roachno,noloc[i])
#                    resfreq[x,y] = f0
#                    atten[x,y] = attenval
                    h5file.flush()
                    bf=1
                    break
            if bf==1:
                break      
    # now go though and point the remaining empty slots at the first open slow
    for i in xrange(256-count):
        bf=0
        for j in xrange(16):
            for k in xrange(16):
                if ca[31-j-16*(roachno/2),k+16*(roachno%2)] == '':
                    ca[31-j-16*(roachno/2),k+16*(roachno%2)] = '/r%d/p%d/' % (roachno,i+count)
                    h5file.flush()
                    bf=1
                    break
            if bf==1:
                break      
'''
for i in xrange(16):
    print ca[i,31]
'''
    

h5file.close()
