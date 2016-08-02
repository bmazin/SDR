import numpy as np
import matplotlib.pyplot as plt
import scipy.signal

if __name__=='__main__':
#    date='20121204'
#    roachNum = 4
#    pixelNum = 102
#    label = '30tap_slowBase'
    date='20160301'
    roachNum = 0
    pixelNum = 0
    label = 'sim_line'
    wienerFile = np.load('/Scratch/dataProcessing/filterTests/wiener_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))
    matchedFile = np.load('/Scratch/dataProcessing/filterTests/matched_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label))

    rawdata = wienerFile['rawdata']
    #finalFilterCoeffs=finalFilterCoeffs,finalTemplate=finalTemplate,roughTemplate=roughTemplate,noiseSpectrum=noiseSpectrum,data=data)
    wienerFilterCoeffs = wienerFile['finalFilterCoeffs'].real
    wienerFilterCoeffs = wienerFilterCoeffs / (25.*np.max(np.abs(wienerFilterCoeffs)))
    template = wienerFile['finalTemplate']
    template = template / (25.*np.max(template))
    noiseSpectrum = wienerFile['noiseSpectrum']
    matchedFilter = matchedFile['matchedFilter']
    matchedFilter = matchedFilter / (25.*np.max(matchedFilter))

    bPlotCoeffs = True
    if bPlotCoeffs:
        fig,ax = plt.subplots(1,1)
        ax.plot(wienerFilterCoeffs,'r.-',label='weiner')
        ax.plot(template,'k.-',label='template')
        ax.plot(matchedFilter,'b.-',label='matched')

    endIdx = 100000
    templateFilteredData = scipy.signal.lfilter(template,1,rawdata)
    wienerFilteredData = scipy.signal.lfilter(wienerFilterCoeffs,1,rawdata)
    matchedFilteredData = scipy.signal.lfilter(matchedFilter,1,rawdata)

    np.savez('/Scratch/dataProcessing/filterTests/filteredData_{}_r{}p{}_{}.npz'.format(date,roachNum,pixelNum,label),rawdata=rawdata,wienerFilterCoeffs=wienerFilterCoeffs,template=template,matchedFilter=matchedFilter,noiseSpectrum=noiseSpectrum,templateFilteredData=templateFilteredData,wienerFilteredData=wienerFilteredData,matchedFilteredData=matchedFilteredData)

    bPlotPeaks = True
    if bPlotPeaks:
        fig,ax = plt.subplots(1,1)
        ax.plot(rawdata[0:endIdx],'.-',color='gray',label='raw')
        ax.plot(templateFilteredData[0:endIdx],'.-',color='k',label='template')
        ax.plot(wienerFilteredData[0:endIdx],'.-',color='r',label='wiener')
        ax.plot(matchedFilteredData[0:endIdx],'.-',color='b',label='matched')
        ax.legend(loc='best')

    plt.show()
