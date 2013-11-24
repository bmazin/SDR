import numpy
from scipy import *
from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math
import sim_utilities


############################################################################################
#   Important constants
###########################################################################################
size = 500
dt = 1.
time = numpy.array([i*dt for i in range(size)])
sigma = 10.


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
	p.append(math.exp(-t/(25*dt)))
p = numpy.array(p)
p = p/p.max()


############################################################################################
#   Define matched FIR (g), take the Fourier transform, fit for IIR coeffs.
############################################################################################
den = numpy.dot(p, numpy.dot(M,p))
g = (numpy.dot(M,p)+numpy.dot(p,M))/(2*den)
gf = numpy.fft.fft(g)
gf = numpy.array(gf[250:500].tolist()+gf[0:250].tolist())

df = 1/(size*dt)
freq = numpy.array([i*df-250*df for i in range(size)])
fitfunc = lambda p, x: (p[0]+p[1]*x**2)/((p[0]+p[1]*x**2)**2 + (p[2]*x+p[3]*x**3)**2)
errfunc = lambda p, x, y: fitfunc(p, x) - y
p0 = [0.5249, 79.19, -38.9, 199.9]
p1, success = optimize.leastsq(errfunc, p0[:], args=(freq, gf.real), maxfev=2000)
print p1
imagfitfunc = lambda p, x: (p[2]*x+p[3]*x**3)/((p[0]+p[1]*x**2)**2 + (p[2]*x+p[3]*x**3)**2)


############################################################################################
#   make fake data with a pulse and noise.
############################################################################################
p = []
L = 6*size
time = numpy.array([i*dt for i in range(L)])
for t in time:
	if t >= (L/2)*dt:
        	p.append(math.exp(-(t-(L/2)*dt)/(25*dt)))
	else:
        	p.append(0.)
p = numpy.array(p)
p = p/p.max()
noise = numpy.array([random.gauss(0, sigma) for i in range(L)])
Amplitude = 100.
signal = noise + Amplitude*p


###########################################################################################
#   Produce result of matched FIR
###########################################################################################
A_fir = []
for i in range(L-size):
	A_fir.append(numpy.dot(signal[i:size+i], g))

y = numpy.array([0.]*L)
for i in range(3, L):
	a0 = p1[0]+p1[1]+p1[2]+p1[3]
	a1 = -p1[1]-2*p1[2]-3*p1[3]
	a2 = p1[2]+3*p1[3]
	a3 = -p1[3]
	y[i] = (-a1*y[i-1]-a2*y[i-2]-a3*y[i-3]+10*signal[i])/a0
	#if i == 4:
		#print y[i], -a1*y[i-1], -a2*y[i-2], -a3*y[i-3], signal[i]
		#print a0, a1, a2, a3
print a0, a1, a2, a3


############################################################################################
#   Plot stuff.
############################################################################################
fig = mpl.figure()
ax0 = fig.add_subplot(311)
#ax0.plot(signal,'.', A_fir, '.', y, '.')
ax0.plot(signal,'.', A_fir, '.', y, '.')
ax1 = fig.add_subplot(312)
ax1.plot(gf.real,'.', gf.imag, '.')
ax2 = fig.add_subplot(313)
ax2.loglog(abs(gf)[250:500])

mpl.show()

