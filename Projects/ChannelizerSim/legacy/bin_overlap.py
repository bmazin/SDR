import numpy as np
import matplotlib.pyplot as plt
import math
import random
from matplotlib.backends.backend_pdf import PdfPages

samples = 51200
L = samples/512
fs = 512e6
dt = 1/fs
time = [i*dt for i in range(samples)]


def pfb_fir(x):
	N = len(x)
	T = 4
	L = 512
	bin_width_scale = 2.5
	dx = T*math.pi/L/T
	X = np.array([n*dx-T*math.pi/2 for n in range(T*L)])
	coeff = np.sinc(bin_width_scale*X/math.pi)*np.hanning(T*L)
	
	y = np.array([0+0j]*(N-T*L))
	for n in range((T-1)*L, N):
		m = n%L
		coeff_sub = coeff[L*T-m::-L]
		y[n-T*L] = (x[n-(T-1)*L:n+L:L]*coeff_sub).sum()
	
	return y


freqs = [i*1e5 + 6.01e6 for i in range(80)]

bin = []
bin_pfb8, bin_pfb9, bin_pfb10, bin_pfb11, bin_pfb12 = [], [], [], [], []
for f in freqs:
	signal = np.array([complex(math.cos(2*math.pi*f*t), math.sin(2*math.pi*f*t)) for t in time])
	y = pfb_fir(signal)

	bin_pfb8.append(np.fft.fft(y[0:512])[8])
	bin_pfb9.append(np.fft.fft(y[0:512])[9])
	bin_pfb10.append(np.fft.fft(y[0:512])[10])
	bin_pfb11.append(np.fft.fft(y[0:512])[11])
	bin_pfb12.append(np.fft.fft(y[0:512])[12])

bin = np.array(bin)
bin_pfb8 = np.array(bin_pfb8)
bin_pfb9 = np.array(bin_pfb9)
bin_pfb10 = np.array(bin_pfb10)
bin_pfb11 = np.array(bin_pfb11)
bin_pfb12 = np.array(bin_pfb12)
freqs = np.array(freqs)/1e6

pp = PdfPages('fig2.pdf')

fig = plt.figure()
ax0 = fig.add_subplot(111)
ax0.plot(freqs, 10*np.log10(abs(bin_pfb9)/512), 'k--') 
ax0.plot(freqs, 10*np.log10(abs(bin_pfb10)/512), 'ko-.', markersize=4.0)
ax0.plot( freqs, 10*np.log10(abs(bin_pfb11)/512), 'k:')
ax0.set_xlabel('Frequency (MHz)')
ax0.set_ylabel('Gain (dB)')
#ax0.axvline(x = 10, linewidth=1, color='k')
pp.savefig()
pp.close()

plt.show()
