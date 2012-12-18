import numpy as np
import random

import matplotlib.pyplot as plt


############################################################################################
#   some constants
###########################################################################################
size = 800
sigma = 10
roachNum = 4
pixelNum = 0
savefile ='/Scratch/filterData/matched20121128.txt'
noisefile = '/Scratch/filterData/20121123/r%dp%dNoiseSpectra.dat'%(roachNum,pixelNum)



############################################################################################
#   Define noise covariance matrix.
#   The covariance function is the inverse FFT of the noise spectral density
############################################################################################
noiseSpectrum = np.loadtxt(noisefile)#Already in canonical order, resolution at 1250 Hzz
autocovariance = np.abs(np.fft.ifft(noiseSpectrum[:,1]))

sampledAutocovariance = autocovariance[0:size]
shiftingRow = np.concatenate((sampledAutocovariance[:0:-1],sampledAutocovariance))
covMatrix = []

for iRow in range(size):
    covMatrix.append(shiftingRow[size-iRow-1:size-iRow-1+size])

covMatrix = np.array(covMatrix)

covMatrixInv = np.linalg.inv(covMatrix)


#L = 2050    # just some big number to smooth C.
#C_avg = np.array([0.]*size)
#nf_avg = np.array([0.]*size)
#for m in range(L):
#    noise = [random.gauss(0, sigma) for i in range(size)]
#    C = np.correlate(noise, noise, 'full')/size
#    C_avg = C_avg + C[0:size]
#v = list(C_avg/L)
#b = []
#for i in range(size):
#        b.append(v[size-i-1:size] + [0]*(size-i-1))
#M_inv = np.array(b)
#M = np.linalg.inv(M_inv)
#
#L = int(1e6)
#noise = []
#for m in range(L):
#    noise.append([random.gauss(0, sigma) for i in range(size)])
#covM = np.cov(noise,rowvar=0)
#covMinv= np.linalg.inv(covM)


############################################################################################
#   Define pulse template.
############################################################################################
template = np.loadtxt('/Scratch/filterData/20121123/r%dp%dTemplate-2pass.dat'%(roachNum,pixelNum))
template = np.array(template)[900:900+800,1]
#template = np.array(template)[1000-5:1000-5+size,1]


############################################################################################
#   Define matched filter, g.
############################################################################################
plt.matshow(covMatrixInv)
plt.colorbar()

matched = np.dot(covMatrixInv,template)
#matched/=sum(matched)
matched /= np.max(matched)
print matched
np.savetxt(savefile,matched)

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
    
fig = plt.figure()
ax1 = fig.add_subplot(111)
ax1.plot(template)
ax1.plot(matched)
plt.show()

