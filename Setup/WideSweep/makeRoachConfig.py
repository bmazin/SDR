import os
import numpy as np

datadir = os.environ['MKID_DATA_DIR']

fl1=np.loadtxt(os.path.join(datadir,'FL1-lofreqs.txt'))
fl2=np.loadtxt(os.path.join(datadir,'FL2-lofreqs.txt'))

outfile = os.path.join(datadir,'roachConfig.txt')

print datadir
print fl1,fl2

roachConfigFile=open(outfile,'a')

for i,lo in enumerate(fl1):
    roachConfigFile.write('%f\t 10\n'%lo)
for i,lo in enumerate(fl2):
    roachConfigFile.write('%f\t 10\n'%lo)
roachConfigFile.close()
