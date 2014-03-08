import unittest
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from WideAnaFile import WideAnaFile

import matplotlib.pyplot as plt
class TestPeaks(unittest.TestCase):

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
        ax[1].set_xlim(5.0, 5.012)

        for peak in waf.peaks:
            x = waf.x[peak]
            if x > xmin and x < xmax:
                ax[1].axvline(x=x,color='r')

        plt.savefig("testWav.png")
if __name__ == '__main__':
    unittest.main()

