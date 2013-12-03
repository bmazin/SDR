import numpy
from scipy import *
from scipy import optimize

import matplotlib.pyplot as mpl
#import pylab
import random, math

x = numpy.loadtxt('test.dat')
#x = numpy.loadtxt('matched_25us_254nm.dat')

n, bins_filtered, patches = mpl.hist(x, 180, normed=1, facecolor='green', alpha=0.75)

fig = mpl.figure()
ax1 = fig.add_subplot(111)
ax1.plot(bins_filtered)
mpl.show()
