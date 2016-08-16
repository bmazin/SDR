import numpy as np
import scipy.signal
import os
import csv
import matplotlib.pyplot as plt

class IirFilter:
    def __init__(self,criticalFreqHz=100,sampleFreqHz=1e6,order=2,btype='lowpass',numCoeffs=None,denomCoeffs=None,zeros=None,poles=None,gain=None):
        self.sampleFreqHz = sampleFreqHz
        self.nyquistFreqHz = sampleFreqHz / 2.
        if numCoeffs == None and zeros == None and poles == None:
            self.criticalFreqHz = criticalFreqHz
            self.order = order
            self.criticalW = criticalFreqHz/self.nyquistFreqHz
            self.ftype = 'butter'
            self.btype = btype
            self.numCoeffs,self.denomCoeffs = scipy.signal.iirfilter(self.order,self.criticalW,btype=self.btype,ftype=self.ftype,output='ba')
            self.zeros,self.poles,self.gain = scipy.signal.iirfilter(self.order,self.criticalW,btype=self.btype,ftype=self.ftype,output='zpk')
        elif numCoeffs != None:
            self.order = len(denomCoeffs)
            self.numCoeffs = numCoeffs
            self.denomCoeffs = denomCoeffs
            self.zeros,self.poles,self.gain = scipy.signal.tf2zpk(numCoeffs,denomCoeffs)
        else:
            self.numCoeffs,self.denomCoeffs = scipy.signal.zpk2tf(zeros,poles,gain)

            
            


    def freqResp(self,**kwargs):
        afreqs,freqResp = scipy.signal.freqz(self.numCoeffs,self.denomCoeffs,**kwargs)
        sampledFreqsHz = afreqs * self.nyquistFreqHz / np.pi
        freqRespDb = 20.*np.log10(np.abs(freqResp))
        return {'sampledFreqsHz':sampledFreqsHz,'freqRespDb':freqRespDb,'freqResp':freqResp}

    def filterData(self,data):
        filteredData = scipy.signal.lfilter(self.numCoeffs,self.denomCoeffs,data)
        return filteredData

    def plotFreqResponse(self,ax=None,showMe=True,label=None,**kwargs):
        freqRespDict = self.freqResp(**kwargs)
        if ax == None:
            fig,ax = plt.subplots(1,1)
        ax.plot(freqRespDict['sampledFreqsHz'] / 1.e3,freqRespDict['freqRespDb'],label=label)
        ax.set_xlabel('freq (kHz)')
        ax.set_ylabel('filter response (dB)')
        if showMe:
            plt.show()

    def save(self,path=''):
        fullPath = os.path.abspath(path)
        
        if os.path.basename(fullPath) == '' or os.path.isdir(fullPath):
            filename = '{}Iir{}Hz.csv'.format(self.btype,self.criticalFreqHz)
            fullPath = os.path.join(fullPath,filename)
        header = '{} {} IIR, criticalFreq = {} Hz, sampleFreq = {} Hz \n numeratorCoeffs\ndenomenatorCoeffs'.format(self.ftype,self.btype,self.criticalFreqHz,self.sampleFreqHz)
        
        writer = csv.writer(open(fullPath, "w"))
        writer.writerow(['criticalFreqHz',self.criticalFreqHz])
        writer.writerow(['sampleFreqHz',self.sampleFreqHz])
        writer.writerow(['btype',self.btype])
        writer.writerow(['ftype',self.ftype])

        writer.writerow(['numCoeffs',self.numCoeffs])
        writer.writerow(['denomCoeffs',self.denomCoeffs])

if __name__ == '__main__':
    sampleRate = 1e6 # 1 MHz
    criticalFreqHz = 4000 #Hz
    hpSos = IirFilter(sampleFreqHz=sampleRate,criticalFreqHz=criticalFreqHz,btype='highpass')

    alpha=0.999
    hpOnePole = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-1]),denomCoeffs=np.array([1, -alpha]))
    f=2*np.sin(np.pi*criticalFreqHz/sampleRate)
    Q=.75
    q=1./Q
    hpSvf = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))

    q=1./.5
    print 'critical freq',criticalFreqHz,'Hz','Q',Q
    print 'Kf',f,'Kq',q
    hpSvf2 = IirFilter(sampleFreqHz=sampleRate,numCoeffs=np.array([1,-2,1]),denomCoeffs=np.array([1+f**2, f*q-2,1-f*q]))
    print 'hpSvf .7 poles',hpSvf.poles
    print 'hpSvf .5 poles',hpSvf2.poles
    print 'hpOnePole poles',hpOnePole.poles
    print 'hpSos poles',hpSos.poles

    sampleWFreqs = np.linspace(0,np.pi/100.,6000)

    fig,ax = plt.subplots(1,1)
    hpSos.plotFreqResponse(worN=sampleWFreqs,ax=ax,showMe=False,label='hpSos')
    hpOnePole.plotFreqResponse(worN=sampleWFreqs,ax=ax,showMe=False,label='hpOnePole')
    hpSvf.plotFreqResponse(worN=sampleWFreqs,ax=ax,showMe=False,label='hpSvf .7')
    hpSvf2.plotFreqResponse(worN=sampleWFreqs,ax=ax,showMe=False,label='hpSvf .5')

    ax.legend(loc='best')

    plt.show()
    
