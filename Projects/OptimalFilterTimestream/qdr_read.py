import numpy as np
import corr
import time
import struct
import matplotlib.pyplot as plt


roach = corr.katcp_wrapper.FpgaClient('10.0.0.11',7147)
time.sleep(2)
print 'connection established'

L=2**20
roach.write_int('startSnap',0)
time.sleep(0.1)
roach.write_int('startSnap',1)
time.sleep(5)
data = roach.read('qdr0_memory',4*L)
time.sleep(0.1)
roach.write_int('startSnap',0)
phase = struct.unpack('>%dI'%L,data)


fig=plt.figure()
ax=fig.add_subplot(111)
ax.plot(np.arange(len(phase)),phase)
plt.show()
