import numpy as np
import matplotlib.pyplot as plt
import math
import random, sim_utilities, mkid

fs = 512e6
freqRes = 7812.5
dt = 1/fs


def pfb_fir(x):
    N = len(x)
    T = 4
    L = 512
    bin_width_scale = 2.5
    dx = T*math.pi/L/T
    X = np.array([n*dx-T*math.pi/2 for n in range(T*L)])
    coeff = np.sinc(bin_width_scale*X/math.pi)*np.hamming(T*L)
    
    y = np.array([0+0j]*(N-T*L))
    for n in range((T-1)*L, N):
        m = n%L
        coeff_sub = coeff[L*T-m::-L]
        y[n-T*L] = (x[n-(T-1)*L:n+L:L]*coeff_sub).sum()
    
    return y


###########################
# First stage and freq comb
###########################
freqs = [i*1e6+random.uniform(-1e5,1e5) for i in range(9,12)]
print freqs
N = len(freqs)

I, Q = mkid.freqCombLUT(freqs, fs, freqRes, 2**15-1) 
lut_len = len(I)
samples = 4*lut_len
samples = 2*4*512
L = samples/512

signal = np.array([0+0j]*samples)
for i in range(samples):
    signal[i] = complex(I[i%lut_len], -Q[i%lut_len]) 

y0 = pfb_fir(signal[0:samples-256])
y1 = pfb_fir(signal[256::])


bins = np.array([[0+0j]*200]*N)
for n in range(100):
    # Calculate double fft
    fft0 = np.fft.fft(y0[n*512:(n+1)*512])
    fft1 = np.fft.fft(y1[n*512:(n+1)*512])
    # Perform freq-dependent phase shift
    for i in range(512):
        if i%2 == 1:
            fft1[i] = -fft1[i]
     
    for m in range(N):
        bins[m, 2*n] = fft0[m+1]
        bins[m, 2*n+1] = fft1[m+1]


#############################
# DDS signal for second stage
#############################
samples = 100*2
fs = 2e6
dt = 1/fs
time = [i*dt for i in range(samples)]

p = 0
mag = []
for n in range(N):
    f = +freqs[n]-int(round(freqs[n]/1e6))*1e6
    print f
    dds = np.array([complex(math.cos(2*math.pi*f*t+p), math.sin(2*math.pi*f*t+p)) for t in time])
    y = dds*bins[n].conjugate()
    mag.append(abs(y[samples-50:samples].mean()))

fig = plt.figure()
ax0 = fig.add_subplot(211)
#ax0.plot(bins[0,:].real, '.-', bins[1,:].real, '.-', bins[2,:].real, '.-', bins[3,:].real, '.-')
ax0.plot(dds.real, '.-', dds.imag, '.-')


ax1 = fig.add_subplot(212)
#ax1.plot(I[0:512], '.-', I[256:768], '.-')
#ax1.plot(signal[0:512].real, '.-', signal[256:768].real, '.-')
ax1.semilogy(mag, '.-')
#ax1.semilogy(abs(fft0), '.-', abs(fft1), '.-')

plt.show()
