import numpy as np
import matplotlib.pyplot as plt


path = '/media/disk2/sci3gamma/20120901/'

# Alter pscale, xstart, ystart, and angle to match the grid
# Set up a scale factor for pixel locations
#pscale=13.7;
pscale=8.82;
# Pick x position offset
#xstart=pscale*5.5;
xstart=pscale*18.2;
# Pick y position offset
#ystart=pscale*10.8;
ystart=pscale*7.55;
# Angle of setup
angle=3.2;
# Find the sine and cosine of angle to use for rotations
s=np.sin(np.pi*angle/180.)
c=np.cos(np.pi*angle/180.)
# Size of grid
xsize=22;
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
infile.append(path + '20120902_r4.pos')
infile.append(path + '20120902_r5.pos')
infile.append(path + '20120902_r6.pos')
infile.append(path + '20120902_r7.pos')

psfile=[]
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
    if j==0:
        xpos += 0
        ypos += 0
    if j==1:
        xpos += 3.1
        ypos -= 0.2
    if j==2:
        xpos += 3
        ypos += 0
    if j==3:
        xpos -= 3.85
        ypos -= 0.95
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
xstart=xsize*np.linspace(0,1,23)
# ystart = [0,0,0,...,0]
ystart=np.zeros(23)
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
for i in range(23):
    plt.plot([xstart2[i],xstop2[i]],[ystart2[i],ystop2[i]],'g')

ystart=ysize*np.linspace(0,1,47)
xstart=np.zeros(47)
ystop=ystart
xstop=xstart+xsize

xstart2=xstart*c - ystart*s
xstop2=xstop*c - ystop*s
ystart2=xstart*s + ystart*c
ystop2=xstop*s + ystop*c

# Horizontal lines
for i in range(47):
    plt.plot([xstart2[i],xstop2[i]],[ystart2[i],ystop2[i]],'g')

# mask = [0,1,2,...,len(xvals)-1]
mask=(np.linspace(0,len(xvals)-1,len(xvals))).astype('int')

# find the pixel positions
# Clockwise rotation by angle
xpix=((xvals[mask])*c + (yvals[mask])*s)
ypix=(-1.*(xvals[mask])*s + (yvals[mask])*c)

# Plot the locations of the good pixels
plt.plot(xvals[mask],yvals[mask],'b+')

xpix=xpix.astype('int')
ypix=ypix.astype('int')

# Count the number of pixels inside the entire grid
numfound  += len(np.where((xpix < 22)&(xpix>-1)&(ypix > -1)&(ypix<46))[0])
# Count the number of pixels inside the left half of the grid
numfound2 += len(np.where((xpix < 11)&(xpix>-1)&(ypix > -1)&(ypix<46))[0])

print numfound, 'pixels in grid'
print numfound2, 'pixels in left half of grid'
print numfound-numfound2, 'pixels in right half of grid'
print 'Ratio of good pixels to total pixels on right half of grid:', (numfound-numfound2)/512.

plt.show()
# look for regions with fewest gaps

# how are these values determined? Originally 5,5
xsize=5
ysize=5

goodgrid=np.zeros((22,46))
idx=freqvals.argsort()
print len(xpix), len(freqvals)
f= open(path+'FL2_20120902_freq_atten_x_y.txt','w')
for i in range(len(xpix)):
#    print freqvals[idx[i]], xpix[idx[i]], ypix[idx[i]]
    
    f= open(path+'FL2_20120902_freq_atten_x_y.txt','a')
    f.write(str(freqvals[idx[i]]) + '\t' + str(int(attenvals[idx[i]])) +'\t' + str(xpix[idx[i]]) + '\t' + str(ypix[idx[i]]) +'\n')
    f.close()
    
    xmin=np.max([0,xpix[i]-xsize])
    xmax=np.min([22,xpix[i]+xsize])
    ymin=np.max([0,ypix[i]-xsize])
    ymax=np.min([46,ypix[i]+xsize])
    goodgrid[xmin:xmax,ymin:ymax] += 1
print goodgrid, np.max(goodgrid)

plt.imshow(goodgrid)

#plt.show()
