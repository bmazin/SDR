
# encoding: utf-8
"""
pulses.py

Created by Ben Mazin on 2011-05-04.
Copyright (c) 2011 . All rights reserved.
"""

import numpy as np
import time
import os
from tables import *
import matplotlib
import scipy as sp
import scipy.signal
from matplotlib.pyplot import plot, figure, show, rc, grid
import matplotlib.pyplot as plt
#import matplotlib.image as mpimg
import mpfit
#import numexpr
#from iqsweep import *

class Photon(IsDescription):
    """The pytables derived class that holds pulse packet data on the disk.
    Put in a marker pulse with at = int(time.time()) and phase = -32767 every second.
    """
    at = UInt32Col()            # pulse arrival time in microseconds since last sync pulse
#    phase = Int16Col()          # optimally filtered phase pulse height

class RawPulse(IsDescription):
    """The pytables derived class that hold raw pulse data on the disk.
    """
    starttime = Float64Col()    # start time of pulse data
    samprate = Float32Col()     # sample rate of the data in samples/sec
    npoints = Int32Col()        # number of data points in the pulse
    f0 =  Float32Col()          # resonant frequency data was taken at 
    atten1 =  Float32Col()      # attenuator 1 setting data was taken at
    atten2 =  Float32Col()      # attenuator 2 setting data was taken at
    Tstart = Float32Col()       # temp data was taken at
        
    I = Float32Col(2000)        # I pulse data, up to 5000 points.
    Q = Float32Col(2000)

class PulseAnalysis(IsDescription):     # contains final template info
    flag = Int16Col()                   # flag for quality of template.  If this could be a bad template set > 0
    count = Float32Col()                # number of pulses going into this template
    pstart = Int16Col()                 # index of peak of template
    phasetemplate = Float64Col(2000)
    phasenoise = Float64Col(800)
    phasenoiseidx = Float64Col(800)
    #optfilt = Complex128(800)   
    
    # fit quantities
    trise = Float32Col()                # fit value of rise time                    
    tfall = Float32Col()                # fit value of fall time
    
    # optimal filter parameters
    coeff = Float32Col(100)             # coefficients for the near-optimal filter
    nparam = Int16Col()                 # number of parameters in the filter

class BeamMap(IsDescription):
    roach = UInt16Col()                 # ROACH board number (0-15) for now!
    resnum = UInt16Col()                # resonator number on roach board (corresponds to res # in optimal pulse packets)
    f0 = Float32Col()                   # resonant frequency of center of sweep (can be used to get group name)
    pixel = UInt32Col()                 # actual pixel number - bottom left of array is 0, increasing up
    xpos = Float32Col()                 # physical X location in mm
    ypos = Float32Col()                 # physical Y location in mm
    scale = Float32Col(3)               # polynomial to convert from degrees to eV 

class ObsHeader(IsDescription):
    target = StringCol(80)
    datadir = StringCol(80)             # directory where observation data is stored
    calfile = StringCol(80)             # path and filename of calibration file
    beammapfile = StringCol(80)         # path and filename of beam map file
    version = StringCol(80)
    instrument = StringCol(80)
    telescope = StringCol(80)
    focus = StringCol(80)
    parallactic = Float64Col()
    ra = Float64Col()
    dec = Float64Col()
    alt = Float64Col()
    az = Float64Col()
    airmass = Float64Col()
    equinox = Float64Col()
    epoch = Float64Col()
    obslat = Float64Col()
    obslong = Float64Col()
    obsalt = Float64Col()
    timezone = Int32Col()
    localtime = StringCol(80)
    ut = Float64Col()
    lst = StringCol(80)
    jd = Float64Col()
    platescl = Float64Col()
    exptime = Int32Col()
    
# Make a fake observation file
def FakeObservation(obsname, start, exptime):
    
    # simulation parameters
    nroach = 4              # number of roach boards
    nres = 256              # number of pixels on each roach
    xpix = 32               # pixels in x dir
    ypix = 32               # pixels in y dir
    R = 15                  # mean energy resolution
    good = 0.85             # fraction of resonators that are good 
    #exptime = 10            # duration of fake exposure in seconds
    
    fullobspath = obsname.split("/")
    obsfile = fullobspath.pop()
    obspath = "/".join(fullobspath)+"/"
    
    h5file = openFile(obsname, mode = "r")
    carray = h5file.root.beammap.beamimage.read()
    h5file.close()
    
    filt1 = Filters(complevel=1, complib='zlib', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
    
    h5file = openFile(obsname, mode = "a")
    
    ''' beam map inserted from beam map file during header gen
    # make beamap table
    bgroup = h5file.createGroup('/','beammap','Beam Map of Array')
    filt = Filters(complevel=0, complib='zlib', fletcher32=False)
    filt1 = Filters(complevel=1, complib='blosc', fletcher32=False)      # without minimal compression the files sizes are ridiculous...
    btable = h5file.createTable(bgroup, 'beammap', BeamMap, "Table of anaylzed beam map data",filters=filt1)
    w = btable.row

    # make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
    ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (32,32), filters=filt1)  
    
    for i in xrange(nroach):
        for j in xrange(nres):
            w['roach'] = i
            w['resnum'] = ((41*j)%256)
            w['f0'] = 3.5 + (i%2)*.512 + 0.002*j
            w['pixel'] = ((41*j)%256) + 256*i
            w['xpos'] = np.floor(j/16)*0.1 
            w['ypos'] = (j%16)*0.1 
            if i == 1 or i == 3:
                w['ypos'] = (j%16)*0.1 + 1.6 
            if i == 2 or i == 3:
                w['xpos'] = np.floor(j/16)*0.1 + 1.6                          
            w.append()
            colidx = int(np.floor(j/16))
            rowidx = 31 - j%16
            if i == 1 or i == 3:
                rowidx -= 16                
            if i >= 2:
                colidx += 16
            ca[rowidx,colidx] = 'r'+str(i)+'/p'+str( ((41*j)%256) ) 
    h5file.flush()
    carray = ca.read()  
    '''

    # load up the 32x32 image we want to simulate
    sourceim = plt.imread('/Users/ourhero/Documents/python/MazinLab/Arcons/ucsblogo.png')
    sourceim = sourceim[:,:,0]

    # make directory structure for pulse data
    dptr = []
    for i in xrange(nroach):
        group = h5file.createGroup('/','r'+str(i),'Roach ' + str(i))
        for j in xrange(nres):
            subgroup = h5file.createGroup(group,'p'+str(j))
            dptr.append(subgroup)
            
    '''
    # now go in an update the beamimages array to contain the name of the actual data array
    for i in xrange(32):
        for j in xrange(32):
            name = h5file.getNode('/',name=ca[i,j])
            for leaf in name._f_walkNodes('Leaf'):
                newname = ca[i,j]+'/'+leaf.name
                ca[i,j] = newname
    '''
    
    # create fake photon data
    #start = np.floor(time.time())
    
    # make VLArray tables for the photon data
    vlarr=[]
    for i in dptr:
        tmpvlarr = h5file.createVLArray(i, 't'+str(int(start)), UInt32Atom(shape=()),expectedsizeinMB=0.1,filters=filt1)
        vlarr.append(tmpvlarr)

    idx = np.arange(2000)
    for i in xrange(exptime):
        print i
        t1 = time.time()
        for j in vlarr:
            # sky photons
            nphot = 1000 + int(np.random.randn()*np.sqrt(1000))
            #arrival = np.uint32(idx[:nphot]*700.0 + np.random.randn(nphot)*100.0)
            arrival = np.uint64(np.random.random(nphot)*1e6)
            energy = np.uint64(np.round((20.0 + np.random.random(nphot)*80.0)*20.0))
            photon = np.bitwise_or( np.left_shift(energy,12), arrival )

            # source photons

            # figure out where this group is on the array
            pgroup = j._g_getparent().__str__()
            #print "printing pgroup", pgroup
            ngroup = (pgroup.split(' '))[0]+'/t'+str(start)
            #print "printing ngroup", ngroup
            cidx = np.where(carray == ngroup[1:])
            #print "printing ngroup 1:" ,ngroup[1:]
            #print "printing cidx", cidx

            #print sourceim[cidx]
            sphot = 100.0 * (sourceim[cidx])[0]
            sphot += np.sqrt(sphot)*np.random.randn()
            sphot = np.uint32(sphot)
            #print sphot
            if sphot >= 1.0: 
                arrival = np.uint64(np.random.random(sphot)*1e6)
                energy = np.uint64( (60.0 + np.random.randn(sphot)*3.0)*20.0 )
                source = np.bitwise_or( np.left_shift(energy,12), arrival )            
                plist = np.concatenate((photon,source))
            else:
                plist = photon
            #splist = np.sort(plist)
            
            j.append(plist)
            
        t2 = time.time()
        dt = t2-t1
        if t2-t1 < 1:
            #delay for 1 second between creating seconds of false data
            time.sleep(1-dt)
    
    '''
    idx = np.arange(2000)
    for i in xrange(exptime):
        print i
        t1 = time.time()
        for j in vlarr:
            # sky photons
            nphot = 1000 + int(np.random.randn()*np.sqrt(1000))
            #arrival = np.uint32(idx[:nphot]*700.0 + np.random.randn(nphot)*100.0)
            arrival = np.uint32(np.random.random(nphot)*1e6)
            energy = np.uint32(np.round((20.0 + np.random.random(nphot)*80.0)*20.0))
            photon = np.bitwise_or( np.left_shift(arrival,12), energy )                                  

            # source photons
            
            # figure out where this group is on the array
            pgroup = j._g_getparent().__str__()
            ngroup = (pgroup.split(' '))[0]
            cidx = np.where(carray == ngroup[1:])
            
            #print sourceim[cidx]
            sphot = 100.0 * (sourceim[cidx])[0]
            sphot += np.sqrt(sphot)*np.random.randn()
            sphot = np.uint32(sphot)
            #print sphot
            if sphot >= 1.0: 
                arrival = np.uint32(np.random.random(sphot)*1e6)
                energy = np.uint32( (60.0 + np.random.randn(sphot)*3.0)*20.0 )
                source = np.bitwise_or( np.left_shift(arrival,12), energy )            
                plist = np.concatenate((photon,source))
            else:
                plist = photon
            #splist = np.sort(plist)
            
            j.append(plist)
        '''
    h5file.close()
            
# make a preview image from obsfile
def QuickLook(obsfile,tstart,tend):
    h5file = openFile(obsfile, mode = "r")    

    image = np.zeros((32,32))
    #mask = np.repeat(np.uint32(4095),2000)

    # load beamimage
    bmap = h5file.root.beammap.beamimage

    for i in xrange(32):
        for j in xrange(32):
            photons = h5file.root._f_getChild(bmap[i][j])
            for k in range(tstart,tend):
                #energy = np.bitwise_and( mask[:len(photons[0])],photons[0])
                image[i][j] += len(photons[k])
    
    # subtract off sky 
    skysub = np.float32(image - np.median(image))
                 
    h5file.close()

    # display the image    
    fig = plt.figure()
    ax = fig.add_subplot(111)
    cax = ax.imshow(skysub,cmap='gray', interpolation='nearest')
    cbar = fig.colorbar(cax)
    plt.show() 

# Make a pulse template from the pulses saved in filename
def MakeTemplate(pulsedat):
    
    # open the pulse file
    h5file = openFile(pulsedat, mode = "r")
    r1 = h5file.root.r1
    
    # create the template file
    tfile = openFile(pulsedat.replace('.h5','-template.h5'), mode = "w", title = "Optimal filter data file created " + time.asctime() )
    tempr1 = tfile.createGroup('/','r1','ROACH 1')

    # loop through pulse data
    for group in r1._f_walkGroups():
        if group == r1:                # walkgroups returns itself as first entry, so skip it - there is probably a more elegant way!
            continue
        print group
        
        # go through all the raw pulses in table and generate the template
        tP=np.zeros(2000,dtype='float64')
        tA=np.zeros(2000,dtype='float64')
        tPf=np.zeros(2000,dtype='float64')
        tAf=np.zeros(2000,dtype='float64')
        noise = np.zeros(800,dtype='float64')
        
        # read the table into memory (too slow otherwise!)
        dat = group.iqpulses.read()
        
        N = len(dat)
        count = 0.0
        peaklist = []
        idx = np.arange(2000)*2.0
        fitidx = np.concatenate((idx[:900],idx[1800:]))
        
        # center of loop
        xc = 0.0
        yc = 0.0
        
        # determine median prepulse levels for first 100 pulses
        I1m = np.median(dat['I'][:100,:900])
        Q1m = np.median(dat['Q'][:100,:900])   
        
        # make a prelimiary template with 1000 pulses, then a better one with all of them
        if N > 1000:
            N = 1000
        
        # first pass    
        for j in xrange(N):
            I = dat['I'][j]
            Q = dat['Q'][j]
            
            # reference all pulses to first 100 pulses (1/f removal)
            I += (I1m - np.median(I[1:900]))
            Q += (Q1m - np.median(Q[1:900]))
    
            # transform to phase
            P1 = np.arctan2( Q-yc, I-xc )
            #P1 = numexpr.evaluate('arctan2( Q-yc, I-xc )')
            
            # remove phase wraps and convert to degrees
            P2 = np.rad2deg(np.unwrap(P1))
            
            # subtract baseline
            fit = np.poly1d(np.polyfit(fitidx,np.concatenate((P2[:900],P2[1800:])),1))
            P3 = P2 - fit(idx)
    
            # skip pulses with bad baseline subtraction
            stdev = np.std(P3[:100])
            if np.abs(np.mean(P3[:100])-np.mean(P3[1900:])) > stdev*2.0 :
                continue
            
            # eliminate doubles
            
            # first pass fit all non-noise pulses
            peak = np.max(P3[980:1050])
            peaklist.append(peak)
            if peak < 15.0 or peak > 120.0:
                continue
    
            # if peak not near the center skip 
            ploc = (np.where(P3 == peak))[0]
            if ploc < 980 or ploc > 1020:
                continue
    
            # align pulse so peak happens at center
            P4 = np.roll(P3,1000-ploc)
            
            # normalize and add to template
            tP += P4/np.max(P4)            
            count += 1
    
        print 'First Pass =',int(count),'pulses'        
        tP /= count
        tA /= count
        
        # make a second pass through using the initial template as the kernel to determine pulse start time
        peaklist = np.asarray(peaklist)
        pm = np.median(peaklist[np.where(peaklist>15)])
        pdev = np.std(peaklist[np.where(peaklist>15)])
        print pm,'+-',pdev,'degrees'
        
        N = len(dat)
        count = 0.0
        t1 = time.time()
        for j in xrange(N):
            I = dat['I'][j]
            Q = dat['Q'][j]
            
            # reference all pulses to first 100 pulses (1/f removal)
            I += (I1m - np.median(I[1:900]))
            Q += (Q1m - np.median(Q[1:900]))
    
            # transform to phase
            P1 = np.arctan2( Q-yc, I-xc )
                
            # remove phase wraps and convert to degrees
            P2 = np.rad2deg(np.unwrap(P1))
            
            # subtract baseline - this step is slow - speed up!
            fit = np.poly1d(np.polyfit(fitidx,np.concatenate((P2[:900],P2[1800:])),1))
            P3 = P2 - fit(idx)
    
            # skip pulses with bad baseline subtraction
            stdev = np.std(P3[:100])
            if np.abs(np.mean(P3[:100])-np.mean(P3[1900:])) > stdev*2.0 :
                continue
            
            # eliminate doubles
            
            # Only fit pulses near the peak
            
            conv = np.convolve(tP[900:1500],P3)
            #conv = scipy.signal.fftconvolve(tP[950:1462],np.concatenate( (P3,P3[0:48]) ) )
            ploc = int((np.where(conv == np.max(conv)))[0] - 1160.0)
            peak = np.max(P3[1000+ploc])
    
            #print ploc,peak
            if peak < pm - 4.0*pdev or peak > pm + 4.0*pdev:
                continue
    
            # if peak not near the center skip 
            if ploc < -30 or ploc > 30:
                continue
    
            # align pulse so peak happens at center
            P4 = np.roll(P3,-ploc)
            
            # normalize and add to template
            tPf += P4/np.max(P4)            
            count += 1    
            
            # compute noise PSD
            noise += np.abs( np.fft.fft(np.deg2rad(P4[50:850])) )**2
        
        t2 = time.time()
        tPf /= count
        noise /= count
        noiseidx = np.fft.fftfreq(len(noise),d=0.000002)
        print 'Second Pass =',int(count),'pulses'
        print 'Pulses per second = ', N/(t2-t1)    
         
        # calculate optimal filter parameters
        
        # save the template information in a new file
        # create a group off root for each resonator that contains iq sweep, pulse template, noise, and optimal filter coefficents
        pgroup = tfile.createGroup(tempr1,group._v_name, 'data to set up optimal filtering' )
        group.iqsweep.copy(newparent=pgroup)        # copy in IQ sweep data
        
        #filt = Filters(complevel=5, complib='zlib', fletcher32=True)
        filt = Filters(complevel=0, complib='zlib', fletcher32=False)
        table = tfile.createTable(pgroup, 'opt', PulseAnalysis, "optimal filter data",filters=filt)
        w = table.row
        if( count < 500 or pm < 10 or pm > 150):
            w['flag'] = 1
        else:
            w['flag'] = 0
        w['count'] = count
        w['pstart'] = (np.where( tPf == np.max(tPf)))[0]
        w['phasetemplate'] = tPf
        w['phasenoise'] = noise
        w['phasenoiseidx'] = noiseidx
        w.append()
        
        break 
   
    #plot(tPf)
    plot(noiseidx,noise)
    show()
 
    h5file.close() 
    tfile.close()

def FakeTemplateData():  # make fake data and write it to a h5 file
    
    filename = '/Users/bmazin/Data/Projects/pytest/fakepulse2.h5'
    h5file = openFile(filename, mode='w', title = "Fake Pulse file created " + time.asctime() )
    r1 = h5file.createGroup('/','r1','ROACH 1')
    
    # open IQ sweep file
    sweepdat = '/Users/bmazin/Data/Projects/pytest/ps_20110505-172336.h5'
    iqfile = openFile(sweepdat, mode = "r")
    swp = iqfile.root.sweeps

    # loop through each IQ sweep in sweepddat and create fake pulses for it
    for group in swp._f_walkGroups():
        if group == swp:                # walkgroups returns itself as first entry, so skip it - there is probably a more elegant way!
            continue
        print group
    
        pgroup = h5file.createGroup(r1,group._v_name, 'IQ pulse data' )
        pname = 'iqpulses'
        #filt = Filters(complevel=5, complib='zlib', fletcher32=True)
        filt = Filters(complevel=0, complib='zlib', fletcher32=False)
        table = h5file.createTable(pgroup, pname, RawPulse, "IQ Pulse Data",filters=filt) 
        p = table.row

        # copy the IQ sweep data into the file
        group._f_copyChildren(pgroup)
    
        trise = 0.1
        tfall = 65.0
    
        for j in xrange(1000):
            p['starttime'] = time.time()
            p['samprate'] = 500000.0
            p['npoints'] = 2000
            p['f0'] = 3.65
            p['atten1'] = 30
            p['atten2'] = 0
            p['Tstart'] = 0.1
    
            I = np.zeros(2000)
            Q = np.zeros(2000)
            idx = np.arange(1000,dtype='float32')
            I[1000:2000] = (1.0 - np.exp( -idx/trise ) ) * np.exp(-idx/tfall) * 0.25
            Q[1000:2000] = (1.0 - np.exp( -idx/trise ) ) * np.exp(-idx/tfall) 
            I += 2.0 - np.random.normal(size=2000)*.01  # add noise
            Q += np.random.normal(size=2000)*.01     
            
            # move arrival time
            I = np.roll(I, int((np.random.normal()*10.0)+0.5) )
            Q = np.roll(Q, int((np.random.normal()*10.0)+0.5) )
                      
            p['I'] = np.concatenate( (I,np.zeros(2000-len(I))),axis=0 )
            p['Q'] = np.concatenate( (Q,np.zeros(2000-len(Q))),axis=0 )
            p.append()
        
        table.flush()  
             
    h5file.close()
    iqfile.close()
     
#print 'Running!'
#FakeTemplateData()
#pulsedat = '/Users/bmazin/Data/Projects/pytest/fakepulse2.h5'
#MakeTemplate(pulsedat)
#fakedat = '/Users/bmazin/Data/Projects/pytest/fakeobs.h5'
#FakeObservation(fakedat)
#QuickLook(fakedat,0,10)
#print 'Done.'
