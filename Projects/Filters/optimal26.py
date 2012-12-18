import numpy as np
import random

import matplotlib.pyplot as plt


############################################################################################
#   some constants
###########################################################################################
size = 26 
sigma = 10
roachNum = 4
pixelNum = 0
savefile ='/Scratch/filterData/optimal20121128.txt'
noisefile = '/Scratch/filterData/20121123/r%dp%dNoiseSpectra-new.dat'%(roachNum,pixelNum)

#load noise spectrum
noiseSpectrum = np.loadtxt(noisefile)[:,1]#Already in canonical order, resolution at 1250 Hzz
noiseSpectrum = noiseSpectrum[0:size]

#   Define pulse template.
template = np.loadtxt('/Scratch/filterData/20121123/r%dp%dTemplate-2pass-new.dat'%(roachNum,pixelNum))
offset=3
template = template[1000-offset:1000-offset+size,1]
templateSpectrum = np.fft.fft(template)
optimalSpectrum = templateSpectrum/noiseSpectrum
freqs = np.fft.fftfreq(size)
optimalNormalization = sum(abs(optimalSpectrum)**2/noiseSpectrum)
optimalSpectrum /= optimalNormalization
#plt.loglog(freqs,np.abs(noiseSpectrum),'-')
#plt.loglog(freqs,np.abs(templateSpectrum),'-')
#plt.loglog(freqs,np.abs(optimalSpectrum),'-')
#plt.show()
optimal = np.abs(np.fft.ifft(optimalSpectrum))
optimal/=np.sum(optimal)
print optimal

#template = np.array(template)[1000-5:1000-5+size,1]


np.savetxt(savefile,optimal)

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
    
fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.plot(optimal)
plt.show()

