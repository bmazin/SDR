import numpy as np
import matplotlib.pyplot as plt

import scipy.ndimage as ndimage
from util.popup import PopUp,plotArray
import sys


footprint = np.array([[1,1,1],
                      [1,0,1],
                      [1,1,1]])

secondNeighborFootprint = np.array([[0,0,1,0,0],
                                    [0,0,0,0,0],
                                    [1,0,0,0,1],
                                    [0,0,0,0,0],
                                    [0,0,1,0,0]])

sideFootprint = np.array([[0,0,0],
                          [1,0,1],
                          [0,0,0]])

def addGradient(tile,slope=0.,angle=0.):
    nRows,nCols = np.shape(tile)
    xslope = slope*np.cos(angle)
    yslope = slope*np.sin(angle)
    xgrid,ygrid = np.meshgrid(xrange(nCols),xrange(nRows))
    gradVals = xslope*xgrid+yslope*ygrid
    #normalize
    gradVals -= np.mean(gradVals)
    #plotArray(gradVals,title='{} {}'.format(slope,angle))
    tileWithGrad = tile + gradVals
    return tileWithGrad


class neighborDistClass:
    def __init__(self, _array):
        # store the shape:
        self.shape = _array.shape
        self._array = _array
        # initialize the coordinates:
        self.coordinates = [0] * len(self.shape)

    def minFilter(self, buffer):
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

    def maxFilter(self, buffer):
        current = self._array[tuple(self.coordinates)]
        result = np.max(np.abs(current - buffer))
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

def countCollisions2(tile,minFreqSep):
    freqList = np.sort(np.reshape(tile,(-1,)))
    freqDists = np.diff(freqList)
    nCollisions = np.sum(freqDists<minFreqSep)
    return nCollisions

def countCollisions(tile,minFreqSep):
    freqList = np.sort(np.reshape(tile,(-1,)))
    binWidth = 0.5
    hist,binEdges = np.histogram(freqList,bins=(np.max(freqList)-np.min(freqList))/binWidth)
    #plt.plot(binEdges[0:-1],hist)
    #plt.show()
    hist[hist>=1] = hist[hist>=1] -1
    nCollisions = np.sum(hist)
    return nCollisions

def phaseMap(tile,nPhases,nSlopes,maxSlope=10,displayMap=False,minFreqSep=.5):
    phases = np.linspace(0.,2.*np.pi,nPhases)
    slopes = np.linspace(0.5,maxSlope,nSlopes)
    pmap = np.zeros((nSlopes,nPhases))
    for iSlope,slope in enumerate(slopes):
        if iSlope % 100 == 0:
            print iSlope
        for iPhase,phase in enumerate(phases):
            tileWithGrad = addGradient(tile,slope,phase)
            #plotArray(tileWithGrad,title='slope {} angle {}'.format(slope,phase))
            pmap[iSlope,iPhase] = countCollisions(tileWithGrad,minFreqSep=minFreqSep)

    percentMap = 100.*pmap/len(np.ravel(tile))
    print 'median unusable pixels (%) above slope {}: {}'.format(slopes[0],np.median(percentMap.ravel()))
    print 'sdev unusable pixels (%) above slope {}: {}'.format(slopes[0],np.std(percentMap.ravel()))
    print 'min,max unusable pixels (%) above slope {}: {} {}'.format(slopes[0],np.min(percentMap.ravel()),np.max(percentMap.ravel()))
    hist,binEdges = np.histogram(percentMap,bins=150)
    plt.plot(binEdges[0:-1],hist)
    plt.show()

    if displayMap:
        pop = PopUp(showMe=False)
        pop.plotArray(percentMap,cbarLabel='Unusable Pixels (%)')
        xticks = np.array(pop.axes.get_xticks(),dtype=np.int)
        yticks = np.array(pop.axes.get_yticks(),dtype=np.int)
        print xticks
        print yticks

        pop.axes.set_xticklabels(['{:.0f}'.format(phase*180./np.pi) for phase in phases[xticks[0:-1]]])
        pop.axes.set_yticklabels(['{:.1f}'.format(slope) for slope in slopes[yticks[0:-1]]])
        pop.axes.set_xlabel('Gradient Angle (${}^{\circ}$)')
        pop.axes.set_ylabel('Gradient Slope (MHz/pixel)')
        pop.axes.xaxis.tick_bottom()
        pop.show()
    return {'numberUnusablePixels':pmap,'gradientAnglesDeg':(phases*180./np.pi),'gradientSlopesMHz':slopes,'percentUnusable':percentMap}

def checkTile(tile,title=''):
    nRow,nCol= np.shape(tile)
    freqList = np.sort(np.reshape(tile,(-1,)))

    nearestDist = neighborDistClass(tile)
    minDists = ndimage.generic_filter(tile, nearestDist.minFilter, footprint=footprint,mode='constant',cval=np.inf)

    nearestDist = neighborDistClass(tile)
    minDists2 = ndimage.generic_filter(tile, nearestDist.minFilter, footprint=secondNeighborFootprint,mode='constant',cval=np.inf)

    nearestDist = neighborDistClass(tile)
    minDistsWrap = ndimage.generic_filter(tile, nearestDist.minFilter, footprint=sideFootprint,mode='wrap',cval=np.inf)

    nearestDist = neighborDistClass(tile)
    maxDists = ndimage.generic_filter(tile, nearestDist.maxFilter, footprint=footprint,mode='reflect')

    plotArray(title=title,image=tile,normNSigma=2.,origin='upper')
    plotArray(title='{} min dists wrap'.format(title),image=minDistsWrap,normNSigma=2.,origin='upper')
    plotArray(title='{} min dists'.format(title),image=minDists,normNSigma=2.,origin='upper')
    plotArray(title='{} min dists 2nd nearest'.format(title),image=minDists2,normNSigma=2.,origin='upper')
    plotArray(title='{} max dists'.format(title),image=maxDists,normNSigma=2.,origin='upper')

#    def f(thing):
#        thing.axes.hist(minDists.ravel(),bins=100)
#        thing.axes.set_title('{} min dists'.format(title))
#        
#    pop = PopUp(plotFunc=f)

    def f(thing):
        thing.axes.hist(minDists2.ravel(),bins=100)
        thing.axes.set_title('{} second neighbor min dists'.format(title))
        
    pop = PopUp(plotFunc=f)
    #fig,ax = plt.subplots(1,1)

#    fig,ax = plt.subplots(1,1)
#    ax.hist(maxDists.ravel(),bins=100)
#    ax.set_title('{} max dists'.format(title))

#top = np.loadtxt('d2_top.txt')
#bottom = np.loadtxt('d2_bottom.txt')
if __name__=='__main__':
    if len(sys.argv) > 1:
        tilePath = sys.argv[1]
    else:
        tilePath = 'top.txt'
    
    tile = np.loadtxt(tilePath)
    nRow,nCol= np.shape(tile)
    checkTile(tile,title='')
    #plotArray(tile,origin='upper')
    #phaseMap(tile,nSlopes=2000,nPhases=2000,maxSlope=30,displayMap=True)
    phaseMap(tile,nSlopes=300,nPhases=300,maxSlope=1.5,displayMap=True)


print 'done'
plt.show()
