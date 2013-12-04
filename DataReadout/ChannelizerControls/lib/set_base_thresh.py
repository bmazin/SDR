import numpy as np
import corr
import time
import struct
import sys
from Utils.bin import *

roach = []
alpha = 1.
out=castBin(alpha,quantization='Round',nBits=16,binaryPoint=13)
print out
for i in (0,1,2,3,4,5,6,7):
    print 'roach ',i
    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%i,7147)
    time.sleep(1)
    try:
        roach.write_int('capture_base_thresh',out)
    except:
        print 'error'
