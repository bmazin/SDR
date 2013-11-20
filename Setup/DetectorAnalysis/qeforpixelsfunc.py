import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools

def peakfit(y1,y2,y3):
    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
    return y4

def binToDeg_12_9(binOffset12_9):
    x = binOffset12_9/2.0**9-4.0
    return x*180.0/np.pi

def NumPhotonInWVLPulses(qeDataFilename, qeObsTime, roach, pixlist, initial, peakw, troughw,  dectv, NSec=3600, nwvl=14, plotYorN= 'N', pause= 'N', pauseInitial=0, pausePeak=1, indicesTooCloseCutoff=3):
    
    delayforIR=3
    peaks=[]
    darkflux=[0,initial-2*indicesTooCloseCutoff]

    if pause=='Y':
        for x in xrange(0,pausePeak):
    	    init=initial+int((peakw+troughw)*x)
            fin=init+int(peakw)
            peaks.append(init)
            peaks.append(fin)
        for x in xrange(0,nwvl-pausePeak):
    	    init=pauseInitial+int((peakw+troughw+delayforIR)*x)
            fin=init+int(peakw)
            peaks.append(init)
            peaks.append(fin)
        for x in xrange(0,pausePeak):
            init=int(initial+peakw+2*indicesTooCloseCutoff+(peakw+troughw)*x)
            fin=init+int(troughw)-3*indicesTooCloseCutoff
            darkflux.append(init)
            darkflux.append(fin)
        for x in xrange(0,nwvl-pausePeak):
            init=int(pauseInitial+peakw+2*indicesTooCloseCutoff+(peakw+troughw+delayforIR)*x)
            fin=init+int(troughw+delayforIR)-3*indicesTooCloseCutoff
            darkflux.append(init)
            darkflux.append(fin)
    else:
        for x in xrange(0,nwvl):
            init=initial+int((peakw+troughw)*x)
            fin=init+int(peakw)
            peaks.append(init)
            peaks.append(fin)

    	for x in xrange(0,nwvl):
            init=int(initial+peakw+2*indicesTooCloseCutoff+(peakw+troughw)*x)
            fin=init+int(troughw)-3*indicesTooCloseCutoff
            darkflux.append(init)
            darkflux.append(fin)
    print 'The times indicating the beginning and end of each peak are'
    print peaks
    #print darkflux



    NPulses=[]
    pulseMask = int(12*'1',2)#bitmask of 12 ones

    fid = tables.openFile(qeDataFilename,mode='r')

    for pix in pixlist:
        photonSec=[]
        temp=[]
        pulseh=[[] for x in xrange(NSec)]
        dataset=fid.getNode('/r%d/p%d/t%d'%(roach,pix,qeObsTime))
        for ind, sec in enumerate(dataset):
            for packet in sec:
                pulseh[ind].append(1)
        #			packet = int(packet)
        #			beforePeak = binToDeg_12_9(packet>>44 & pulseMask)
        #			atPeak = binToDeg_12_9(packet>>32 & pulseMask)
        #			afterPeak = binToDeg_12_9(packet >> 20 & pulseMask)        #			if beforePeak+afterPeak-2*atPeak != 0:
        #				peak = peakfit(beforePeak,atPeak,afterPeak)
        #				pulseh[ind].append(peak) 
        # the peaks for all photons in each second is in its own row of pulseh
        for q in pulseh:
        	photonSec.append(len(q))

    	fin=[]
        tpeak=[]
        for i in xrange(0,len(peaks)/2):
            pk=np.average(photonSec[peaks[2*i]:peaks[2*i+1]])
            dk=np.average(photonSec[darkflux[2*i]:darkflux[2*i+1]]+photonSec[darkflux[2*i+2]:darkflux[2*i+3]])
            net=pk-dk
            fin.append(net)
            tpeak.append(np.average([peaks[2*i],peaks[2*i+1]]))
#            fin.append(pk)
        NPulses.append(fin)

        # photonSec has the total number of photons per second, 
        if plotYorN == 'Y':
        #            plt.plot(photonSec)
            fig=plt.figure()
            ax=fig.add_subplot(111)
            ax.plot(peaks,[0]*len(peaks),'ro')
            ax.plot(tpeak,fin,'bo')
            ax.plot(photonSec)
            ax.set_xlabel('Time')
            ax.set_ylabel('Number of Photons')
            ax.set_title('# Photons vs. Time r%dp%d'%(roach,pix))
            plt.grid(True)
            plt.show()
            plt.close()

    fid.close()
    return NPulses


def qeFuncOfWvl(qeDataFilename, qeObsTime, roach, pixel, ini, peakw, troughw,  dectv, NSec=3600, nwvl=14, plotYorN='N'):

    pixlist= [pixel]

    NPulses = NumPhotonInWVLPulses(qeDataFilename, qeObsTime, roach, pixlist, ini, peakw, troughw,  dectv, NSec, nwvl, plotYorN='N', indicesTooCloseCutoff=3)

    qeresults=[]

    for i in xrange(0,len(dectv)):
        qewvl=1/(dectv[i]*10**7/NPulses[0][i]*.0007096896)
        qeresults.append(qewvl)
    return qeresults
