import numpy as np
import matplotlib.pyplot as plt
import time

def tone(freq,nSamples,sampleRate):
    dt = 1/sampleRate
    time = np.arange(0,nSamples)*dt
    out = np.exp(2*np.pi*1.j*freq*time)
    #out = np.cos(2*np.pi*freq*time)
    return out

def pfb(x,nTaps=4,fftSize=512,binWidthScale=2.5,windowType='hanning'):
    windowSize = nTaps*fftSize
    angles = np.arange(-nTaps/2.,nTaps/2.,1./fftSize)
    window = np.sinc(binWidthScale*angles)
    if windowType == 'hanning':
        window *= np.hanning(windowSize)

    out = np.zeros(len(x)-windowSize,np.complex128)
    for i in xrange(0,len(out),fftSize):
        windowedChunk = x[i:i+windowSize]*window
        out[i:i+fftSize] = windowedChunk.reshape(nTaps,fftSize).sum(axis=0)
    return out

def dftSingle(signal,n,freqIndex):
    indices = np.arange(0,n)
    signalCropped = signal[0:n]
    dft = np.sum(signalCropped*np.exp(-2*np.pi*1.j*indices*freqIndex/N))
    return dft

fftSize=512
nTaps=4
nSamples = 4*nTaps*fftSize
sampleRate = 512.e6
freqList = np.linspace(6.01e6,14.e6-0.01e6,0.01e6)

nFreq = len(freqList)
freqIndex = 10.#10MHz
freqResponseFFT = np.zeros(nFreq)
freqResponsePFB = np.zeros(nFreq)
for iFreq,freq in enumerate(freqList):
    if iFreq % (nFreq/10) == 0:
        print iFreq // (nFreq/10),'of 10'
    signal = tone(freq,nSamples,sampleRate)

    fft = (np.fft.fft(signal,fftSize))
    fft /= fftSize
    fftBin = np.abs(fft[freqIndex])
    freqResponseFFT[iFreq] = fftBin

    fft = (np.fft.fft(pfb(signal,fftSize=fftSize,nTaps=nTaps),fftSize))
    fft /= fftSize
    fftBin = np.abs(fft[freqIndex])
    freqResponsePFB[iFreq] = fftBin

freqResponseFFT = 10*np.log10(freqResponseFFT)
freqResponsePFB = 10*np.log10(freqResponsePFB)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(freqList,freqResponseFFT)
ax.plot(freqList,freqResponsePFB)

plt.show()

