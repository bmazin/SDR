import numpy as np
import matplotlib.pyplot as plt
from fitFunctions import gaussian
import mpfit
import scipy.stats
import scipy.interpolate

def smoothBaseline(baselines,nPtsInMode=50):
    modBases = np.array(baselines)
    for i in range(len(modBases)):
        startIdx = i-nPtsInMode//2
        if startIdx < 0:
            startIdx = 0
        endIdx = i+nPtsInMode//2
        if endIdx >= len(modBases):
            endIdx = len(modBases)-1
        trimmedSample = scipy.stats.mstats.trim(baselines[startIdx:endIdx],(.1,.1),relative=True)
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

    nBins=100
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

    parinfo = [ {'n':0,'value':params[0],'limits':[1., 500.], 'limited':[True,True],'fixed':False,'parname':"Sigma",'error':0},
       {'n':1,'value':params[1],'limits':[x_offset-sigma*2, x_offset+sigma*2],'limited':[True,True],'fixed':False,'parname':"x offset",'error':0},
       {'n':2,'value':params[2],'limits':[1., 2.*amplitude],'limited':[True,True],'fixed':False,'parname':"Amplitude",'error':0},
       {'n':3,'value':params[3],'limited':[False,False],'fixed':False,'parname':"y_offset",'error':0}]

    fa = {'x':energyHistBinEdges[0:-1],'y':energyHist,'err':errs}

    m = mpfit.mpfit(gaussian, functkw=fa, parinfo=parinfo, maxiter=1000, quiet=quiet)
    if (quiet == False):
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

roachNum=4
pixelNum=0
npz = np.load('detected700Blue.npz')
bases=npz['bases']
peaks=npz['peaks']+bases
energies=npz['energies']
baselines=npz['baselines']
threshold=npz['threshold']
idx=npz['idx']
qdrValues=npz['qdrValues']
filtered=npz['filtered']

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
smoothBases = smoothBaseline(goodBases,idx/1.e6)


closeSpacingMask = timeSpacing < 100

modEnergies = peaks-smoothBases
tau=25.
expTails = modEnergies*np.exp(-timeSpacing/tau)
expPeaks = expTails+smoothBases
closeExpPeaks = peaks[closeSpacingMask]-expTails[closeSpacingMask]
expEnergies = modEnergies-expTails

sampleStart=5000
fig = plt.figure()
ax = fig.add_subplot(111)
filteredIdx = np.array(np.arange(10000,20000),dtype=np.int)
ax.plot(filteredIdx,filtered[filteredIdx],'y-')
#ax.plot(filtered,'y-')
ax.plot(idx-sampleStart,peaks-expTails,'c.')
ax.plot(idx[closeSpacingMask]-sampleStart,peaks[closeSpacingMask]-expTails[closeSpacingMask],'b.')
ax.plot(idx-sampleStart,smoothBases,'k')
print threshold
ax.plot(idx-sampleStart,smoothBases+threshold,'r')

print 'peaks:',len(peaks),'deadtime peaks',np.sum(closeSpacingMask),'false peaks',np.sum(expEnergies[closeSpacingMask]>threshold)
print 'deadtime peaks','%.2f%%'%(100.*np.sum(closeSpacingMask)/len(peaks)),'false deadtime peaks','%.2f%%'%(100.*np.sum(expEnergies[closeSpacingMask]>threshold)/np.sum(closeSpacingMask))

nBins = 100
energyHist,energyHistBins = np.histogram(energies,bins=nBins,density=True)
modEnergyHist,modEnergyHistBins = np.histogram(modEnergies,bins=nBins,density=True)
expEnergyHist,expEnergyHistBins = np.histogram(expEnergies,bins=nBins,density=True)

#fig = plt.figure()
#ax = fig.add_subplot(111)
#ax.step(peakHistBins[0:-1],peakHist,'c')
#ax.step(baseHistBins[0:-1],baseHist,'k')
#ax.step(energyHistBins[0:-1],energyHist,'b')
#
#nBins = 200
#peakHist,peakHistBins = np.histogram(farPeaks,bins=nBins)
#baseHist,baseHistBins = np.histogram(farBases,bins=nBins)
#energyHist,energyHistBins = np.histogram(farEnergies,bins=nBins)

resolutionDict = fitR(energies)
modResolutionDict = fitR(modEnergies)

modEnergyHist,modEnergyHistBins = np.histogram(modEnergies,bins=nBins,density=True)
farEnergyHist,farEnergyHistBins = np.histogram(farEnergies,bins=nBins,density=True)
closeEnergyHist,closeEnergyHistBins = np.histogram(energies[np.logical_not(spacingMask)],bins=nBins,density=True)
modFarEnergyHist,modFarEnergyHistBins = np.histogram(modEnergies[spacingMask],bins=nBins,density=True)
modCloseEnergyHist,modCloseEnergyHistBins = np.histogram(modEnergies[np.logical_not(spacingMask)],bins=nBins,density=True)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.step(energyHistBins[0:-1],energyHist,'b')
ax.step(modEnergyHistBins[0:-1],modEnergyHist,'g')
ax.step(expEnergyHistBins[0:-1],expEnergyHist,'y')
ax.plot(resolutionDict['energyHistBinEdges'][0:-1],resolutionDict['gaussfit'],'m')
ax.plot(modResolutionDict['energyHistBinEdges'][0:-1],modResolutionDict['gaussfit'],'purple')


#energies=modEnergies
#energyHist = modEnergyHist
#energyHistBins = modEnergyHistBins

baseDiffs = np.abs(bases-smoothBases)
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(timeSpacing,baseDiffs,',')
ax.plot(timeSpacing[spacingMask],np.abs(farBases-smoothBases[spacingMask]),',')

    
print 'Standard deviations:'
print 'raw baselines',np.std(bases)
print 'smoothed baselines',np.std(smoothBases)
print 'raw peaks',np.std(peaks)
print 'peak-rawBases',np.std(energies)
print 'time_cut peak-rawBases',np.std(farEnergies)
print 'peak-smoothBases',np.std(modEnergies)
print 'raw R=',resolutionDict['resolution']
print 'mod R=',modResolutionDict['resolution']
plt.show()
