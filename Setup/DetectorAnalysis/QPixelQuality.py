#!/usr/bin/python
import numpy as np
from matplotlib import pyplot as plt
import matplotlib.patches as pat
import tables
import re
import collections
import scipy
from PixelQualityfunc import *

closefcutoff=.0007   #when the program compares the approximate freq in frequency files to the accurate frequency in the fit file, it will accept a difference of the closefcutoff (GHz)

bmaptitle='/media/disk2/sci3gamma/20120904/PositionKnownOnlybeamimage_double_refined_20120904.h5'

#for feedline 1
title1=title2='20120827/ps_freq'
titlefits1='20120823adr/20120823_FL1_100mK_gold0-fits.txt'
#for feedline 2
titlefits2='20120823adr/20120823_FL2_100mK_gold0-fits.txt'

pdftitle='/home/sean/data/fitshist/20120912QPixelQuality.pdf'
 

#--Get an accurate array with roach,pixel,f,Q in the correct position--

accuratefQ = createAccuratefQMatrix(bmaptitle, title1,titlefits1,title2,titlefits2,closefcutoff=3)

fid=tables.openFile(bmaptitle)
b=fid.root.beammap.beamimage


pixarray = [[None for col in range(44)] for row in range(46)]
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
    	            pixarray[row][column]=([[roachNum,pixelNum],accuratefQ[roachNum][pixelNum]])
                    pixlist.append([[roachNum,pixelNum],accuratefQ[roachNum][pixelNum]])
#            else:
#               print roachNum,pixelNum
#        else:
#            print roachNum,pixelNum

fid.close()

#--Plot what the detector looks like with the f,Q, and position written inside each 'pixel'--

fig=plt.figure(figsize=(23,14))
plt.subplots_adjust(left = 0.04, right= 0.97, bottom= .05, top= .95)
ax=fig.add_subplot(111)

binaryPixArray = scipy.zeros((46,44))
#binaryPixArray=scipy.random.random((46,44))
#binaryPixArray=np.around(binaryPixArray)

textsize=4.5
problem=[]
for row in xrange(0,46):
    for column in xrange(0,44):
        pix=pixarray[row][column]
        if pix==None:
            color='Black'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%s\n| (%d,%d)-'%('|       ','|      ',row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	elif pix[1][1]<40000:
            binaryPixArray[row][column]=1
            color= 'Blue'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%.1f\n(%d,%d)'%('|         ',pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	elif pix[1][1]<80000:
            binaryPixArray[row][column]=1
            color= 'Green'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%.1f\n(%d,%d)'%('|         ',pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	elif pix[1][1]<120000:
            binaryPixArray[row][column]=1
            color= 'Yellow'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%.1f\n(%d,%d)'%('|         ',pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	elif pix[1][1]<160000:
            binaryPixArray[row][column]=1
            color= 'Orange'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%.1f\n(%d,%d)'%('|         ',pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	else :
            binaryPixArray[row][column]=1
            color= 'Red'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%.1f\n(%d,%d)'%('|         ',pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
 

#print problem	

ax.text(0, 1.02, 'Each box represents a pixel. Black means the pixel is dead.\nB: Q<40k, G: 40k<Q<80k, Y: 80k<Q<120k, O: 120k<Q<160k, R: Q>160k', bbox=dict(facecolor='white', alpha=1), size=10)
plt.title('Pixel Quality and Characteristics for 20120912 Detector', size=24, position=(.5,1.01))
fig.savefig(pdftitle)
plt.show()
plt.close()
