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
    def __init__(self,xtime,ytime,xfilelength,yfilelength):
        self.crx_median = np.zeros((2024,xtime))
        self.cry_median = np.zeros((2024,ytime))
        self.crx = np.zeros(((xfilelength,2024,xtime)))
        self.cry = np.zeros(((yfilelength,2024,ytime)))
        self.flag = np.zeros(2024)
        self.peakpos = np.zeros((2,2024))
    # Try to find a peak position by manually selecting an approximate peak location
    def on_click(self,event):
        # If x sweep plot (top plot) is clicked
        if(event.y > 250):
            self.xvals=np.arange(len(self.crxmedian[pixelno][:]))
            self.xpeakguess=event.xdata
            self.xfitstart=max([self.xpeakguess-20,0])
            self.xfitend=min([self.xpeakguess+20,len(self.xvals)])
            params = fitgaussian(self.crxmedian[pixelno][self.xfitstart:self.xfitend],self.xvals[self.xfitstart:self.xfitend])
            self.xfit = gaussian(params,self.xvals)
            self.peakpos[0,self.pixelno]=params[0]
        # If y sweep plot (bottom plot) is clicked
        else:
            self.yvals=np.arange(len(self.cry_median[pixelno][:]))
            self.ypeakguess=event.xdata
            self.yfitstart=max([self.ypeakguess-20,0])
            self.yfitend=min([self.ypeakguess+20,len(self.yvals)])
            params = fitgaussian(self.cry_median[pixelno][self.yfitstart:self.yfitend],self.yvals[self.yfitstart:self.yfitend])
            self.yfit = gaussian(params,self.yvals)
            self.peakpos[1,self.pixelno]=params[0]
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

def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1


# Specify input/output directory and files
path = '/Users/kids/desktop/Beammapping/'

xsweep = []
xsweep.append('obs_20121010-031709.h5')
xsweep.append('obs_20121010-035925.h5')


ysweep = []
ysweep.append('obs_20121010-041802.h5')
ysweep.append('obs_20121010-025118.h5')


number_of_roaches = 8
roach_pixel_count = np.zeros(number_of_roaches)
for roachno in xrange(0,number_of_roaches):
    roach_pixel_count[roachno] = file_len(path + 'ps_freq%i.txt' %roachno)-1

# Load the input files
# X sweep data
h5file_x = []
ts_x = []
exptime_x = []
for i in range(len(xsweep)):
    h5file_x.append(openFile(path + xsweep[i], mode = 'r'))
    ts_x.append(int(h5file_x[i].root.header.header.col('unixtime')[0]))
    exptime_x.append(int(h5file_x[i].root.header.header.col('exptime')[0]))
# Y sweep data
h5file_y = []
ts_y = []
exptime_y = []
for i in range(len(ysweep)):
    h5file_y.append(openFile(path + ysweep[i], mode = 'r'))
    ts_y.append(int(h5file_y[i].root.header.header.col('unixtime')[0]))
    exptime_y.append(int(h5file_y[i].root.header.header.col('exptime')[0]))

# Print start and sweep durations, also pixel selection commands
for i in range(len(xsweep)):
    print 'Start Time %i = ' %i,ts_x[i], ts_y[i]
for i in range(len(xsweep)):
    print 'exptime_x %i =' %i,exptime_x[i],'and exptime_y %i =' %i, exptime_y[i]
print '"A" = Accept, "D" = Delete, "Q" = Quit, "X" = X Only, "Y" = Y Only'

# Create a BeamMapper instance
# Go through each of the pixels (originally (0,2024))
for roachno in xrange(0,number_of_roaches):
    map = BeamMapper(exptime_x[0],exptime_y[0],len(xsweep),len(ysweep))
    f=open(path + 'r%i.pos' %roachno,'w')
    for pixelno in xrange(0,int(roach_pixel_count[roachno])):
        map.pixelno=pixelno
        map.flag[pixelno] = pixelno
    
        # Store the x data into crx
        pn = []
        data = np.empty(((len(xsweep),exptime_x[0])), dtype = object)
        for i in range(len(xsweep)):
            pn.append('/r%d/p%d/t%d' % ( roachno ,pixelno, ts_x[i]))       
        try:
            for i in range(len(xsweep)):
                data[i][:] = h5file_x[i].root._f_getChild(pn[i]).read()
            for j in xrange(0,exptime_x[0]):
                median_array = []
                for i in range(len(xsweep)):
                    median_array.append(len(data[i][j]))
                map.crx_median[pixelno][j] = np.median(median_array)
                for i in range(len(xsweep)):
                    map.crx[i][pixelno][j] = len(data[i][j])
        except:
            pass
     
        # Store the y data into cry
        pn = []
        data = np.empty(((len(ysweep),exptime_y[0])), dtype = object)
        for i in range(len(ysweep)):
            pn.append('/r%d/p%d/t%d' % ( roachno ,pixelno, ts_y[i]))
        try:
            for i in range(len(ysweep)):
                data[i][:] = h5file_y[i].root._f_getChild(pn[i]).read()
            for j in xrange(exptime_y[0]):
                median_array = []
                for i in range(len(ysweep)):
                    median_array.append(len(data[i][j]))
                map.cry_median[pixelno][j] = np.median(median_array)
                for i in range(len(ysweep)):
                    map.cry[i][pixelno][j] = len(data[i][j])
        except:
            pass

        print 'roach %d, pixel %d' % (roachno, pixelno)
        map.fig = plt.figure()

        # do fit of x-position
        map.ax = map.fig.add_subplot(211)
        map.xvals=np.arange(len(map.crx_median[pixelno][:]))
        plt.title(str(pixelno))
        plt.plot(map.xvals,map.crx_median[pixelno][:])       
        map.xpeakguess=np.where(map.crx_median[pixelno][:] == map.crx_median[pixelno][:].max())[0][0]
        map.xfitstart=max([map.xpeakguess-20,0])
        map.xfitend=min([map.xpeakguess+20,len(map.xvals)])
        params_x = fitgaussian(map.crx_median[pixelno][map.xfitstart:map.xfitend],map.xvals[map.xfitstart:map.xfitend])
        print 'x: [center, width, height, back] =', params_x
        map.xfit = gaussian(params_x,map.xvals)
        plt.plot(map.xvals, map.xfit)
        for i in range(len(xsweep)):
            plt.plot(map.xvals,map.crx[i][pixelno][:],alpha = .2)
        map.ax.set_ylim(params_x[3]-30,params_x[2]+75)
        map.peakpos[0,pixelno]=params_x[0]
            
        # do fit of y-position
        map.ax = map.fig.add_subplot(212)
        map.yvals=np.arange(len(map.cry_median[pixelno][:]))
        plt.title(str(pixelno+1))
        plt.plot(map.yvals,map.cry_median[pixelno][:])     
        map.ypeakguess=np.where(map.cry_median[pixelno][:] == map.cry_median[pixelno][:].max())[0][0]
        map.yfitstart=max([map.ypeakguess-20,0])
        map.yfitend=min([map.ypeakguess+20,len(map.yvals)])
        params_y = fitgaussian(map.cry_median[pixelno][map.yfitstart:map.yfitend],map.yvals[map.yfitstart:map.yfitend])
        print 'y: [center, width, height, back] =', params_y
        map.yfit = gaussian(params_y,map.yvals)
        plt.plot(map.yvals, map.yfit)
        for i in range(len(ysweep)):
            plt.plot(map.yvals,map.cry[i][pixelno][:],alpha = .2)
        map.ax.set_ylim(params_y[3]-30,params_y[2]+75)
        map.peakpos[1,pixelno]=params_y[0]

        # AUTOMATICALLY DELETE OBVIOUSLY BAD PIXELS
        
#        if((params_x[0] == 9.5 and params_y[0] == 9.5) or (params_x[1] >= 100 and params_y[1] >= 100)):
#            map.peakpos[0,pixelno]=0
#            map.peakpos[1,pixelno]=0
#            map.flag[pixelno] = -1*pixelno
#            plt.close()
#            f=open(path+'Sweep_1/r%i.pos' %roachno,'a')
#            f.write(str(map.peakpos[0,pixelno])+'\t'+str(map.peakpos[1,pixelno])+'\t'+str(int(map.flag[pixelno]))+'\n')
#            f.close()
#        else:
        map.connect()
        while True:
            # Accept pixel with 'a'
            response=raw_input('>')
            if(response == 'a'):
                print 'Response: ', response
                plt.close()
                f=open(path+'r%i.pos' %roachno,'a')
                f.write(str(map.peakpos[0,pixelno])+'\t'+str(map.peakpos[1,pixelno])+'\t'+str(int(map.flag[pixelno]))+'\n')
                f.close()
                break
            # Delete pixel with 'd'
            elif(response == 'd'):
                print 'Response: ', response
                map.peakpos[0,pixelno]=0
                map.peakpos[1,pixelno]=0
                map.flag[pixelno] = -1*pixelno
                plt.close()
                f=open(path+'r%i.pos' %roachno,'a')
                f.write(str(map.peakpos[0,pixelno])+'\t'+str(map.peakpos[1,pixelno])+'\t'+str(int(map.flag[pixelno]))+'\n')
                f.close()
                break
            # Control whether only the x or y pixel is selected
            # x is okay
            elif(response == 'x'):
                print 'Response: ', response
                map.peakpos[1,pixelno]=0
                map.flag[pixelno] = -1*pixelno
                plt.close()
                f=open(path+'r%i.pos' %roachno,'a')
                f.write(str(map.peakpos[0,pixelno])+'\t'+str(map.peakpos[1,pixelno])+'\t'+str(int(map.flag[pixelno]))+'\n')
                f.close()
                break
            # y is okay
            elif(response == 'y'):
                print 'Response: ', response
                map.peakpos[0,pixelno]=0
                map.flag[pixelno] = -1*pixelno
                plt.close()
                f=open(path+'r%i.pos' %roachno,'a')
                f.write(str(map.peakpos[0,pixelno])+'\t'+str(map.peakpos[1,pixelno])+'\t'+str(int(map.flag[pixelno]))+'\n')
                f.close()
                break
            # Quit program with 'q'
            elif(response == 'q'):
                sys.exit(0)
            plt.show()
            
h5file_x.close()
h5file_y.close()
f.close()
