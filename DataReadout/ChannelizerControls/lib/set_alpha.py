import numpy as np
import corr
import time
import struct
import sys
import os
from Utils.bin import *

roach = []
alpha = 0.08
out=castBin(alpha,quantization='Round')
for i in os.environ['MKID_ROACHES']:
    print 'in set_alpha.py:  roach ',i
    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%s'%i,7147)
    time.sleep(.2)
    try:
        roach.write_int('capture_Baseline_alpha',out)
    except:
        print 'ERROR writing alpha register'
