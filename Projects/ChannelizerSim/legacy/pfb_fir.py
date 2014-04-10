import numpy as np
import matplotlib.pyplot as plt
import math
import random

samples = 512*8
#samples = 51200
L = samples/512
fs = 512e6
dt = 1/fs
time = [i*dt for i in range(samples)]

fig = plt.figure()
ax0 = fig.add_subplot(111)

def pfb_fir(x):
	L = len(x)
	P = 8
	N = 512
	bin_width_scale = 1.0
	dx = math.pi/N
	X = np.array([n*dx-P*math.pi/2 for n in range(P*N)])
	#coeff = np.sinc(bin_width_scale*X/math.pi)
	#coeff = np.sinc(bin_width_scale*X/math.pi)*np.hamming(P*N)
	
		
	y = np.array([0+0j]*N)

	for m in range(N):
		coeff_sub = coeff[m:m+(P-1)*N+1:N]
		y[m] = (x[m:m+(P-1)*N+1:N]*coeff_sub).sum()
	
	return y


freq = [8.005e6+i*0.04e6 for i in range(100)]
bin = []
bin_pfb = []

for f in freq:
	signal = np.array([complex(math.cos(2*math.pi*f*t), math.sin(2*math.pi*f*t)) for t in time])
	y = pfb_fir(signal)
	bin.append(np.fft.fft(signal[0:512])[10])
	bin_pfb.append(np.fft.fft(y[0:512])[10])

bin = np.array(bin)
bin_pfb = np.array(bin_pfb)

freqs = np.array(freq)/1e6

#fig = plt.figure()
#ax0 = fig.add_subplot(111)
#ax0.plot(bin_pfb, '.-')
ax0.semilogy(freqs, abs(bin), '.-', freqs, abs(bin_pfb), '.-')

#steps = 256*8
#dx = 8*math.pi/steps
#X = np.array([-4*math.pi+n*dx for n in range(steps)])
#coeff = np.sinc(X/math.pi)
#raw = np.array([(np.sin(x)/x) for x in X])
#raw = np.array([(math.sin(x)/x)*(1/2. + math.cos(x/1.)/2.) for x in X])

#ax1 = fig.add_subplot(212)
#ax1.plot(X, coeff, '.-')
#ax1.semilogy(bin_int, '.-')
#ax1.plot(signal_int[0:100].real, '.-', signal[0:100].real, '.-')
plt.show()
