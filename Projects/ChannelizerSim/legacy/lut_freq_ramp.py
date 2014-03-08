import pylab, numpy


sampleRate = 512e6
resolution = 7812.5
L = int(sampleRate/resolution)
P = 16

f_start = 11e6
f_end = 10e6
N = int(f_end/resolution)

a = sampleRate*(f_end - f_start)/L/(P-1)

print f_end-f_start, sampleRate*(f_end - f_start), L

amp = 32767.
freq = []

I, Q = numpy.array([0.]*P*L), numpy.array([0.]*P*L)
for n in range(P*L):
	if n < (P-1)*L:
		f = f_start + a*n/sampleRate/2
		da = n*amp/(P-1)/L
		I[n] = da*numpy.cos(2*numpy.pi*f*n/sampleRate)
		Q[n] = da*numpy.sin(2*numpy.pi*f*n/sampleRate)
		#I[n] = amp*numpy.cos(2*numpy.pi*f*n/sampleRate)
		#Q[n] = amp*numpy.sin(2*numpy.pi*f*n/sampleRate)
	else:
		f = f_start + a*(P-1)*L/sampleRate
		I[n] = amp*numpy.cos(2*numpy.pi*f*n/sampleRate+N*numpy.pi)
		Q[n] = amp*numpy.sin(2*numpy.pi*f*n/sampleRate+N*numpy.pi)
		#I[n] = amp*numpy.cos(2*numpy.pi*f*n/sampleRate+numpy.pi)
		#Q[n] = amp*numpy.sin(2*numpy.pi*f*n/sampleRate+numpy.pi)
	freq.append(f)
	
x = numpy.array([0+0j]*P*L)
for n in range(P*L):
	x[n] = complex(I[n], Q[n])

xf = numpy.fft.fft(x)
df = sampleRate/P/L
f = [i*df for i in range(P*L)]

pylab.semilogy(f[0:P*L/2], abs(xf)[0:P*L/2], '.')
#pylab.plot(Q, '.')
pylab.show()


