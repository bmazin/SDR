import numpy as np
import matplotlib.pyplot as plt

import scipy.ndimage as ndimage
from util.popup import PopUp,plotArray


footprint = np.array([[1,1,1],
                      [1,0,1],
                      [1,1,1]])


sideFootprint = np.array([[0,0,0],
                          [1,0,1],
                          [0,0,0]])
class nearestDistClass:
    def __init__(self, _array):
        # store the shape:
        self.shape = _array.shape
        self._array = _array
        # initialize the coordinates:
        self.coordinates = [0] * len(self.shape)

    def filter(self, buffer):
        current = self._array[tuple(self.coordinates)]
        result = np.min(np.abs(current - buffer))
        #print self.coordinates,current,buffer,result

        # calculate the next coordinates:
        axes = range(len(self.shape))
        axes.reverse()
        for jj in axes:
            if self.coordinates[jj] < self.shape[jj] - 1:
                self.coordinates[jj] += 1
                break
            else:
                self.coordinates[jj] = 0
        return result

top = np.loadtxt('top.txt')
bottom = np.loadtxt('bottom.txt')
nRow,nCol= np.shape(top)

topFreqs = np.sort(np.reshape(top,(-1,)))
bottomFreqs = np.sort(np.reshape(bottom,(-1,)))

topSweet = top[25:,:]
bottomSweet = bottom[0:15,:]
print np.shape(topSweet),np.shape(bottomSweet)
topSweetFreqs = np.sort(np.reshape(topSweet,(-1,)))
bottomSweetFreqs = np.sort(np.reshape(bottomSweet,(-1,)))

print np.min(topFreqs),np.max(topFreqs)
print np.min(bottomFreqs),np.max(bottomFreqs)
print np.min(topSweetFreqs),np.max(topSweetFreqs)
print np.min(bottomSweetFreqs),np.max(bottomSweetFreqs)


nearestDist = nearestDistClass(top)
topMinDists = ndimage.generic_filter(top, nearestDist.filter, footprint=footprint,mode='constant',cval=np.inf)
nearestDist = nearestDistClass(bottom)
bottomMinDists = ndimage.generic_filter(bottom, nearestDist.filter, footprint=footprint,mode='constant',cval=np.inf)
nearestDist = nearestDistClass(top)
topMinDistsWrap = ndimage.generic_filter(top, nearestDist.filter, footprint=sideFootprint,mode='wrap',cval=np.inf)
nearestDist = nearestDistClass(bottom)
bottomMinDistsWrap = ndimage.generic_filter(bottom, nearestDist.filter, footprint=sideFootprint,mode='wrap',cval=np.inf)

plotArray(title='top',image=topMinDistsWrap,normNSigma=2.)
plotArray(title='top',image=topMinDists,normNSigma=2.)
plotArray(title='top',image=top,normNSigma=2.)
plotArray(title='bottom',image=bottomMinDistsWrap,normNSigma=2.)
plotArray(title='bottom',image=bottomMinDists,normNSigma=2.)
plotArray(title='bottom',image=bottom,normNSigma=2.)

fig = plt.figure()
plt.hist(topMinDists,bins=100)
fig = plt.figure()
plt.hist(bottomMinDists,bins=100)
#
#fig = plt.figure()
#plt.plot(bottomFreqs,'.-')
#
#fig = plt.figure()
#plt.plot(topSweetFreqs)
#plt.plot(bottomSweetFreqs)

print 'done'
plt.show()
