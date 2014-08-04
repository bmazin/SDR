#!/usr/bin/env python
# encoding: utf-8

import numpy as np
from tables import *
import os
import ast
nRoachRows=int(os.environ['MKID_NROW'])
nRoachCols=int(os.environ['MKID_NCOL'])
roachMatrix = ast.literal_eval(os.environ['MKID_ROACH_MATRIX'])
#nRoachRows = 23
#nRoachCols = 11
#roachMatrix = np.array([[2,0,5,6],[3,1,4,7]])
path = os.environ['MKID_BEAMMAP_PATH']
print'beamimage at ',path
if os.path.exists(path):
    print "that file already exists so I quit"
    exit(1)
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
ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (nRoachRows,nRoachCols), filters=filt1)  

# load of the text file with resonator data in it and use it to make the beamimage

NCHANNELS_PER_ROACH=253
for iRoachRow,roachRow in enumerate(roachMatrix):
    for iRoachCol,roachCol in enumerate(roachRow):
        roach = roachCol

        for pixRow in range(nRoachRows):
            for pixCol in range(nRoachCols):
                x = iRoachCol*nRoachCols+pixCol
                y = iRoachRow*nRoachRows+pixRow
                pixel = (pixRow*nRoachCols+pixCol)%NCHANNELS_PER_ROACH
                name = '/r%d/p%d/' % (roach,pixel)
                ca[y,x]=name


h5file.flush()
np.set_printoptions(threshold=np.nan)
print ca.read()

h5file.close()
print 'Success:  done writing',path
