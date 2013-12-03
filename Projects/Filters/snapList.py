import glob
import os
import numpy as np

roaches = []
pixels = []
path = '/Scratch/filterData/20131123/'
file = open(os.path.join(path,'snap_list.txt'),'w')
for snap in sorted(glob.glob(os.path.join(path,'*20secs.dat'))):
    snap = os.path.basename(snap)

    roach = int(snap.split('r')[1].split('p')[0])
    pixel = int(snap.split('r')[1].split('p')[1].split('_')[0])
    file.write('%d %d\n'%(roach,pixel))
file.close()


