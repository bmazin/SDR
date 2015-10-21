import numpy
import sys
from scipy import *
from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math


############################################################################################
#   some constants
###########################################################################################
#size = 50
size = 26
lifetime_us = int(sys.argv[1]) #microseconds
#size = 500
dt = 1.#us
lifetime = lifetime_us/dt
time = numpy.array([i*dt for i in range(size)])
sigma = 10.
savefile ='matched_%dus.txt' % lifetime

############################################################################################
#   Define noise correlation function
############################################################################################
L = 2050    # just some big number to smooth C.
C_avg = numpy.array([0.]*size)
nf_avg = numpy.array([0.]*size)
for m in range(L):
    noise = [random.gauss(0, sigma) for i in range(size)]
    C = numpy.correlate(noise, noise, 'full')/size
    C_avg = C_avg + C[0:size]
v = list(C_avg/L)
b = []
for i in range(size):
	b.append(v[size-i-1:size] + [0]*(size-i-1))
M_inv = numpy.array(b)
M = numpy.linalg.inv(M_inv)


############################################################################################
#   Define pulse template.
############################################################################################
p = []
for t in time:
	# ARCONS used 25 us time constant.
	#p.append(math.exp(-t/(25*dt)))
	p.append(math.exp(-t/(lifetime)))
p = numpy.array(p)
p = p/p.max()


############################################################################################
#   Define matched filter, g.
############################################################################################
den = numpy.dot(p, numpy.dot(M,p))
g = (numpy.dot(M,p)+numpy.dot(p,M))/(2*den)
print '[',
for G in g:
	print G, ',',
print ']'
print len(g)
numpy.savetxt(savefile,g)

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
############################################################################################
# Create a bunch of pulses and examine the statistics.
# Note, the convolution of the filter coefficients and the signal are done with
# "numpy.dot(g, signal)."  Also, the following assumes the arrival time is known.
############################################################################################
Amplitude = 50.
A, A_raw = [], []
for i in range(1000):
	noise = numpy.array([random.gauss(0, sigma) for i in range(size)])
	signal = noise + Amplitude*p
	A.append(numpy.dot(g, signal))
	A_raw.append(signal[0])

#np, bins_raw, patches_peaks = mpl.hist(A_raw, 50, normed=1, facecolor='blue', alpha=0.75)
n, bins_filtered, patches = mpl.hist(A, 50, normed=1, facecolor='green', alpha=0.75)
fig = mpl.figure()
ax1 = fig.add_subplot(211)
ax1.plot(bins_filtered)
#ax1.plot(bins_raw, bins_filtered)
ax2 = fig.add_subplot(212)
ax2.plot(p, '.')
ax3 = ax2.twinx()
ax3.plot(g,'r.')
#ax2.plot(signal.tolist()[250:500]+signal.tolist()[0:250], '.', g, '.', p, '.')
mpl.show()

