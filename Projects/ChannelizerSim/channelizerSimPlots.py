import numpy as np
import matplotlib.pyplot as plt
import scipy.signal
    

def tone(freq,nSamples,sampleRate,initialPhase=0.):
    dt = 1/sampleRate
    time = np.arange(0,nSamples)*dt
    out = np.exp(1.j*(2*np.pi*freq*time+initialPhase))
    #out = np.cos(2*np.pi*freq*time)
    return out

def toneWithPhasePulse(freq,nSamples,sampleRate=512.e6,pulseAmpDeg=-35.,decayTime=30.e-6,riseTime=.5e-6,pulseArrivalTime=50.e-6,initialPhase=0.):
    dt = 1./sampleRate
    time = np.arange(0,nSamples)*dt
    pulseArrivalIndex = pulseArrivalTime//dt
    pulseAmp = np.pi/180.*pulseAmpDeg
    pulse = np.exp(-time[0:nSamples-pulseArrivalIndex]/decayTime)
    rise = np.exp(-time[0:pulseArrivalIndex]/riseTime)[::-1]
    paddedPulse = np.append(rise,pulse)
    phase = pulseAmp*paddedPulse
    out = np.exp(1.j*(2*np.pi*freq*time+phase+initialPhase))
    return out
    
def pfb(x,nTaps=4,fftSize=512,binWidthScale=2.5,windowType='hanning'):
    windowSize = nTaps*fftSize
    angles = np.arange(-nTaps/2.,nTaps/2.,1./fftSize)
    window = np.sinc(binWidthScale*angles)
    if windowType == 'hanning':
        window *= np.hanning(windowSize)

    nFftChunks = len(x)//fftSize
    #it takes a windowSize worth of x values to get the first out value, so there will be windowsize fewer values in out, assuming x divides evenly by fftSize
    out = np.zeros(nFftChunks*fftSize-windowSize,np.complex128)
    for i in xrange(0,len(out),fftSize):
        windowedChunk = x[i:i+windowSize]*window
        out[i:i+fftSize] = windowedChunk.reshape(nTaps,fftSize).sum(axis=0)
    return out

def dftBin(k,k0,m,N=512):
    return np.exp(1.j*m*np.pi*k0)*(1-np.exp(1.j*2*np.pi*k0))/(1-np.exp(1.j*2*np.pi/N*(k0-k)))

def dftSingle(signal,n,freqIndex):
    indices = np.arange(0,n)
    signalCropped = signal[0:n]
    dft = np.sum(signalCropped*np.exp(-2*np.pi*1.j*indices*freqIndex/N))
    return dft

instrument = 'arcons'#'darkness'
if instrument == 'arcons':
    fftSize=512 
    nPfbTaps=4
    sampleRate = 512.e6
    clockRate = 256.e6
    bFlipSigns = True
    lpfCutoff = 250.e3# 125 kHz in old firmware, should probably be 250 kHz
    nLpfTaps = 20
    binOversamplingRate = 2. #number of samples from the same bin used in a clock cycle
    downsample = 2
elif instrument == 'darkness':
    fftSize=2**12#2048 #2**11
    nPfbTaps=4
    sampleRate = 1.8e9
    clockRate = 225.e6
    bFlipSigns = True
    lpfCutoff = 250.e3# 125 kHz in old firmware, should probably be 250 kHz
    nLpfTaps = 20
    binOversamplingRate = 2. #number of samples from the same bin used in a clock cycle
    downsample = 1
nSimultaneousInputs = sampleRate/clockRate #number of consecutive samples (from consecutive channels) used in a clock cycle
binSpacing = sampleRate/fftSize #space between fft bin centers
binSampleRate = binOversamplingRate*nSimultaneousInputs*clockRate/fftSize #each fft bin is sampled at this rate
print 'instrument: ',instrument
print nSimultaneousInputs,' consecutive inputs'
print binSpacing/1.e6, 'MHz between bin centers'
print binSampleRate/1.e6, 'MHz sampling of fft bin'

lpf = scipy.signal.firwin(nLpfTaps, cutoff=lpfCutoff, nyq=binSampleRate/2.,window='hanning')

#Define the resonant frequency of interest
#resFreq = 10.99e6 #[Hz]
resFreq = 10.4e6 #[Hz]
binIndex = round(resFreq/binSpacing) #nearest FFT freq bin to resFreq
binFreq = binIndex*binSpacing #center frequency of bin at binIndex
print 'binFreq',binFreq

#Define some additional nearby resonant frequencies.  These should be filtered out of the channel of interest.
resSpacing = .501e6 #250 kHz minimum space between resonators
resFreq2 = resFreq-resSpacing#[Hz] Resonator frequency
resFreq3 = resFreq+resSpacing#[Hz] Resonator frequency
resFreqIndex = fftSize*resFreq/sampleRate
resFreqIndex2 = fftSize*resFreq2/sampleRate
resFreqIndex3 = fftSize*resFreq3/sampleRate
print 'nearest-k',binIndex
print 'freq',resFreq/1.e6,'MHz k0',resFreqIndex
print 'freq2',resFreq2/1.e6,'MHz k0',resFreqIndex2
print 'freq3',resFreq3/1.e6,'MHz k0',resFreqIndex3

nSamples = 4*nPfbTaps*fftSize
#Simulate the frequency response for a range of frequencies
freqStep = 0.01e6
freqResponseBandwidth = 8.e6
#1st stage, apply pfb and fft
freqList = np.arange(binFreq-freqResponseBandwidth/2, binFreq+freqResponseBandwidth/2, freqStep)
nFreq = len(freqList)
freqResponseFft = np.zeros(nFreq,dtype=np.complex128)
freqResponsePfb = np.zeros(nFreq,dtype=np.complex128)
#sweep through frequencies
for iFreq,freq in enumerate(freqList):
    signal = tone(freq,nSamples,sampleRate)

    fft = (np.fft.fft(signal,fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponseFft[iFreq] = fftBin

    fft = (np.fft.fft(pfb(signal,fftSize=fftSize,nTaps=nPfbTaps),fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponsePfb[iFreq] = fftBin


freqResponseFftDb = 10*np.log10(np.abs(freqResponseFft))
freqResponsePfbDb = 10*np.log10(np.abs(freqResponsePfb))

#2nd stage, shift res freq to zero and apply low pass filter
normFreqStep = freqStep*2*np.pi/binSampleRate
#binBandNormFreqs = np.arange(-np.pi-10*normFreqStep,np.pi,normFreqStep)
binBandNormFreqs = (freqList-resFreq)*2*np.pi/binSampleRate # frequencies in bandwidth of a fft bin[rad/sample]
_,freqResponseLpf = scipy.signal.freqz(lpf, worN=binBandNormFreqs)
freqResponseLpfDb = 10*np.log10(np.abs(freqResponseLpf))
binBandFreqs = resFreq+binBandNormFreqs*binSampleRate/(2.*np.pi)

freqResponse = freqResponseLpf*freqResponsePfb
phaseResponse = np.rad2deg(np.unwrap(np.angle(freqResponse)))
phaseResponseLpf = np.rad2deg(np.unwrap(np.angle(freqResponseLpf)))
phaseResponsePfb = np.rad2deg(np.unwrap(np.angle(freqResponsePfb)))
#phaseResponse = np.angle(freqResponse,deg=True)
#phaseResponseLpf = np.angle(freqResponseLpf,deg=True)
#phaseResponsePfb = np.angle(freqResponsePfb,deg=True)
freqResponseDb = 10.*np.log10(np.abs(freqResponse))

freqListMHz = freqList/1.e6
#Plot Response vs Frequency for 1st and 2nd stages
def f(fig,ax):
    ax.plot(freqListMHz,freqResponsePfbDb,label='FFT bin')
    #ax.plot(freqListMHz,freqResponseFftDb)
    #ax.plot(freqListMHz,freqResponseLpfDb)
    ax.plot(freqListMHz,freqResponseDb,label='final channel')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.axvline(resFreq2/1.e6,color='.8')
    ax.axvline(resFreq3/1.e6,color='.8')
    ax.set_ylim(-50,0)
    ax.set_ylabel('response (dB)')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='lower left')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

#Plot Response vs Phase for 1st and 2nd stages
def f(fig,ax):
    ax.plot(freqListMHz,phaseResponse,label='overall')
    ax.plot(freqListMHz,phaseResponseLpf,label='LPF')
    ax.plot(freqListMHz,phaseResponsePfb,label='FFT')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.axvline(resFreq2/1.e6,color='.8')
    ax.axvline(resFreq3/1.e6,color='.8')
    ax.set_ylabel('phase response ($^\circ$)')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='best')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

###################################################################
#Now we'll simulate the full channelizer with a probe tone at the resonant frequency
nSamples = 100*nPfbTaps*fftSize


#signal = tone(resFreq,nSamples,sampleRate)
signal = toneWithPhasePulse(resFreq,nSamples,sampleRate)

#add in other tones
signal += toneWithPhasePulse(resFreq2,nSamples,sampleRate,pulseAmpDeg=-90.,pulseArrivalTime=200.e-6,initialPhase=2.)
signal += toneWithPhasePulse(resFreq3,nSamples,sampleRate,pulseAmpDeg=-80.,pulseArrivalTime=300.e-6,initialPhase=1.)
#signal += tone(resFreq3,nSamples,sampleRate,initialPhase=1.)

time = np.arange(nSamples)/sampleRate/1.e-6 #in us
#signal = tone(resFreq,nSamples,sampleRate)+tone(10.e6,nSamples,sampleRate)

#Plot raw signal vs time coming in from ADC
def f(fig,ax):
    ax.plot(time,np.angle(signal),'r')
    ax.plot(time,np.abs(signal),'b')
    ax.set_xlabel('Time (us)')
    ax.set_title('Signal with Phase Pulse')
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

rawFftSize=100000
rawFft = 10*np.log10(np.fft.fftshift(np.abs(np.fft.fft(signal,n=rawFftSize)/rawFftSize)))
rawFreqs = sampleRate*np.fft.fftshift(np.fft.fftfreq(rawFftSize))/1.e6
#plot fft of raw signal
def f(fig,ax):
    ax.plot(rawFreqs,rawFft)
    ax.set_xlabel('Freq (MHz)')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nraw signal')
    ax.set_xlim((resFreq-2.*resSpacing)/1.e6,(resFreq+2.*resSpacing)/1.e6)
    ax.set_ylim(-35,5)
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

filteredSignal0 = pfb(signal[:-fftSize/2],fftSize=fftSize,nTaps=nPfbTaps)
filteredSignal1 = pfb(signal[fftSize/2:],fftSize=fftSize,nTaps=nPfbTaps)
#trim off end if the length doesn't evenly divide by fftSize
nFfts = len(filteredSignal0)//fftSize
filteredSignal0 = filteredSignal0[:nFfts*fftSize]
filteredSignal1 = filteredSignal1[:nFfts*fftSize]

foldedSignal0 = np.reshape(filteredSignal0,(nFfts,fftSize))
foldedSignal1 = np.reshape(filteredSignal1,(nFfts,fftSize))
ffts0 = np.fft.fft(foldedSignal0,n=fftSize,axis=1) #each row will be the fft of a row in foldedSignal
ffts1 = np.fft.fft(foldedSignal1,n=fftSize,axis=1) 

#flip signs for odd frequencies in every other bin sample
if bFlipSigns:
    ffts1[:,1::2] *= -1

binTimestream0 = ffts0[:,binIndex] #pick out values for the bin corresponding to resFreq
binTimestream1 = ffts1[:,binIndex] 


#binTimestream = binTimestream0
binTimestream = np.hstack(zip(binTimestream0,binTimestream1))#interleave timestreams
time = time[:len(filteredSignal0):fftSize/binOversamplingRate]

#Plot signal vs time coming out of FFT bin
def f(fig,ax):
    ax.plot(time,np.real(binTimestream),color='b')
    ax.plot(time,np.imag(binTimestream),color='r')
    ax.set_xlabel('Time (us)')
    ax.set_title('After 1st Stage')
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))


binFftSize=100 #Now for checking shifted frequencies in a bin
binFft = 10*np.log10(np.fft.fftshift(np.abs(np.fft.fft(binTimestream,n=binFftSize)/binFftSize)))
binFreqs = (binFreq+np.fft.fftshift(np.fft.fftfreq(binFftSize))*binSampleRate)/1.e6#MHz

#plot fft of signal coming out of FFT bin with frequencies shifted to show the resonant frequency
def f(fig,ax):
    ax.plot(binFreqs,binFft)
    ax.set_xlabel('Freq (MHz)')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nsampled FFT bin')
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

binFreqs = np.fft.fftshift(np.fft.fftfreq(binFftSize))

#plot fft of signal coming out of FFT bin
def f(fig,ax):
    ax.plot(binFreqs,binFft)
    ax.set_xlabel('Freq/$f_s$')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nsampled FFT bin')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

ddsTimestream = tone(freq=binFreq-resFreq,nSamples=len(binTimestream),sampleRate=binSampleRate)
channelTimestream = binTimestream*ddsTimestream

def f(fig,ax):
    ax.plot(time,np.abs(channelTimestream),color='b')
    ax.plot(time,np.angle(channelTimestream,deg=True),color='r')
    ax.set_title('After DDS')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))


channelFftSize=100 #Now for checking shifted frequencies in a bin
channelFft = 10*np.log10(np.fft.fftshift(np.abs(np.fft.fft(channelTimestream,n=channelFftSize)/channelFftSize)))
channelFreqs = (resFreq+np.fft.fftshift(np.fft.fftfreq(channelFftSize))*binSampleRate)/1.e6#MHz

#plot fft of signal coming out of DDS mixer with frequencies shifted to show the resonant frequency
def f(fig,ax):
    ax.plot(channelFreqs,channelFft)
    ax.set_xlabel('Freq (MHz)')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nDDS mixer output')
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

channelFreqs = np.fft.fftshift(np.fft.fftfreq(channelFftSize))

#plot fft of signal coming out of DDS mixer
def f(fig,ax):
    ax.plot(channelFreqs,channelFft)
    ax.set_xlabel('Freq/$f_s$')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nDDS mixer output')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))


channelTimestream = np.convolve(channelTimestream,lpf,mode='same')

channelTimestream = channelTimestream[::downsample]
time=time[::downsample]

finalFftSize=200 #Now for checking shifted frequencies in a bin
finalFft = 10*np.log10(np.fft.fftshift(np.abs(np.fft.fft(channelTimestream,n=finalFftSize)/finalFftSize)))
finalFreqs = (resFreq+np.fft.fftshift(np.fft.fftfreq(finalFftSize))*binSampleRate)/1.e6#MHz

#plot fft of signal coming out of DDS mixer with frequencies shifted to show the resonant frequency
def f(fig,ax):
    ax.plot(finalFreqs,finalFft)
    ax.set_xlabel('Freq (MHz)')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nLPF output')
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

finalFreqs = np.fft.fftshift(np.fft.fftfreq(finalFftSize))

#plot fft of signal coming out of DDS mixer
def f(fig,ax):
    ax.plot(finalFreqs,finalFft)
    ax.set_xlabel('Freq/$f_s$')
    ax.set_ylabel('Amp (dB)')
    ax.set_title('Frequency Content of\nLPF output')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))

phase = np.angle(channelTimestream,deg=True)[1:-1]
time = time[1:-1]
phaseOffset = phase[0]
phase -= phaseOffset #in readout, done by rotating IQ loops in templar

customFIR = np.loadtxt('matched_30us.txt')[::-1]
filteredPhase = np.convolve(phase,customFIR,mode='same')

def f(fig,ax):
    #ax.plot(time,np.abs(channelTimestream),color='b')
    ax.plot(time,phase,color='r',marker='.')
    ax.plot(time,filteredPhase,color='m',marker='.')
    ax.set_xlabel('Time (us)')
    ax.set_ylabel('Phase ($^{\circ}$)')
    ax.set_title('Output Phase')
fig,ax = plt.subplots(1,1)
f(fig,ax)
#pop(plotFunc=lambda gui: f(fig=gui.fig,ax=gui.axes))
plt.show()

