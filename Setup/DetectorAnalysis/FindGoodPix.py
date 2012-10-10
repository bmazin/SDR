import tables
import numpy as np
import matplotlib.pyplot as plt
import math

#This program evaluates the functuality of each pixel in a single roach board.  Alter the time range to match a peak (look at qeroughplot.py to visualize the peaks).  The output is a sorted list of [average # of photons seen, pixel] View qe plots of the best pixels using qeplotforpixels.py

qeDataFilename= '/media/disk2/sci3gamma/qe_20120824-230828.h5' 
qeObsTime=1345874908

roach=4


NPixels=253

finish=[]
fid = tables.openFile(qeDataFilename,mode='r')

for pix in xrange(0,NPixels):
	temp=[]
	dataset=fid.getNode('/r%d/p%d/t%d'%(roach,pix,qeObsTime))
	for t in xrange(260,270):	
		temp.append(len(dataset[t])) 
	finish.append([int(np.average(temp)),pix])
print sorted(finish)
fid.close()
