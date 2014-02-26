
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

R = 100
#freqs = [i*1e5 + 6.0e6 for i in range(R)]
freqs = [i*1e4 + 6.0e6 for i in range(R*8)]

bin = []
bin_pfb8, bin_pfb9, bin_pfb10, bin_pfb11, bin_pfb12, bin_pfb13 = [], [], [], [], [], []
for f in freqs:
	print f
	signal = np.array([complex(math.cos(2*math.pi*f*t), math.sin(2*math.pi*f*t)) for t in time])
	y = pfb_fir(signal)

	bin_pfb8.append(np.fft.fft(y[0:512])[8])
	bin_pfb9.append(np.fft.fft(y[0:512])[9])
	bin_pfb10.append(np.fft.fft(y[0:512])[10])
	bin_pfb11.append(np.fft.fft(y[0:512])[11])
	bin_pfb12.append(np.fft.fft(y[0:512])[12])
	bin_pfb13.append(np.fft.fft(y[0:512])[13])

bin = np.array(bin)
bin_pfb8 = np.array(bin_pfb8)
bin_pfb9 = np.array(bin_pfb9)
bin_pfb10 = np.array(bin_pfb10)
bin_pfb11 = np.array(bin_pfb11)
bin_pfb12 = np.array(bin_pfb12)
bin_pfb13 = np.array(bin_pfb13)
freqs = np.array(freqs)/1e6

b = scipy.signal.firwin(20, cutoff=0.125, window="hanning")
w,h = scipy.signal.freqz(b,1, 4*R, whole=1)
h = np.array(h[2*R:4*R].tolist()+h[0:2*R].tolist())
#h = np.array(h[20:40].tolist()+h[0:20].tolist())
fir8 = np.array([0+0j]*R*8)
fir9 = np.array([0+0j]*R*8)
fir10 = np.array([0+0j]*R*8)
fir11 = np.array([0+0j]*R*8)
fir12 = np.array([0+0j]*R*8)

"""
fir8[0:32] = h[8:43]
fir9[0:40] = h
fir10[20:60] = h
fir11[33:73] = h
fir12[55:80] = h[0:25]
"""

fir8[0:320] = h[80:430]
fir9[0:400] = h
fir10[200:600] = h
fir11[330:730] = h
fir12[550:800] = h[0:250]

pp = PdfPages('fig4.pdf')

fig = plt.figure()
ax0 = fig.add_subplot(111)

#ax0.plot(freqs, abs(fir9), '.', freqs, abs(fir10), '.', freqs, abs(fir11), '.')

#ax0.plot(freqs, 10*np.log10(abs(bin_pfb8)/512), 'k-') 
#ax0.plot(freqs, 10*np.log10(abs(bin_pfb9)/512), 'k--') 
#ax0.plot(freqs, 10*np.log10(abs(bin_pfb10)/512), 'k-')
#ax0.plot(freqs, 10*np.log10(abs(bin_pfb11)/512), 'k-.')
#ax0.plot(freqs, 10*np.log10(abs(bin_pfb12)/512), 'k--')

ax0.plot(freqs, 10*np.log10(abs(fir8)*abs(bin_pfb8)/512), 'k-')
ax0.plot(freqs, 10*np.log10(abs(fir9)*abs(bin_pfb9)/512), 'k--')
ax0.plot(freqs, 10*np.log10(abs(fir10)*abs(bin_pfb10)/512), 'k-.')
ax0.plot(freqs, 10*np.log10(abs(fir11)*abs(bin_pfb11)/512), 'k:')
ax0.plot(freqs, 10*np.log10(abs(fir12)*abs(bin_pfb13)/512), 'k-')

ax0.set_xlabel('Frequency (MHz)')
ax0.set_ylabel('Gain (dB)')
ax0.set_ylim((-50,0))
#ax0.axvline(x = 10, linewidth=1, color='k')
pp.savefig()
pp.close()

plt.show()
