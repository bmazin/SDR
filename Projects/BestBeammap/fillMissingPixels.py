import numpy as np
import os
import matplotlib.pyplot as plt
import random
from arrayPopup import plotArray

#oldPath = '/mnt/data0/Darkness/20160722/beammap20160722.txt'
oldPath = 'adjusted_beammap.txt'
newPath = 'filledBeammap20160722.txt'

psBasePath = '/mnt/data0/Darkness/20160722/'
fl1Paths = ['ps_FL1_a_full.txt','ps_FL1_b_full.txt']
fl2Paths = ['ps_FL2_a_full.txt','ps_FL2_b_full.txt']
fl3Paths = ['ps_FL3_a_full.txt','ps_FL3_b_full.txt']

oldBeammap = np.loadtxt(oldPath)

goodResIds = oldBeammap[:,0]

nPixels = 10000
allResIds = np.arange(nPixels)

nRowsPerFeedline = 25
nRows = 125
nCols = 80
nFeedlines = 3

fls = []
fl1a = np.loadtxt(os.path.join(psBasePath,fl1Paths[0]))
fl1b = np.loadtxt(os.path.join(psBasePath,fl1Paths[1]))
fls.append(np.concatenate([fl1a,fl1b]))
fl2a = np.loadtxt(os.path.join(psBasePath,fl2Paths[0]))
fl2b = np.loadtxt(os.path.join(psBasePath,fl2Paths[1]))
fls.append(np.concatenate([fl2a,fl2b]))
fl3a = np.loadtxt(os.path.join(psBasePath,fl3Paths[0]))
fl3b = np.loadtxt(os.path.join(psBasePath,fl3Paths[1]))
fls.append(np.concatenate([fl3a,fl3b]))

allResIds = np.concatenate(fls)[:,0]


grid = np.zeros((nRows,nCols))

newBeammapRows = []
for iFeedline in range(nFeedlines):

    for iPixel,pixel in enumerate(oldBeammap):
        rid,fail,x,y,feedline = pixel
        if y < 0:
            print pixel,rid,fail,x,y,feedline
        grid[y,x] = 1

    badResMask = np.array([not (rid in goodResIds) for rid in fls[iFeedline][:,0]],dtype=np.bool)
    badResIds = fls[iFeedline][badResMask,0]

    for rid in badResIds:
        #make a random assignment, then check if it's taken
        assignRow = random.randint(iFeedline*nRowsPerFeedline,(iFeedline+1)*nRowsPerFeedline-1)
        assignCol = random.randint(0,nCols-1)
        while (grid[assignRow,assignCol] != 0):
            assignRow = random.randint(iFeedline*nRowsPerFeedline,(iFeedline+1)*nRowsPerFeedline-1)
            assignCol = random.randint(0,nCols-1)
        grid[assignRow,assignCol] = 2
        fail = 1 #randomly assigning a pixel, so certainly a failed bemmap pixel
        newBeammapRows.append([rid,1,assignCol,assignRow,iFeedline])
    print 'finished assignments for feedine',iFeedline
plotArray(grid,origin='upper')

newBeammap = np.concatenate([oldBeammap,newBeammapRows])
np.savetxt(newPath,newBeammap,fmt='%d\t%d\t%d\t%d\t%d')



        






