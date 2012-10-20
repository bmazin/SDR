import tables
import numpy as np
import matplotlib.pyplot as plt
import math

#This program evaluates the functuality of each pixel in a single roach board.  Alter the time range to match a peak (look at qeroughplot.py to visualize the peaks).  The output is a sorted list of [average # of photons seen, pixel] View qe plots of the best pixels using qeplotforpixels.py

#qeDataFilename= '/home/sean/data/20121010/obs_20121010-215637.h5'
qeDataFilename= '/home/sean/data/20121018/obs_20121019-044657.h5'
#qeObsTime=1349906199
qeObsTime=1350622020
roach=5


NPixels=253

finish=[]
Final=[]
pixels=[]
fid = tables.openFile(qeDataFilename,mode='r')

for pix in xrange(0,NPixels):
	temp=[]
	dataset=fid.getNode('/r%d/p%d/t%d'%(roach,pix,qeObsTime))
	for t in xrange(316,324):	
		temp.append(len(dataset[t])) 
	finish.append([int(np.average(temp)),pix])
Final=sorted(finish)
print Final
for pix in xrange(0,len(Final)):
    Final[pix]=Final[pix][1]

print Final
fid.close()
