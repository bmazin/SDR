#!/usr/bin/env python
# encoding: utf-8
"""
iqsweep.py

Created by Ben Mazin on 2011-03-24.
Copyright (c) 2011 . All rights reserved.
"""

from tables import *
import numpy as np
import os
import sys
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import time
import pdb
#import powspec_rebin

class IQsweeptables(IsDescription):
    """The pytables derived class that hold IQ sweep data on the disk
    """
    # recorded data
    f0 = Float32Col()
    span = Float32Col()
    fsteps = Int32Col()
    atten1 = Int32Col()
    atten2 = Int32Col()
    scale = Float32Col()
    PreadoutdB = Float32Col()
    Tstart = Float32Col()
    Tend = Float32Col()
    I0 = Float32Col()
    Q0 = Float32Col()
    resnum = Int32Col()
    freq = Float32Col(2000) 
    I = Float32Col(2000)
    Q = Float32Col(2000)
    Isd = Float32Col(2000)
    Qsd = Float32Col(2000)
    time = Float64Col()
            
    # data products from loop fit
    vmaxidx = Int32Col()
    Iceng = Float32Col()
    Qceng = Float32Col()
    Icen = Float32Col()
    Qcen = Float32Col()
    Qm = Float32Col()
    Qc = Float32Col()
    Qi = Float32Col()
    fm = Float32Col()
    dipdb = Float32Col()    
    popt = Float32Col(10)
    fpoints = Float32Col()
    fI = Float32Col(2000)
    fQ = Float32Col(2000)
    ff = Float32Col(2000)
    
    # data products from mag fit
    mag = Float32Col(2000)
    magfreq = Float32Col(2000)
    magfit = Float32Col(2000)
    mopt = Float32Col(6)
    
    # data products from noise analysis
    savenoise = Int32Col()
    samprate = Float32Col()  
    pn = Float32Col(2552)
    pnidx = Float32Col(2552)
    an = Float32Col(2552)
    anidx = Float32Col(2552)  
    fn1k = Float32Col()

class optimalpow(IsDescription):
    """The pytables derived class that stored the optimal readout power and f0 for the resonator
    """
    Pmax = Float32Col()
    f0 = Float32Col()

class IQsweep:
    """A class for IQ sweep data designed to be compatible with pytables.  
       Holds the IQ response of a single resonator and functions that process it.  
           LoadSWP(filename,resnum) method to load the standard .swp files from the analog readout into an object.
           FitLoopMP() method fits the sweep data with Ben's loop fit code
           FitMagMP() method fits the sweep data with Ben's simple magnitue fit code
           AnalyzeNoise() method crunches the noise data 
           Save(filename,gstring,mode) method saves the class in h5 file filename in group gstring ('r0','r1',etc) with write mode mode ('w','a')
           Load(filename,gstring,f0,atten1) method loads sweep data from h5 file filename with center freq f0 and input atten setting atten1
           Pdf(filename) plots the IQ sweep (and fit if present) to a pdf file
    """    
    def __init__(self):
        pass
         
    def LoadSWP(self,filename,resnum):          # Load sweep data from .swp format text files

        self.resnum = resnum

        #read header
        f = open(filename, 'r')
        h1,h2,h3,self.atten1 = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        h4,h5,h6,self.atten2 = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        self.Tstart,self.Tend = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        Iz1,Iz1sd = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        Qz1,Qz1sd = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        Iz2,Iz2sd = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        Qz2,Qz2sd = np.fromstring(f.readline()[:-1],dtype=np.float32,sep='\t')
        f.close()

        #read table
        data = np.loadtxt(filename, skiprows=7)
        self.time = time.time()
        self.savenoise = 0
       
        if self.resnum == 0:
            self.f0 = h1
            self.span = h2
            self.fsteps = int(h3)
            self.I0 = Iz1
            self.Q0 = Qz1
            self.freq = data[:self.fsteps,0]
            self.I = data[:self.fsteps,1]
            self.Q = data[:self.fsteps,3]
            self.Isd = data[:self.fsteps,2]
            self.Qsd = data[:self.fsteps,4]
    
        else:
            self.f0 = h4
            self.span = h5
            self.fsteps = int(h6)
            self.I0 = Iz2
            self.Q0 = Qz2
            self.freq = data[h3:h3+self.fsteps,0]
            self.I = data[h3:h3+self.fsteps,1]
            self.Q = data[h3:h3+self.fsteps,3]        
            self.Isd = data[h3:h3+self.fsteps,2]
            self.Qsd = data[h3:h3+self.fsteps,4]

    def FitLoopMP(self):                    # Fit the sweep using the full IQ data with MPFIT!
     
        import mpfit
        # find center from IQ max
        vel = np.sqrt((self.I[0:self.fsteps-2]-self.I[1:self.fsteps-1])**2 + (self.Q[0:self.fsteps-2]-self.Q[1:self.fsteps-1])**2)
        svel = smooth(vel)
        cidx = (np.where(svel==max(svel)))[0]
        self.vmaxidx = cidx[0]
    
        # Try to pass fsteps/2 points but work even if closer to the edge than that
        low = cidx - self.fsteps/4
        if low < 0:
            low = 0

        high = cidx + self.fsteps/4
        if cidx > self.fsteps :
            high = self.fsteps

        #print cidx,low,high

        idx = self.freq[low:high]*1e9
        I = self.I[low:high]-self.I0
        Q = self.Q[low:high]-self.Q0
    
        #print len(I)
    
        s21 = np.zeros(len(I)*2)
        s21[:len(I)] = I
        s21[len(I):] = Q
    
        sigma = np.zeros(len(I)*2)
        sigma[:len(I)] = self.Isd[low:high]
        sigma[len(I):] = self.Qsd[low:high]
    
        # take a guess at center
        self.Iceng = (max(I)-min(I))/2.0 + min(I)
        self.Qceng = (max(Q)-min(Q))/2.0 + min(Q)

        ang = np.arctan2( Q[self.fsteps/4] - self.Qceng, I[self.fsteps/4] - self.Iceng )
        #print ang

        if ang >= 0 and ang <= np.pi:
            ang -= np.pi/2
        if ang >= -np.pi and ang < 0:
             ang += np.pi/2

        #print Q[self.fsteps/4]-self.Qceng, I[self.fsteps/4]-self.Iceng
        #print ang
        
        #parinfo = [{'value':0., 'fixed':0, 'limited':[1,1], 'limits':[0.,0.]}]*10
        parinfo=[ {'value':0., 'fixed':0, 'limited':[1,1], 'limits':[0.,0.]} for i in range(10) ]
        
        parinfo[0]['value'] = 50000.0
        parinfo[0]['limits'] = [5000.0,1e6]
        
        parinfo[1]['value'] = np.mean(idx) 
        parinfo[1]['limits'] = [ np.min(idx),np.max(idx)]
        
        parinfo[2]['value'] = 1.0
        parinfo[2]['limits'] = [1e-4,1e2]
        
        parinfo[3]['value'] = 800.0 
        parinfo[3]['limits'] = [1.0,4e4]
        
        parinfo[4]['value'] = 500.0 
        parinfo[4]['limits'] = [-5000.0,5000.0]
        
        parinfo[5]['value'] = ang 
        parinfo[5]['limits'] = [-np.pi*1.1,np.pi*1.1]
        
        parinfo[6]['value'] = np.max(I[low:high]) - np.min(I[low:high]) 
        parinfo[6]['limits'] = [parinfo[6]['value'] - 0.5*parinfo[6]['value']  , parinfo[6]['value'] + 0.5*parinfo[6]['value'] ]
        
        parinfo[7]['value'] = np.max(Q[low:high]) - np.min(Q[low:high]) 
        parinfo[7]['limits'] = [parinfo[7]['value'] - 0.5*parinfo[7]['value']  , parinfo[7]['value'] + 0.5*parinfo[6]['value'] ]
        
        parinfo[8]['value'] = self.Iceng
        parinfo[8]['limits'] = [parinfo[8]['value'] - np.abs(0.5*parinfo[8]['value'])  , parinfo[8]['value'] + np.abs(0.5*parinfo[8]['value']) ]
        
        parinfo[9]['value'] = self.Qceng
        parinfo[9]['limits'] = [parinfo[9]['value'] - np.abs(0.5*parinfo[9]['value'])  , parinfo[9]['value'] + np.abs(0.5*parinfo[9]['value']) ]
        
        fa = {'x':idx, 'y':s21, 'err':sigma}
    
        #pdb.set_trace()
         
        # use magfit Q if available        
        try:
            Qguess = np.repeat(self.mopt[0],10) 
        except:
            Qguess = np.repeat(range(10)*10000)
    
        chisq=1e50
        for x in range(10):
            # Fit
            Qtry = Qguess[x] + 20000.0*np.random.normal()
            if Qtry < 5000.0:
                Qtry = 5000.0
            parinfo[0]['value'] = Qtry
            parinfo[2]['value'] = 1.1e-4 + np.random.uniform()*90.0
            parinfo[3]['value'] = 1.0 + np.random.uniform()*3e4            
            parinfo[4]['value'] = np.random.uniform()*9000.0 - 4500.0    
            if x > 5:
                parinfo[5]['value'] = np.random.uniform(-1,1)*np.pi
            # fit!
            m = mpfit.mpfit(RESDIFFMP,functkw=fa,parinfo=parinfo,quiet=1)
            popt = m.params        
            newchisq = m.fnorm            
            if newchisq < chisq:
                chisq = newchisq
                bestpopt = m.params
        
        try:
            popt = bestpopt
        except:
            popt = m.params

        self.popt = popt
        self.Icen = popt[8]
        self.Qcen = popt[9]

        fit = RESDIFF(idx,popt[0],popt[1],popt[2],popt[3],popt[4],popt[5],popt[6],popt[7],popt[8],popt[9])

        #pdb.set_trace()

        # compute dipdb,Qc,Qi
        radius = abs((popt[6]+popt[7]))/4.0
        diam = (2.0*radius) / (np.sqrt(popt[8]**2 + popt[9]**2) +  radius)
        Qc = popt[0]/diam
        Qi = popt[0]/(1.0-diam)
        dip = 1.0 - 2.0*radius/(np.sqrt(popt[8]**2 + popt[9]**2) +  radius)
        dipdb = 20.0*np.log10(dip)
    
        # internal power
        power = 10.0**((-self.atten1-35.0)/10.0)
        Pint = 10.0*np.log10((2.0 * self.popt[0]**2/(np.pi * Qc))*power)

        #print popt
        #print radius,diam,Qc,Qi,dip,dipdb

        self.Qm = popt[0]
        self.fm = popt[1]
        self.Qc = Qc
        self.Qi = Qi
        self.dipdb = dipdb
        self.Pint = Pint
    
        self.fpoints = len(I)
        self.fI = fit[:len(I)]
        self.fQ = fit[len(I):]
        self.ff = self.freq[low:high]
    
    def FitMagMP(self):                       # Fit the sweep using just the magnitude data
        import mpfit
        # find center from IQ max
        vel = np.sqrt((self.I[0:self.fsteps-2]-self.I[1:self.fsteps-1])**2 + (self.Q[0:self.fsteps-2]-self.Q[1:self.fsteps-1])**2)
        svel = smooth(vel)
        cidx = (np.where(svel==max(svel)))[0]
        self.vmaxidx = cidx[0]

        idx = self.freq*1e9
        mag = np.sqrt((self.I-self.I0)**2 +  (self.Q-self.Q0)**2)
        norm = np.max(mag)
        mag = mag / norm

        #Q,f0,carrier,depth,slope,curve
        parinfo=[ {'value':0., 'fixed':0, 'limited':[1,1], 'limits':[0.,0.]} for i in range(6) ]

        parinfo[0]['value'] = 50000.0
        parinfo[0]['limits'] = [5000.0,1e6]

        parinfo[1]['value'] = np.mean(idx) 
        parinfo[1]['limits'] = [ np.min(idx),np.max(idx)]

        parinfo[2]['value'] = 1.0
        parinfo[2]['limits'] = [1e-4,1e2]

        parinfo[3]['value'] = 0.7
        parinfo[3]['limits'] = [0.01,10.0]

        parinfo[4]['value'] = 0.1 
        parinfo[4]['limits'] = [-5000.0,5000.0]

        parinfo[5]['value'] = -10.0
        parinfo[5]['limits'] = [-1e8,1e8]

        sigma = np.repeat(0.00001,len(mag))
        fa = {'x':idx, 'y':mag, 'err':sigma}

        #pdb.set_trace()
 
        chisq=1e50
        for x in range(10):
            # Fit
            Qtry = x*10000.0 + 5000.0*np.random.normal()
            if Qtry < 5000.0:
                Qtry = 5000.0
            parinfo[0]['value'] = Qtry
            # fit!
            m = mpfit.mpfit(MAGDIFFMP,functkw=fa,parinfo=parinfo,quiet=1)
            popt = m.params        
            newchisq = m.fnorm            
            #print newchisq
            if newchisq < chisq:
                chisq = newchisq
                bestpopt = m.params

        popt = bestpopt

        #print popt

        fit = MAGDIFF(idx,popt[0],popt[1],popt[2],popt[3],popt[4],popt[5])
        self.mag = np.sqrt((self.I-self.I0)**2 +  (self.Q-self.Q0)**2)/norm
        self.magfreq = self.freq
        self.magfit = fit
        self.mopt = popt

    def PlotIQ(self):                   # Plot the sweep
     
        fig = plt.figure( figsize=(8, 6), dpi=100)
        
        ax = fig.add_subplot(111)
        ax.plot(self.I[:self.fsteps]-self.I0,self.Q[:self.fsteps]-self.Q0,'bo')    
        ax.plot(self.Iceng,self.Qceng,'gx')       
        ax.plot(self.I[self.vmaxidx]-self.I0,self.Q[self.vmaxidx]-self.Q0,'go')
        ax.plot(self.Icen,self.Qcen,'rx')        
        ax.plot(self.fI,self.fQ,'r')
         
        #leg = ax.legend(['Q = ' + '{0:.2f}'.format(self.popt[0]), 'f$_0$ = ' + '{0:.6f}'.format(self.popt[1]/1e9), 'Q$_c$ = ' + '{0:.2f}'.format(self.Qc),'Q$_i$ = ' + '{0:.2f}'.format(self.Qi),'|S$_{21}$|$_{min}$ = ' + '{0:.2f}'.format(self.dipdb)],loc=4, shadow=True,numpoints=1)
        #print 'Q = ' + '{0:.2f}'.format(self.popt[0]) + '\nf$_0$ = ' + '{0:.6f}'.format(self.popt[1]/1e9) + '\nQ$_c$ = ' + '{0:.2f}'.format(self.Qc) + '\nQ$_i$ = ' + '{0:.2f}'.format(self.Qi) + '\n|S$_{21}$|$_{min}$ = ' + '{0:.2f}'.format(self.dipdb)
        #leg = ax.text(.5,.5,'Q = ' + '{0:.2f}'.format(self.popt[0]) + '\nf$_0$ = ' + '{0:.6f}'.format(self.popt[1]/1e9) + '\nQ$_c$ = ' + '{0:.2f}'.format(self.Qc) + '\nQ$_i$ = ' + '{0:.2f}'.format(self.Qi) + '\n|S$_{21}$|$_{min}$ = ' + '{0:.2f}'.format(self.dipdb),transform=ax.transAxes)
        
        ax.grid(False)
        ax.set_xlabel('I')
        ax.set_ylabel('Q')
        
        # the matplotlib.patches.Rectangle instance surrounding the legend
        #frame = leg.get_frame()
        #frame.set_facecolor('0.80')    # set the frame face color to light gray
        
        # matplotlib.text.Text instances
        #for t in leg.get_texts():
        #    t.set_fontsize('small')    # the legend text fontsize

        # matplotlib.lines.Line2D instances
        #for l in leg.get_lines():
        #    l.set_linewidth(1.5)  # the legend line width
        plt.show()

    def PlotMag(self):                   # Plot the sweep
     
        fig = plt.figure( figsize=(8, 6), dpi=100)
        
        ax = fig.add_subplot(111)
        ax.plot(self.freq,20.0*np.log10(self.mag),'bo')    
        ax.plot(self.magfreq,20.0*np.log10(self.magfit),'r')
            
        ax.grid(False)
        ax.set_xlabel('Frequency (GHz)')
        ax.set_ylabel('|S$_{21}$| (dB)')
        
        plt.show()
          
    def Save(self,filename,roach,wmode):            # Save IQ sweep data into a HDF5 file
        
        h5file = openFile(filename, mode = wmode, title = "IQ sweep file created " + time.asctime() )

        # if there is no existing roach group, create one
        try:
            #group = h5file.root.r0
            group = h5file.getNode('/',roach )
        except:
            group = h5file.createGroup("/",roach, 'ROACH Identifier' )
        
        # if there is no existing sweep group, create one
        #if group.__contains__('sweeps'):
        #    group = group.sweeps
        #else:
        #    group = h5file.createGroup(group,'sweeps', 'IQ sweep data' )

        # make a group for each resonator
        try:
            group = h5file.getNode(group,'f'+str(int(np.float32(self.f0)*10000.0)) )
        except:
            group = h5file.createGroup(group,'f'+str(int(np.float32(self.f0)*10000.0)), 'Group Created ' + time.ctime(self.time) )        
        
        # store sweeps with various Tstart and atten settings in the same table
        try:
            table = group.iqsweep
            swp = group.iqsweep.row
        except:
            filt = Filters(complevel=5, complib='zlib', fletcher32=True)
            table = h5file.createTable(group,'iqsweep', IQsweeptables, "IQ Sweep Data",filters=filt) 
            swp = table.row

        try:
            swp['f0'] = np.float32(self.f0)
            swp['span'] = self.span
            swp['fsteps'] = self.fsteps
            swp['atten1'] = self.atten1                
            swp['atten2'] = self.atten2
            swp['scale'] = self.scale                
            swp['PreadoutdB'] = self.PreadoutdB
            swp['Tstart'] = self.Tstart
            swp['Tend'] = self.Tend
            swp['I0'] = self.I0
            swp['Q0'] = self.Q0
            swp['resnum'] = self.resnum
            swp['freq'] = np.concatenate( (self.freq,np.zeros(2000-self.fsteps)),axis=0 )
            swp['I'] = np.concatenate( (self.I,np.zeros(2000-self.fsteps)),axis=0 )
            swp['Q'] = np.concatenate( (self.Q,np.zeros(2000-self.fsteps)),axis=0 )
            swp['Isd'] = np.concatenate( (self.Isd,np.zeros(2000-self.fsteps)),axis=0 )
            swp['Qsd'] = np.concatenate( (self.Qsd,np.zeros(2000-self.fsteps)),axis=0 )
            swp['time'] = self.time
        except:
            pass

        try:
            swp['vmaxidx'] = self.vmaxidx
            swp['Iceng'] = self.Iceng
            swp['Qceng'] = self.Qceng
            swp['Icen'] = self.Icen
            swp['Qcen'] = self.Qcen
            swp['Qm'] = self.Qm
            swp['fm'] = self.fm
            swp['Qc'] = self.Qc
            swp['Qi'] = self.Qi
            swp['dipdb'] = self.dipdb
            swp['popt'] = self.popt
            swp['fpoints'] = self.fpoints        
            swp['fI'] = np.concatenate( (self.fI,np.zeros(2000-self.fI.__len__())),axis=0 )
            swp['fQ'] = np.concatenate( (self.fQ,np.zeros(2000-self.fQ.__len__())),axis=0 )
            swp['ff'] = np.concatenate( (self.ff,np.zeros(2000-self.ff.__len__())),axis=0 )
        except:
            pass

        # data products from mag fit
        try:
            swp['mag'] = np.concatenate( (self.mag,np.zeros(2000-self.fsteps)),axis=0 )
            swp['magfreq'] =  np.concatenate( (self.magfreq,np.zeros(2000-len(self.magfreq))),axis=0 )
            swp['magfit'] = np.concatenate( (self.magfit,np.zeros(2000-len(self.magfit))),axis=0 )
            swp['mopt'] = self.mopt
        except:
            pass

        # data products from noise analysis
        try:
            swp['pn'] = self.pn
            swp['pnidx'] = self.pnidx
            swp['an'] = self.an
            swp['anidx'] = self.anidx
            swp['fn1k'] = self.fn1k
        except:
            pass
        
        # now save noise data if present and save flag is set
        if self.savenoise > 0:
            try:
                swp['samprate'] = self.samprate    
                swp['savenoise'] = self.savenoise    
                try:
                    noise = group.iqnoise
                except:     
                    noise = h5file.createVLArray(group, 'iqnoise', Int16Atom(shape=()), "Noise data stored in ragged array of ints. [0] = I, [1] = Q")
                noise.append(self.Ix1)
                noise.append(self.Qx1)            
            except:
                print "Unexpected error saving noise data: ", sys.exc_info()[0]
                     
        swp.append()
        table.flush()       
        h5file.close()

    def Load(self,filename,roach,f0,atten):            # Load the desired IQ sweep data from a HDF5 file

        #load the sweep with center frequency closest to f0 and input atten=atten1
        h5file = openFile(filename, mode = "r")
            
        # find the table with the sweep data in it.
        try:
            group = h5file.getNode('/',roach )
            group = h5file.getNode(group,'f'+str(int(f0*10000.0)) )
            table = group.iqsweep
            k = table.readWhere('atten1 == atten')
        except:
            print 'Did not find sweep in file!'
            h5file.close()
            return     
        
        try:    
            self.f0 = k['f0'][0]
            self.span = k['span'][0]
            self.fsteps = k['fsteps'][0]
            self.atten1 = k['atten1'][0] 
            self.atten2 = k['atten2'][0]
            self.scale = k['scale'][0]
            self.PreadoutdB = k['PreadoutdB'][0]                       
            self.Tstart = k['Tstart'][0]
            self.Tend = k['Tend'][0]
            self.I0 = k['I0'][0]
            self.Q0 = k['Q0'][0]
            self.resnum = k['resnum'][0]
            self.time = k['time'][0]
        except:
            pass
        
        try:
            self.freq = k['freq'][0,0:self.fsteps]
            self.I = k['I'][0,0:self.fsteps]
            self.Q = k['Q'][0,0:self.fsteps]
            self.Isd = k['Isd'][0,0:self.fsteps]
            self.Qsd = k['Qsd'][0,0:self.fsteps]   
            self.vmaxidx = k['vmaxidx'][0]
            self.Iceng = k['Iceng'][0]
            self.Qceng = k['Qceng'][0]
            self.Icen = k['Icen'][0]
            self.Qcen= k['Qcen'][0]
            self.Qm= k['Qm'][0]
            self.fm= k['fm'][0]          
            self.Qc= k['Qc'][0]
            self.Qi= k['Qi'][0]
            self.dipdb= k['dipdb'][0]
            self.popt = k['popt'][0]
            self.fpoints = k['fpoints'][0]
            self.fI = k['fI'][0,0:self.fpoints]
            self.fQ = k['fQ'][0,0:self.fpoints]
            self.ff = k['ff'][0,0:self.fpoints]
        except:
            pass

        try:            
            self.mag = k['mag'][0,0:self.fpoints]
            self.magfreq = k['magfreq'][0]
            self.magfit = k['magfit'][0]
            self.mopt = k['mopt'][0]
        except:
            pass            

        try:
            self.savenoise =  k['savenoise'][0]      
            self.samprate =  k['samprate'][0]
            self.pn = k['pn'][0]
            self.pnidx = k['pnidx'][0]    
            self.an = k['an'][0]
            self.anidx = k['anidx'][0]    
            self.kn1k = k['fn1k'][0]           
        except:
            pass

        h5file.close() 

    def LoadLeaf(self,table,row):                # Load up sweep table data from a hdf5 table
      
        # speed things up by loading the whole table at once
        k = table.read()

        try:    
            self.f0 = k['f0'][row]
            self.span = k['span'][row]
            self.fsteps = k['fsteps'][row]
            self.atten1 = k['atten1'][row] 
            self.atten2 = k['atten2'][row]
            self.scale = k['scale'][row]
            self.PreadoutdB = k['PreadoutdB'][row]       
            self.Tstart = k['Tstart'][row]
            self.Tend = k['Tend'][row]
            self.I0 = k['I0'][row]
            self.Q0 = k['Q0'][row]
            self.resnum = k['resnum'][row]
            self.time = k['time'][row]
        except:
            pass
        
        try:
            self.freq = k['freq'][row,0:self.fsteps]
            self.I = k['I'][row,0:self.fsteps]
            self.Q = k['Q'][row,0:self.fsteps]
            self.Isd = k['Isd'][row,0:self.fsteps]
            self.Qsd = k['Qsd'][row,0:self.fsteps]   
            self.vmaxidx = k['vmaxidx'][row]
            self.Iceng = k['Iceng'][row]
            self.Qceng = k['Qceng'][row]
            self.Icen = k['Icen'][row]
            self.Qcen= k['Qcen'][row]
            self.Qm= k['Qm'][row]
            self.fm= k['fm'][row]          
            self.Qc= k['Qc'][row]
            self.Qi= k['Qi'][row]
            self.dipdb= k['dipdb'][row]
            self.popt = k['popt'][row]
            self.fpoints = k['fpoints'][row]
            self.fI = k['fI'][row,0:self.fpoints]
            self.fQ = k['fQ'][row,0:self.fpoints]
            self.ff = k['ff'][row,0:self.fpoints]
        except:
            pass

        try:            
            self.mag = k['mag'][row,0:self.fpoints]
            self.magfreq = k['magfreq'][row]
            self.magfit = k['magfit'][row]
            self.mopt = k['mopt'][row]
        except:
            pass            

        try:
            self.savenoise =  k['savenoise'][row]      
            self.samprate =  k['samprate'][row]
            self.pn = k['pn'][row]
            self.pnidx = k['pnidx'][row]    
            self.an = k['an'][row]
            self.anidx = k['anidx'][row]    
            self.kn1k = k['fn1k'][row]           
        except:
            pass

    def Pdf(self,filename):
        pp = PdfPages(filename)
        
        matplotlib.rcParams['font.size']=8
        
        fig = plt.figure( figsize=(7.5, 9), dpi=100)
        
        try:
            ax = fig.add_subplot(221)
            ax.plot(self.I[:self.fsteps]-self.I0,self.Q[:self.fsteps]-self.Q0,'bo',markersize=4)
            ax.plot(self.Iceng,self.Qceng,'gx')
            ax.plot(self.I[self.vmaxidx]-self.I0,self.Q[self.vmaxidx]-self.Q0,'go',markersize=4)
            ax.plot(self.Icen,self.Qcen,'rx')
            ax.plot(self.fI,self.fQ,'r')
            ax.set_xlabel('I')
            ax.set_ylabel('Q')
        except:
            pass
            
        # overplot some noise data
        try:
            ax.plot(self.Ix1[0:5000]*0.2/32767.0-self.I0,self.Qx1[0:5000]*0.2/32767.0-self.Q0,'c.',markersize=1)
        except:
            pass
                
        try:
            ax2 = fig.add_subplot(222)
            ax2.plot(self.freq,20.0*np.log10(self.mag),'bo',markersize=4)    
            ax2.plot(self.magfreq,20.0*np.log10(self.magfit),'r')            
            ax2.grid(False)
            ax2.set_xlabel('Frequency (GHz)')
            ax2.set_ylabel('|S$_{21}$| (dB)')
        except:
            pass

        try:
            ax3 = fig.add_subplot(212)
            ax3.plot(self.pnidx[1:],10.0*np.log10(self.pn[1:]),'r',self.anidx[1:],10.0*np.log10(self.an[1:]),'k')           
            ax3.set_title('P$_{int}$ = ' + '{0:.2f}'.format(self.Pint) + ' dBm, Frequency Noise at 1 kHz = ' + '{0:.2e}'.format(self.fn1k) + ' Hz$^2$/Hz' )        
            ax3.set_xscale('log')
            ax3.set_autoscale_on(False)         
            ax3.set_xlim([1,1e5])
            ax3.set_ylim([-100,-50])        
            ax3.set_xlabel('Frequency (Hz)')
            ax3.set_ylabel('Phase (Red) and Amplitude (Black) Noise (dBc/Hz)')
            ax3.grid(True)
            text = 'Q = ' + '{0:.2f}'.format(self.Qm) + '\nf$_0$ = ' + '{0:.6f}'.format(self.fm/1e9) + '\nQ$_c$ = ' + '{0:.2f}'.format(self.Qc) + '\nQ$_i$ = ' + '{0:.2f}'.format(self.Qi) + '\n|S$_{21}$|$_{min}$ = ' + '{0:.2f}'.format(self.dipdb)
        
            bbox_args = dict(boxstyle="round", fc="0.8")
            ax3.annotate(text,
                         xy=(0.75, 0.9),  xycoords='axes fraction',
                         xytext=(0.75, 0.9), textcoords='axes fraction',
                         ha="left", va="top",
                         bbox=bbox_args)
        except:
            pass

        try:
            ax4 = ax3.twinx()
            ax4.set_ylim([np.log10((10**(-100.0/10.0))/(16.0*self.popt[0]**2)),np.log10((10**(-50.0/10.0))/(16.0*self.popt[0]**2))])        
            ax4.set_ylabel('Frequency Noise log$_{10}$(Hz$^2$/Hz)', color='r')
    
            for tl in ax4.get_yticklabels():
                tl.set_color('r')
        except:
            pass

        pp.savefig()
        pp.close()
        
    def LoadNoise(self,filename,resnum):
        # Load up noise data
        self.noisename = filename
        
        f = open(filename, 'rb')
        fsize = os.fstat(f.fileno())[6]
        if fsize < 10:
            print 'No Noise File!'
            return        
        
        hdr = np.fromfile(f, dtype=np.float64,count=12)
        
        self.samprate = 200000.0
        self.Ix1 = np.zeros(2000000,dtype=np.int16)
        self.Qx1 = np.zeros(2000000,dtype=np.int16)
        
        for x in range(10):
            if resnum == 0:
                self.Ix1[x*200000:(x+1)*200000] = np.fromfile(f, dtype=np.int16,count=200000)
                self.Qx1[x*200000:(x+1)*200000] = np.fromfile(f, dtype=np.int16,count=200000)
                dummy = np.fromfile(f, dtype=np.int16,count=200000)
                dummy = np.fromfile(f, dtype=np.int16,count=200000)
            else:
                dummy = np.fromfile(f, dtype=np.int16,count=200000)
                dummy = np.fromfile(f, dtype=np.int16,count=200000)
                self.Ix1[x*200000:(x+1)*200000] = np.fromfile(f, dtype=np.int16,count=200000)
                self.Qx1[x*200000:(x+1)*200000] = np.fromfile(f, dtype=np.int16,count=200000)
        
        self.savenoise = len(self.Ix1)
        dummy = 0        
        f.close()
        
    def AnalyzeNoise(self):
        import matplotlib.mlab
        # Analyze noise data
        
        # subtract off zero point and move center of resonance to (0,0)
        Ix1a = self.Ix1*0.2/32767.0 - self.I0 - self.Icen
        Qx1a = self.Qx1*0.2/32767.0 - self.Q0 - self.Qcen
        
        #convert to mag and phase
        resang = np.arctan2(np.mean(Qx1a), np.mean(Ix1a) )

        nI = (Ix1a*np.cos(resang) + Qx1a*np.sin(resang))
        nQ = (-Ix1a*np.sin(resang) + Qx1a*np.cos(resang))

        rad = np.mean(nI)
        nI = nI/rad
        nQ = nQ/rad
        
        phase = np.arctan2(nQ,nI)
        amp = np.sqrt(nI**2 + nQ**2)
            
        # low frequency FFTs
        pnlow, pnlowidx = matplotlib.mlab.psd(phase,NFFT=262144,Fs=self.samprate,noverlap=131072)
        anlow, anlowidx = matplotlib.mlab.psd(amp,NFFT=262144,Fs=self.samprate,noverlap=131072)

        #pdb.set_trace()          
        #self.pnidx,self.pn,dummy = powspec_rebin.rebin(pnlowidx[1:],pnslow[1:],binsize=0.002,sampling=1)
        #self.anidx,self.an,dummy = powspec_rebin.rebin(anlowidx[1:],anlow[1:],binsize=0.002,sampling=1)

        # high frequency FFTs
        pnhigh, pnhighidx = matplotlib.mlab.psd(phase,NFFT=4096,Fs=self.samprate,noverlap=2048)
        anhigh, anhighidx = matplotlib.mlab.psd(amp,NFFT=4096,Fs=self.samprate,noverlap=2048)
 
        self.pn = np.zeros(2552)
        self.pn[0:512] = pnlow[0:512]
        self.pn[512:2552] = pnhigh[8:2048]   
        
        self.pnidx = np.zeros(2552)
        self.pnidx[0:512] = pnlowidx[0:512]
        self.pnidx[512:2552] = pnhighidx[8:2048]
        
        self.an = np.zeros(2552)
        self.an[0:512] = anlow[0:512]
        self.an[512:2552] = anhigh[8:2048]   
        
        self.anidx = np.zeros(2552)
        self.anidx[0:512] = anlowidx[0:512]
        self.anidx[512:2552] = anhighidx[8:2048]
        
        # calculate frequency noise at 1 kHz
        coeff = np.polyfit(self.pnidx[521:526],self.pn[521:526],1)
        pf = np.poly1d(coeff)        
        self.fn1k = pf(1000)/(16.0*self.popt[0]**2)

def RESDIFF(x,Q,f0,aleak,ph1,da,ang1,Igain,Qgain,Ioff,Qoff):
#       Q = p[0]          ;  Q
#       f0 = p[1]         ;  resonance frequency
#       aleak = p[2]      ;  amplitude of leakage
#       ph1 = p[3]        ;  phase shift of leakage
#       da = p[4]         ;  variation of carrier amplitude
#       ang1 = p[5]       ;  Rotation angle of data
#       Igain = p[6]      ;  Gain of I channel
#       Qgain = p[7]      ;  Gain of Q channel
#       Ioff = p[8]       ;  Offset of I channel
#       Qoff = p[9]       ;  Offset of Q channel

    l = len(x)
    dx = (x - f0) / f0

    # resonance dip function
    s21a = (np.vectorize(complex)(0,2.0*Q*dx)) / (complex(1,0) + np.vectorize(complex)(0,2.0*Q*dx))
    s21a = s21a - complex(.5,0)
    s21b = np.vectorize(complex)(da*dx,0) + s21a + aleak*np.vectorize(complex)(1.0-np.cos(dx*ph1),-np.sin(dx*ph1))

    # scale and rotate
    Ix1 = s21b.real*Igain
    Qx1 = s21b.imag*Qgain
    nI1 = Ix1*np.cos(ang1) + Qx1*np.sin(ang1)
    nQ1 = -Ix1*np.sin(ang1) + Qx1*np.cos(ang1)

    #scale and offset
    nI1 = nI1 + Ioff
    nQ1 = nQ1 + Qoff

    s21 = np.zeros(l*2)
    s21[:l] = nI1
    s21[l:] = nQ1

    return s21

def RESDIFFMP(p, fjac=None, x=None, y=None, err=None):

    Q = p[0]          #  Q
    f0 = p[1]         #  resonance frequency
    aleak = p[2]      #  amplitude of leakage
    ph1 = p[3]        #  phase shift of leakage
    da = p[4]         #  variation of carrier amplitude
    ang1 = p[5]       #  Rotation angle of data
    Igain = p[6]      #  Gain of I channel
    Qgain = p[7]      #  Gain of Q channel
    Ioff = p[8]       #  Offset of I channel
    Qoff = p[9]       #  Offset of Q channel

    l = len(x)
    dx = (x - f0) / f0

    # resonance dip function
    s21a = (np.vectorize(complex)(0,2.0*Q*dx)) / (complex(1,0) + np.vectorize(complex)(0,2.0*Q*dx))
    s21a = s21a - complex(.5,0)
    s21b = np.vectorize(complex)(da*dx,0) + s21a + aleak*np.vectorize(complex)(1.0-np.cos(dx*ph1),-np.sin(dx*ph1))

    # scale and rotate
    Ix1 = s21b.real*Igain
    Qx1 = s21b.imag*Qgain
    nI1 = Ix1*np.cos(ang1) + Qx1*np.sin(ang1)
    nQ1 = -Ix1*np.sin(ang1) + Qx1*np.cos(ang1)

    #scale and offset
    nI1 = nI1 + Ioff
    nQ1 = nQ1 + Qoff

    s21 = np.zeros(l*2)
    s21[:l] = nI1
    s21[l:] = nQ1

    status=0
    return [status, (y-s21)/err]

def MAGDIFFMP(p, fjac=None, x=None, y=None, err=None):
    Q = p[0]
    f0 = p[1]
    carrier = p[2]
    depth = p[3]
    slope = p[4]
    curve = p[5]

    dx = (x - f0) / f0
    s21 = (np.vectorize(complex)(0,2.0*Q*dx)) / (complex(1,0) + np.vectorize(complex)(0,2.0*Q*dx))
    mag1 = (np.abs(s21)-1.0)*depth + carrier + slope*dx + curve*dx*dx    

    status=0
    return [status, (y-mag1)/err]

def MAGDIFF(x,Q,f0,carrier,depth,slope,curve):
    dx = (x - f0) / f0
    s21 = (np.vectorize(complex)(0,2.0*Q*dx)) / (complex(1,0) + np.vectorize(complex)(0,2.0*Q*dx))
    mag1 = (np.abs(s21)-1.0)*depth + carrier + slope*dx + curve*dx*dx    
    return mag1

def smooth(x, window_len=10, window='hanning'):
    """smooth the data using a window with requested size.

    This method is based on the convolution of a scaled window with the signal.
    The signal is prepared by introducing reflected copies of the signal 
    (with the window size) in both ends so that transient parts are minimized
    in the begining and end part of the output signal.

    input:
        x: the input signal 
        window_len: the dimension of the smoothing window
        window: the type of window from 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'
            flat window will produce a moving average smoothing.

    output:
        the smoothed signal

    example:

    import numpy as np    
    t = np.linspace(-2,2,0.1)
    x = np.sin(t)+np.random.randn(len(t))*0.1
    y = smooth(x)

    see also: 

    numpy.hanning, numpy.hamming, numpy.bartlett, numpy.blackman, numpy.convolve
    scipy.signal.lfilter

    TODO: the window parameter could be the window itself if an array instead of a string   
    """

    if x.ndim != 1:
        raise ValueError, "smooth only accepts 1 dimension arrays."

    if x.size < window_len:
        raise ValueError, "Input vector needs to be bigger than window size."

    if window_len < 3:
        return x

    if not window in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
        raise ValueError, "Window is on of 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'"

    s=np.r_[2*x[0]-x[window_len:1:-1], x, 2*x[-1]-x[-1:-window_len:-1]]
    #print(len(s))

    if window == 'flat': #moving average
        w = np.ones(window_len,'d')
    else:
        w = getattr(np, window)(window_len)
    y = np.convolve(w/w.sum(), s, mode='same')
    return y[window_len-1:-window_len+1]
        