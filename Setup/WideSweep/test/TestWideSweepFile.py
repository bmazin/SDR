import unittest
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from WideSweepFile import WideSweepFile

import matplotlib.pyplot as plt
class TestWideSweepFile(unittest.TestCase):

    def testWsf(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)
        wsf.fitSpline()
        wsf.findPeaks()
        fig,ax = plt.subplots(2)
        ax[0].plot(wsf.x,wsf.mag,label='mag')
        ax[0].set_xlabel("frequency")
        ax[0].set_ylabel("magnitude")
        ax[0].legend()

        ax[1].plot(wsf.x,wsf.mag,label='mag')
        ax[1].set_xlabel("frequency")
        ax[1].set_ylabel("magnitude")
        ax[1].legend().get_frame().set_alpha(0.5)

        xmin = 5.0
        xmax = 5.012
        ax[1].set_xlim(xmin, xmax)

        for peak in wsf.peaks:
            x = wsf.x[peak]
            if x > xmin and x < xmax:
                ax[1].axvline(x=x,color='r')

        plt.savefig("testWsf.png")

    def testWsf2(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)

        var = wsf.mag.var()
        m = len(wsf.mag)

        #splineS = m*var/20.0
        #print "var,m,splineS=",var,m,splineS
        #splineK = 5
        #wsf.fitSpline(splineS=splineS,splineK=splineK)

        wn = 0.01
        wsf.fitFilter(wn=wn)

        m = 2
        wsf.findPeaks(m=m)
        fig,ax = plt.subplots(2)
        ax[0].plot(wsf.x,wsf.mag,label='mag')
        ax[0].plot(wsf.x,wsf.baseline,label='baseline')
        ax[0].set_xlabel("frequency")
        ax[0].set_ylabel("magnitude")
        ax[0].legend()
        xmin = 3.25
        xmax = 3.27
        ax[0].set_xlim(xmin, xmax)
        for peak in wsf.peaks:
            x = wsf.x[peak]
            if x > xmin and x < xmax:
                ax[0].axvline(x=x,color='r')
        ax[0].set_title("filter wn=%f findPeaks m=%f"%(wn,m))
        ax[1].plot(wsf.x,wsf.mag,label='mag')
        ax[1].plot(wsf.x,wsf.baseline,label='baseline')
        ax[1].set_xlabel("frequency")
        ax[1].set_ylabel("magnitude")
        ax[1].legend().get_frame().set_alpha(0.5)
        xmin = 5.0
        xmax = 5.012
        ax[1].set_xlim(xmin, xmax)
        for peak in wsf.peaks:
            x = wsf.x[peak]
            if x > xmin and x < xmax:
                ax[1].axvline(x=x,color='r')

        plt.savefig("testWsf2.png")

    def testFilter(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)
        wsf.filter()
        fig,ax = plt.subplots()
        ax.plot(wsf.x,wsf.mag,label='mag')
        ax.plot(wsf.x,wsf.filtered,label='filtered')
        xmin = 3.2
        xmax = 3.4
        ax.set_xlim(xmin,xmax)
        ax.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFilter.png")

    def testFilter2(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)
        fig,ax = plt.subplots()
        ax.plot(wsf.x,wsf.mag,label='mag')

        wsf.fitFilter(wn=0.1)
        ax.plot(wsf.x,wsf.baseline,label='filtered baseline wn=0.1')

        wsf.fitFilter(wn=0.5)
        ax.plot(wsf.x,wsf.baseline,label='filtered baseline wn=0.5')

        wsf.fitSpline()
        ax.plot(wsf.x,wsf.baseline,label='spline baseline')

        xmin = 3.293
        xmax = 3.294
        ax.set_xlim(xmin,xmax)
        ax.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFilter2.png")
    def testFits(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)

        fig,ax = plt.subplots()
        ax.plot(wsf.x,wsf.mag,label='mag')

        for wn in [0.001, 0.01, 0.1]:
            wsf.fitFilter(wn=wn)
            ax.plot(wsf.x,wsf.baseline,label='filtered baseline wn=%0.3f'%wn)

        wsf.fitSpline()
        ax.plot(wsf.x,wsf.baseline,label='spline baseline')

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


        wsf = WideSweepFile(fileName)
        wn = 0.010
        wsf.fitFilter(wn=0.5)
        values = wsf.mag-wsf.baseline
        plt.plot(wsf.x,values,label="filtered with wn=%0.3f"%wn)
        xmin = 3.25
        xmax = 3.27
        plt.xlim(xmin,xmax)
        plt.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFindPeaksThreshold.png")

        #wsf.findPeaksThreshold(threshSigma=threshSigma)
        #plt.figure()
        #plt.plot(wsf.fptCenters, wsf.fptHg[0])
        #plt.yscale("symlog", linthreshy=0.1)
        #plt.axvline(wsf.fptAverage, c="red", ls=":")
        #plt.axvline(wsf.fptAverage-threshSigma*wsf.fptStd, c="green", ls="--")
        #plt.savefig("testFpt-hg.png")

    def testFitSpline(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)
        plt.plot(wsf.x,wsf.mag,label='mag')
        
        for splineS in [1,0.9,0.5,0.3]:
            wsf.fitSpline(splineS=splineS)
            plt.plot(wsf.x,wsf.baseline,label='s=%f'%splineS)
        xmin = 3.25
        xmax = 3.27
        plt.xlim(xmin,xmax)
        plt.legend().get_frame().set_alpha(0.5)
        plt.savefig("testFitSpline.png")

    def testCreatePdf(self):
        fileName = 'ucsb_100mK_24db_1.txt'
        wsf = WideSweepFile(fileName)
        wsf.createPdf('ucsb_100mK_24db_1-good.pdf')
if __name__ == '__main__':
    unittest.main()

