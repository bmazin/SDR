import unittest,sys,os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from PSFile import PSFile
class TestPSFile(unittest.TestCase):
    def testInit(self):
        fn = 'ps_r0_20140815-121539.h5'
        psf = PSFile(fn)
        print "fn=",psf.openfile
        for i,freq in enumerate(psf.freq):
            print "i=",i," freq=",freq
if __name__ == '__main__':
    unittest.main()
