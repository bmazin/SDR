import numpy as np
import matplotlib.pyplot as plt
from util.popup import plotArray
import os
import struct

def covFromPsd(powerSpectrum,size=None):
    autocovariance = np.abs(np.fft.ifft(powerSpectrum))
    if size is None:
        size = len(autocovariance)
    sampledAutocovariance = autocovariance[0:size]

    shiftingRow = np.concatenate((sampledAutocovariance[:0:-1],sampledAutocovariance))
    covMatrix = []

    for iRow in range(size):
        covMatrix.append(shiftingRow[size-iRow-1:size-iRow-1+size])

    covMatrix = np.array(covMatrix)

    covMatrixInv = np.linalg.inv(covMatrix)
    return {'covMatrix':covMatrix,'covMatrixInv':covMatrixInv,'autocovariance':sampledAutocovariance}

def covFromData(data,size=800,nTrials=None):
    nSamples = len(data)
    if nTrials is None:
        nTrials = nSamples//size
    data = data[0:nTrials*size]
    data = data.reshape((nTrials,size))
    data = data.T
    
    covMatrix = np.cov(data)
    covMatrixInv = np.linalg.inv(covMatrix)
    return {'covMatrix':covMatrix,'covMatrixInv':covMatrixInv}

if __name__=='__main__':
    folder = '/Scratch/dataProcessing/filterTests/'
#    date='20121204'
#    roachNum = 4
#    pixelNum = 102
#    label = '30tap_slowBase'

    date='20160301'
    roachNum = 0
    pixelNum = 0
    nSecs=100
    label = 'sim_base'
    wienerFile = np.load(os.path.join(folder,'wiener_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label)))
    wienerFilterCoeffs = wienerFile['finalFilterCoeffs'].real
    template = wienerFile['finalTemplate']
    noiseSpectrum = wienerFile['noiseSpectrum']

    filterSize = 800
    
    #now try making a covariance matrix from raw data
    phaseFilename = os.path.join(os.path.join('/Scratch/filterData/',date),'ch_snap_r{}p{}_{}secs.dat'.format(roachNum,pixelNum,nSecs))
    dataFile = open(phaseFilename,'r')
    data = dataFile.read()
    nQdrWords=2**19 #for firmware with  qdr longsnap
    nBytesPerWord=4 #bytes in each qdr row/word
    nBytesPerSample=2 #bytes in a fix16_13 phase sample
    nSamples = nQdrWords*(nBytesPerWord/nBytesPerSample)*nSecs
    intValues = struct.unpack('>%dh'%(nSamples),data)
    phaseValuesRad = np.array(intValues,dtype=np.float32)/2**13 #move binary point
    phaseValuesDeg = 180./np.pi*phaseValuesRad

    covDict = covFromData(phaseValuesDeg,size=800,nTrials=None)
    covMatrix = covDict['covMatrix']
    covMatrixInv = covDict['covMatrixInv']
    print 'cov done'
    plotArray(covMatrix,title='cov',origin='upper')
    plotArray(covMatrixInv,title='cov^{-1}',origin='upper')

    maxIndex = np.argmax(template)
    if filterSize < len(template):
        template = template[maxIndex-5:maxIndex-5+filterSize]
    
    matchedFilter = np.dot(covMatrixInv,template.T)
    matchedFilter = matchedFilter / np.max(matchedFilter)
    
    bPlotCoeffs = True
    if bPlotCoeffs:
        fig,ax = plt.subplots(1,1)
        ax.plot(wienerFilterCoeffs,'r.-',label='wiener')
        ax.plot(matchedFilter,'c.-',label='matched')
        ax.plot(template,'k.-',label='template')
        ax.legend(loc='best')

    np.savez('/Scratch/dataProcessing/filterTests/matched_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),wienerFilterCoeffs=wienerFilterCoeffs,noiseSpectrum=noiseSpectrum,covMatrix=covMatrix,covMatrixInv=covMatrixInv,matchedFilter=matchedFilter,template=template)

    plt.show()
    
