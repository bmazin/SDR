import os
import numpy as np

"""
write the roachConfig.txt file 
"""
datadir = os.environ['MKID_DATA_DIR']
# here is a list of the number of roaches per feed line
rpfList = np.array(os.environ['MKID_NROACHES'].split(),dtype=np.int)

outfile = os.path.join(datadir,'roachConfig.txt')
print "Now create ",outfile
roachConfigFile=open(outfile,'w') # start a fresh file each time (not append)

for iFeedLine in range(len(rpfList)):
    fn = "FL%d-lofreqs.txt"%(iFeedLine+1)
    print "iFeedLine=",iFeedLine," fn=",fn
    # np.loadtxt does not return a list if the file has only one line
    #fl=np.loadtxt(os.path.join(datadir,fn))
    file = open(os.path.join(datadir,fn))
    fl = file.readlines()
    for i,lo in enumerate(fl):
        roachConfigFile.write('%f\t 10\n'%float(lo))

roachConfigFile.close()
