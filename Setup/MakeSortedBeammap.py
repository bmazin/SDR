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
import os

NROWS=46
NCOLS=44
path = os.environ['BEAMMAP_PATH']
print'beamimage at ',path
#outfile = path + 'sorted_beamimage%dx%d.h5'%(NROWS,NCOLS)

#numpy.fromfile(txtfile,dtype='float32',count=-1,sep=' ')

# make beamap group 
h5file = openFile(path, mode = "w")
if h5file < 0:
    print "ERROR creating file at ",path
    exit(-1)
bgroup = h5file.createGroup('/','beammap','Beam Map of Array')

# make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
filt1 = Filters(complevel=1, complib='zlib', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (NROWS,NCOLS), filters=filt1)  

# load of the text file with resonator data in it and use it to make the beamimage

NCHANNELS_PER_ROACH=253
for x in range(NCOLS):
    for y in range(NROWS):
        roach = (y*NCOLS+x)/NCHANNELS_PER_ROACH
        pixel = (y*NCOLS+x)%NCHANNELS_PER_ROACH
        ca[y,x]='/r%d/p%d/' % (roach,pixel)

h5file.flush()
print ca.read()

h5file.close()
print 'file closed'
