import numpy as np
import matplotlib.pyplot as plt
import scipy.signal
import multiprocessing
import functools
from baselineIIR import IirFilter


#def runTrial(wvlPair,allWavelengths,fullExp):
#    wvlStart,wvlEnd = wvlPair
#
#    startIndex = np.searchsorted(allWavelengths,wvlStart)
#    endIndex = np.searchsorted(allWavelengths,wvlEnd)
#
#    metricDict = h_test_select(fullExp,startIndex,endIndex)
#    metric,pval,nPhotons = metricDict['H'],metricDict['fpp'],metricDict['nEvents']
#    sig = nSigma(1-pval)
#
#    outDict = {'nPhotons':nPhotons,'wvlRange':wvlPair,'metric':metric,'pval':pval,'nSigma':sig}
#    return outDict

def runFilter(filterCoeffs,data):
    filteredData = scipy.signal.fftconvolve(data[np.newaxis,:],filterCoeffs[np.newaxis,:],mode='valid')
    criticalFreq = 200. #Hz
    sampleRate=1.e6
    f=2*np.sin(np.pi*criticalFreq/sampleRate)
    Q=.7
    q=1./Q
    hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
    filteredData = hpSvf.filterData(filteredData)


    return filteredData

if __name__=='__main__':
#    date='20121204'
#    roachNum = 4
#    pixelNum = 102
#    label = '30tap_slowBase'
    date='20160301'
    roachNum = 0
    pixelNum = 0
    label = 'sim_high'
    wienerFile = np.load('/Scratch/dataProcessing/filterTests/wiener_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))
    matchedFile = np.load('/Scratch/dataProcessing/filterTests/matched_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))

    rawdata = wienerFile['rawdata']
    #finalFilterCoeffs=finalFilterCoeffs,finalTemplate=finalTemplate,roughTemplate=roughTemplate,noiseSpectrum=noiseSpectrum,data=data)
    wienerFilterCoeffs = wienerFile['finalFilterCoeffs'].real
    template = wienerFile['finalTemplate']
    noiseSpectrum = wienerFile['noiseSpectrum']
    matchedFilter = matchedFile['matchedFilter']
    superMatchedFilter = matchedFile['superMatchedFilter']

    wienerFilterCoeffs = wienerFilterCoeffs * 3./np.sum(wienerFilterCoeffs**2)
    template = template * 1.5 / np.sum(template**2)
    matchedFilter = matchedFilter *1.5 / np.sum(matchedFilter**2)
    superMatchedFilter = superMatchedFilter *1.5 / np.sum(superMatchedFilter**2)

    wienerOffset = np.argmax(wienerFilterCoeffs)
    templateOffset = np.argmax(template)
    matchedOffset = np.argmax(matchedFilter)
    superMatchedOffset = np.argmax(superMatchedFilter)

    bPlotCoeffs = True
    if bPlotCoeffs:
        fig,ax = plt.subplots(1,1)
        ax.plot(wienerFilterCoeffs,'r.-',label='weiner')
        ax.plot(template,'k.-',label='template')
        ax.plot(matchedFilter,'b.-',label='matched')
        ax.plot(superMatchedFilter,'c.-',label='super matched')

    filters = [template,wienerFilterCoeffs,matchedFilter,superMatchedFilter]
    runFilterFunc = functools.partial(runFilter,data=rawdata)
    pool = multiprocessing.Pool(processes=multiprocessing.cpu_count()-1)
    resultsList = pool.map(runFilterFunc,filters)
    resultsList = [resultData[0,:] for resultData in resultsList] #throw out the extra, unneeded dimension

    templateFilteredData,wienerFilteredData,matchedFilteredData,superMatchedFilteredData = resultsList
    convolveOffset = len(rawdata)-len(templateFilteredData)
    rawdata = rawdata[convolveOffset:]
    print templateOffset,matchedOffset,wienerOffset
    templateFilteredData = np.roll(templateFilteredData,-templateOffset)
    matchedFilteredData = np.roll(matchedFilteredData,-matchedOffset)
    superMatchedFilteredData = np.roll(superMatchedFilteredData,-superMatchedOffset)
    wienerFilteredData = np.roll(wienerFilteredData,-wienerOffset)

    np.savez('/Scratch/dataProcessing/filterTests/filteredDataSubBase_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),rawdata=rawdata,wienerFilterCoeffs=wienerFilterCoeffs,template=template,matchedFilter=matchedFilter,noiseSpectrum=noiseSpectrum,templateFilteredData=templateFilteredData,wienerFilteredData=wienerFilteredData,matchedFilteredData=matchedFilteredData,superMatchedFilteredData=superMatchedFilteredData)
    print 'done save'

    endIdx = 100000
    bPlotPeaks = True
    if bPlotPeaks:
        fig,ax = plt.subplots(1,1)
        ax.plot(rawdata[0:endIdx],'.-',color='gray',label='raw')
        ax.plot(templateFilteredData[0:endIdx],'.-',color='k',label='template')
        ax.plot(wienerFilteredData[0:endIdx],'.-',color='r',label='wiener')
        ax.plot(matchedFilteredData[0:endIdx],'.-',color='b',label='matched')
        ax.plot(superMatchedFilteredData[0:endIdx],'.-',color='c',label='super matched')
        ax.legend(loc='best')
    print 'done plot'

    plt.show()
