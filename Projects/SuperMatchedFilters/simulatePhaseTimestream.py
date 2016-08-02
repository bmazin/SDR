from matplotlib import rcParams, rc
import numpy as np
import sys
from fitFunctions import gaussian
import scipy.interpolate
import scipy.signal
import matplotlib.pyplot as plt
import os
import struct

if __name__=='__main__':

    #identify which pixel and files we want
    roachNum = 0
    pixelNum = 0
    nSecs=50
    rootFolder = '/Scratch/filterData/'
    cps=1000  #counts (pulses) per sec
    date = '20160301'
    label='{}cps_sim_high'.format(cps)
    print label
    folder = os.path.join(rootFolder,date)
    phaseFilename = os.path.join(folder,'ch_snap_r{}p{}_{}.dat'.format(roachNum,pixelNum,label))
    print phaseFilename

    phaseFile = open(phaseFilename,'w')

    nQdrWords=2**19 #for firmware with  qdr longsnap
    nBytesPerWord=4 #bytes in each qdr row/word
    nBytesPerSample=2 #bytes in a fix16_13 phase sample

    nSamples = nQdrWords*(nBytesPerWord/nBytesPerSample)*nSecs
    print nSamples,'samples'

    np.random.seed(0)
    phaseValuesDeg = np.random.normal(loc=0.,scale=5.,size=nSamples)

    bSineNoise = True
    if bSineNoise:
        sineNoiseFreq = 2.*np.pi/23.
        sineNoiseAmpDeg = 10.
        sineNoise = sineNoiseAmpDeg*np.sin(sineNoiseFreq*np.arange(nSamples))
        phaseValuesDeg += sineNoise

    bShiftingBaseline = True
    if bShiftingBaseline:
        sineNoiseFreq = 2.*np.pi/10023. #lower frequency than can be captured in 800 tap filters
        sineNoiseAmpDeg = 5.
        baseline = sineNoiseAmpDeg*np.sin(sineNoiseFreq*np.arange(nSamples))
        phaseValuesDeg += baseline

    #add some pulses
    nPulses = cps*nSecs
    lowIndex = 0
    highIndex = nSamples - 1
    pulseArrivalIndices = np.random.random_integers(low=lowIndex,high=highIndex,size=nPulses)
    pulseAmpDeg = 100.
    #create a decaying exponential for the tail
    pulseDecayTime = 200. #us (samples)
    nPulseSamples = pulseDecayTime*5
    t = np.arange(nPulseSamples)
    pulseTemplate = -pulseAmpDeg*np.exp(-t/pulseDecayTime)

    for iPulse in xrange(nPulses):
        pulseArrivalIdx = pulseArrivalIndices[iPulse]
        if pulseArrivalIdx+nPulseSamples < nSamples:
            phaseValuesDeg[pulseArrivalIdx:pulseArrivalIdx+nPulseSamples] += pulseTemplate

    phaseValuesRad = phaseValuesDeg*np.pi/180.
    intValues = np.array(phaseValuesRad*2**13,dtype=np.int16) #convert to fix16_13
    print intValues[0:10]
    print phaseValuesRad[0:10]
    print phaseValuesDeg[0:10]
    print np.array(intValues[0:10],dtype=np.uint16)
    print len(intValues)
    phaseStr = struct.pack('>%dh'%(nSamples),*intValues)
    print len(phaseStr)
    phaseFile.write(phaseStr)

    fig,ax = plt.subplots(1,1)
    ax.plot(pulseTemplate)

    fig,ax = plt.subplots(1,1)
    ax.plot(phaseValuesDeg[0:100000])
    plt.show()
