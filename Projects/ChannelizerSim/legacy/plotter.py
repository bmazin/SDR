import numpy
import struct
import random
import mkid
import matplotlib.pyplot as mpl




data = numpy.loadtxt('Template-2pass.dat')
t = data[0,:]
p = data[1,:]
print t
print '................'
print p

mpl.plot(t, p, '.-')
mpl.show()




