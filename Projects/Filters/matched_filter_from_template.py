import numpy
from scipy import *
from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math, struct


############################################################################################
#   some constants
###########################################################################################
size = 26 
sigma = 10



############################################################################################
#   Define noise correlation function.  For such a short filter, the noise is white, and the
#   noise is considered the same for all.
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
template = np.loadtxt('template.dat')
p = np.array(template)


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

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
	
fig = mpl.figure()
ax1 = fig.add_subplot(211)
ax1.plot(p[0,:], '.')
ax2 = fig.add_subplot(212)
ax1.plot(p[1,:], '.')
mpl.show()

