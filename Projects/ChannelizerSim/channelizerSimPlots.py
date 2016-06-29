# File: channelizerSimPlots.py
# Author: Matt Strader
# This script simulates the functionality of the channelizer firmware
# used to read out ARCONS and similar MKID instruments
import numpy as np
import matplotlib.pyplot as plt
import scipy.signal
    

def tone(freq,nSamples,sampleRate,initialPhase=0.,toneAmp=1.):
    '''Creates an array of samples from a pure tone

    Parameters
    ----------
    freq : float
        The frequency of the tone in the same units as sampleRate
    nSamples : int
        number of samples of generated tone
    sampleRate : float
        the number of times the tone is sampled per unit of time.  Any appropriate units will work if consistent with freq
    initialPhase : float
        an optional phase offset for the beginning of the tone in radians
    
    Returns
    -------
    out : array of floats, length nSamples
        the generated tone
    '''
    dt = 1/sampleRate
    time = np.arange(0,nSamples)*dt
    out = toneAmp*np.exp(1.j*(2*np.pi*freq*time+initialPhase))
    #out = np.cos(2*np.pi*freq*time)
    return out

def toneWithPhasePulse(freq,nSamples,sampleRate=512.e6,pulseAmpDeg=-35.,decayTime=30.e-6,riseTime=.5e-6,pulseArrivalTime=50.e-6,initialPhase=0.,toneAmp=1.):
    '''Creates an array of samples from a tone with a phase pulse

    At a designated time, there is an exponential pulse in the sampled tone as might be seen in a readout tone passed
    through an MKID while a photon has struck. The amplitude portion of a photon hit is not simulated. 
    If the sampleRate is in Hz, all times (decayTime, riseTime, pulseArrivalTime) should be in seconds.

    Parameters
    ----------
    freq : float
        The frequency of the tone in the same units as sampleRate
    nSamples : int
        number of samples of generated tone
    sampleRate : float
        the number of times the tone is sampled per unit of time.  Any appropriate units will work if consistent with freq
    pulseAmpDeg : float
        the amplitude of the phase pulse in degrees
    decayTime : float
        the exponential decay time of the pulse
    riseTime : float
        the exponential rise time of the pulse
    pulseArrivalTime : float
        The time at which the phase pulse should occur.
    initialPhase : float
        an optional phase offset for the beginning of the tone in radians
    
    Returns
    -------
    out : array of floats, length nSamples
        the generated tone with the phase pulse
    '''
    dt = 1./sampleRate
    time = np.arange(0,nSamples)*dt
    pulseArrivalIndex = pulseArrivalTime//dt
    pulseAmp = np.pi/180.*pulseAmpDeg
    #create a decaying exponential for the tail
    pulse = np.exp(-time[0:nSamples-pulseArrivalIndex]/decayTime)
    #create an exponential and reverse it for the inital rise of the pulse
    rise = np.exp(-time[0:pulseArrivalIndex]/riseTime)[::-1]
    #create the combined pulse
    paddedPulse = np.append(rise,pulse)
    phase = pulseAmp*paddedPulse
    out = toneAmp*np.exp(1.j*(2*np.pi*freq*time+phase+initialPhase))
    return out
    
def pfb(x,nTaps=4,fftSize=512,binWidthScale=2.5,windowType='hamming'):
    '''Peforms a polyphase filter bank on input data

    A PFB is applied to data before performing an fft to change the frequency response characteristics of the fft
    In particular, the frequency response near the center of an fft bin can be made flatter with near unity gain
    and lessens the leakage from side lobes

    Parameters
    ----------
    x : array of floats
        The data to be filtered
    nTaps : int
        number of taps in the pfb
    binWidthScale : float
        values greater than one expand the width of the fft bin
    windowType : string
        at the moment accepted values are 'hanning' or None
    
    Returns
    -------
    out : array of floats
        the result of applying the pfb to x
    '''
    windowSize = nTaps*fftSize
    angles = np.arange(-nTaps/2.,nTaps/2.,1./fftSize)
    window = np.sinc(binWidthScale*angles)
    if windowType == 'hanning':
        window *= np.hanning(windowSize)
    elif windowType == 'hamming':
        window *= np.hamming(windowSize)

    nFftChunks = len(x)//fftSize
    #it takes a windowSize worth of x values to get the first out value, so there will be windowsize fewer values in out, assuming x divides evenly by fftSize
    out = np.zeros(nFftChunks*fftSize-windowSize,np.complex128)
    for i in xrange(0,len(out),fftSize):
        windowedChunk = x[i:i+windowSize]*window
        out[i:i+fftSize] = windowedChunk.reshape(nTaps,fftSize).sum(axis=0)
    return out


#Choose the instrument to simulate
instrument = 'darkness'#'darkness'
if instrument == 'arcons':
    fftSize=512 
    nPfbTaps=4
    sampleRate = 512.e6 #512 MHz
    clockRate = 256.e6
    bFlipSigns = True
    lpfCutoff = 125.e3#250.e3# 125 kHz in old firmware, should probably be 250 kHz
    nLpfTaps = 20
    binOversamplingRate = 2. #number of samples from the same bin used in a clock cycle
    downsample = 2
    pfbBinWidthScale = 2.5
    toneAmp=1.
elif instrument == 'darkness':
    fftSize=2**11#2048 #2**11
    nPfbTaps=4
    sampleRate = 2.e9
    clockRate = 250.e6
    bFlipSigns = True
    lpfCutoff = 125.e3
    nLpfTaps = 20
    binOversamplingRate = 2. #number of samples from the same bin used in a clock cycle
    downsample = 2
    pfbBinWidthScale = 2.
    toneAmp = 1.0
nSimultaneousInputs = sampleRate/clockRate #number of consecutive samples (from consecutive channels) used in a clock cycle
binSpacing = sampleRate/fftSize #space between fft bin centers
binSampleRate = binOversamplingRate*nSimultaneousInputs*clockRate/fftSize #each fft bin is sampled at this rate
print 'instrument: ',instrument
print nSimultaneousInputs,' consecutive inputs'
print binSpacing/1.e6, 'MHz between bin centers'
print binSampleRate/1.e6, 'MHz sampling of fft bin'


#Define the resonant frequency of interest
#resFreq = 10.99e6 #[Hz]
resFreq = 7.32421875e6 #(7.+3/8.)*1.e6 #[Hz]
#resFreq = 7.5*binSpacing
binIndex = round(resFreq/binSpacing) #nearest FFT freq bin to resFreq
binFreq = binIndex*binSpacing #center frequency of bin at binIndex
print 'binFreq',binFreq

#Define some additional nearby resonant frequencies.  These should be filtered out of the channel of interest.
#later we'll make some readout tones at these frequencies, add them in, and channelize to see that they're filtered
resSpacing = .501e6 #250 kHz minimum space between resonators
resFreq2 = 9.0e6#resFreq-resSpacing#[Hz] Resonator frequency
resFreq3 = resFreq+resSpacing#[Hz] Resonator frequency
resFreqIndex = fftSize*resFreq/sampleRate
resFreqIndex2 = fftSize*resFreq2/sampleRate
resFreqIndex3 = fftSize*resFreq3/sampleRate
print 'nearest-k',binIndex
print 'freq',resFreq/1.e6,'MHz k0',resFreqIndex
print 'freq2',resFreq2/1.e6,'MHz k0',resFreqIndex2
print 'freq3',resFreq3/1.e6,'MHz k0',resFreqIndex3

nSamples = 4*nPfbTaps*fftSize
#Calculate the frequency response for a range of frequencies
freqStep = 0.01e6
freqResponseBandwidth = 8.e6
#Frequency response for 1st stage of channelizer, apply pfb and fft to coarsely divide up frequency space

#make a list of frequencies for which we'll check the response
freqList = np.arange(binFreq-freqResponseBandwidth/2, binFreq+freqResponseBandwidth/2, freqStep)
nFreq = len(freqList)
freqResponseFft = np.zeros(nFreq,dtype=np.complex128)
freqResponsePfb = np.zeros(nFreq,dtype=np.complex128)
#sweep through frequencies
for iFreq,freq in enumerate(freqList):
    #for each frequency, see how much of it makes it into the fft bin of interest
    # for a standard fft and for a pfb
    signal = tone(freq,nSamples,sampleRate,toneAmp=toneAmp)

    fft = (np.fft.fft(signal,fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponseFft[iFreq] = fftBin

    fft = (np.fft.fft(pfb(signal,fftSize=fftSize,nTaps=nPfbTaps,binWidthScale=pfbBinWidthScale,windowType='hamming'),fftSize))
    fft /= fftSize
    fftBin = fft[binIndex]
    freqResponsePfb[iFreq] = fftBin


freqResponseFftDb = 20*np.log10(np.abs(freqResponseFft))
freqResponsePfbDb = 20*np.log10(np.abs(freqResponsePfb))

#Frequency response for 2nd stage of channelizer, shift res freq to zero and apply low pass filter
#this narrows the bin around the desired readout frequency
lpf = scipy.signal.firwin(nLpfTaps, cutoff=lpfCutoff, nyq=binSampleRate/2.,window='hanning')
arconsLpf = scipy.signal.firwin(nLpfTaps, cutoff=125.e3, nyq=1.e6,window='hanning')
print lpf
print arconsLpf

binBandNormFreqs = (freqList-resFreq)*2*np.pi/binSampleRate # frequencies in bandwidth of a fft bin[rad/sample]
_,freqResponseLpf = scipy.signal.freqz(lpf, worN=binBandNormFreqs)
freqResponseLpfDb = 20*np.log10(np.abs(freqResponseLpf))
binBandFreqs = resFreq+binBandNormFreqs*binSampleRate/(2.*np.pi)

#for the overall response after the lpf and pfb, multiply the curves we calculated earlier
freqResponse = freqResponseLpf*freqResponsePfb
phaseResponse = np.rad2deg(np.unwrap(np.angle(freqResponse)))
phaseResponseLpf = np.rad2deg(np.unwrap(np.angle(freqResponseLpf)))
phaseResponsePfb = np.rad2deg(np.unwrap(np.angle(freqResponsePfb)))
freqResponseDb = 20.*np.log10(np.abs(freqResponse))

freqListMHz = freqList/1.e6
#Plot Response vs Frequency for 1st and 2nd stages
def f(fig,ax):
    ax.plot(freqListMHz,freqResponsePfbDb,label='FFT bin')
    ax.plot(freqListMHz,freqResponseDb,label='final channel')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.axvline(resFreq2/1.e6,color='.8')
    ax.axvline(resFreq3/1.e6,color='.8')
    ax.set_ylim(-90,0)
    ax.set_ylabel('response (dB)')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='lower left')
fig,ax = plt.subplots(1,1)
f(fig,ax)

def f(fig,ax):
    ax.plot(freqListMHz,freqResponseFftDb,label='FFT bin')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.axvline(resFreq2/1.e6,color='.8')
    ax.axvline(resFreq3/1.e6,color='.8')
    ax.set_ylim(-50,0)
    ax.set_ylabel('response (dB)')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='lower left')
fig,ax = plt.subplots(1,1)
f(fig,ax)

def f(fig,ax):
    ax.plot(freqListMHz,freqResponseFft,label='FFT bin')
    ax.plot(freqListMHz,np.abs(freqResponsePfb),label='PFB bin')
    ax.axvline(resFreq/1.e6,color='.5',label='resonant freq')
    ax.axvline(resFreq2/1.e6,color='.8')
    ax.axvline(resFreq3/1.e6,color='.8')
    ax.set_ylabel('fft response')
    ax.set_xlabel('frequency (MHz)')
    ax.legend(loc='lower left')
fig,ax = plt.subplots(1,1)
f(fig,ax)
np.savez('responseTheory.npz',freqListMHz=freqListMHz,freqResponsePfbDb=freqResponsePfbDb,freqResponseDb=freqResponseDb,freqResponse=freqResponse,phaseResponse=phaseResponse,freqResponseLpf=freqResponseLpf,freqResponsePfb=freqResponsePfb,freqResponseFft=freqResponseFft,freqResponseFftDb=freqResponseFftDb)
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
#Now we'll simulate the full channelizer by 
# generating a sampled probe tone at the resonant frequency,
# applying the 2 stages of channelization
# and inspecting the phase of the channel corresponding to the resonant frequency
nSamples = 100*nPfbTaps*fftSize

# here's the signal we're interested in.  Use defaults to include phase pulse that we'll try to recover
signal = toneWithPhasePulse(resFreq,nSamples,sampleRate)

#add in other tones with their own pulses.  We don't want those pulses to show up in this channel
#signal += toneWithPhasePulse(resFreq2,nSamples,sampleRate,pulseAmpDeg=-90.,pulseArrivalTime=200.e-6,initialPhase=2.)
#signal += toneWithPhasePulse(resFreq3,nSamples,sampleRate,pulseAmpDeg=-80.,pulseArrivalTime=300.e-6,initialPhase=1.)
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
rawFft = 20*np.log10(np.fft.fftshift(np.abs(np.fft.fft(signal,n=rawFftSize)/rawFftSize)))
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

filteredSignal0 = pfb(signal[:-fftSize/2],fftSize=fftSize,nTaps=nPfbTaps,binWidthScale=pfbBinWidthScale)
filteredSignal1 = pfb(signal[fftSize/2:],fftSize=fftSize,nTaps=nPfbTaps,binWidthScale=pfbBinWidthScale)
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
binFft = 20*np.log10(np.fft.fftshift(np.abs(np.fft.fft(binTimestream,n=binFftSize)/binFftSize)))
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
channelFft = 20*np.log10(np.fft.fftshift(np.abs(np.fft.fft(channelTimestream,n=channelFftSize)/channelFftSize)))
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
finalFft = 20*np.log10(np.fft.fftshift(np.abs(np.fft.fft(channelTimestream,n=finalFftSize)/finalFftSize)))
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

