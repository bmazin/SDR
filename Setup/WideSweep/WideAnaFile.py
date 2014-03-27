import numpy as np
from scipy.interpolate import UnivariateSpline
import Peaks
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
        spline = UnivariateSpline(x,y,s=self.splineS, k=self.splineK)
        self.y['magUSpline'] = spline(x)

    def findPeaks(self, m=2, useDifference=True):
        if useDifference:
            diff = self.y['magUSpline'] - self.y['mag']
        else:
            diff = -self.y['mag']            
        self.peaks = Peaks.peaks(diff,m)
