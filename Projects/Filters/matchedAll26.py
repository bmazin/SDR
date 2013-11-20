import numpy as np
import random

import matplotlib.pyplot as plt


size = 26
finalSize = 26
sigma = 10
roachNum = 4
pixelNum = 0
pixelList = np.loadtxt('filter_list.txt')
fig = plt.figure()
ax1 = fig.add_subplot(111)
NRoach = 8
NPixel = 256
defaultMatched = np.loadtxt('/Users/matt/Documents/mazin/filters/turk/matched_30us.txt')
for roachNum in xrange(NRoach):
    allMatched = []
    savefile ='/Users/matt/Documents/mazin/filters/pulseData/20121204/matched26r%d.txt'%roachNum
    for pixelNum in xrange(NPixel):
        print roachNum,pixelNum 
        try:
            noisefile = '/Users/matt/Documents/mazin/filters/pulseData/20121204/r%dp%dNoiseSpectra26.dat'%(roachNum,pixelNum)

            #   Define noise covariance matrix.
            #   The covariance function is the inverse FFT of the noise spectral density
            noiseSpectrum = np.loadtxt(noisefile)#Already in canonical order, resolution at 1250 Hzz
            autocovariance = np.abs(np.fft.ifft(noiseSpectrum[:,1]))

            sampledAutocovariance = autocovariance[0:size]
            shiftingRow = np.concatenate((sampledAutocovariance[:0:-1],sampledAutocovariance))
            covMatrix = []

            for iRow in range(size):
                covMatrix.append(shiftingRow[size-iRow-1:size-iRow-1+size])

            covMatrix = np.array(covMatrix)
            covMatrixInv = np.linalg.inv(covMatrix)

            #   Define pulse template.
            template = np.loadtxt('/Users/matt/Documents/mazin/filters/pulseData/20121204/r%dp%dTemplate-2pass-new.dat'%(roachNum,pixelNum))
            initialOffset = 3
            template = np.array(template)[1000-initialOffset:1000-initialOffset+size,1]

            #   Define matched filter, g.
            #plt.matshow(covMatrixInv)
            #plt.colorbar()

            matched = np.dot(covMatrixInv,template)
            offset=3
            matched = matched[initialOffset-offset:initialOffset-offset+finalSize]
            matched/=sum(matched)
            if np.max(matched) > 2e-1:
                matched*=(1e-1/np.max(matched))
#            if np.max(matched[2:6]) <= 1.1*np.max([np.mean(matched[::2]),np.mean(matched[1::2]),np.mean(matched[::3]),np.mean(matched[1::3]),np.mean(matched[2::3])]):
#                print 'bad filter, setting to default'
#                matched = np.array(defaultMatched)
            #matched /= np.max(matched)
            allMatched.append(matched)
            plt.plot(matched)
            plt.show()
        except:
            print 'setting to default'
            matched = np.array(defaultMatched)
            allMatched.append(matched)


    allMatched = np.array(allMatched)
    print np.shape(allMatched)
    np.savetxt(savefile,allMatched)

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
    
plt.show()

