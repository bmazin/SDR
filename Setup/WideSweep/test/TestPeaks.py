import unittest
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import Peaks as Peaks
import numpy as np

class TestPeaks(unittest.TestCase):

    def testPeaks(self):
        peaks = [10,56]
        n = np.random.normal(100.0, 1.0,100)
        for peak in peaks:
            n[peak] = 500
        p = Peaks.peaks(n,2)
        print "p=",p

if __name__ == '__main__':
    unittest.main()

