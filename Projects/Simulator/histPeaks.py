import numpy as np
import matplotlib.pyplot as plt
from fitFunctions import gaussian
import mpfit
import scipy.stats
import scipy.interpolate
import smooth


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

def base(phases,threshold,nAvg=2**12,skipFactor=2**7):
    phase = np.array(phases)
    nPoints = len(phases)
    phases = phases[::skipFactor]
    baselines = np.array(phases)
    includeThreshold=0.25*threshold
    for iPhase,phase in enumerate(phases[1:]):
        oldAvg = baselines[iPhase]
        
        startIdx = iPhase+1-4*nAvg
        if startIdx < 0:
            startIdx = 0
        segment = phases[startIdx:iPhase+1]
        segment = segment[(segment-oldAvg)>includeThreshold]
        segment = segment[-nAvg:]
        avg = np.mean(segment)
        baselines[iPhase+1]=avg
    baselines=np.repeat(baselines,skipFactor)
    baselines = baselines[0:nPoints]
    return baselines
        


def fitR(energies):
    nBins=153
    mask = energies < -6000
    energies = energies[mask]
    extremeDict = extrema(energies)
    
    energyHist,energyHistBinEdges = np.histogram(energies,bins=nBins,density=True)

    amplitude = 0.95*np.max(energyHist)
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

    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.step(energyHistBinEdges[0:-1],energyHist)
    ax.plot(energyHistBinEdges[0:-1],gaussfit)

    return {'gaussfit':gaussfit,'resolution':resolution,'sigma':sigma,'x_offset':x_offset,'amplitude':amplitude,'y_offset':y_offset,'energyHist':energyHist,'energyHistBinEdges':energyHistBinEdges}


roachNum=4
pixelNum=0
bSmoothed = True
if bSmoothed:
    npz = np.load('detected700Blue_dead10.npz')
else:
    npz = np.load('detected600Red_dead100.npz')
    
bases=npz['bases']
peaks=npz['peaks']+bases
baselines=npz['baselines']
threshold=npz['threshold']
idx=npz['idx']
qdrValues=npz['qdrValues']
filtered=npz['filtered']
#newBaselines=np.array(base(filtered,threshold),dtype=np.int)
#newBases = newBaselines[idx]

energies = peaks-bases
timeSpacing = np.diff(idx)
timeSpacing = np.append(2000,timeSpacing)
spacingMask = timeSpacing > 1000 #us
#spacingMask = np.append(spacingMask,False)

print 'sufficently spaced photons:',np.sum(spacingMask)


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
normModEnergies = modEnergies/np.mean(modEnergies)
#energyTau = tau*normModEnergies**.5 #give tau a little energy dependence
expTails = modEnergies*np.exp(-timeSpacing/tau)

expPeaks = expTails+smoothBases
expEnergies = modEnergies-expTails
expMask = expEnergies<threshold
notExpMask = expMask==False
expEnergiesCut = expEnergies[expMask]

filteredIdx = np.array(np.arange(10000,100000),dtype=np.int)
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

nBins = 100
energyHist,energyHistBins = np.histogram(energies,bins=nBins,density=True)
modEnergyHist,modEnergyHistBins = np.histogram(modEnergies,bins=nBins,density=True)
expEnergyCutHist,expEnergyCutHistBins = np.histogram(expEnergiesCut,bins=nBins,density=True)

#peakHist,peakHistBins = np.histogram(peaks,bins=nBins,density=True)
#baseHist,baseHistBins = np.histogram(bases,bins=nBins,density=True)
#expEnergyHist,expEnergyHistBins = np.histogram(energies,bins=nBins,density=True)
#fig = plt.figure()
#ax = fig.add_subplot(111)
#ax.step(peakHistBins[0:-1],peakHist,'c')
#ax.step(baseHistBins[0:-1],baseHist,'k')
#ax.step(energyHistBins[0:-1],energyHist,'b')

resolutionDict = fitR(energies)
modResolutionDict = fitR(expEnergiesCut)

modEnergyHist,modEnergyHistBins = np.histogram(modEnergies,bins=nBins,density=True)
farEnergyHist,farEnergyHistBins = np.histogram(farEnergies,bins=nBins,density=True)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.step(energyHistBins[0:-1],energyHist,'b')
ax.step(expEnergyCutHistBins[0:-1],expEnergyCutHist,'y')
ax.plot(resolutionDict['energyHistBinEdges'][0:-1],resolutionDict['gaussfit'],'m')
ax.plot(modResolutionDict['energyHistBinEdges'][0:-1],modResolutionDict['gaussfit'],'purple')


#energies=modEnergies
#energyHist = modEnergyHist
#energyHistBins = modEnergyHistBins

    
print 'Standard deviations:'
print 'raw baselines',np.std(bases)
#print 'new baselines',np.std(newBases)
print 'smoothed baselines',np.std(smoothBases)
print 'raw peaks',np.std(peaks)
print 'peak-rawBases',np.std(energies)
print 'time_cut peak-rawBases',np.std(farEnergies)
print 'peak-smoothBases',np.std(modEnergies)
print 'raw R=',resolutionDict['resolution']
print 'mod R=',modResolutionDict['resolution']
plt.show()
