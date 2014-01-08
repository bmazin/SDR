import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from fitFunctions import gaussian
import mpfit
import scipy.stats
import smooth
from util.ObsFile import ObsFile
from util.FileName import FileName

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

#obs_20130612-003423_CorrectedCount.txt
#timeBinStarts = np.array([74.,201.,327.,454.,581.,707.,833.,960.,1087.,1214.,1340.,1467.,1594.,1721.,1846.])
timeBinWidth = 56.
timeBinSpacing = 70.
powermeter = open('obs_20130612-003423_CorrectedCount.txt', 'r')
pixToUse = [[0,26],[2,25],[2,27],[2,31],[2,34],[2,39],[3,17],[3,26],[3,32],
            [3,36],[4,26],[4,32],[5,32],[6,22],[6,29],[6,30],[7,25],[7,27],[7,28],
            [7,32],[7,37],[8,30],[10,32],[10,42],[11,30],[12,29],[12,31],[13,29],[13,31],
            [14,27],[14,32],[15,25],[15,26],[15,30],[15,31],[15,32],[16,23],[16,30],
            [17,23],[17,25],[17,26],[17,39],[18,24],[18,28],[19,23],[19,26],[19,28],[19,30]]

#obs_20131019_025156.h5
timeBinStarts = np.array([112.,195.,275.,357.,445.,527.,609.,690.,772.,854.,942.,1024.,1106.,1187.])
timeBinWidth = 16.
timeBinSpacing = 66.
powermeter = open('obs_20130612-003423_CorrectedCount.txt', 'r') ##fix later
pixToUse = [[0,0]]

inCounts = []
for line in powermeter:
    if '#' in line:
        continue
    inCounts.append(float(line.strip()))
inCounts = np.array(inCounts)


cmap = matplotlib.cm.jet
obsFileName = '/Scratch/linearityTestData/obs_20130612-003423.h5'
obs = ObsFile(obsFileName)


row,col=pixToUse[0]
allResolutions = []
allModResolutions = []
allModResolutions2 = []
allCountRates = []
timeBinStarts = timeBinStarts[0:-3]
for (row,col) in pixToUse[0:3]:
    firstSec=timeBinStarts[0]
    intTime=timeBinWidth
    resolutions = []
    modResolutions = []
    modResolutions2 = []
    countRates = []

    fig = plt.figure()
    ax = fig.add_subplot(111)
    fig2 = plt.figure()
    ax2 = fig2.add_subplot(111)
    fig3 = plt.figure()
    ax3 = fig3.add_subplot(111)

    print (row,col)

    for iTimeBin,firstSec in enumerate(timeBinStarts):
        colorFraction = (iTimeBin+1.)/len(timeBinStarts)
        color=cmap(colorFraction)
        packetListDict = obs.getTimedPacketList(row,col,firstSec=firstSec,integrationTime=intTime)

        timestamps = packetListDict['timestamps']
        rawPeakHeights = packetListDict['peakHeights']
        baselines = packetListDict['baselines']
        nCounts = len(timestamps)
        countRate = nCounts/intTime
        print '%.0f cps'%countRate,

        modBaselines = smoothBaseline(baselines,timestamps)
        phases = rawPeakHeights-baselines
        modPhases = rawPeakHeights-modBaselines

        ax.plot(timestamps,rawPeakHeights,'c,')
        ax.plot(timestamps,baselines,'k,')
        ax.plot(timestamps,modBaselines,'r-')

        #do an initial hard-coded clip to take the noise tail out
        phases = phases[phases<-180]
        modPhases = modPhases[modPhases<-180]
        #parse out the minima before and after the gaussian peak in each histogram
        exDict = extrema(phases)
        modExDict = extrema(modPhases)
        try:
            phaseUpperBound = exDict['extremeX'][exDict['bMaximums']==False][-1]
            phaseMax = exDict['extremeX'][np.argmax(exDict['extremeY'])]
            phaseLowerBound = phaseMax-(phaseUpperBound-phaseMax)
            modPhaseUpperBound = modExDict['extremeX'][modExDict['bMaximums']==False][-1]
            modPhaseMax = modExDict['extremeX'][np.argmax(modExDict['extremeY'])]
            modPhaseLowerBound = modPhaseMax-(modPhaseUpperBound-modPhaseMax)

    #        modPhases = modPhases[np.logical_and(modPhases<-260,modPhases>-534)]
    #        phases = phases[np.logical_and(modPhases<-260,modPhases>-534)]
    #        rawPeakHeights = rawPeakHeights[np.logical_and(rawPeakHeights<1672,1350<rawPeakHeights)]
            if phaseUpperBound > phaseLowerBound:
                phases = phases[np.logical_and(phases<phaseUpperBound,phases>phaseLowerBound)]
            if modPhaseUpperBound > modPhaseLowerBound:
                modPhases = modPhases[np.logical_and(modPhases<modPhaseUpperBound,modPhases>modPhaseLowerBound)]
        except IndexError:
            print 'clipping before R fit failed'
        
        



        rDict = fitR(phases)
        modRDict = fitR(modPhases)
        ax2.plot(rDict['energyHistBinEdges'][0:-1],rDict['energyHist'],color=color)
        ax2.plot(rDict['energyHistBinEdges'][0:-1],rDict['gaussfit'],color=color)
        ax3.plot(modRDict['energyHistBinEdges'][0:-1],modRDict['energyHist'],color=color)
        ax3.plot(modRDict['energyHistBinEdges'][0:-1],modRDict['gaussfit'],color=color)

        resolutions.append(rDict['resolution'])
        modResolutions.append(modRDict['resolution'])
        countRates.append(countRate)

    ax.set_title('(%d,%d)'%(row,col))
    ax2.set_title('raw (%d,%d)'%(row,col))
    ax3.set_title('pt smooth (%d,%d)'%(row,col))
    allResolutions.append(resolutions)
    allModResolutions.append(modResolutions)
    allCountRates.append(countRates)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(countRates,resolutions,'b')
    ax.plot(countRates,modResolutions,'r')
    ax.set_title('(%d,%d)'%(row,col))
allCountRates = np.array(allCountRates)
allResolutions = np.array(allResolutions)
allModResolutions = np.array(allModResolutions)
np.savez('ts2.npz',allResolutions=allResolutions,allModResolutions=allModResolutions,allCountRates=allCountRates)
plt.show()




