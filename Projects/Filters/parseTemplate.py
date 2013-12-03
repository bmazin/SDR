import numpy as np

table = np.loadtxt('template.dat')
t = table[:,1]
np.savetxt('template2.dat',t)
