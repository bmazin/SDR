import numpy as np
import matplotlib.pyplot as plt

import scipy.ndimage as ndimage
from util.popup import plotArray

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

class FreqMapTile:
    def __init__(self,nRows,nCols,startFreq,bandwidth,verbosity=0,name=''):
        self.nRows = nRows
        self.nCols = nCols
        self.nFreqs = self.nRows*self.nCols
        self.shape = (nRows,nCols)
        self.startFreq = startFreq
        self.bandwidth = bandwidth
        self.constraints = []
        self.freqHoles = []
        self.verbosity = verbosity
        self.name = name
        self.minNeighborSeparation = 0
        self.minSecondNeighborSeparation = 0
        self.maxNeighborSeparation = np.inf

    def addFreqHole(self,holeWidth,holeCenter):
        holeLowerBound = holeCenter - holeWidth/2.
        holeUpperBound = holeCenter + holeWidth/2.
        self.freqHoles.append((holeLowerBound,holeUpperBound))
        
    def makeFreqList(self):
        availableBandwidth = self.bandwidth
        for holeLowerBound,holeUpperBound in self.freqHoles:
            availableBandwidth -= (holeUpperBound - holeLowerBound)
        #bandwidthPerFreq  = availableBandwidth / (self.nFreqs-2) #why -2?
        bandwidthPerFreq  = availableBandwidth / (self.nFreqs-1)
        self.freqList = np.zeros(self.nFreqs)
        currentFreq = self.startFreq
        for iFreq in xrange(self.nFreqs):
            for holeLowerBound,holeUpperBound in self.freqHoles:
                if holeLowerBound < currentFreq and currentFreq < holeUpperBound:
                    #we already stepped bandwidthPerFreq, undo that and instead step
                    #the width of the hole
                    currentFreq += (holeUpperBound-holeLowerBound)-bandwidthPerFreq
            self.freqList[iFreq] = currentFreq
            currentFreq += bandwidthPerFreq
            
        if self.verbosity >= 1:
            print 'built freq list'
            print 'freq holes:',self.freqHoles
            print 'start freq',self.startFreq
            print 'stop freq',np.max(self.freqList)
            print 'num freqs',len(self.freqList)
        if self.verbosity >= 2:
            print 'freq list:',self.freqList

    def addConstraint(self,constraint):
        self.constraints.append(constraint)

    def __getitem__(self,key):
        return self.freqTable[key]

    def checkPlacement(self,valToPlace,row,col):
        #relative indices for the cells immediately surrounding row,col
        dr = np.array([-1,-1,-1,0,0,1,1,1])
        dc = np.array([-1,0,1,-1,1,-1,0,1])
        dr2 = np.array([-2,0,0,2])
        dc2 = np.array([0,-2,2,0])

        rowIndices = row+dr
        colIndices = col+dc
        rowIndices2 = row+dr2
        colIndices2 = col+dc2

        #dr = dr % self.nRows
        colIndices = colIndices % self.nCols #wrap around right and left edge as needed
        validRowIndices = (0 <= rowIndices) & (rowIndices < self.nRows)
        validRowIndices2 = (0 <= rowIndices2) & (rowIndices2 < self.nRows) & (0 <= colIndices2) & (colIndices2 < self.nCols)
        if np.any(validRowIndices == 0):
            colIndices = colIndices[validRowIndices]
            rowIndices = rowIndices[validRowIndices]
        if np.any(validRowIndices2 == 0):
            colIndices2 = colIndices2[validRowIndices2]
            rowIndices2 = rowIndices2[validRowIndices2]

        neighborVals = self.freqTable[rowIndices,colIndices]
        neighborVals2 = self.freqTable[rowIndices2,colIndices2]
        neighborDists = np.abs(neighborVals - valToPlace)
        neighborDists2 = np.abs(neighborVals2 - valToPlace)
        distsInRange = np.all((self.minNeighborSeparation < neighborDists) & (neighborDists < self.maxNeighborSeparation)) and np.all(self.minSecondNeighborSeparation < neighborDists2)
        return distsInRange
        
    def runSwaps(self,nSwaps):
        for iSwap in xrange(nSwaps):
            if iSwap % 1000 == 0:
                print iSwap,' of',nSwaps
            goodPlacement = False
            while not goodPlacement:
                firstRow,firstCol = (np.random.randint(0,self.nRows),np.random.randint(0,self.nCols))
                secondRow,secondCol = (np.random.randint(0,self.nRows),np.random.randint(0,self.nCols))
                firstVal = self.freqTable[firstRow,firstCol]
                secondVal = self.freqTable[secondRow,secondCol]
                goodPlacement = self.checkPlacement(firstVal,secondRow,secondCol) and self.checkPlacement(secondVal,firstRow,firstCol)
                if goodPlacement:
                    self.freqTable[firstRow,firstCol] = secondVal
                    self.freqTable[secondRow,secondCol] = firstVal
            
        
    def findLayoutSolution(self):
        self.makeFreqList()
        idxStep = np.searchsorted(self.freqList,self.startFreq+self.minNeighborSeparation)+1

        idxTable = np.array([[iRow*self.nCols+iCol for iCol in xrange(self.nCols)] for iRow in xrange(self.nRows)])

        idxTable = (idxTable*idxStep) % self.nFreqs


        #make sure all the frequencies will be represented
        assert np.all(np.sort(np.ravel(idxTable)) == np.arange(self.nFreqs))
        
        self.freqTable = self.freqList[idxTable]

    def simpleModulusSolution(self,idxStep=87):
        self.makeFreqList()
        minIdxStep = np.searchsorted(self.freqList,self.startFreq+self.minNeighborSeparation)+1

        #idxStep = int(np.floor(2.5*idxStep))+1
        #idxStep = 69 # min 67 MHz, max 700 MHz
        #idxStep = 87 # min 84 MHz, max 526 MHz

        idxList = np.arange(self.nFreqs)
        modIdxList = (idxList*idxStep)%(self.nFreqs)
        print 'idxStep',idxStep
        print 'nFreqs',self.nFreqs

        diffIdxList = np.abs(np.diff(modIdxList))

        idxTable = np.reshape(modIdxList,(self.nRows,self.nCols))


        #make sure all the frequencies will be represented
        #assert np.all(np.sort(np.ravel(idxTable)) == np.arange(self.nFreqs))
        
        self.freqTable = self.freqList[idxTable]

    def simpleGradientSolution(self):
        self.makeFreqList()
        idxStep = self.nCols

        #idxStep = int(np.floor(2.5*idxStep))+1
        #idxStep = 69 # min 67 MHz, max 700 MHz
        #idxStep = 87 # min 84 MHz, max 526 MHz

        idxList = np.arange(self.nFreqs)
        modIdxList = (idxList*idxStep)%(self.nFreqs) + ((idxList*idxStep)//self.nFreqs)
        
        print 'idxStep',idxStep
        print 'nFreqs',self.nFreqs

        diffIdxList = np.abs(np.diff(modIdxList))

        idxTable = np.reshape(modIdxList,(self.nCols,self.nRows)).T



        #do some flips so neighboring columns aren't next to others with close values
        nRowFlip = 4
        for iRowGroup in xrange(int(np.ceil(1.*self.nRows/nRowFlip))):
            slc = slice(iRowGroup*nRowFlip,(iRowGroup+1)*nRowFlip)
            idxTable[slc,1::2] = idxTable[slc,1::2][::-1,:]

        nRowFlip = 8
        for iRowGroup in xrange(int(np.ceil(1.*self.nRows/nRowFlip))):
            slc = slice(iRowGroup*nRowFlip,(iRowGroup+1)*nRowFlip)
            idxTable[slc,1::2] = idxTable[slc,1::2][::-1,:]

        #move cols around so 5 cols follows a pattern
#        idxTable2 = np.array(idxTable)
#        nColGroup = 5
#        for i in range(self.nCols/nColGroup):
#            idxTable[:,i::nColGroup] = idxTable2[:,i*nColGroup:(i+1)*nColGroup]

        #move the lowest frequency rows to the center and alternate placing higher frequency rows outward from center
#        idxTable2 = np.array(idxTable)
#        idxTable[0:self.nRows/2,:] = idxTable2[::-2]
#        idxTable[self.nRows/2:,:] = idxTable2[::2]

        plotArray(idxTable)
        #make sure all the frequencies appear in the table exactly once
        assert np.all(np.sort(np.ravel(idxTable)) == np.arange(self.nFreqs))
        
        self.freqTable = self.freqList[idxTable]
        np.savetxt('idx.txt',idxTable)

    def simpleGradientSolution2(self):
        self.makeFreqList()
        idxStep = self.nCols

        #idxStep = int(np.floor(2.5*idxStep))+1
        #idxStep = 69 # min 67 MHz, max 700 MHz
        #idxStep = 87 # min 84 MHz, max 526 MHz

        idxList = np.arange(self.nFreqs)
        modIdxList = (idxList*idxStep)%(self.nFreqs) + ((idxList*idxStep)//self.nFreqs)
        
        print 'idxStep',idxStep
        print 'nFreqs',self.nFreqs

        diffIdxList = np.abs(np.diff(modIdxList))

        idxTable = np.reshape(modIdxList,(self.nCols,self.nRows)).T



        #do some flips so neighboring columns aren't next to others with close values
        nRowFlip = 4
        for iRowGroup in xrange(int(np.ceil(1.*self.nRows/nRowFlip))):
            slc = slice(iRowGroup*nRowFlip,(iRowGroup+1)*nRowFlip)
            idxTable[slc,1::2] = idxTable[slc,1::2][::-1,:]

        nRowFlip = 8
        for iRowGroup in xrange(int(np.ceil(1.*self.nRows/nRowFlip))):
            slc = slice(iRowGroup*nRowFlip,(iRowGroup+1)*nRowFlip)
            idxTable[slc,1::2] = idxTable[slc,1::2][::-1,:]

        #adjust last row
        
        idxTable2 = np.array(idxTable)
        idxTable[-1:,1::2] = idxTable2[-10:-9,1::2]
        idxTable[-10:-9,1::2] = idxTable2[-1:,1::2]

        idxTable[0,:] = idxTable2[8,:]
        idxTable[8,:] = idxTable2[0,:]

        #once more but shift down 1 row to make sure the last row gets a flip
#        nRowFlip = 15
#        for iRowGroup in xrange(int(np.ceil(1.*self.nRows/nRowFlip))):
#            slc = slice(1+iRowGroup*nRowFlip,1+(iRowGroup+1)*nRowFlip)
#            idxTable[slc,1::2] = idxTable[slc,1::2][::-1,:]

        #reverse order of odd cols
        #idxTable[:,:] = idxTable[:,::-1]

        #regroup cols
#        idxTable2 = np.array(idxTable)
#        nColGroup = 2 #nCols should be divisible by this
#        nColInterleaves = self.nCols/nColGroup
#        for i in range(nColInterleaves):
#            idxTable[:,i::nColInterleaves] = idxTable2[:,i*nColGroup:(i+1)*nColGroup]

       #move the lowest frequency rows to the center and alternate placing higher frequency rows outward from center
        idxTable2 = np.array(idxTable)
        idxTable[0:self.nRows/2,:] = idxTable2[self.nRows%2::2,:][::-1,:]
        idxTable[self.nRows/2:,:] = idxTable2[::2]

        plotArray(idxTable,origin='upper',cmap='hot')
        #make sure all the frequencies appear in the table exactly once
        assert np.all(np.sort(np.ravel(idxTable)) == np.arange(self.nFreqs))
        
        self.freqTable = self.freqList[idxTable]
        np.savetxt('idx.txt',idxTable)

    def modulusSolution(self,idxStep=87):
        self.makeFreqList()
        minIdxStep = np.searchsorted(self.freqList,self.startFreq+self.minNeighborSeparation)+1

        #idxStep = int(np.floor(2.5*idxStep))+1
        #idxStep = 69 # min 67 MHz, max 700 MHz
        #idxStep = 87 # min 84 MHz, max 526 MHz

        idxList = np.arange(self.nFreqs)
        modIdxList = (idxList*idxStep)%(self.nFreqs)
        print 'idxStep',idxStep
        print 'nFreqs',self.nFreqs
        startsList = np.where(np.diff(modIdxList) < 0)[0]+1

        for i,iStart in enumerate(startsList):
            if i % 2 == 0:
                if i == len(startsList)-1:
                    iEnd = len(modIdxList)
                else:
                    iEnd = startsList[i+1]

                modIdxList[iStart:iEnd] = modIdxList[iStart:iEnd][::-1]

        diffIdxList = np.abs(np.diff(modIdxList))

        idxTable = np.reshape(modIdxList,(self.nRows,self.nCols))


        #make sure all the frequencies will be represented
        #assert np.all(np.sort(np.ravel(idxTable)) == np.arange(self.nFreqs))
        
        self.freqTable = self.freqList[idxTable]

def darknessSolution():
    tile0 = FreqMapTile(nRows=40,nCols=25,startFreq=4000.,bandwidth=2000.,verbosity=2,name='center')
    #tile0.addFreqHole(holeWidth=10.,holeCenter=1000.)
    tile0.minNeighborSeparation = 70
    tile0.minSecondNeighborSeparation = 8
    tile0.maxNeighborSeparation = 550
    tile0.simpleGradientSolution()

    tile1 = FreqMapTile(nRows=40,nCols=25,startFreq=6200.,bandwidth=2000.,verbosity=2,name='outer')
    #tile0.addFreqHole(holeWidth=10.,holeCenter=1000.)
    tile1.minNeighborSeparation = 70
    tile1.minSecondNeighborSeparation = 8
    tile1.maxNeighborSeparation = 550
    tile1.simpleGradientSolution()

    np.savetxt('darkness_center.txt',tile0.freqTable)
    np.savetxt('darkness_outer.txt',tile1.freqTable)

    plotArray(tile0[:,:],origin='upper')
    tile0.runSwaps(int(1e4))
    tile1.runSwaps(int(1e4))

    np.savetxt('darkness_center_swap_{}min_{}max.txt'.format(tile0.minNeighborSeparation,tile0.maxNeighborSeparation),tile0.freqTable)
    np.savetxt('darkness_outer_swap_{}min_{}max.txt'.format(tile1.minNeighborSeparation,tile1.maxNeighborSeparation),tile1.freqTable)

    combinedTile = np.vstack([tile1[0:20,:],tile0[:,:],tile1[20:,:]])
    np.savetxt('darkness_feedline.txt',combinedTile)

    print 'saved!'

def mecSolution():
    tile0 = FreqMapTile(nRows=73,nCols=14,startFreq=0.,bandwidth=2000.,verbosity=2,name='center')
    #tile0.addFreqHole(holeWidth=10.,holeCenter=1000.)
    tile0.minNeighborSeparation = 70
    tile0.minSecondNeighborSeparation = 8
    tile0.maxNeighborSeparation = 550
    tile0.simpleGradientSolution2()

    tile1 = FreqMapTile(nRows=73,nCols=14,startFreq=2200.,bandwidth=2000.,verbosity=2,name='outer')
    #tile0.addFreqHole(holeWidth=10.,holeCenter=1000.)
    tile1.minNeighborSeparation = 70
    tile1.minSecondNeighborSeparation = 8
    tile1.maxNeighborSeparation = 550
    tile1.simpleGradientSolution2()

    np.savetxt('mec_center.txt',tile0.freqTable)
    np.savetxt('mec_outer.txt',tile1.freqTable)

    tile0.runSwaps(int(1e4))
    tile1.runSwaps(int(1e4))

    np.savetxt('mec_center_swap_{}min_{}max.txt'.format(tile0.minNeighborSeparation,tile0.maxNeighborSeparation),tile0.freqTable)
    np.savetxt('mec_outer_swap_{}min_{}max.txt'.format(tile1.minNeighborSeparation,tile1.maxNeighborSeparation),tile1.freqTable)
    combinedTile = np.vstack([tile1[0:36,:],tile0[:,:],tile1[36:,:]])
    plotArray(combinedTile,origin='upper')
    np.savetxt('mec_feedline.txt',combinedTile,fmt='%.1f')

    print 'saved!'
        
if __name__=='__main__':
#    bottomTile = FreqMapTile(nRows=40,nCols=25,startFreq=2500.,bandwidth=2000.,verbosity=1,name='bottom')
#    bottomTile.addFreqHole(holeWidth=10.,holeCenter=2500.+1000.)
#    bottomTile.minNeighborSeparation = 70.
#    bottomTile.simpleModulusSolution()
#    np.savetxt('mod.txt',bottomTile.freqTable)
    mecSolution()
    
