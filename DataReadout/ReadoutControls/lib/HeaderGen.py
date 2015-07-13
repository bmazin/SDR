#!/usr/bin/env python
# encoding: utf-8
"""
HeaderGen.py

Call HeaderGen from ARCONS control GUI to start write of observation file.

Created by Ben Mazin on 2011-05-04.
Copyright (c) 2011 . All rights reserved.

Modified by Seth Meeker on 2011-06-02

"""

import pulses_v1 as pulses
import time,datetime,os,ephem
import numpy as np
from tables import *

filt1 = Filters(complevel=1, complib='zlib', fletcher32=False)

def BeamImage(obsfile, beammapfile, timestamp):
    print "creating BeamImage and copying into observation file"
    nBeamRows = 46
    nBeamCols = 44
    bmfile = openFile(beammapfile, 'r')
    h5file = openFile(obsfile, 'a')
    #read beammap in to memory to create beam image
    bmap = bmfile.root.beammap.beammap.read()
    #create beammap node in obs file and copy over from beam map file
    bgroup = h5file.createGroup('/','beammap','Beam Map of Array')
    h5file.copyNode(bmfile.getNode('/beammap/beammap'),newparent=bgroup,recursive=True)  
    bmfile.close()
    # make beammap array - this is a 2d array (top left is 0,0.  first index is column, second is row) containing a string with the name of the group holding the photon data
    ca = h5file.createCArray(bgroup, 'beamimage', StringAtom(itemsize=40), (nBeamRows,nBeamCols), filters=filt1)  
    for i in range(len(bmap)):
        rowidx = bmap[i][8]
        colidx = bmap[i][6]
        ca[colidx,rowidx] = 'r'+str(bmap[i][4])+'/p'+str(int(bmap[i][3]))+'/t'+str(timestamp)
        #ca[rowidx,colidx] = 'r'+str(bmap[i][4])+'/p'+str(int(bmap[i][2]))+'/t'+str(timestamp)
    h5file.flush()
    carray = ca.read() 
    h5file.close()

def HeaderGen(filename,beammapfile,lt,exptime,ra,dec,alt,az,airmass,lst,passedfilt,dir="./",telescope = "Broida", target="Target",equinox=2000.0,epoch=2011.0,focus=np.nan, parallactic=np.nan, seeing=0):
    #lt = time.time() #passed in call to HeaderGen
    dt = datetime.datetime.utcfromtimestamp(lt)
          
    h5f = openFile(str(dir)+'/'+str(filename), mode='w')
    hdrgrp = h5f.createGroup('/','header','Group containing observation description')
    hdrtable = h5f.createTable(hdrgrp, 'header', pulses.ObsHeader, "Header",filters=filt1)
    w = hdrtable.row
    w['target'] = target #passed in call to HeaderGen
    w['datadir'] = dir 
    w['calfile'] = dir + 'something.h5'
    w['beammappath'] = os.environ['MKID_BEAMMAP_PATH']
    w['beammapfile'] = beammapfile #passed in call to HeaderGen
    w['version'] = 'ARCONS Observation v2.0'
    w['instrument'] = 'ARCONS v2.0 - 2024 pixel (46x44) array, 8 ROACH readout.'
    w['boffile'] = os.environ['BOFFILE']
    w['firmware'] = os.environ['FIRMWARE_COMMIT']
    w['customFIR'] = os.environ['MKID_CUSTOM_FIR']
    w['freqpath'] = os.environ['MKID_FREQ_PATH']
    w['description'] = ''
    w['filt'] = passedfilt
    
    if telescope == "Palomar":
        w['telescope'] = 'Palomar 200" Hale Telescope'
        w['obslat'] = 33.0 + 21.0/60.0 + 21.6/3600.0 #Palomar
        w['obslong'] = -1.*(116.0 +  51.0/60.0 + 46.80/3600.0) #Palomar
        w['obsalt'] = 1706.0 #Palomar
    if telescope == "Lick":
        w['telescope'] = 'Lick 36 inch Shane Telescope' 
        w['obslat'] = 37.0 + 20.0/60.0 + 24.6/3600.0 #Lick
        w['obslong'] = -1.*(121.0 +  38.0/60.0 + 43.80/3600.0) #Lick
        w['obsalt'] = 1283.0 #Lick
    if telescope == "Broida":
        w['telescope'] = 'Mazin Lab, UCSB' 
        w['obslat'] = 34.414243 #UCSB's location according to Google Earth
        w['obslong'] = -119.843009
        w['obsalt'] = 100.0

    if focus != np.nan:
        w['focus'] = focus
    if parallactic != np.nan:
        w['parallactic'] = parallactic

    #crab = ephem.readdb("Crab Pulsar,f|L,5:34:31.97,22:00:52.1,16.5,2000")

    w['seeing'] = seeing
    w['airmass'] = airmass
    w['equinox'] = equinox
    w['epoch'] = epoch
    
    w['timezone'] = time.altzone/3600.0
    w['localtime'] = time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime(lt))
    w['unixtime'] = lt
    w['utc'] = time.strftime("%a, %d %b %Y %H:%M:%S", time.gmtime(lt))

    #palomar = ephem.Observer()
    #palomar.long, palomar.lat = '116.0:51.0:46.80', '33.0:21.0:21.6'
    #palomar.date = ephem.Date(dt)
    #palomar.elevation =  1706.0

    #crab.compute(palomar)

    #w['ra'] = crab.ra*12.0/ephem.pi #pulled from TCS
    w['ra'] = ra
    #w['dec'] = crab.dec*180.0/ephem.pi #pulled from TCS
    w['dec'] = dec
    #w['lst'] = palomar.sidereal_time().__str__() #pulled from TCS
    w['lst'] = lst
    w['jd'] = ephem.julian_date(dt)

    #w['alt'] = crab.alt*180.0/ephem.pi #pulled from TCS
    w['alt'] = alt
    #w['az'] = crab.az*180.0/ephem.pi #pulled from TCS
    w['az'] = az
    
    w['platescl'] = 0.3
    #w['exptime'] = 10.0 #passed in call to HeaderGen
    w['exptime'] = exptime
    
    w.append()    
    h5f.close()
    h5f = openFile(str(dir)+'/'+str(filename), mode='r')
    print str(dir)+'/'+str(filename)
    test = h5f.root.header.header.read()
    print 'exptime written is ',test['exptime'][0]
    h5f.close()
    #BeamImage(dir+'/'+str(filename), beammapfile, lt)
    
