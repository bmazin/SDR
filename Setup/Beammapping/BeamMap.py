import numpy as np
from tables import *
import time
import matplotlib.pyplot as plt
import sys
from matplotlib.backends.backend_pdf import PdfPages
import scipy.signal as signal
from scipy import optimize
import scipy.stats as stats


# Define the various classes and functions needed for the beam mapping
# Define BeamMapper class - this allows you to change the location of a peak if there is a mistake
class BeamMapper():    
    # Initialize variables needed within the class
    def __init__(self,xtime,ytime):
        self.crx = np.zeros((1024,xtime))
        self.cry = np.zeros((1024,ytime))
        self.flag = np.zeros(1024)
        self.peakpos = np.zeros((2,1024))
    # Try to find a peak position by manually selecting an approximate peak location
    def on_click(self,event):
        # If x sweep plot (top plot) is clicked
        if(event.y > 250):
            self.xvals=np.arange(len(self.crx[i][:]))
            self.xpeakguess=event.xdata
            self.xfitstart=max([self.xpeakguess-10,0])
            self.xfitend=min([self.xpeakguess+10,len(self.xvals)])
            params = fitgaussian(self.crx[i][self.xfitstart:self.xfitend],self.xvals[self.xfitstart:self.xfitend])
            self.xfit = gaussian(params,self.xvals)
            self.peakpos[0,self.i]=params[0]
        # If y sweep plot (bottom plot) is clicked
        else:
            self.yvals=np.arange(len(self.cry[i][:]))
            self.ypeakguess=event.xdata
            self.yfitstart=max([self.ypeakguess-10,0])
            self.yfitend=min([self.ypeakguess+10,len(self.yvals)])
            params = fitgaussian(self.cry[i][self.yfitstart:self.yfitend],self.yvals[self.yfitstart:self.yfitend])
            self.yfit = gaussian(params,self.yvals)
            self.peakpos[1,self.i]=params[0]
    # Connect to plot
    def connect(self):
        self.cid = self.fig.canvas.mpl_connect('button_press_event', self.on_click)

# Define a standard Gaussian distribution function
def gaussian(pars, x):
    center, width, height, back = pars
    width = float(width)
    return back + height*np.exp(-(((center-x)/width)**2)/2)

# Define an error function between data and a Gaussian
def errorfunction(params, data, x):
    errorfunction = data - gaussian(params,x)
    return errorfunction

# Find an optimal Guassian fit for the data, return parameters of that Gaussian
def fitgaussian(data,x):
    params=(x.mean(),2.*(x[1]-x[0]),data.max(), 0.)
    p, success = optimize.leastsq(errorfunction, params, args=(data, x))
    return p


# Specify input/output directory and files
path = '/media/disk2/20120814_SCI3alpha/'
xsweep = 'bm_X_FL2.h5'
ysweep = 'bm_Y_FL2.h5'
f=open('FL2_out.pos','w')

# Load the input files
# X sweep data
h5file_x = openFile(path + xsweep, mode = "r")
ts_x = int(h5file_x.root.header.header.col('ut')[0])
exptime_x = int(h5file_x.root.header.header.col('exptime')[0])
# Y sweep data
h5file_y = openFile(path + ysweep, mode = "r")
ts_y = int(h5file_y.root.header.header.col('ut')[0])
exptime_y = int(h5file_y.root.header.header.col('exptime')[0])

# Print start and sweep durations
print 'Start Time = ',ts_x, ts_y
print 'exptime_x =',exptime_x,'and exptime_y =', exptime_y
print '"A" = Accept, "D" = Delete, "Q" = Quit'

# Create a BeamMapper instance
map = BeamMapper(exptime_x,exptime_y)

# Go through each of the pixels (originally (0,1024))
for i in xrange(0,1023):
    map.i=i
    map.flag[i] = i
    
    # Store the x data into crx  
    pn = '/r%d/p%d/t%d' % ( int(i/256) ,i%256, ts_x)
    try:
        data = h5file_x.root._f_getChild(pn).read()
        for j in xrange(exptime_x):
            map.crx[i][j] = len(data[j])
    except:
        pass
    
    # Store the y data into cry
    pn = '/r%d/p%d/t%d' % ( int(i/256) ,i%256, ts_y)
    try:
        data = h5file_y.root._f_getChild(pn).read()
        for j in xrange(exptime_y):
            map.cry[i][j] = len(data[j])
    except:
        pass

    print 'roach %d, pixel %d' % (int(i/256), i%256)
    map.fig = plt.figure()

    # do fit of x-position
    map.ax = map.fig.add_subplot(211)
    map.xvals=np.arange(len(map.crx[i][:]))
    plt.title(str(i))
    plt.plot(map.xvals,map.crx[i][:])
    map.xpeakguess=np.where(map.crx[i][:] == map.crx[i][:].max())[0][0]
    map.xfitstart=max([map.xpeakguess-10,0])
    map.xfitend=min([map.xpeakguess+10,len(map.xvals)])
    params = fitgaussian(map.crx[i][map.xfitstart:map.xfitend],map.xvals[map.xfitstart:map.xfitend])
    print 'x: [center, width, height, back] =', params
    map.xfit = gaussian(params,map.xvals)
    plt.plot(map.xvals, map.xfit)
    map.peakpos[0,i]=params[0]
        
    # do fit of y-position
    map.ax = map.fig.add_subplot(212)
    map.yvals=np.arange(len(map.cry[i][:]))
    plt.title(str(i+1))
    plt.plot(map.yvals,map.cry[i][:])
    map.ypeakguess=np.where(map.cry[i][:] == map.cry[i][:].max())[0][0]
    map.yfitstart=max([map.ypeakguess-10,0])
    map.yfitend=min([map.ypeakguess+10,len(map.yvals)])
    params = fitgaussian(map.cry[i][map.yfitstart:map.yfitend],map.yvals[map.yfitstart:map.yfitend])
    print 'y: [center, width, height, back] =', params
    map.yfit = gaussian(params,map.yvals)
    plt.plot(map.yvals, map.yfit)
    map.peakpos[1,i]=params[0]
    
    map.connect()
    while True:
        # Accept pixel with 'a'
        response=raw_input('>')
        if(response == 'a'):
            print 'Response: ', response
            plt.close()
            f=open(path+'FL2_out.pos','a')
            f.write(str(map.peakpos[0,i])+'\t'+str(map.peakpos[1,i])+'\t'+str(int(map.flag[i]))+'\n')
            f.close()
            break
        # Delete pixel with 'd'
        elif(response == 'd'):
            print 'Response: ', response
            map.peakpos[0,i]=0
            map.peakpos[1,i]=0
            map.flag[i] = -1*i
            plt.close()
            f=open(path+'FL2_out.pos','a')
            f.write(str(map.peakpos[0,i])+'\t'+str(map.peakpos[1,i])+'\t'+str(int(map.flag[i]))+'\n')
            f.close()
            break
        # Quit program with 'q'
        elif(response == 'q'):
            sys.exit(0)
        plt.show()

h5file_x.close()
h5file_y.close()
f.close()
