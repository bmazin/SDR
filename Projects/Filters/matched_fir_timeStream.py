import numpy
#from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math
import sim_utilities

############################################################################################
#   Important constants
###########################################################################################
size = 10
#size = 500
time = numpy.array([i*2e-6 for i in range(size)])
sigma = 10.
tau = 1e-4
############################################################################################
#   Define noise correlation function
############################################################################################
L = 1050    # just some big number to smooth C.
C_avg = numpy.array([0.]*size)
for n in range(L):
    noise = [random.gauss(0, sigma) for i in range(size)]
    C = numpy.correlate(noise, noise, 'full')/size
    C_avg = C_avg + C[0:size]

v = list(C_avg/L)

#Make M_inv out of noise correlation function.
b = []
for i in range(size):
	b.append(v[size-i-1:size] + [0]*(size-i-1))

M_inv = numpy.array(b)
M = numpy.linalg.inv(M_inv)


############################################################################################
#   make template pulse, p, with 50 us lifetime.
############################################################################################
tau_p = 1e-5
p_template = []
for t in time:
	p_template.append(math.exp(-t/100e-6))
	#p_template.append(math.exp(-t/50e-6))
p_template = numpy.array(p_template)
#p_template = numpy.array(sim_utilities.lpf(p_template, tau_p, 2e-6))
p_template = p_template/p_template.max()



############################################################################################
#   make fake data with a pulse and noise.
############################################################################################
p = []
L = 60*size
time = numpy.array([i*2e-6 for i in range(L)])
for t in time:
    if t >= (L/2)*2e-6:
        p.append(math.exp(-(t-(L/2)*2e-6)/50e-6))
    else:
        p.append(0.)
p = numpy.array(p)
#p = numpy.array(sim_utilities.lpf(p, tau_p, 2e-6))
p = p/p.max()

noise = numpy.array([random.gauss(0, sigma) for i in range(L)])
#noise = numpy.array([random.gauss(0, sigma) for i in range(2*L)])
#noise = sim_utilities.lpf(noise, tau, 2e-6)[L:2*L]
Amplitude = 100.
signal = noise + Amplitude*p


A = []
rawPeak = []
W = L-size
for i in range(L-size):
    num = 0.5*(numpy.dot(signal[i:size+i], numpy.dot(M,p_template))+numpy.dot(p_template, numpy.dot(M,signal[i:i+size])))
    den = numpy.dot(p_template, numpy.dot(M,p_template))
    A.append(num/den)
    #   find raw peak height for comparison.
    rawPeak.append(signal.max())

fig = mpl.figure()
ax0 = fig.add_subplot(311)
ax0.plot(signal)
ax1 = fig.add_subplot(312)
ax1.plot(sim_utilities.lpf(signal, 3e-4, 2e-6))
ax2 = fig.add_subplot(313)
ax2.plot(A)
mpl.show()

