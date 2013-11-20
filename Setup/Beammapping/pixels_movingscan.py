import numpy as np
import matplotlib.pyplot as plt


path = '/Users/kids/desktop/Beammapping/'

# Alter pscale, xstart, ystart, and angle to match the grid
# Set up a scale factor for pixel locations
#pscale=13.7;
pscale=8.9;
# Pick x position offset
#xstart=pscale*5.5;
xstart=pscale*5;
# Pick y position offset
#ystart=pscale*10.8;
ystart=pscale*11.3;
# Angle of setup
angle=4.2;
# Find the sine and cosine of angle to use for rotations
s=np.sin(np.pi*angle/180.)
c=np.cos(np.pi*angle/180.)
# Size of grid
xsize=44;
ysize=46;

# Not sure about this
numfound=0
numfound2=0

# Initialize variables
xvals=np.empty(0,dtype='float32')
yvals=np.empty(0,dtype='float32')
xfile=np.empty(0,dtype='float32')
yfile=np.empty(0,dtype='float32')
freqvals=np.empty(0,dtype='float32')
attenvals=np.empty(0,dtype='float32')

# Create a list of position files from beam mapping
infile=[]
infile.append(path + 'r0.pos')
infile.append(path + 'r1.pos')
infile.append(path + 'r2.pos')
infile.append(path + 'r3.pos')
infile.append(path + 'r4.pos')
infile.append(path + 'r5.pos')
infile.append(path + 'r6.pos')
infile.append(path + 'r7.pos')

psfile=[]
psfile.append(path + 'ps_freq0.txt')
psfile.append(path + 'ps_freq1.txt')
psfile.append(path + 'ps_freq2.txt')
psfile.append(path + 'ps_freq3.txt')
psfile.append(path + 'ps_freq4.txt')
psfile.append(path + 'ps_freq5.txt')
psfile.append(path + 'ps_freq6.txt')
psfile.append(path + 'ps_freq7.txt')

# Create origin and scale factor
origin=[[xstart,ystart]]*len(infile)
scale=[pscale]*len(infile)
print origin;
# If files need different origins
origin[0][0] -= 0;
origin[0][1] += 0;

# Extract x position, y position, and flag from input files
for j in range(len(infile)):
    print infile[j]
    xpos, ypos, flag=np.loadtxt(infile[j],unpack='True')
    freq, xcenpos, ycenpos, atten=np.loadtxt(psfile[j],unpack='True',skiprows=1)

# Mark the good pixels, all deleted flags will have negative values (except 0?)
    goodpix=[]
    addpix=np.where(flag > 0)[0]
    if flag[0] == 0 and xpos[0] != 0 and ypos[0] != 0:
        goodpix = np.append(0,addpix)
    else:
        goodpix = addpix

    #Shift to account for true origin and divide by the scale factor
    xpos -= origin[j][0]
    xpos /= scale[j]
    ypos -= origin[j][1]
    ypos /= scale[j]
#    if j==0:
#        xpos += 0
#        ypos -= 1.2
#    if j==4:
#        xpos -= 0.5
#        ypos += 1.2
#    if j==5:
#        xpos += 0.1
#        ypos -= 1.1
#    if j==6:
#        xpos += 0.1
#        ypos += 1
#    if j==7:
#        xpos -= 0.3
#        ypos -= 1
        
        
    print len(xpos[goodpix]), 'Good Pixels'

    #Create a list of good pixel locations
    xvals=np.append(xvals,xpos[goodpix])
    yvals=np.append(yvals,ypos[goodpix])
    freqvals=np.append(freqvals,freq[goodpix])
    attenvals=np.append(attenvals,atten[goodpix])
    xfile=np.append(xfile,xpos)
    yfile=np.append(yfile,ypos)
'''
    mask2=(np.linspace(0,len(xpos)-1,len(xpos))).astype('int')
    xfile=((xpos[mask2])*c + (ypos[mask2])*s)
    yfile=(-1.*(xpos[mask2])*s + (ypos[mask2])*c)
    xfile=xfile.astype('int')
    yfile=yfile.astype('int')
    
    f= open('xyint%i.txt' %j,'w')
    for i in range(len(xfile)):
        f= open('xyint%i.txt' %j,'a')
        f.write(str(xfile[i]) + '\t' + str(yfile[i]) + '\n')
        f.close()
'''
print len(xvals), 'Total Good Pixels'
print 'xmin, xmax =', np.min(xvals), np.max(xvals)
print 'ymin, ymax =', np.min(yvals), np.max(yvals)

# xstart = [0,1,2,...,32]
xstart=xsize*np.linspace(0,1,xsize+1)
# ystart = [0,0,0,...,0]
ystart=np.zeros(xsize+1)
# xstop = [0,1,2,...,32]
xstop=xstart
# ystop = [32,32,32,...,32]
ystop=ystart+ysize

# Transform with 2x2 rotation matrix
xstart2=xstart*c - ystart*s
xstop2=xstop*c - ystop*s
ystart2=xstart*s + ystart*c
ystop2=xstop*s + ystop*c

# plot square grid with 32x32 boxes, rotated counter-clockwise by angle, vertical lines
for i in range(xsize+1):
    plt.plot([xstart2[i],xstop2[i]],[ystart2[i],ystop2[i]],'g')

ystart=ysize*np.linspace(0,1,ysize+1)
xstart=np.zeros(ysize+1)
ystop=ystart
xstop=xstart+xsize

xstart2=xstart*c - ystart*s
xstop2=xstop*c - ystop*s
ystart2=xstart*s + ystart*c
ystop2=xstop*s + ystop*c

# Horizontal lines
for i in range(ysize+1):
    plt.plot([xstart2[i],xstop2[i]],[ystart2[i],ystop2[i]],'g')

# mask = [0,1,2,...,len(xvals)-1]
mask=(np.linspace(0,len(xvals)-1,len(xvals))).astype('int')

# find the pixel positions
# Clockwise rotation by angle
xpix=((xvals[mask])*c + (yvals[mask])*s)
ypix=(-1.*(xvals[mask])*s + (yvals[mask])*c)

# Plot the locations of the good pixels
plt.plot(xvals[mask],yvals[mask],'b+')

#xpix=xpix.astype('int')
#ypix=ypix.astype('int')

# Count the number of pixels inside the entire grid
numfound  += len(np.where((xpix < xsize)&(xpix>-1)&(ypix > -1)&(ypix<ysize))[0])
print numfound, 'pixels in grid'

plt.show()
# look for regions with fewest gaps

# how are these values determined? Originally 5,5
xsize=5
ysize=5

goodgrid=np.zeros((xsize,ysize))
idx=freqvals.argsort()
print len(xpix), len(freqvals)
f= open('freq_atten_x_y.txt','w')
for i in range(len(xpix)):
#    print freqvals[idx[i]], xpix[idx[i]], ypix[idx[i]]
    
    f= open('freq_atten_x_y.txt','a')
    f.write(str(freqvals[idx[i]]) + '\t' + str(attenvals[idx[i]]) +'\t' + str(xpix[idx[i]]) + '\t' + str(ypix[idx[i]]) +'\n')
    f.close()
        
    xmin=np.max([0,xpix[i]-xsize])
    xmax=np.min([xsize,xpix[i]+xsize])
    ymin=np.max([0,ypix[i]-xsize])
    ymax=np.min([ysize,ypix[i]+xsize])
    goodgrid[xmin:xmax,ymin:ymax] += 1
print goodgrid, np.max(goodgrid)

plt.imshow(goodgrid)

#plt.show()

