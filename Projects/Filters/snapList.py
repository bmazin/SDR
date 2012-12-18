import glob
import os
import numpy as np

roaches = []
pixels = []
file = open('snap_list.txt','w')
path = '/Users/matt/Documents/mazin/filters/pulseData/20121204'
for snap in sorted(glob.glob(os.path.join(path,'*secs.dat'))):
    snap = os.path.basename(snap)

    roach = int(snap.split('r')[1].split('p')[0])
    pixel = int(snap.split('r')[1].split('p')[1].split('_')[0])
    file.write('%d %d\n'%(roach,pixel))
file.close()


