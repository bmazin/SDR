import numpy as np
import matplotlib.pyplot as plt
import scipy.signal

def tone(freq,nSamples,sampleRate):
    dt = 1/sampleRate
    time = np.arange(0,nSamples)*dt
    out = np.exp(2*np.pi*1.j*freq*time)
    #out = np.cos(2*np.pi*freq*time)
    return out

def pfb(x,nTaps=4,fftSize=512,binWidthScale=2.,windowType='hanning'):
    windowSize = nTaps*fftSize
    angles = np.arange(-nTaps/2.,nTaps/2.,1./fftSize)
    window = np.sinc(binWidthScale*angles)
    if windowType == 'hanning':
        window *= np.hanning(windowSize)

    nFFTChunks = len(x)//fftSize
    #it takes a windowSize worth of x values to get the first out value, so there will be windowsize fewer values in out, assuming x divides evenly by fftSize
    out = np.zeros(nFFTChunks*fftSize-windowSize,np.complex128)
    for i in xrange(0,len(out),fftSize):
        windowedChunk = x[i:i+windowSize]*window
        out[i:i+fftSize] = windowedChunk.reshape(nTaps,fftSize).sum(axis=0)
    return out

def dftSingle(signal,n,binIndex):
    indices = np.arange(0,n)
    signalCropped = signal[0:n]
    dft = np.sum(signalCropped*np.exp(-2*np.pi*1.j*indices*binIndex/N))
    return dft

instrument = 'darkness'#'darkness'
if instrument == 'arcons':
    fftSize=512 #2**11
    nTaps=4
    sampleRate = 512.e6
    clockRate = 256.e6
else:
    fftSize=2048 #2**11
    nTaps=4
    sampleRate = 1.8e9
    clockRate = 225.e6

binOversamplingRate = 2. #number of samples from the same bin used in a clock cycle
nSimultaneousInputs = sampleRate/clockRate #number of consecutive samples (from consecutive channels) used in a clock cycle
binSpacing = sampleRate/fftSize #space between fft bin centers
binSampleRate = binOversamplingRate*nSimultaneousInputs*clockRate/fftSize #each fft bin is sampled at this rate

resFreq = 10.3e6 #Hz
binIndex = round(resFreq/binSpacing) #nearest FFT freq bin to resFreq
binFreq = binIndex*binSpacing #bin center frequency at binIndex

nSamples = 4*nTaps*fftSize
freqStep = 0.01e6
#1st stage, apply pfb and fft
freqList = np.arange(binFreq-4.e6, binFreq+4.e6, freqStep)
nFreq = len(freqList)
freqResponseFFT = np.zeros(nFreq,dtype=np.complex128)
freqResponsePFB = np.zeros(nFreq,dtype=np.complex128)
#sweep through frequencies
for iFreq,freq in enumerate(freqList):
    signal = tone(freq,nSamples,sampleRate)

    fft = (np.fft.fft(signal,fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponseFFT[iFreq] = fftBin

    fft = (np.fft.fft(pfb(signal,fftSize=fftSize,nTaps=nTaps),fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponsePFB[iFreq] = fftBin


freqResponseFFTdb = 10*np.log10(np.abs(freqResponseFFT))
freqResponsePFBdb = 10*np.log10(np.abs(freqResponsePFB))

#2nd stage, shift res freq to zero and apply low pass filter
normFreqStep = freqStep*2*np.pi/binSampleRate
#binBandNormFreqs = np.arange(-np.pi-10*normFreqStep,np.pi,normFreqStep)
binBandNormFreqs = (freqList-resFreq)*2*np.pi/binSampleRate # frequencies in bandwidth of a fft bin[rad/sample]
lpfCutoff = 250.e3# 250 kHz in old firmware, should probably be 512 kHz
lpf = scipy.signal.firwin(20, cutoff=lpfCutoff, nyq=binSampleRate/2.,window='hanning')
_,freqResponseLPF = scipy.signal.freqz(lpf, worN=binBandNormFreqs)
freqResponseLPFdb = 10*np.log10(np.abs(freqResponseLPF))
binBandFreqs = resFreq+binBandNormFreqs*binSampleRate/(2.*np.pi)

freqResponse = freqResponseLPF*freqResponsePFB
phaseResponse = np.unwrap(np.angle(freqResponse))*180./np.pi
phaseResponseLPF = np.unwrap(np.angle(freqResponseLPF))*180./np.pi
phaseResponsePFB = np.unwrap(np.angle(freqResponsePFB))*180./np.pi
freqResponseDB = 10.*np.log10(np.abs(freqResponse))

freqListMHz = freqList/1.e6
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(freqListMHz,freqResponsePFBdb,label='FFT bin')
#ax.plot(freqListMHz,freqResponseFFTdb)
#ax.plot(freqListMHz,freqResponseLPFdb)
ax.plot(freqListMHz,freqResponseDB,label='final channel')
ax.set_ylim(-50,0)
ax.set_ylabel('response (dB)')
ax.set_xlabel('frequency (MHz)')
ax.legend(loc='best')

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(freqListMHz,phaseResponse,label='overall')
ax.plot(freqListMHz,phaseResponseLPF,label='LPF')
ax.plot(freqListMHz,phaseResponsePFB,label='FFT')
ax.set_ylabel('phase response ($^\circ$)')
ax.set_xlabel('frequency (MHz)')
ax.legend(loc='best')

plt.show()

