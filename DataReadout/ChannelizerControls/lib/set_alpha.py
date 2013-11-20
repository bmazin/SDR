import numpy as np
import corr
import time
import struct
import sys
from Utils.bin import *

roach = []
alpha = 0.08
out=castBin(alpha,quantization='Round')
for i in xrange(8):
    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%i,7147)
    time.sleep(.2)
    roach.write_int('capture_Baseline_alpha',out)
