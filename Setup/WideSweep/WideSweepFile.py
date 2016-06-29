import numpy as np
from scipy.interpolate import UnivariateSpline
from scipy import signal
import Peaks
#from interval import interval, inf, imath
import math

import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

class WideSweepFile():
    """
    Handle data written by the program SegmentedSweep.vi
    
    The first seven lines are header information.
    Each remaining line is frequency, I, sigma_I, Q, sigma_Q

    """
    def __init__(self,fileName):
        file = open(fileName,'r')
        (self.fr1,self.fspan1,self.fsteps1,self.atten1) = \
            file.readline().split()
        (self.fr2,self.fspan2,self.fsteps2,self.atten2) = \
            file.readline().split()
        (self.ts,self.te) = file.readline().split()
        (self.Iz1,self.Izsd1) = [float(x) for x in file.readline().split()]
        (self.Qz1,self.Qzsd1) = [float(x) for x in file.readline().split()]
        (self.Iz2,self.Izsd2) = [float(x) for x in file.readline().split()]
        (self.Qz2,self.Qzsd2) = [float(x) for x in file.readline().split()]
        file.close()
        self.data1 = np.loadtxt(fileName, skiprows=7)
        self.loadedFileName=fileName
        self.x = self.data1[:,0]
        self.n = len(self.x)
        ind = np.arange(self.n)
        Iz = np.where(ind<self.n/2, self.Iz1, self.Iz2)
        self.I = self.data1[:,1]
        self.I = self.I - Iz
        self.Ierr = self.data1[:,2]
        Qz = np.where(ind<self.n/2, self.Qz1, self.Qz2)
        self.Q = self.data1[:,3] - Qz
        self.Qerr = self.data1[:,4]
        self.mag = np.sqrt(np.power(self.I,2) + np.power(self.Q,2))

    def fitSpline(self, splineS=1, splineK=3):
        x = self.data1[:,0]
        y = self.mag        
        self.splineS = splineS
        self.splineK = splineK
        spline = UnivariateSpline(x,y,s=self.splineS, k=self.splineK)
        self.baseline = spline(x)

    def findPeaks(self, m=2, useDifference=True):
        if useDifference:
            diff = self.baseline - self.mag
        else:
            diff = -self.mag            
        self.peaksDict = Peaks.peaks(diff,m,returnDict=True)
        self.peaks = self.peaksDict['big']
        self.pk = self.peaksDict['pk']

    def findPeaksThreshold(self,threshSigma):
        self.fptThreshSigma = threshSigma
        values = self.mag-self.baseline
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
            iPeak += 1

    def filter(self, order=4, rs=40, wn=0.1):
        b,a = signal.cheby2(order, rs, wn, btype="high", analog=False)
        self.filtered = signal.filtfilt(b,a,self.mag)

    def fitFilter(self, order=4, rs=40, wn=0.5):
        self.filter(order=order, rs=rs, wn=wn)
        self.baseline = self.mag-self.filtered

    def createPdf(self, pdfFile, deltaF=0.15, plotsPerPage=5):
        nx = int(deltaF*len(self.x)/(self.x.max()-self.x.min()))
        pdf_pages = PdfPages(pdfFile)
        db = 20*np.log10(self.mag/self.mag.max())
        startNewPage = True
        for i0 in range(0,len(self.x),nx):
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
        if not startNewPage:
            pdf_pages.savefig(fig)
        pdf_pages.close()

    def resFit(self,ind0,ind1):
        """
        Logic copied from MasterResonatorAnalysis/resfit.pro
        """
        if ind0 < len(self.x)/2:
            iZero = self.Iz1
            qZero = self.Qz1
        else:
            iZero = self.Iz2
            qZero = self.Qz2
