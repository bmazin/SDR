import numpy as np
import corr
import time
import struct
import sys
from Utils.bin import *

roach = []
bOldBase = 0
criticalFreq = 200 #Hz
sampleRate = 1.e6
Q=.7

baseKf=2*np.sin(np.pi*criticalFreq/sampleRate)
baseKq=1./Q
#baseKf = .0012566369787 #fc=200 Hz
#baseKf = .0025132734614 #fc=400 Hz
#baseKf = .000628318520383 #fc=100 Hz
#baseKf = .000251327411626 #fc=40 Hz
#baseKf = .0251320797667  #fc=4000 Hz
#baseKf = 0.
#baseKf = 0.1
#baseKq = 1.4285714
binBaseKf=castBin(baseKf,quantization='Round',nBits=18,binaryPoint=16,format='uint')
binBaseKq=castBin(baseKq,quantization='Round',nBits=18,binaryPoint=16,format='uint')
print 'Kf:',baseKf,binBaseKf
print 'Kq:',baseKq,binBaseKq
print 'using old base:',bOldBase==1
roaches = os.environ['MKID_ROACHES']
for i in roaches:
    print 'in set_svf:  roach ',i
    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%s'%i,7147)
    time.sleep(.2)
    roach.write_int('capture_base_Kf',binBaseKf)
    roach.write_int('capture_base_Kq',binBaseKq)
