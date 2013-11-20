import glob
import numpy as np
import os

roaches = []
pixels = []
file = open('filter_list.txt','w')
path = '/Users/matt/Documents/mazin/filters/pulseData/20121204/'
for snap in sorted(glob.glob(os.path.join(path,'*NoiseSpectra26.dat'))):
    snap = os.path.basename(snap)
    print snap

    roach = int(snap.split('r')[1].split('p')[0])
    pixel = int(snap.split('r')[1].split('p')[1].split('N')[0])
    file.write('%d %d\n'%(roach,pixel))
file.close()


