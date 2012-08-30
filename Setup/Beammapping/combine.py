import numpy as np
import matplotlib.pyplot as plt

grid0=np.load('grid0.npz')
print grid0.files
xvals0=grid0['arr_0']
yvals0=grid0['arr_1']
mask0=grid0['arr_4']
grid1=np.load('grid1.npz')
xvals1=grid1['arr_0']
yvals1=grid1['arr_1']
mask1=grid1['arr_4']
grid2=np.load('grid2.npz')
xvals2=grid2['arr_0']
yvals2=grid2['arr_1']
mask2=grid2['arr_4']
grid3=np.load('grid3.npz')
xvals3=grid3['arr_0']
yvals3=grid3['arr_1']
mask3=grid3['arr_4']
plt.plot(xvals0[mask0],yvals0[mask0],'b+')
plt.plot(xvals1[mask1],yvals1[mask1],'g+')
plt.plot(xvals2[mask2],yvals2[mask2],'r+')
plt.plot(xvals3[mask3],yvals3[mask3],'k+')
plt.show()

