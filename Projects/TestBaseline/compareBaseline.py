import sys
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from fitFunctions import gaussian
import mpfit
import scipy.stats
import smooth
from util.ObsFile import ObsFile
from util.FileName import FileName
import Utils.bin as binTools
import os
import struct

def smoothBaseline(baselines,nPtsInMode=400):
    modBases = np.array(baselines)
    for i in range(len(modBases)):
        startIdx = i-nPtsInMode//2
        if startIdx < 0:
            startIdx = 0
        endIdx = i+nPtsInMode//2
        if endIdx >= len(modBases):
            endIdx = len(modBases)-1
        trimmedSample = scipy.stats.mstats.trim(baselines[startIdx:endIdx],(.4,0),relative=True)
        modBases[i] = np.ma.mean(trimmedSample)
    return modBases

def smoothBaseline(baselines,timestamps,timeToAverage=500e-3):
    #timeToAverage = 10e-3 #10 ms
    modBases = np.array(baselines)
    for i,ts in enumerate(timestamps):
        startIdx = np.searchsorted(timestamps,ts-timeToAverage/2.)
        endIdx = np.searchsorted(timestamps,ts+timeToAverage/2.)
        trimmedSample = scipy.stats.mstats.trim(baselines[startIdx:endIdx],(.5,0),relative=True)
        modBases[i] = np.ma.mean(trimmedSample)
    print 2*(endIdx-startIdx)
    return modBases

def fitR(energies):

    nBins=43
    #mask = energies < -250
    #energies = energies[mask]
    energyHist,energyHistBinEdges = np.histogram(energies,bins=nBins,density=True)



    amplitude = 0.9*np.max(energyHist)
    #x_offset = np.median(phasebins[ind_left:ind_right])
    #sigma = 50.
    x_offset = energyHistBinEdges[np.argmax(energyHist)]
    sigma = np.std(energies)*.8
    #print 'sigma: ', sigma
    y_offset = 1.e-8

    params=[sigma, x_offset, amplitude, y_offset]  # First guess at fit params
    errs = np.sqrt(energyHist)
    errs[np.where(errs == 0.)] = 1.
    quiet = True

    parinfo = [ {'n':0,'value':params[0],'limits':[sigma/10., 10*sigma], 'limited':[True,True],'fixed':False,'parname':"Sigma",'error':0},
       {'n':1,'value':params[1],'limits':[x_offset-sigma*2, x_offset+sigma*2],'limited':[True,True],'fixed':False,'parname':"x offset",'error':0},
       {'n':2,'value':params[2],'limits':[0.5*amplitude, 2.*amplitude],'limited':[True,True],'fixed':False,'parname':"Amplitude",'error':0},
       {'n':3,'value':params[3],'limited':[False,False],'fixed':False,'parname':"y_offset",'error':0}]

    fa = {'x':energyHistBinEdges[0:-1],'y':energyHist,'err':errs}

    m = mpfit.mpfit(gaussian, functkw=fa, parinfo=parinfo, maxiter=1000, quiet=quiet)
    if m.status <= 0:
        print m.status, m.errmsg

    mpp = m.params                                #The fit params
    mpperr = m.perror

    for k,p in enumerate(mpp):
        parinfo[k]['value'] = p
        #print parinfo[k]['parname'],p," +/- ",mpperr[j]
        if k==0: sigma = p
        if k==1: x_offset = p
        if k==2: amplitude = p
        if k==3: y_offset = p

    gaussfit = y_offset + amplitude * np.exp( - (( energyHistBinEdges[0:-1] - x_offset)**2) / ( 2. * (sigma**2)))

    resolution = np.abs(x_offset/(2.355*sigma))
    return {'gaussfit':gaussfit,'resolution':resolution,'sigma':sigma,'x_offset':x_offset,'amplitude':amplitude,'y_offset':y_offset,'energyHist':energyHist,'energyHistBinEdges':energyHistBinEdges}


def extrema(a):
    nBins=300
    hist,binEdges = np.histogram(a,bins=nBins,density=True)
    smoothWindowSize=50
    histSmooth = smooth.smooth(hist,smoothWindowSize,'hanning')
    binCenters = binEdges[0:-1]+np.diff(binEdges)/2.
    extremeIdxs = np.where(np.diff(np.sign(np.diff(histSmooth))))[0]+1
    bMaximums = np.diff(np.sign(np.diff(histSmooth)))<0
    bMaximums = bMaximums[np.where(np.diff(np.sign(np.diff(histSmooth))))]
#    fig = plt.figure()
#    ax = fig.add_subplot(111)
#    ax.plot(binCenters,histSmooth)
#    ax.plot(binCenters,hist)
#    ax.plot(binCenters[extremeIdxs],histSmooth[extremeIdxs],'.')
#    plt.show()
    return {'extremeX':binCenters[extremeIdxs],'extremeY':hist[extremeIdxs],'bMaximums':bMaximums}


def extract(values):
    newValues = np.array(values,dtype=np.int64)
    for i in range(len(values)):
        val = int(values[i])
        newValues[i] = binTools.extractBin(int(values[i]),format='deg')
    return newValues
        
#def detectPulses(sample,threshold,baselines):
#    filtered = np.array(sample)
#
#    #threshold = calcThreshold(filtered[0:2000])
#    filtered -= baselines
#    derivative = np.diff(filtered)
#    peakHeights = []
#    t = 0
#    negDeriv = derivative <= 0
#    posDeriv = np.logical_not(negDeriv)
#
#    triggerBooleans = filtered[1:-2] < threshold
#    peakCondition1 = np.logical_and(negDeriv[0:-2],posDeriv[1:-1])
#    peakCondition2 = np.logical_and(triggerBooleans,posDeriv[2:])
#    peakBooleans = np.logical_and(peakCondition1,peakCondition2)
#    try:
#        peakIndices = np.where(peakBooleans)[0]+1
#        i = 0
#        p = peakIndices[i]
#        deadtime=100#us
#        while p < peakIndices[-1]:
#            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadtime , peakIndices-p <= 0)]#apply deadtime
#            i+=1
#            if i < len(peakIndices):
#                p = peakIndices[i]
#            else:
#                p = peakIndices[-1]
#    except IndexError:
#        return np.array([]),np.array([]),np.array([])
#
#
#    peakHeights = filtered[peakIndices]
#    return peakIndices,peakHeights

def detectPulses(sample,threshold,baselines,deadtime=10):
    #deadtime in ticks (us)
    filtered = np.array(sample)

    #threshold = calcThreshold(filtered[0:2000])
    filtered -= baselines
    derivative = np.diff(filtered)
    peakHeights = []
    t = 0
    negDeriv = derivative <= 0
    posDeriv = np.logical_not(negDeriv)
    print np.shape(derivative)
    print np.shape(filtered)
    print np.shape(negDeriv)

    nNegDerivChecks = 10
    lenience = 1
    triggerBooleans = filtered[nNegDerivChecks:-2] < threshold

    negDerivChecksSum = np.zeros(len(negDeriv[0:-nNegDerivChecks-1]))
    for i in range(nNegDerivChecks):
        negDerivChecksSum += negDeriv[i:i-nNegDerivChecks-1]
    peakCondition0 = negDerivChecksSum >= nNegDerivChecks-lenience
    peakCondition1 = np.logical_and(posDeriv[nNegDerivChecks:-1],posDeriv[nNegDerivChecks+1:])
    peakCondition01 = np.logical_and(peakCondition0,peakCondition1)
    peakBooleans = np.logical_and(triggerBooleans,peakCondition01)

    try:
        peakIndices = np.where(peakBooleans)[0]+nNegDerivChecks
        i = 0
        p = peakIndices[i]
        while p < peakIndices[-1]:
            peakIndices = peakIndices[np.logical_or(peakIndices-p > deadtime , peakIndices-p <= 0)]#apply deadtime
            i+=1
            if i < len(peakIndices):
                p = peakIndices[i]
            else:
                p = peakIndices[-1]
    except IndexError:
        return np.array([]),np.array([]),np.array([])


    peakHeights = filtered[peakIndices]
    return peakIndices,peakHeights

cmap = matplotlib.cm.jet
path = '/Scratch/labData/20131125/'
obsFileName = os.path.join(path,'obs_20131126-035710.h5')
obs = ObsFile(obsFileName)

roachNum = 0
pixelNum = 50
secs=10
cps=500
bFiltered = True
phaseFilename = os.path.join(path,'ch_snap_r%dp%d_%dsecs.dat'%(roachNum,pixelNum,secs))
phaseFile = open(phaseFilename,'r')
phase = phaseFile.read()
numQDRSamples=2**19
numBytesPerSample=4
nLongsnapSamples = numQDRSamples*2*secs
qdrValues = struct.unpack('>%dh'%(nLongsnapSamples),phase)
qdrValues = qdrValues[0:1048576]
qdrPhaseValues = np.array(qdrValues,dtype=np.float32)*360./2**16*4/np.pi #convert from adc units to degrees
nPhaseValues=len(qdrValues)
offset = (189369-435169)*1.e-6
qdrTimes = 1.e-6*np.arange(nPhaseValues)+offset
print nPhaseValues,'us in snapshot'
iQdrMin = np.argmin(qdrPhaseValues)
print 'min qdr',iQdrMin,qdrPhaseValues[iQdrMin]


row,col=38,21
firstSec=0
intTime=5
countRates = []

print (row,col)

color='k'
packetListDict = obs.getTimedPacketList(row,col,firstSec=firstSec,integrationTime=intTime)

timestamps = packetListDict['timestamps']
rawPeakHeights = packetListDict['peakHeights']
rawBaselines = packetListDict['baselines']

peakHeights = (np.array(rawPeakHeights,dtype=np.float)/2.**9-4.)*180./np.pi
baselines = (np.array(rawBaselines,dtype=np.float)/2.**9-4.)*180./np.pi

iObsMin = np.argmin(peakHeights[0:100])
print 'min obs',iObsMin,timestamps[iObsMin],peakHeights[iObsMin]


peakHeightsFilled = np.zeros(intTime*1e6)
peakHeightsFilled[np.array(1e6*timestamps,dtype=np.int)] = peakHeights
filledTimes = np.arange(intTime*1e6)*1.e-6

baseline = np.mean(baselines)
threshold = -25.

qdrPeakIdx,qdrPeakHeights = detectPulses(qdrPhaseValues,threshold,baseline)
qdrPeakIdxDead,qdrPeakHeightsDead = detectPulses(qdrPhaseValues,threshold,baseline,deadtime=0)
qdrPeakHeights += baseline
qdrPeakHeightsDead += baseline

qdrCorSample = np.zeros(len(qdrPhaseValues))
qdrCorSample[qdrPeakIdx] = qdrPeakHeights


#print 'starting correlation'
#cor = np.correlate(peakHeightsFilled,qdrCorSample,mode='same')
#print 'finished correlation'

#imin = np.argmin(cor)
#print imin,cor[imin]

nCounts = len(timestamps)
secs = np.unique(np.array(timestamps,dtype=np.int))
print nCounts
if nCounts > 0:
    duration = np.max(secs)+1
    print 1.*nCounts/duration

    phases = peakHeights-baselines

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(qdrTimes,qdrPhaseValues,'k,-')
    ax.plot(qdrTimes[qdrPeakIdxDead],qdrPeakHeightsDead,'bd')
    ax.plot(qdrTimes[qdrPeakIdx],qdrPeakHeights,'rd')
    ax.plot(timestamps,peakHeights,'c.')
    ax.plot(timestamps,baselines,'r,-')
    plt.show()


#    fig = plt.figure()
#    ax = fig.add_subplot(111)
#    ax.plot(cor,'m')
#    plt.show()


