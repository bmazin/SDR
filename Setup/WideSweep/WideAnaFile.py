import numpy as np
from scipy.interpolate import UnivariateSpline
from scipy import signal
import Peaks
from interval import interval, inf, imath
import math

import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

class WideAnaFile():
    def __init__(self,fileName):
        file = open(fileName,'r')
        (self.fr1,self.fspan1,self.fsteps1,self.atten1) = file.readline().split()
        (self.fr2,self.fspan2,self.fsteps2,self.atten2) = file.readline().split()
        (self.ts,self.te) = file.readline().split()
        (self.Iz1,self.Izsd1) = file.readline().split()
        (self.Qz1,self.Qzsd1) = file.readline().split()
        (self.Iz2,self.Izsd2) = file.readline().split()
        (self.Qz2,self.Qzsd2) = file.readline().split()
        file.close()
        self.data1 = np.loadtxt(fileName, skiprows=7, usecols=(0,1,3))
        self.loadedFileName=fileName
        self.x = self.data1[:,0]
        self.y = {}
        self.y['mag']=np.sqrt(np.power(self.data1[:,1]-float(self.Iz2),2) + np.power(self.data1[:,2]-float(self.Qz2),2))

    def fitSpline(self, splineS=1, splineK=3):
        x = self.data1[:,0]
        y = self.y['mag']        
        self.splineS = splineS
        self.splineK = splineK
        print "now fit spline with s,k=",splineS,splineK
        spline = UnivariateSpline(x,y,s=self.splineS, k=self.splineK)
        self.y['baseline'] = spline(x)

    def findPeaks(self, m=2, useDifference=True):
        if useDifference:
            diff = self.y['baseline'] - self.y['mag']
        else:
            diff = -self.y['mag']            
        self.peaksDict = Peaks.peaks(diff,m,returnDict=True)
        self.peaks = self.peaksDict['big']

    def findPeaksThreshold(self,threshSigma):
        self.fptThreshSigma = threshSigma
        values = self.y['mag']-self.y['baseline']
        self.fptHg = np.histogram(values,bins=100)
        self.fptCenters = 0.5*(self.fptHg[1][:-1] + self.fptHg[1][1:])
        self.fptAverage = np.average(self.fptCenters,weights=self.fptHg[0])
        self.fptStd = np.sqrt(np.average((self.fptCenters-self.fptAverage)**2, 
                                      weights=self.fptHg[0]))
        thresh = self.fptAverage - threshSigma*self.fptStd
        ind = np.arange(len(values))[values < thresh]
        self.threshIntervals = interval()
        for i in ind-1:
            self.threshIntervals = threshIntervals | interval[i-0.6,i+0.6]
        self.peaks = np.zeros(len(threshIntervals))

        iPeak = 0
        for threshInterval in self.threshIntervals:
            i0 = int(math.ceil(self.threshInterval[0]))
            i1 = int(math.ceil(self.threshInterval[1]))
            peak = np.average(self.x[i0:i1],weights=np.abs(values[i0:i1]))
            self.peaks[iPeak] = peak
            x0 = self.x[i0]
            x1 = self.x[i1]
            print "iPeak=%d i0=%d i1=%d x0=%f x1=%f peak=%f"%(iPeak,i0,i1,x0,x1,peak)
            iPeak += 1
    def filter(self, order=4, rs=40, wn=0.1):
        b,a = signal.cheby2(order, rs, wn, btype="high", analog=False)
        self.y['filtered'] = signal.filtfilt(b,a,self.y['mag'])

    def fitFilter(self, order=4, rs=40, wn=0.5):
        self.filter(order=order, rs=rs, wn=wn)
        self.y['baseline'] = self.y['mag']-self.y['filtered']

    def createPdf(self, pdfFile, deltaF=0.15, plotsPerPage=5):
        print "begin createPdf to ",pdfFile
        print "fMin,fMax=",self.x.min(),self.x.max()
        print "number of bins",len(self.x)
        nx = int(deltaF*len(self.x)/(self.x.max()-self.x.min()))
        print "nx=",nx
        pdf_pages = PdfPages(pdfFile)
        db = 20*np.log10(self.y['mag']/self.y['mag'].max())
        startNewPage = True
        for i0 in range(0,len(self.x),nx):
            print "i0=",i0
            if startNewPage:
                fig = plt.figure(figsize=(8.5,11), dpi=100)
                iPlot = 0
                startNewPage = False
            iPlot += 1
            ax = fig.add_subplot(plotsPerPage, 1, iPlot)
            ax.plot(self.x[i0:i0+nx],db[i0:i0+nx])
            ax.set_xlabel("Frequency (GHz)")
            ax.set_ylabel("S21(db)")
            if iPlot == plotsPerPage:
                startNewPage = True
                pdf_pages.savefig(fig)
                print "saved a page"
        pdf_pages.close()
