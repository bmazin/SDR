import numpy as np
import matplotlib.pyplot as plt
import struct
import os

def parseQDRPhaseSnap(folder, roachNum=0, pixelNum=0, steps=60):
    path = os.path.join(folder,'ch_snap_r%dp%d_%dsecs.dat'%(roachNum, pixelNum, steps))
    phaseFile = open(path, 'r')
    phase = phaseFile.read()
    phaseVals = struct.unpack('>{}h'.format(len(phase)/2),phase)
    phaseVals = np.array(phaseVals, dtype=np.float)*360./2**16*4/np.pi
    return phaseVals
