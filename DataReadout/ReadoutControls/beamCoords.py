import tables
import numpy as np
import os
import sys

if len(sys.argv) == 2:
    beamFilename = os.getenv('BEAMMAP_PATH')
elif len(sys.argv) == 3:
    beamFilename = sys.argv[2]
else:
    print 'Usage: %s pixelName [beammapPath]'%(sys.argv[0])

beamFile = tables.openFile(beamFilename)
beammap = beamFile.root.beammap.beamimage.read()
print np.where(beammap==sys.argv[1])
beamFile.close()
