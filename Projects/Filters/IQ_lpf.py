from pylab import *

import scipy.signal as signal
import numpy


#Plot frequency and phase response
def mfreqz(b,a=1):
    w,h = signal.freqz(b,a, whole=1)
    h_dB = 20 * log10 (abs(h))
    subplot(111)
    plot(w/max(w), h_dB)
    #plot(w/max(w),h_dB)
    #ylim(-150, 5)
    ylabel('Magnitude (db)')
    xlabel(r'Normalized Frequency (x$\pi$rad/sample)')
    title(r'Frequency response')


sampleRate = 2.e6/1.024 #Hz a bit less than a 2 MHz
print 'sampleRate',sampleRate
nyquistFreq = sampleRate / 2.
print 'nyquist',nyquistFreq
desiredCutoff = 250.e3 #Hz


n = 20
#n = 20
b = signal.firwin(n, cutoff = desiredCutoff, nyq=nyquistFreq, window = "hanning")
mfreqz(b)


#n = 21
#c = signal.firwin(n, [.45, .55])
#mfreqz(c)

for i,c in enumerate(b):
    print c

#sig = numpy.array([0.19, -2.95]*13)
#print numpy.correlate(sig, b)

show()
