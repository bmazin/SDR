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

############################################################################################
#   Define noise correlation function
############################################################################################
L = 2050    # just some big number to smooth C.
C_avg = numpy.array([0.]*size)
nf_avg = numpy.array([0.]*size)
for m in range(L):
    #n = [random.gauss(0, sigma) for i in range(2*size)]
    #noise = sim_utilities.lpf(n, 1e-5, 2e-6)[500:1000]
    noise = [random.gauss(0, sigma) for i in range(size)]
    C = numpy.correlate(noise, noise, 'full')/size
    C_avg = C_avg + C[0:size]
v = list(C_avg/L)

############################################################################################
#   Make M_inv out of <nn>.
############################################################################################
b = []
for i in range(size):
	b.append(v[size-i-1:size] + [0]*(size-i-1))
M_inv = numpy.array(b)
M = numpy.linalg.inv(M_inv)


############################################################################################
#   Make template pulse, p, with 50 us lifetime.
############################################################################################
p = []
for t in time:
	p.append(math.exp(-t/25e-6))
p = sim_utilities.lpf(p, 1e-5, 2e-6)
p = numpy.array(p)
p = p/p.max()

den = numpy.dot(p, numpy.dot(M,p))
g = (numpy.dot(M,p)+numpy.dot(p,M))/(2*den)
gf = numpy.fft.fft(g)

#print '[',
#for b in gf.imag:
#	print str(b) + ',',
#print ']'

fig = mpl.figure()
ax0 = fig.add_subplot(311)
ax0.plot(abs(gf)[0:250],'.')
ax1 = fig.add_subplot(312)
ax1.plot(gf.real[0:250],'.', gf.imag[0:250], '.')
ax2 = fig.add_subplot(313)
ax2.plot(p,'.')

mpl.show()

