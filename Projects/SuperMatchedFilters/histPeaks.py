import numpy as np
import matplotlib.pyplot as plt
from fitFunctions import gaussian
import mpfit
import scipy.stats
import scipy.interpolate
import smooth


def extrema(a,bPlot=False,nBins=300,smoothWindowSize=50):
    hist,binEdges = np.histogram(a,bins=nBins,density=True)
    histSmooth = smooth.smooth(hist,smoothWindowSize,'hanning')
    binCenters = binEdges[0:-1]+np.diff(binEdges)/2.
    extremeIdxs = np.where(np.diff(np.sign(np.diff(histSmooth))))[0]+1
    bMaximums = np.diff(np.sign(np.diff(histSmooth)))<0
    bMaximums = bMaximums[np.where(np.diff(np.sign(np.diff(histSmooth))))]

    if bPlot:
        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax.plot(binCenters,histSmooth)
        ax.plot(binCenters,hist)
        ax.plot(binCenters[extremeIdxs],histSmooth[extremeIdxs],'.')
    return {'extremeX':binCenters[extremeIdxs],'extremeY':hist[extremeIdxs],'bMaximums':bMaximums}

def smoothBaseline(baselines,timestamps,timeToAverage=500e-3,trimLimits=(.5,0)):
    """Calculates new baseline points as a trimmed mean of given points within a time window

    INPUTS
        baselines - an array of baseline points
        timestamps - the times corresponding to the baseline points, in seconds
        timeToAverage - the window around each baseline in which to calculate the trimmed mean, in seconds
        trimLimits - the relative fraction to trim below and above for each mean, by default trim lower half of points and keep the rest
    OUTPUTS
        modBases - the trimmed means at each baseline point
    """
    #make a copy of baselines, we'll replace each element
    modBases = np.array(baselines)
    for i,ts in enumerate(timestamps):
        #find the first and last baseline indices that are included by the time window
        startIdx = np.searchsorted(timestamps,ts-timeToAverage/2.)
        endIdx = np.searchsorted(timestamps,ts+timeToAverage/2.)
        #trim the values by the given relative fraction,
        #by default throw out the lower half of values since these are the most contaminated by negative pulses
        trimmedSample = scipy.stats.mstats.trim(baselines[startIdx:endIdx],trimLimits,relative=True)
        modBases[i] = np.ma.mean(trimmedSample)
    return modBases


def fitR(energies,bPlot=False,nBins=153,lowerEnergyCutoff=-6000):

    mask = energies < lowerEnergyCutoff
    energies = energies[mask]
    energyHist,energyHistBinEdges = np.histogram(energies,bins=nBins,density=True)

    #make some rough guesses for initial params
    amplitude = 0.95*np.max(energyHist)
    x_offset = energyHistBinEdges[np.argmax(energyHist)]
    sigma = np.std(energies)*.8
    y_offset = 1.e-8

    params=[sigma, x_offset, amplitude, y_offset]  
    #assume poisson errors in the histogram
    errs = np.sqrt(energyHist)
    #remove the bad values
    errs[np.where(errs == 0.)] = np.inf
    #errs[np.where(errs == 0.)] = 1.
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
        #print parinfo[k]['parname'],p," +/- ",mpperr[k]
        if k==0: sigma = p
        if k==1: x_offset = p
        if k==2: amplitude = p
        if k==3: y_offset = p

    gaussfit = y_offset + amplitude * np.exp( - (( energyHistBinEdges[0:-1] - x_offset)**2) / ( 2. * (sigma**2)))

    resolution = np.abs(x_offset/(2.355*sigma))

    if bPlot:
        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax.step(energyHistBinEdges[0:-1],energyHist)
        ax.plot(energyHistBinEdges[0:-1],gaussfit)

    return {'gaussfit':gaussfit,'resolution':resolution,'sigma':sigma,'x_offset':x_offset,'amplitude':amplitude,'y_offset':y_offset,'energyHist':energyHist,'energyHistBinEdges':energyHistBinEdges}


roachNum=4
pixelNum=102
bSmoothed = True
date='20121204'
label='30tap_slowBase'
npz = np.load('/Scratch/dataProcessing/filterTests/sdetected_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))
    
bases=npz['bases']
peaks=npz['peaks']+bases
baselines=npz['baselines']
threshold=npz['threshold']
idx=npz['idx']
qdrValues=npz['qdrValues']
filtered=npz['filtered']


def analyze(idx,peaks,bases,baselines):
    energies = peaks-bases #subtract baselines for our standard photon energy proxy

    #check number of ticks between detected peaks
    timeSpacing = np.diff(idx)
    #treat these as the time since the last peak at the current index
    #to line up the indices, we need to add a value, the time since the last peak
    #for the first detected photon. Assume 2000 ticks (2 ms)
    timeSpacing = np.append(2000,timeSpacing)

    #make a mask of detected photon indices in which there has been at least
    # spacingThreshold ticks since the last pulse
    spacingThreshold = 1000 #us
    spacingMask = timeSpacing > spacingThreshold
    print 'sufficently spaced photons:',np.sum(spacingMask)

    #apply the spacing mask
    farPeaks = peaks[spacingMask]
    farBases = bases[spacingMask]
    farEnergies = energies[spacingMask]
    farIdx = idx[spacingMask]

    goodBases = np.array(bases)
    if bSmoothed:
        smoothBases = np.array(bases)
    else:
        smoothBases = smoothBaseline(goodBases,idx/1.e6)


    closeSpacingMask = timeSpacing < 100

    modEnergies = peaks-smoothBases

    tau=80.
    expTails = modEnergies*np.exp(-timeSpacing/tau)

    expPeaks = expTails+smoothBases
    expEnergies = modEnergies-expTails
    expMask = expEnergies<threshold
    notExpMask = expMask==False
    expEnergiesCut = expEnergies[expMask]

    filteredIdx = np.array(np.arange(5000,10000),dtype=np.int)
    phaseVel = np.diff(filtered)
    phaseVelSum = np.cumsum(phaseVel)
    phaseVelSign = np.sign(phaseVel)
    phaseVelSign[phaseVelSign==1]=0
    phaseVelSignCount = np.cumsum(phaseVelSign)

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax2 = ax.twinx()
    ax.plot(filteredIdx,phaseVel[filteredIdx],'.-',color='Gold')
    ax.plot(filteredIdx,100*phaseVelSign[filteredIdx],'.-',color='g')
    ax2.plot(filteredIdx,filtered[filteredIdx],'k.-')
    ax2.plot(idx[expMask],peaks[expMask],'r.')
    ax2.plot(idx[expMask==False],peaks[expMask==False],'m.')
    ax2.set_xlim([filteredIdx[0],filteredIdx[-1]])
    ax.set_xlim([filteredIdx[0],filteredIdx[-1]])
    ax2.set_ylim([np.min(filtered[filteredIdx]),np.max(filtered[filteredIdx])])

    sampleStart=5000
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(filteredIdx,filtered[filteredIdx],'k.-')

    #ax.plot(idx[notExpMask],peaks[notExpMask]-expTails[notExpMask],'m.')
    #ax.plot(idx[expMask],peaks[expMask]-expTails[expMask],'r.')

    #ax.plot(idx,peaks,'r.')
    ax.plot(idx[expMask],peaks[expMask],'r.')
    ax.plot(idx[expMask==False],peaks[expMask==False],'m.')
    ax.plot(idx,smoothBases,'DarkOrange')
    ax.plot(idx,bases,'g.')
    ax.plot(filteredIdx,baselines[filteredIdx],'b-')
    ax.plot(idx,expPeaks,'g')
    print threshold
    ax.plot(idx,smoothBases+threshold,'k')

    print 'peaks:',len(peaks),'deadtime peaks',np.sum(closeSpacingMask),'false peaks',np.sum(expMask==False)
    print 'deadtime peaks','%.2f%%'%(100.*np.sum(closeSpacingMask)/len(peaks)),'false deadtime peaks','%.2f%%'%(100.*np.sum(expEnergies[closeSpacingMask]>threshold)/np.sum(closeSpacingMask))

    byEyeCutoff=-6000
    energies=energies[energies<byEyeCutoff]
    expEnergiesCut=expEnergiesCut[expEnergiesCut<byEyeCutoff]

    nBins = 200
    energyHist,energyHistBins = np.histogram(energies,bins=nBins,density=True)
    expEnergyCutHist,expEnergyCutHistBins = np.histogram(expEnergiesCut,bins=nBins,density=True)

    resolutionDict = fitR(energies)
    expResolutionDict = fitR(expEnergiesCut)
    modResolutionDict = fitR(modEnergies)
    farResolutionDict = fitR(farEnergies)

    modEnergyHist,modEnergyHistBins = np.histogram(modEnergies,bins=nBins,density=True)
    expEnergyHist,expEnergyHistBins = np.histogram(expEnergies,bins=nBins,density=True)
    farEnergyHist,farEnergyHistBins = np.histogram(farEnergies,bins=nBins,density=True)

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.step(energyHistBins[0:-1],energyHist,'b')
    ax.step(expEnergyCutHistBins[0:-1],expEnergyCutHist,'goldenrod')
    #ax.step(farEnergyHistBins[0:-1],farEnergyHist,'r')
    ax.plot(resolutionDict['energyHistBinEdges'][0:-1],resolutionDict['gaussfit'],'darkblue')
    ax.plot(expResolutionDict['energyHistBinEdges'][0:-1],expResolutionDict['gaussfit'],'darkgoldenrod')
    #ax.plot(farResolutionDict['energyHistBinEdges'][0:-1],farResolutionDict['gaussfit'],'darkred')
        
    print 'Standard deviations:'
    print 'raw baselines',np.std(bases)
    #print 'new baselines',np.std(newBases)
    print 'smoothed baselines',np.std(smoothBases)
    print 'raw peaks',np.std(peaks)
    print 'peak-rawBases',np.std(energies)
    print 'time_cut peak-rawBases',np.std(farEnergies)
    print 'peak-smoothBases',np.std(modEnergies)
    print ''
    print 'raw\t\t\tR=',resolutionDict['resolution']
    print 'smooth base\t\tR=',modResolutionDict['resolution']
    print 'exp tail subtracted\tR=',expResolutionDict['resolution']
    print 'spacing cut\t\tR=',farResolutionDict['resolution']
analyze(idx,peaks,bases,baselines)
plt.show()
