#!/bin/python

import tables
import sys
import os
import glob
path = sys.argv[1]
for obs in glob.glob(os.path.join(path,'obs*.h5')):
    f=tables.openFile(obs,'r')
    hdr=f.root.header.header.read()
    print os.path.basename(obs)
    print hdr['localtime'][0]
    print hdr['description'][0]
    print ''
    f.close()



