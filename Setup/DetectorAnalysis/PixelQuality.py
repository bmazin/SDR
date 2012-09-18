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

bmaptitle='/media/disk2/sci3gamma/beamimage_sci3gamma.h5'

#for feedline 1
title1=title2='20120827/ps_freq'
titlefits1='20120823adr/20120823_FL1_100mK_gold0-fits.txt'
#for feedline 2
titlefits2='20120823adr/20120823_FL2_100mK_gold0-fits.txt'

pdftitle='/home/sean/data/fitshist/20120912PixelQuality.pdf'
dithertitle='/home/sean/data/fitshist/20120912PixelQualitydither.pdf'
sqDimOpt=30  
#This is the dimension of pixel area in the center of the area that we are evaluating to find the optimal dither position 

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
            color='Brown'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, '%s\n%s\n| (%d,%d)     -'%('|       ','|      ',row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)
	elif len(pixarray[row][column])== 2:
            binaryPixArray[row][column]=1
            color= 'PaleGreen'
            ax.text(.002+ 0.02275*column,0.003+ 0.0217*row, 'r%dp%d \n%.5f\n%.1f (%d,%d)'%(pix[0][0],pix[0][1],pix[1][0],pix[1][1]/1000,row,column), bbox=dict(facecolor=color, alpha=.6), size=textsize)

	else:
            problem.append([row,column])

#--Add boxes around best sections of array.  The purple boxes are around the best areas that are completely filled with working pixels, the dark blue boxes are around the best sections for one higher dimension--

optimalIndTotal=[]
Allfilledin=1

dim=2
plusD=0
while Allfilledin==1:
    boxsum=[]
    for row in xrange(0,46+1-(plusD+dim)):
        for column in xrange(0,44+1-(plusD+dim)):
            boxvalues=[]
            for i in xrange(0,plusD+dim):
                for j in xrange(0,plusD+dim):
                    boxvalues.append(binaryPixArray[row+i][column+j])
            boxsum.append([sum(boxvalues),row,column])
  
    boxsum=sorted(boxsum)
    if boxsum[len(boxsum)-1][0] != (plusD+dim)**2:
        Allfilledin=0
    else:
        plusD=plusD+1
    optimalIndices=[]
    stillmax=1
    x=len(boxsum)-1
    while stillmax==1:
            if boxsum[len(boxsum)-1][0]==boxsum[x][0]:
                optimalIndices.append([boxsum[x][1],boxsum[x][2]])
                x=x-1
            else:
                stillmax=0
    optimalIndTotal.append(optimalIndices)
#print optimalIndTotal

dim=len(optimalIndTotal)
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((0.02275*ind[1],0.0217*ind[0]),width=0.02275*dim, height=0.0217*dim, color='Indigo', fill=False, lw=2)
    ax.add_patch(rect)
    ax.figure.canvas.draw()

dim=len(optimalIndTotal)+1
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((1/44.*ind[1],1/46.*ind[0]),width=1/44.*dim, height=1/46.*dim, color='MediumBlue', fill=False, lw=2)
    ax.add_patch(rect)
    ax.figure.canvas.draw()

#print problem	

ax.text(-0.7, 1.02, 'Each box represents a pixel. Green means the pixel is working.\npixelnumber, f0(GHz), Q(k), and pixel location are inside each box.', bbox=dict(facecolor='white', alpha=1), size=10)
plt.title('Pixel Quality and Characteristics for 20120912 Detector', size=24, position=(.5,1.01))
fig.savefig(pdftitle)
plt.show()
plt.close()

#--Figure out optimal placement of 4 dithers in rect. formation by looking at the percentage of good pixels in the center sqDimOpt by sqDimOpt region--

yvariation=int((46-sqDimOpt)/2)
xvariation=int((44-sqDimOpt)/2)

binaryPixArray=np.array(binaryPixArray)
impSection=binaryPixArray[yvariation:(46-yvariation),xvariation:(44-xvariation)]
percentgood=np.sum(impSection)/(sqDimOpt**2.)

resultPercent=[]
for j in xrange(-xvariation,xvariation+1):
    for i in xrange(-yvariation, yvariation+1):
        ditherArray=np.array([[None for col in range(sqDimOpt)] for row in range(sqDimOpt)])
        for row in xrange(0, sqDimOpt):
            for column in xrange(0, sqDimOpt):
                ditherArray[row,column]=binaryPixArray[row+yvariation,column+xvariation]+binaryPixArray[(row+yvariation),(column+xvariation+j)]+binaryPixArray[(row+yvariation+i),(column+xvariation)]+binaryPixArray[(row+yvariation+i),(column+xvariation+j)]
        resultPercent.append([sum(sum(1 for i in row if i>0) for row in ditherArray)/(sqDimOpt**2.),i,j])
resultPercent=sorted(resultPercent)

i=resultPercent[len(resultPercent)-1][1]
j=resultPercent[len(resultPercent)-1][2]
ditherArray=np.array([[None for col in range(sqDimOpt)] for row in range(sqDimOpt)])
for row in xrange(0, sqDimOpt):
    for column in xrange(0, sqDimOpt):
        ditherArray[row,column]=int(binaryPixArray[row+yvariation,column+xvariation]+binaryPixArray[(row+yvariation),(column+xvariation+j)]+binaryPixArray[(row+yvariation+i),(column+xvariation)]+binaryPixArray[(row+yvariation+i),(column+xvariation+j)])
finalresultPercent=sum(sum(1 for i in row if i>0) for row in ditherArray)/(sqDimOpt**2.)
#print impSection
#print ditherArray

print 'Considering the middle %dx%d pixels'%(impSection.shape[0],impSection.shape[1])
print 'The percent of working pixels initially is %f'%percentgood
print 'The percent with 4 dithers in rect. formation is %f'%finalresultPercent
print 'best dither position: up %d rows and %d columns to the right'%(i,j)

#--Now we will make two plots comparing the center area with and without dithering--
fig2=plt.figure(figsize=(26,11))
plt.subplots_adjust(left = 0.04, right= 0.9, bottom= .05, top= .95)
ax1=fig2.add_subplot(121)
ax2=fig2.add_subplot(122)

textsize=4.5

ax1.text(0, 1.02, 'Green means the pixel is working.\nThe dither position is up %d rows and %d rows to the right'%(i,j), bbox=dict(facecolor='white', alpha=1), size=10)

problem=[]

for row in xrange(0,sqDimOpt):
    for column in xrange(0,sqDimOpt):
        if binaryPixArray[row+yvariation][column+xvariation]==0:
            color='Brown'
            ax1.text(.002+ 1./sqDimOpt*column,0.003+ 1./sqDimOpt*row, '%s\n%s\n| (%d,%d)'%('| ','|  ',row+yvariation,column+xvariation), bbox=dict(facecolor=color, alpha=.6), size=textsize)
        else:
            color= 'PaleGreen'
            ax1.text(.002+ 1./sqDimOpt*column,0.003+ 1./sqDimOpt*row, '%s\n%s\n| (%d,%d)'%('|   ','|   ',row+yvariation,column+xvariation), bbox=dict(facecolor=color, alpha=.6), size=textsize)
            	
for row in xrange(0,sqDimOpt):
    for column in xrange(0,sqDimOpt):
        if ditherArray[row][column]==0: 
            color='Brown'
            ax2.text(.002+ 1./sqDimOpt*column,0.003+ 1./sqDimOpt*row, '%s\n%s\n| (%d,%d)'%('|  ','|  ',row+yvariation,column+xvariation), bbox=dict(facecolor=color, alpha=.6), size=textsize)
        else:
            color= 'PaleGreen'
            ax2.text(.002+ 1./sqDimOpt*column,0.003+ 1./sqDimOpt*row, '%s\n%s\n| (%d,%d)'%('|   ','|  ',row+yvariation,column+xvariation), bbox=dict(facecolor=color, alpha=.6), size=textsize)

optimalIndTotal=[]
Allfilledin=1

dim=2
plusD=0
while Allfilledin==1:
    boxsum=[]
    for row in xrange(yvariation,46-yvariation+1-(plusD+dim)):
        for column in xrange(xvariation,44-xvariation+1-(plusD+dim)):
            boxvalues=[]
            for i in xrange(0,plusD+dim):
                for j in xrange(0,plusD+dim):
                    boxvalues.append(binaryPixArray[row+i][column+j])
            boxsum.append([sum(boxvalues),row,column])

    boxsum=sorted(boxsum)
    if boxsum[len(boxsum)-1][0] != (plusD+dim)**2:
        Allfilledin=0
    else:
        plusD=plusD+1
    optimalIndices=[]
    stillmax=1
    x=len(boxsum)-1
    while stillmax==1:
        if boxsum[len(boxsum)-1][0]==boxsum[x][0]:
            optimalIndices.append([boxsum[x][1],boxsum[x][2]])
            x=x-1
        else:
            stillmax=0
    optimalIndTotal.append(optimalIndices)
#print optimalIndTotal

dim=len(optimalIndTotal)
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((1./sqDimOpt*ind[1],1./sqDimOpt*ind[0]),width=1./sqDimOpt*dim, height=1./sqDimOpt*dim, color='Indigo', fill=False, lw=2)
#    ax1.add_patch(rect)
#    ax1.figure.canvas.draw()

dim=len(optimalIndTotal)+1
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((1./sqDimOpt*ind[1],1./sqDimOpt*ind[0]),width=1./sqDimOpt*dim, height=1./sqDimOpt*dim, color='MediumBlue', fill=False, lw=2)
#    ax1.add_patch(rect)
#    ax1.figure.canvas.draw()

optimalIndTotal=[]
Allfilledin=1

dim=2
plusD=0
while Allfilledin==1:
    boxsum=[]
    for row in xrange(0,sqDimOpt+1-(plusD+dim)):
        for column in xrange(0,sqDimOpt+1-(plusD+dim)):
            boxvalues=[]
            for i in xrange(0,plusD+dim):
                for j in xrange(0,plusD+dim):
                    boxvalues.append(ditherArray[row+i][column+j])
            boxsum.append([sum(1 for i in boxvalues if i>0),row,column])
  
    boxsum=sorted(boxsum)
    if boxsum[len(boxsum)-1][0] != (plusD+dim)**2:
        Allfilledin=0
    else:
        plusD=plusD+1
    optimalIndices=[]
    stillmax=1
    x=len(boxsum)-1
    while stillmax==1:
            if boxsum[len(boxsum)-1][0]==boxsum[x][0]:
                optimalIndices.append([boxsum[x][1],boxsum[x][2]])
                x=x-1
                if x<0:
                    stillmax=0
            else:
                stillmax=0
    optimalIndTotal.append(optimalIndices)
#print optimalIndTotal

dim=len(optimalIndTotal)
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((1./sqDimOpt*ind[1],1./sqDimOpt*ind[0]),width=1./sqDimOpt*dim, height=1./sqDimOpt*dim, color='Indigo', fill=False, lw=2)
#    ax2.add_patch(rect)
#    ax2.figure.canvas.draw()

dim=len(optimalIndTotal)+1
for ind in optimalIndTotal[dim-2]:
    rect = pat.Rectangle((1./sqDimOpt*ind[1],1./sqDimOpt*ind[0]),width=1./sqDimOpt*dim, height=1./sqDimOpt*dim, color='MediumBlue', fill=False, lw=2)
#    ax2.add_patch(rect)
#    ax2.figure.canvas.draw()


ax1.set_title('%dx%d middle section of array'%(sqDimOpt,sqDimOpt))
ax2.set_title('%dx%d section of array with 4 dithers in rect. formation'%(sqDimOpt,sqDimOpt))
fig2.savefig(dithertitle)
plt.show()
plt.close()
