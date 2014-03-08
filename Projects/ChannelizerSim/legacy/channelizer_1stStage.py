import numpy as np
import matplotlib.pyplot as plt
import math
import random

fs = 512e6
freqRes = 7812.5
dt = 1/fs

f = 8.90e6

def pfb_fir(x):
	N = len(x)
	T = 4
	L = 512
	bin_width_scale = 2.5
	dx = T*math.pi/L/T
	X = np.array([n*dx-T*math.pi/2 for n in range(T*L)])
	coeff = np.sinc(bin_width_scale*X/math.pi)*np.hamming(T*L)
	
	y = np.array([0+0j]*(N-T*L))
	for n in range((T-1)*L, N):
		m = n%L
		coeff_sub = coeff[L*T-m::-L]
		y[n-T*L] = (x[n-(T-1)*L:n+L:L]*coeff_sub).sum()
	
	return y



 
###########################
# First stage and freq comb
###########################
lut_len = int(fs/freqRes)
time = [dt*i for i in range(lut_len)]
signal = np.array([complex(math.cos(2*math.pi*f*t), math.sin(2*math.pi*f*t)) for t in time])
samples = 4*lut_len
L = samples/512

y0 = pfb_fir(signal[0:samples-256])
y1 = pfb_fir(signal[256::])

bins = np.array([[0+0j]*200]*32)
for n in range(100):
	fft0 = np.fft.fft(y0[n*512:(n+1)*512])
	fft1 = np.fft.fft(y1[n*512:(n+1)*512])
	for i in range(512):
		if i%2 ==1:
			fft1[i] = -fft1[i]
	
	for m in range(1):
		bins[m,2*n] = fft0[10]
		bins[m,2*n+1] = fft1[10]

print abs(bins[0,0])

fig = plt.figure()
ax0 = fig.add_subplot(211)
ax0.plot(bins[0].real, '.-', bins[0].imag, '.-')

ax2 = fig.add_subplot(212)
ax2.plot(abs(np.fft.fft(bins[0])), '.-')

plt.show()
