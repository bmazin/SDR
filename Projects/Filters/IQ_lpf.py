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



#Lowpass FIR filter 
#figure(1)
#n = 11
#a = signal.firwin(n, cutoff = .00390625, window = "hanning")
#mfreqz(a)

n = 16
#n = 20
b = signal.firwin(n, cutoff = .125, window = "hanning")
mfreqz(b)


#n = 21
#c = signal.firwin(n, [.45, .55])
#mfreqz(c)

for i,c in enumerate(b):
    print i,c

#sig = numpy.array([0.19, -2.95]*13)
#print numpy.correlate(sig, b)

show()
