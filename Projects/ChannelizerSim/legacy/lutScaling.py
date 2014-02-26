import numpy as np
import matplotlib.pyplot as plt
import math
import random

def freqCombLUT(fList, sampleRate=540e6, resolution=1e4):
    size = int(sampleRate/resolution)
    I = np.array([0.]*size)

    for f in fList:
        phase = random.uniform(-math.pi, math.pi)
        I = np.add(I, singleFreqLUT(f, sampleRate, resolution, phase))

    return I


def singleFreqLUT(f, sampleRate=540e6, resolution=1e4, phase=0):
	size = int(sampleRate/resolution)
	data = np.array([0.]*size)

	start_x = 2*np.pi*f/sampleRate+phase
	end_x = 2*np.pi*f*size/sampleRate+phase
	x = np.linspace(start_x, end_x, size)
	data = np.cos(x)

	return data




fs = 512e6
freqRes = 7812.5
N = 1024
amps = np.array([0]*N)
for j in range(N):
	freqs = np.array([i*(256e6/j)+random.uniform(-1,1)*5e4 for i in range(j)])
	I = freqCombLUT(freqs, fs, freqRes)
	a = I.max()
	amps[j] = a
	print j, a 

print 'done.'

np.savetxt('lut_amps.dat', amps)


fig = plt.figure()
ax0 = fig.add_subplot(111)
#ax0.plot(I, '.-')
ax0.plot(amps, '.-')


plt.show()
