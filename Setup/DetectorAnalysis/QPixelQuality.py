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
import os

closefcutoff=.0007   #when the program compares the approximate freq in frequency files to the accurate frequency in the fit file, it will accept a difference of the closefcutoff (GHz)

#bmaptitle='/media/disk2/sci3gamma/20120904/PositionKnownOnlybeamimage_double_refined_20120904.h5'
bmaptitle='/home/sean/data/20121106/sci4a_beammap.h5'

#for feedline 1
title1=title2='20121105adr/ps_freq'
titlefits1='20121105adr/FL1-adr-sci4a-higherTc-good-fits.txt'
#for feedline 2
#titlefits2='20121006/20121006-SCI4-ADR-FL2-fits.txt'
titlefits2='20121105adr/FL2-adr-sci4a-higherTc-all-fits.txt'

outTitle='/home/sean/data/fitshist/20121106_Q_PixelQuality.fits'
freqOutTitle='/home/sean/data/fitshist/20121106_freqMap.fits'
 

#--Get an accurate array with roach,pixel,f,Q in the correct position--

accuratefQ = createAccuratefQMatrix(bmaptitle, title1,titlefits1,title2,titlefits2,closefcutoff=3)

fid=tables.openFile(bmaptitle)
b=fid.root.beammap.beamimage


pixarray = [[-1 for col in range(44)] for row in range(46)]
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
    	            pixarray[row][column]=(accuratefQ[roachNum][pixelNum][1]/1000)
    	            freqarray[row][column]=(accuratefQ[roachNum][pixelNum][0]/1000)

#            else:
#               print roachNum,pixelNum
#        else:
#            print roachNum,pixelNum

fid.close()

#--Plot what the detector looks like with the f,Q, and position written inside each 'pixel'--
pixarray=np.array(pixarray)
freqarray=np.array(freqarray)

print np.shape(pixarray)
scale_nstds = 3
scale_max=np.mean(pixarray[:][:])+scale_nstds*np.std(pixarray[:][:])
plt.matshow(pixarray[:][:],vmin=0,vmax=scale_max)
plt.title('Q')
plt.xlabel('Col')
plt.ylabel('Row')
plt.colorbar()
plt.show()


hdu = pyfits.PrimaryHDU(pixarray)
hdu2 = pyfits.PrimaryHDU(freqarray)
hdu.writeto(outTitle,clobber=True)
hdu2.writeto(freqOutTitle,clobber=True)
