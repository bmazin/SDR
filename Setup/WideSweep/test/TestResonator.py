import sys,os
import unittest
import numpy as np
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from Resonator import Resonator
from mpfit import mpfit
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
class TestResonator(unittest.TestCase):
    """
    Test data copied from IDL session running autfit-pro with input 
    file FL2-right.txt, for the first resonator found
    """
    def testQuickFit(self):
        f = np.loadtxt("resonatorTestQIMA.txt", usecols=(1,))
        I = np.loadtxt("resonatorTestQIMA.txt", usecols=(2,))
        Q = np.loadtxt("resonatorTestQIma.txt", usecols=(3,))
        res = Resonator(f,I,Q)

        mag   = np.loadtxt("resonatorTestQIMA.txt", usecols=(4,))
        phase = np.loadtxt("resonatorTestQIMA.txt", usecols=(5,))
        for j in range(len(I)):
            self.assertAlmostEqual(I[j],res.I[j])
            self.assertAlmostEqual(Q[j],res.Q[j])
            self.assertAlmostEqual(mag[j],res.mag[j],places=5)
            self.assertAlmostEqual(phase[j],res.phase[j],places=6)

        dist1 = np.loadtxt("resonatorTestDist1.txt", usecols=(1,))
        for j in range(len(res.dist1)):
            self.assertAlmostEqual(res.dist1[j],dist1[j], places=6)
        self.assertEquals(len(res.dist1),len(dist1))

        self.assertEquals(50, res.residx)
        self.assertAlmostEquals(-0.35312287, res.xrc1)
        self.assertAlmostEquals(5.9134903, res.yrc1, places=6)

        m = res.quickFit()
        print m.params
        # The values from the idl version are similar, but not too close
        idl = [34093.219, 2.8350927, 0.11120927, 0.76291197,
              3993.5131, 0.0000000, 0.0000000]        
        self.assertAlmostEqual(m.params[0]/idl[0],0.7965, places=4)
        self.assertAlmostEqual(m.params[1]/idl[1],1, places=5)
        self.assertAlmostEqual(m.params[2]/idl[2],1.239136, places=5)
        self.assertAlmostEqual(m.params[3]/idl[3],1.035355, places=5)
        self.assertAlmostEqual(m.params[4]/idl[4],0.202167, places=5)
    def testMagModel(self):
        f = np.loadtxt("resonatorTestQIMA.txt", usecols=(1,))
        I = np.loadtxt("resonatorTestQIMA.txt", usecols=(2,))
        Ierr = 0.001*np.ones(len(I))
        Q = np.loadtxt("resonatorTestQIma.txt", usecols=(3,))
        Qerr = 0.001*np.ones(len(Q))
        res = Resonator(f,I,Ierr,Q,Qerr)
        qfp = res.quickFitPrep()
        x = qfp['functkw']['x']
        p = qfp['p0']
        yModel = Resonator.magModel(x,p)

        yData = qfp['functkw']['y']
        err = qfp['functkw']['err']
        mdl = Resonator.magDiffLin(p, fjac=None, x=x, y=yData, err=err)
        chi2 = np.power(mdl[1],2).sum()
        print "chi2=",chi2
        parinfo = qfp['parinfo']
        functkw = qfp['functkw']
        m = mpfit(Resonator.magDiffLin, p, parinfo=parinfo, functkw=functkw, quiet=1)
        print "m=",m
        pFit = m.params
        yFit = Resonator.magModel(x,pFit)
        plt.clf()
        plt.plot(x,yData,label="data")
        plt.plot(x,yModel,label="first guess model")
        plt.plot(x,yFit,label="fit model")
        plt.legend(loc='lower right')
        title="Q=%.1f f0=%.5f carrier=%.3f depth=%.2f \n slope=%.1f curve=%.1f w=%.1f"%tuple(pFit.tolist())
        plt.title(title)
        plt.savefig("testMagModel.png")

    def testResModel(self):
        f = np.loadtxt("resonatorTestQIMA.txt", usecols=(1,))
        I = np.loadtxt("resonatorTestQIMA.txt", usecols=(2,))
        Ierr = 0.001*np.ones(len(I))
        Q = np.loadtxt("resonatorTestQIma.txt", usecols=(3,))
        Qerr = 0.001*np.ones(len(Q))
        res = Resonator(f,I,Ierr,Q,Qerr)
        rfp = res.resFitPrep()
        x = rfp['functkw']['x']
        p = rfp['p0']
        yModel = Resonator.resModel(x,p)

        yData = rfp['functkw']['y']
        err = rfp['functkw']['err']
        rdl = Resonator.resDiffLin(p, fjac=None, x=x, y=yData, err=err)
        chi2 = np.power(rdl[1],2).sum()
        print "chi2=",chi2
        parinfo = rfp['parinfo']
        functkw = rfp['functkw']
        m = mpfit(Resonator.resDiffLin, p, parinfo=parinfo, functkw=functkw, quiet=1)
        pFit = m.params

        rdlFit = Resonator.resDiffLin(pFit, fjac=None, x=x, y=yData, err=err)
        chi2Fit = np.power(rdlFit[1],2).sum()
        print "chi2Fit=",chi2Fit
        yFit = Resonator.resModel(x,pFit)
        plt.clf()
        print "xrc1,yrc1=",res.xrc1,res.yrc1
        plt.plot(yData.real,yData.imag,"o",mfc='none',label="data")
        #plt.plot(yData.real[0],yData.imag[0],"+",label="first data")

        #plt.plot(yModel.real,yModel.imag,label="model")
        #plt.plot(yModel.real[0],yModel.imag[0],"o",label="first model")

        plt.plot(yFit.real,yFit.imag,label="fit")
        #plt.plot(yFit.real[0],yFit.imag[0],"o",label="first fit")

        #plt.legend(loc='center')
        #title="Q=%.1f f0=%.5f carrier=%.3f depth=%.2f \n slope=%.1f curve=%.1f w=%.1f"%tuple(pFit.tolist())
        #plt.title(title)
        plt.axvline(linewidth=1,color='b',x=res.xrc1,linestyle=":")
        plt.axhline(linewidth=1,color='b',y=res.yrc1,linestyle=":")
        plt.axes().set_aspect('equal')
        plt.savefig("testResModel.png")

    def testResfit(self):
        pdfPages = PdfPages("testResfit.pdf")
        f = np.loadtxt("resonatorTestQIMA.txt", usecols=(1,))
        I = np.loadtxt("resonatorTestQIMA.txt", usecols=(2,))
        Ierr = 0.001*np.ones(len(I))
        Q = np.loadtxt("resonatorTestQIma.txt", usecols=(3,))
        Qerr = 0.001*np.ones(len(Q))
        res = Resonator(f,I,Ierr,Q,Qerr)
        rf = res.resfit()
        res.plot(rf,pdfPages)
        pdfPages.close()
if __name__ == '__main__':
    unittest.main()

                       
