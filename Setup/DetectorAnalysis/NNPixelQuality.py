#!/usr/bin/python
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.patches as pat
import tables
import re
import collections
import scipy
import pyfits
from PixelQualityfunc import *

closefcutoff=.0007   #when the program compares the approximate freq in frequency files to the accurate frequency in the fit file, it will accept a difference of the closefcutoff (GHz)

#bmaptitle='/media/disk2/sci3gamma/20120904/PositionKnownOnlybeamimage_double_refined_20120904.h5'
bmaptitle='/home/sean/data/20121010/beamimage_sci4_norand.h5'

#for feedline 1
title1=title2='20121006/ps_freq'
titlefits1='20121006/20121006-SCI4-ADR-FL1-fits.txt'
#for feedline 2
titlefits2='20121006/20121006-SCI4-ADR-FL2-fits.txt'

qOutTitle='/home/sean/data/fitshist/20121011_Q_PixelQuality.fits'
qiOutTitle='/home/sean/data/fitshist/20121011_Qi_PixelQuality.fits'
freqOutTitle='/home/sean/data/fitshist/20121011_freqMap.fits'
nnOutTitle='/home/sean/data/fitshist/20121011_NNFreqMap.fits'
collisionOutTitle='/home/sean/data/fitshist/20121011_collisionFreqMap.fits'
 

#--Get an accurate array with roach,pixel,f,Q in the correct position--

accuratefQ = createAccuratefQMatrix(bmaptitle, title1,titlefits1,title2,titlefits2,closefcutoff=3)

fid=tables.openFile(bmaptitle)
b=fid.root.beammap.beamimage


qarray = [[-1 for col in range(44)] for row in range(46)]
qiarray = [[-1 for col in range(44)] for row in range(46)]
freqarray = [[-1 for col in range(44)] for row in range(46)]
pixlist = []
for row in xrange(0,46):
    for column in xrange(0,44):
        string=b[row][column]
        if string != '' :
            a=re.findall(r'\d+',string)
            roachNum=int(a[0])
            pixelNum=int(a[1])
            if roachNum <8:
                if pixelNum<len(accuratefQ[roachNum]):
    	            qarray[row][column]=(accuratefQ[roachNum][pixelNum][1])
    	            qiarray[row][column]=(accuratefQ[roachNum][pixelNum][2])
    	            freqarray[row][column]=(accuratefQ[roachNum][pixelNum][0])

#            else:
#               print roachNum,pixelNum
#        else:
#            print roachNum,pixelNum

fid.close()

#--Plot what the detector looks like with the f,Q, and position written inside each 'pixel'--
qarray=np.array(qarray)
qiarray=np.array(qiarray)
freqarray=np.array(freqarray)
collisionarray=np.array(freqarray)
nnarray = []
nnrow = [-1,-1,-1,0,0,1,1,1]
nncol = [-1,0,1,-1,1,-1,0,1]
for i in range(len(nnrow)):
    dr = nnrow[i]
    dc = nncol[i]
    nndiff = freqarray - np.roll(np.roll(freqarray,dr,axis=0),dc,axis=1)
    nnarray.append(nndiff)

for r in range(46):
    for c in range(44):
        f = freqarray[r,c]
        comparefreqs = freqarray.ravel()
        globaldiff = np.sort(np.abs(comparefreqs-f))
        collisionarray[r,c]=globaldiff[1]

medQ = []
meanQ = []
meanF = []
for r in range(44):
    row=qarray[:,r]
    frow=freqarray[-1,r]
    cleanRow=row[row!=-1]

    medQ.append(np.median(cleanRow))
    meanQ.append(np.mean(cleanRow))
    meanF.append(frow)

fig = plt.figure()
ax=fig.add_subplot(111)
ax.plot(medQ,'r.-',label='median Q')
ax.plot(meanQ,'g.-',label='mean Q')
plt.xlabel('Col Number')
plt.ylabel('Q')
#ax.plot(meanF,'b.-')
plt.show()
nnarray = np.array(nnarray)
diffarray = np.amin(np.abs(nnarray),axis=0)

hdu = pyfits.PrimaryHDU(qarray)
hdu2 = pyfits.PrimaryHDU(freqarray)
hdu3 = pyfits.PrimaryHDU(diffarray)
hdu4 = pyfits.PrimaryHDU(collisionarray)
hdu5 = pyfits.PrimaryHDU(qiarray)
hdu.writeto(qOutTitle,clobber=True)
hdu2.writeto(freqOutTitle,clobber=True)
hdu3.writeto(nnOutTitle,clobber=True)
hdu4.writeto(collisionOutTitle,clobber=True)
hdu5.writeto(qiOutTitle,clobber=True)
