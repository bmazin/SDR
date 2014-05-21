import numpy as np
import scipy.ndimage.filters
from mpfit import mpfit
import math
class Resonator:
    def __init__(self, freq, I, Ierr, Q, Qerr):
        self.freq = freq
        self.I = I
        self.Ierr = Ierr
        self.Q = Q
        self.Qerr = Qerr
        self.mag = np.sqrt(np.power(self.I,2) + np.power(self.Q,2))
        self.phase = np.arctan2(self.Q,self.I)
        self.dist1 = np.sqrt(np.power(self.I[1:]-self.I[0:-1],2) +
                             np.power(self.Q[1:]-self.Q[0:-1],2))
        self.dist1[:11] = 0.0
        self.dist1[-11:] = 0.0
        self.dist1 = Resonator.smooth(self.dist1)
        self.residx = np.argmax(self.dist1)+1
        width = len(self.dist1)/5
        temp = self.I[self.residx-width:self.residx+width]
        self.xrc1 = (temp.min()+temp.max())/2.0
        temp = self.Q[self.residx-width:self.residx+width]
        self.yrc1 = (temp.min()+temp.max())/2.0


    @staticmethod
    def smooth(a, width=15):
        """
        ape how smooth works in idl, as used in resfit.pro
        """
        r = np.zeros(len(a))
        for i in range(len(r)):
            if i < (width-1)/2 or i > len(r)-(width+1)/2:
                r[i] = a[i]
            else:                
                r[i] = a[i-width/2:1+i+width/2].sum()/width
        return r
                
    @staticmethod
    def magModel(x, p):
        """ 
        Value of the model at x
        Copied from resfit.pro function MAGDIFF, but in the .pro file the
        difference is calculated in MAGDIFF, but in this .py file
        the difference is calculated in magDiffLin.
        """
        Q = p[0]        #  Q
        f0 = p[1]       #  resonance frequency
        carrier = p[2]  #  value of carrier
        depth = p[3]    #  depth of dip
        slope = p[4]    #  slope of background
        curve = p[5]    #  curve of background
        dx3Weight = p[6]
        dx = (x - f0) / f0

        #s21 = (complex(0,2.0*Q*dx)) / (complex(1,0) + complex(0,2.0*Q*dx))
        s21 = (1j*2.0*Q*dx) / (np.ones(len(dx))  + 1j*2.0*Q*dx)
        s21a = depth*(
            abs(s21) + carrier + slope*dx + curve*dx*dx + dx3Weight*dx*dx*dx)
        return s21a
    @staticmethod
    def magDiffLin(p, fjac=None, x=None, y=None, err=None):
        # Parameter values are passed in "p"
        # If fjac==None then partial derivatives should not be
        # computed.  It will always be None if MPFIT is called with default
        # flag.
        model = Resonator.magModel(x, p)
        # Non-negative status value means MPFIT should continue, 
        # negative means stop the calculation.
        status = 0
        return [status, (y-model)/err]


    def quickFitPrep(self):
        x = self.freq
        y = self.mag/self.mag.max()
        n = len(self.freq)
        middle = int(n/2) - 1
        err = 0.001*np.ones(n)
        
        # p0 is a numpy array of the initial guesses
        Q = 20000.0       # quality factor 
        f0 = x[middle]  # peak position
        carrier = 0.3
        depth = y.max()-y.min()
        slope = -10.0
        curve = 0.0
        dx3Weight = 0.0

        p0 = np.array([Q,f0,carrier,depth,slope,curve,dx3Weight], 
                      dtype='float64')
        parinfo = []
        parinfo.append({'value':Q, 'fixed':0, 'limited':[0,0], 
                        'limits':[5000.0, 200000.0]})
        parinfo.append({'value':f0, 'fixed':0, 'limited':[0,0], 
                        'limits':[x[middle-n/10],x[middle+n/10]]})
        parinfo.append({'value':carrier, 'fixed':0, 'limited':[0,0], 
                        'limits':[1e-3,1e2]})
        parinfo.append({'value':depth, 'fixed':0, 'limited':[0,0], 
                        'limits':[depth/2.0, depth*2.0]})
        parinfo.append({'value':slope, 'fixed':0, 'limited':[0,0], 
                        'limits':[-1e4,1e4]})
        parinfo.append({'value':curve, 'fixed':0, 'limited':[0,0], 
                        'limits':[-1e7,1e7]})
        parinfo.append({'value':dx3Weight, 'fixed':0, 'limited':[0,0], 
                        'limits':[-1e12,1e12]})
        functkw = {'x':x,'y':y,'err':err}

        # This is how mpfit will use these
        #self.mQuickFit = mpfit(
        #    Resonator.magDiffLin, p0, parinfo=parinfo,functkw=fa)

        return {"p0":p0, "parinfo":parinfo,"functkw":functkw}
    
    def quickFit(self,quiet=1):
        qfp = self.quickFitPrep()
        m = mpfit(Resonator.magDiffLin, qfp['p0'], 
                  parinfo=qfp['parinfo'],
                  functkw=qfp['functkw'],
                  quiet=quiet)
        return m

    def resFitPrep(self):
        self.quickFitPrep()
        mQuick = self.quickFit()
        qGuess = mQuick.params[0]
        fGuess = mQuick.params[1]
        dc = math.sqrt(self.xrc1**2 + self.yrc1**2)
        ang1 = math.atan2(-self.yrc1 + self.Q[self.residx],
                          -self.xrc1 + self.I[self.residx])
        width = len(self.dist1)/5
        x =    self.freq[self.residx-width:self.residx+width+1]*1e9
        I = self.I[self.residx-width:self.residx+width+1]
        Q = self.Q[self.residx-width:self.residx+width+1]
        y =    I + 1j*Q  
        yerr =    self.Ierr[self.residx-width:self.residx+width+1] + \
               1j*self.Qerr[self.residx-width:self.residx+width+1]
        deltaAng = math.atan2(self.Q[self.residx+5]-self.yrc1,
                              self.I[self.residx+5]-self.xrc1)        
        ang = ang1 + deltaAng # perhaps this is a minus in resfit.pro

        # Starting values and limits
        parinfo = []
                                    #  0 quality factor 
        parinfo.append({'value':qGuess, 'fixed':0, 'limited':[0,0], 
                        'limits':[5000.0,1000001.0]})
        deltaF = x[len(x)/5]-x[0]
        f0    = fGuess*1e9          #  1 peak position in Hz
        parinfo.append({'value':f0, 'fixed':0, 'limited':[0,0], 
                        'limits':[f0-deltaF,f0+deltaF]})
        aleak = 1.0                 #  2
        parinfo.append({'value':aleak, 'fixed':0, 'limited':[0,0], 
                        'limits':[1e-4,100.0]})
        phi1  = 800.0               #  3
        parinfo.append({'value':phi1, 'fixed':0, 'limited':[0,0], 
                        'limits':[1.0, 4e4]})
        da    = 500.0               #  4
        parinfo.append({'value':da, 'fixed':0, 'limited':[0,0], 
                        'limits':[-5000.0,5000.0]})
        ang1  = ang                 #  5
        parinfo.append({'value':ang1, 'fixed':0, 'limited':[0,0], 
                        'limits':[-4*math.pi,4*math.pi]})
        Igain = I.max()-I.min()     #  6
        parinfo.append({'value':Igain, 'fixed':0, 'limited':[0,0], 
                        'limits':[0.2*Igain, 3.0*Igain]})
        Qgain = Q.max()-Q.min()     #  7
        parinfo.append({'value':Qgain, 'fixed':0, 'limited':[0,0], 
                        'limits':[0.2*Qgain, 3.0*Qgain]})
        Ioff  = float(self.xrc1)    #  8
        parinfo.append({'value':Qgain, 'fixed':0, 'limited':[0,0], 
                        'limits':[self.xrc1-5000.0, self.xrc1+5000.0]})
        Qoff  = float(self.yrc1)    #  9
        parinfo.append({'value':Igain, 'fixed':0, 'limited':[0,0], 
                        'limits':[self.yrc1-5000.0, self.yrc1+5000.0]})
        db    = 0.0                 # 10
        parinfo.append({'value':db, 'fixed':0, 'limited':[0,0], 
                        'limits':[-100000000.0,10000000.0]})
        p0 = np.array([qGuess,f0,aleak,phi1,da,ang1,Igain,Qgain,Ioff,Qoff,db], 
                      dtype='float64')
        functkw = {'x':x,'y':y,'err':yerr}
        return {"p0":p0, "parinfo":parinfo,"functkw":functkw}
 
    @staticmethod
    def resModel(x, p):
        """ 
        Value of the model at x
        Copied from resfit.pro function RESDIFF, but in the .pro file the
        difference is calculated in RESDIFF, but in this .py file
        the difference is calculated in resDiffLin.
        """
        Q = p[0]      # Q
        f0 = p[1]     # resonance frequency
        aleak = p[2]  # amplitude of leakage
        ph1 = p[3]    # phase shift of leakage
        da = p[4]     # variation of carrier amplitude
        ang1 = p[5]   # Rotation angle of data
        Igain = p[6]  # Gain of I channel
        Qgain = p[7]  # Gain of Q channel
        Ioff = p[8]   # Offset of I channel
        Qoff = p[9]   # Offset of Q channel
        db = p[10]    #
        dx = (x - f0) / f0

        # resonance dip function
        s21a = ((1j*2.0*Q*dx) / (1  + 1j*2.0*Q*dx)) - 0.5
        s21b = (da*dx + db*dx*dx) + s21a + \
            aleak*(1.0-np.cos(dx*ph1) - 1j*np.sin(dx*ph1))
        # scale, rotate, and offset
        Ix1 = Igain*s21b.real
        Qx1 = Qgain*s21b.imag
        nI1 =  Ix1*math.cos(ang1) + Qx1*math.sin(ang1) + Ioff
        nQ1 = -Ix1*math.sin(ang1) + Qx1*math.cos(ang1) + Qoff
        s21 = nI1 + 1j*nQ1
        return s21

    @staticmethod
    def resDiffLin(p, fjac=None, x=None, y=None, err=None):
        # Parameter values are passed in "p"
        # If fjac==None then partial derivatives should not be
        # computed.  It will always be None if MPFIT is called with default
        # flag.
        model = Resonator.resModel(x, p)
        # Non-negative status value means MPFIT should continue, 
        # negative means stop the calculation.
        status = 0
        return [status, np.abs((y-model)/err)]

