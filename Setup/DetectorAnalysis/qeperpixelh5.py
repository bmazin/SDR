from tables import *
from PixelQualityfunc import getfQforgoodpix
from qeforpixelsfunc import qeFuncOfWvl

h5filename="SDR/Setup/DetectorAnalysis/qeforpix.h5"
nroach=8
npixel=256
wvls = range(400,1100,50)
nwvl=len(wvls)

bmaptitle='/home/sean/data/common/sorted_beamimage46x44.h5'
#for feedline 1
title1='20120812adr/FL1-ps_freq'
titlefits1='20120812adr/SCI3-40-FL1-ADR-2-fits.txt'
#for feedline 2
title2='20120812adr/FL2-ps_freq'
titlefits2='20120812adr/SCI3-40-FL2-ADR-fits.txt'
#title1/2 gives the base of the filename for the frequency files for Feedline 1/2 (Don't include '.txt'). 
#titlefist1/2 gives the filename of the fits file (include '.txt')
#bmaptitle gives the filename of the beammap (include '.h5')

maxqeCutOff = 0.01       
#if the maximum qe in the list of qe's for that pixel is less than maxqeCutOff, it will not be saved in the h5 file

qeDataFilename='/media/disk2/20120814/obs_20120814-111433.h5'
qeObsTime= 1344968073
ini=454
peakw=14.3846153846
troughw=83.5833333333    
dectv=[.033,.139,.323,.682,1.025,1.287,1.451,1.530,1.420,1.364,1.766,2.291,2.844,3.169]
#this assumes that both FL1 and FL2 are included in the qeDataFile and that the ini, peakw, and troughw values are the same for all roaches
#ini is the time when the first peak starts
#peakw: time interval over which the peak occurs (does not include the first/last 3 seconds of peak)
#troughw: time interval between peaks (includes first/last 3 s of peak)
#dectv is the N of photons seen in the comparison detector *10^-7 for each wvl/peak
#qewvl=1/(dectv[i]*10**7/NPulses[0][i]*.0007096896) is the formula used to find the quantum efficiency. Where NPulses is the average number of photons seen in the ADR detector (the average number of photons seen in the troughs btw peaks is subtracted.

fQlist = getfQforgoodpix(bmaptitle,title1,titlefits1,title2,titlefits2)
#resulting list has each element [[roachnumber,pixelnumber],[f,Q]]

fQqe=[]

for pix in xrange(0,len(fQlist)):
    roach = fQlist[pix][0][0]
    if roach < 4:              #delete this line if qeDataFile has roaches 0...7
        pixel = fQlist[pix][0][1]
        qeresults = qeFuncOfWvl(qeDataFilename, qeObsTime, roach, pixel, ini, peakw, troughw,  dectv, NSec=3600, nwvl=14, plotYorN='N')
        if max(qeresults) > maxqeCutOff:
            fQqe.append([fQlist[pix][0],fQlist[pix][1],qeresults])

#fQqe is a list where each element is [[roachnumber,pixelnumber],[f,Q],[qe(wvl1),...]]
print fQqe[10]

class QEHeader(IsDescription):
    wvl = Float32Col(nwvl)

class Pixel(IsDescription):
    frequency = Float64Col()  
    Q = Float32Col()
    qe = Float32Col(nwvl)

# Open a file in "w"rite mode
h5file = openFile(h5filename, mode = "w", title= "testfile")
hdrgrp = h5file.createGroup('/','header', 'Group containing wvls')
hdrtable = h5file.createTable(hdrgrp, 'Wavelengths', QEHeader)
w = hdrtable.row
w['wvl'] = wvls
w.append()
hdrtable.flush()

roaches = []
pixels = []

for roachnum in xrange(0,nroach):
    roaches.append('r%d'%roachnum)

# Create the groups
for roach in roaches:
    group = h5file.createGroup('/',roach)

# Create a group for each good pixel and put in the correct values
for i in xrange(0,len(fQqe)):
    roach='r%d'%fQqe[i][0][0]
    pixelnum='p%d'%fQqe[i][0][1]
    pixgroup=h5file.createGroup('/'+roach,pixelnum)
    pixtable=h5file.createTable(pixgroup,'pixtable',Pixel)
    pix = pixtable.row
    pix['frequency'] = fQqe[i][1][0]
    pix['Q'] = fQqe[i][1][1]
    pix['qe'] = fQqe[i][2]
    pix.append()
    pixtable.flush()

h5file.close()


