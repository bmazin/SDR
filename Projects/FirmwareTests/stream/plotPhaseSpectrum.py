"""
File:      parsePhaseDump.py
Author:    Matt Strader

"""

import matplotlib, time, struct
import matplotlib.pyplot as plt
import numpy as np
import sys

def getSpectrum(phases,nBins=2**17,sampleRate=1.e6/1.024):
    if nBins is None:
        nBins = len(phases)
        nAvgs = 1
    else:
        nAvgs = len(phases)//nBins
        nPts = nAvgs*nBins
        phases = phases[:nPts]
    dt = 1./sampleRate
    freqs = np.fft.rfftfreq(nBins,d=dt)

    phasesTable = np.reshape(phases,(nAvgs,nBins))
    print np.shape(phasesTable)
    spectra = 1.*np.fft.rfft(phasesTable)
    print np.shape(spectra)
    spectrum = np.average(spectra,axis=0)/nBins
    print np.shape(spectrum)
    spectrumDb = 20.*np.log10(np.abs(spectrum))
    return {'nBins':nBins,'nAvgs':nAvgs,'freqs':freqs,'spectrum':spectrum,'spectrumDb':spectrumDb}

def plotSpectrum(specDict):
    fig,ax = plt.subplots(1,1)
    kHz = 1.e3
    freqsKHz = specDict['freqs']/kHz
    spectrumDb = specDict['spectrumDb']
    print np.shape(freqsKHz),np.shape(spectrumDb)
    ax.step(freqsKHz,spectrumDb)
    ax.set_xlabel('frequency (kHz)')
    ax.set_ylabel('power (dB)')

def parsePhaseDumpFile(path):
    dumpFile = open(path,'rb')
    data = dumpFile.read()
    dumpFile.close()

    nBytes = len(data)
    nWords = nBytes/8 #64 bit words
    #break into 64 bit words
    words = np.array(struct.unpack('>{:d}Q'.format(nWords), data),dtype=object)

    #first let's remove header words, which start with 8 ones
    headerFirstByte = 0xff
    firstBytes = words >> (64-8)
    print nWords,' words parsed'
    words = words[np.where(firstBytes != headerFirstByte)]
    print len(words),' phase words parsed'
    nWords = len(words)
    print words[:5]

    nBitsPerPhase = 12
    binPtPhase = 9
    nPhasesPerWord = 5
    #to parse out the 5 12-bit values, we'll shift down the bits we don't want for each value, then apply a bitmask to take out
    #bits higher than the 12 we want
    #The least significant bits in the word should be the earliest phase, so the first column should have zero bitshift
    bitmask = int('1'*nBitsPerPhase,2)
    bitshifts = nBitsPerPhase*np.arange(nPhasesPerWord)

    #add an axis so we can broadcast
    #and shift away the bits we don't keep for each row
    phases = (words[:,np.newaxis]) >> bitshifts
    phases = phases & bitmask

    #now we have a nWords x nPhasesPerWord array

    #flatten so that the phases are in order
    phases = phases.flatten(order='C')
    phases = np.array(phases,dtype=np.uint64)
    signBits = np.array(phases / (2**(nBitsPerPhase-1)),dtype=np.bool)

    #check the sign bits to see what values should be negative
    #for the ones that should be negative undo the 2's complement, and flip the sign
    phases[signBits] = ((~phases[signBits]) & bitmask)+1
    phases = np.array(phases,dtype=np.double)
    phases[signBits] = -phases[signBits]
    #now shift down to the binary point
    phases = phases / 2**binPtPhase

    #convert from radians to degrees
    phases = 180./np.pi * phases
    print phases[:5]
    print len(phases), 'phases parsed'
    return {'phasesDeg':phases}



#path = '/mnt/data0/MkidDigitalReadout/DataReadout/ChannelizerControls/phase_dump_pixel_0_8_7_2016_18_53.bin'
if __name__=='__main__':
    path = sys.argv[1]
    print path
    parseDict = parsePhaseDumpFile(path)
    plt.plot(parseDict['phasesDeg'][:1000],'.-')

    specDict = getSpectrum(parseDict['phasesDeg'])
    plotSpectrum(specDict)

    plt.show()
