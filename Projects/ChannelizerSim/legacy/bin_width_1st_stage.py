
import matplotlib.pyplot as plt
import scipy.signal
import numpy as np
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

R = 100/5
#freqs = [i*1e5 + 6.0e6 for i in range(R)]
freqs = [i*5e4 + 6.0e6 for i in range(R*8)]

bin = []
bin_pfb = []
for f in freqs:
	print f
	signal = np.array([complex(math.cos(2*math.pi*f*t), math.sin(2*math.pi*f*t)) for t in time])
	y = pfb_fir(signal)

	bin_pfb.append(np.fft.fft(y[0:512])[10])

bin = np.array(bin)
bin_pfb = np.array(bin_pfb)
freqs = np.array(freqs)/1e6

b = scipy.signal.firwin(20, cutoff=0.125, window="hanning")
w,h = scipy.signal.freqz(b,1, 4*R, whole=1)
h = np.array(h[2*R:4*R].tolist()+h[0:2*R].tolist())
#h = np.array(h[20:40].tolist()+h[0:20].tolist())


fig = plt.figure()
ax0 = fig.add_subplot(111)

#ax0.plot(freqs, abs(fir9), '.', freqs, abs(fir10), '.', freqs, abs(fir11), '.')

ax0.plot(freqs, 10*np.log10(abs(bin_pfb)/512), 'k-')


ax0.set_xlabel('Frequency (MHz)')
ax0.set_ylabel('Gain (dB)')
ax0.set_ylim((-50,0))
plt.show()
#ax0.axvline(x = 10, linewidth=1, color='k')
