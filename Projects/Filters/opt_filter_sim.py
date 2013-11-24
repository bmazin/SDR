import numpy
#from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math
import sim_utilities

############################################################################################
#   Important constants
###########################################################################################
size = 500
time = numpy.array([i*2e-6 for i in range(size)])
sigma = 10.
tau = 1e-4
############################################################################################
#   Define noise correlation function
############################################################################################
L = 1050    # just some big number to smooth C.
C_avg = numpy.array([0.]*999)
for n in range(L):
    noise = [random.gauss(0, sigma) for i in range(size)]
    noise = sim_utilities.lpf(noise, tau, 2e-6)
    C = numpy.correlate(noise, noise, 'full')/size
    C_avg = C_avg + C

v = list(C_avg[0:500]/L)
#mpl.plot(v)
#mpl.show()
#Make M_inv out of noise correlation function.
b = []
for i in range(size):
	b.append(v[size-i-1:size] + [0]*(size-i-1))

M_inv = numpy.array(b)
M = numpy.linalg.inv(M_inv)


############################################################################################
#   make template pulse, p, with 50 us lifetime.
############################################################################################
p = []
for t in time:
    if t >= 250*2e-6:
        p.append(math.exp(-(t-250*2e-6)/(0.1*250*2e-6)))
    else:
        p.append(0.)
p = numpy.array(sim_utilities.lpf(p, 2e-6, 2e-6))
p = p/p.max()

A = []
rawPeak = []
Amplitude = 5.0
for i in range(1):
    #   make noise, n.
    noise = numpy.array([random.gauss(0, sigma) for i in range(2*size)])
    noise = sim_utilities.lpf(noise, tau, 2e-6)[size:2*size]

    #   make measured signal, s = Ap + n.
    signal = noise + Amplitude*p

    num = 0.5*(numpy.dot(signal, numpy.dot(M,p))+numpy.dot(p, numpy.dot(M,signal)))
    den = numpy.dot(p, numpy.dot(M,p))
    A.append(num/den)
    #   find raw peak height for comparison.
    rawPeak.append(signal.max())

y = (numpy.dot(M,p)+numpy.dot(p,M))/(2*den)
yf = numpy.fft.fft(numpy.dot(M,p))
nf = numpy.fft.fft(v)
#np, bins_peaks, patches_peaks = mpl.hist(rawPeak, 50, normed=1, facecolor='blue', alpha=0.75)
#n, bins, patches = mpl.hist(A, 50, normed=1, facecolor='green', alpha=0.75)

fig = mpl.figure()
ax0 = fig.add_subplot(211)
#ax0.plot(yf.real,'-', yf.imag, '-')
ax0.plot(abs(yf),'.')
#ax0.plot(bins_peaks, bins)
ax1 = fig.add_subplot(212)
ax1.plot(abs(nf),'.')
#ax1.plot(p,'.-', signal, '.')
mpl.show()

