import unittest
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from WideAnaFile import WideAnaFile

import matplotlib.pyplot as plt
class TestWideAnaFile(unittest.TestCase):

    def testWaf(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)
        waf.fitSpline()
        waf.findPeaks()
        fig,ax = plt.subplots(2)
        ax[0].plot(waf.x,waf.y['mag'],label='mag')
        ax[0].set_xlabel("frequency")
        ax[0].set_ylabel("magnitude")
        ax[0].legend()

        ax[1].plot(waf.x,waf.y['mag'],label='mag')
        ax[1].set_xlabel("frequency")
        ax[1].set_ylabel("magnitude")
        ax[1].legend().get_frame().set_alpha(0.5)

        xmin = 5.0
        xmax = 5.012
        ax[1].set_xlim(xmin, xmax)

        for peak in waf.peaks:
            x = waf.x[peak]
            if x > xmin and x < xmax:
                ax[1].axvline(x=x,color='r')

        plt.savefig("testWaf.png")

    def testWaf2(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)

        var = waf.y['mag'].var()
        m = len(waf.y['mag'])

        #splineS = m*var/20.0
        #print "var,m,splineS=",var,m,splineS
        #splineK = 5
        #waf.fitSpline(splineS=splineS,splineK=splineK)

        wn = 0.01
        waf.fitFilter(wn=wn)

        m = 2
        waf.findPeaks(m=m)
        fig,ax = plt.subplots(2)
        ax[0].plot(waf.x,waf.y['mag'],label='mag')
        ax[0].plot(waf.x,waf.y['baseline'],label='baseline')
        ax[0].set_xlabel("frequency")
        ax[0].set_ylabel("magnitude")
        ax[0].legend()
        xmin = 3.25
        xmax = 3.27
        ax[0].set_xlim(xmin, xmax)
        for peak in waf.peaks:
            x = waf.x[peak]
            if x > xmin and x < xmax:
                ax[0].axvline(x=x,color='r')
        ax[0].set_title("filter wn=%f findPeaks m=%f"%(wn,m))
        ax[1].plot(waf.x,waf.y['mag'],label='mag')
        ax[1].plot(waf.x,waf.y['baseline'],label='baseline')
        ax[1].set_xlabel("frequency")
        ax[1].set_ylabel("magnitude")
        ax[1].legend().get_frame().set_alpha(0.5)
        xmin = 5.0
        xmax = 5.012
        ax[1].set_xlim(xmin, xmax)
        for peak in waf.peaks:
            x = waf.x[peak]
            if x > xmin and x < xmax:
                ax[1].axvline(x=x,color='r')

        plt.savefig("testWaf2.png")

    def testFilter(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)
        waf.filter()
        fig,ax = plt.subplots()
        ax.plot(waf.x,waf.y['mag'],label='mag')
        ax.plot(waf.x,waf.y['filtered'],label='filtered')
        xmin = 3.2
        xmax = 3.4
        ax.set_xlim(xmin,xmax)
        ax.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFilter.png")

    def testFilter2(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)
        fig,ax = plt.subplots()
        ax.plot(waf.x,waf.y['mag'],label='mag')

        waf.fitFilter(wn=0.1)
        ax.plot(waf.x,waf.y['baseline'],label='filtered baseline wn=0.1')

        waf.fitFilter(wn=0.5)
        ax.plot(waf.x,waf.y['baseline'],label='filtered baseline wn=0.5')

        waf.fitSpline()
        ax.plot(waf.x,waf.y['baseline'],label='spline baseline')

        xmin = 3.293
        xmax = 3.294
        ax.set_xlim(xmin,xmax)
        ax.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFilter2.png")
    def testFits(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)

        fig,ax = plt.subplots()
        ax.plot(waf.x,waf.y['mag'],label='mag')

        for wn in [0.001, 0.01, 0.1]:
            waf.fitFilter(wn=wn)
            ax.plot(waf.x,waf.y['baseline'],label='filtered baseline wn=%0.3f'%wn)

        waf.fitSpline()
        ax.plot(waf.x,waf.y['baseline'],label='spline baseline')

        #xmin = 3.356
        #xmax = 3.357
        xmin = 3.25
        xmax = 3.27
        ax.set_xlim(xmin,xmax)
        ax.legend().get_frame().set_alpha(0.5)

        plt.savefig("testFits.png")


    def testFindPeaksThreshold(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        threshSigma = 5


        waf = WideAnaFile(fileName)
        wn = 0.010
        waf.fitFilter(wn=0.5)
        values = waf.y['mag']-waf.y['baseline']
        plt.plot(waf.x,values,label="filtered with wn=%0.3f"%wn)
        xmin = 3.25
        xmax = 3.27
        plt.xlim(xmin,xmax)
        plt.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFindPeaksThreshold.png")

        #waf.findPeaksThreshold(threshSigma=threshSigma)
        #plt.figure()
        #plt.plot(waf.fptCenters, waf.fptHg[0])
        #plt.yscale("symlog", linthreshy=0.1)
        #plt.axvline(waf.fptAverage, c="red", ls=":")
        #plt.axvline(waf.fptAverage-threshSigma*waf.fptStd, c="green", ls="--")
        #plt.savefig("testFpt-hg.png")

    def testFitSpline(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        waf = WideAnaFile(fileName)
        plt.plot(waf.x,waf.y['mag'],label='mag')
        
        for splineS in [1,0.9,0.5,0.3]:
            waf.fitSpline(splineS=splineS)
            plt.plot(waf.x,waf.y['baseline'],label='s=%f'%splineS)
        xmin = 3.25
        xmax = 3.27
        plt.xlim(xmin,xmax)
        plt.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFitSpline.png")
if __name__ == '__main__':
    unittest.main()

