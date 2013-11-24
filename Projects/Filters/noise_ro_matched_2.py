import random, math
import matplotlib.pyplot as mpl
import scipy.signal as signal
import numpy as np


def filter(x):
	steps = len(x)
	y = np.array([0.]*steps)
	y[0] = x[0]
	y[1] = x[1]
	tau = 10.
	omega = 1/1.5
	for i in range(2, steps):
		if i > steps/2:
			dO = 5./(i-steps/2)
			omega = 1/(1.5+dO)
		omega2 = omega**2
		d = 1+tau+1/omega2
		a1 = (tau + 2/omega2)/d
		a2 = (-1/omega2)/d
		b0 = (1+1/omega2)/d
		b1 = -2/omega2/d
		b2 = 1/omega2/d
		y[i] = a1*y[i-1] + a2*y[i-2] + b0*x[i] + b1*x[i-1] + b2*x[i-2]
	return y



samples = 600
sigma = .1

s = np.array([0.]*samples)
for i in range(samples):
	r = random.gauss(0,sigma)
	s[i] = r

s_mod = filter(s)

s_filt = []
for n in range(100, samples):
	s_filt.append(np.correlate(s_mod[n-100:n], s[n-100:n]))
	#s_filt.append(np.convolve(s_mod[n-100:n], s_mod[n:n-100:-1], 'valid'))


fig = mpl.figure()
ax0 = fig.add_subplot(111)
ax0.plot(s, '.-', s_mod, '.-', s_filt, '.-')
#ax0.semilogy(s_mod_f[0:L/2], '.')


mpl.show()

