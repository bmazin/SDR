import random, math
import matplotlib.pyplot as mpl
import scipy.signal as signal
import numpy as np


def filter(x):
	y = np.array([0.+0j]*len(x))
	y[0] = x[0]
	y[1] = x[1]
	tau = 100.
	omega2 = (1/12.5)**2
	
	d = 1+tau+1/omega2
	a1 = (tau + 2/omega2)/d
	a2 = (-1/omega2)/d
	b0 = (1+1/omega2)/d
	b1 = -2/omega2/d
	b2 = 1/omega2/d
	for i in range(2, len(x)):
		y[i] = a1*y[i-1] + a2*y[i-2] + b0*x[i] + b1*x[i-1] + b2*x[i-2]
	return y


samples = 80000
sigma = .1

f_lo = 1/8.
f_s = 1/200.
lo = np.array([0.+0.j]*samples)
s = np.array([0.+0.j]*samples)
no = np.array([0.+0.j]*samples)
for i in range(samples):
	r = random.gauss(0,sigma)
	#r = random.uniform(0,2*np.pi)
	s[i] = complex(np.cos(2*np.pi*i*f_s), np.sin(2*np.pi*i*f_s))
	lo[i] = complex(np.cos(2*np.pi*i*f_lo+r), np.sin(2*np.pi*i*f_lo+r))

slo = s*lo

slo_mod = filter(slo)

#s_down = slo_mod*lo.conjugate()*s.conjugate()
s_down = slo*lo.conjugate()*s.conjugate()

phi = np.array([0.]*samples)
for i in range(samples):
	phi[i] = np.arctan2(s_down[i].imag, s_down[i].real)



s_f = abs(np.fft.fft(s))
lo_f = abs(np.fft.fft(lo))
slo_f = abs(np.fft.fft(slo))

slo_mod_f = abs(np.fft.fft(slo_mod))

s_down_f = abs(np.fft.fft(s_down))


fig = mpl.figure()
ax0 = fig.add_subplot(211)
#ax0.semilogy(s_down_f, '.')
ax0.semilogy(s_f, '.',lo_f, '.', slo_f, '.', s_down_f, '.')

ax1 = fig.add_subplot(212)
#ax1.plot(slo.real,'.-', slo_mod.real, '.-')
ax1.plot(s_down.real,'.', s_down.imag, '.')

mpl.show()

