#!/bin/python

import numpy as np
import matplotlib.pyplot as plt

Npoints = 100
a=3.0
b=1.0
t=np.linspace(0,2*np.pi,Npoints)
amp = 10.0
x=amp/2.0*np.cos(a*t)
y=amp/2.0*np.sin(b*t)

dx = [float('%.2f'%i) for i in np.diff(x)]
dy = [float('%.2f'%i) for i in np.diff(y)]
print dx
print dy

x = np.cumsum(dx)+x[0]
y = np.cumsum(dy)+y[0]
print x[0],y[0]

fig=plt.figure()
ax=fig.add_subplot(111)
ax.plot(x,y,'.')
plt.show()
