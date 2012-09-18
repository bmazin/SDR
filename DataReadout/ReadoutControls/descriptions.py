#!/bin/python

import tables
import sys
import os
import glob
obsPath = sys.argv[1]
for obs in sorted(glob.glob(os.path.join(obsPath,'obs*.h5'))):
    f=tables.openFile(obs,'r')
    try:
        hdrNode = f.getNode('/header/header')
        hdr=hdrNode.read()
        print 'Filename: ',os.path.basename(obs)
        print 'Target: ',hdr['target'][0]
        print 'Local time: ',hdr['localtime'][0]
        print 'UTC: ',hdr['utc'][0]
        print 'Description: ',hdr['description'][0]
        print 'Filter: ',hdr['filt'][0]
        print 'Exposure Time: ',hdr['exptime'][0]
        print ''
        f.close()
    except ValueError:
        print os.path.basename(obs)
        print 'No Header'
    except tables.exceptions.HDF5ExtError:
        print os.path.basename(obs)
        print 'Can\'t Read Header Data'



