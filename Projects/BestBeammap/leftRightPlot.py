#!/bin/python
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

def getList(file):
    posList= np.recfromtxt(file)
    l = [posList['f0'],posList['f2'],posList['f3']]
    l = np.array(l)
    l = l.T
    names = posList['f4']
    return l,names

left,leftNames = getList('freq_atten_x_y_left.txt')
leftX,leftXNames = getList('good_x_left.txt')
leftY,leftYNames = getList('good_y_left.txt')
#left2,left2Names = getList('freq_atten_x_y_left1.txt')
right,rightNames = getList('freq_atten_x_y_right.txt')
rightX,rightXNames = getList('good_x_right.txt')
rightY,rightYNames = getList('good_y_right.txt')
#right2,right2Names = getList('freq_atten_x_y_right2.txt')
#move left to match right
left[:,1]+=.4
left[:,2]-=.2

leftX[:,2]=-2
leftY[:,1]=-2
rightX[:,2]=-2
rightY[:,1]=-2
leftX[:,1]+=.4
leftY[:,2]-=.2
#right2[:,1]+=2
#right2[:,2]-=1

for i,name in enumerate(rightNames):
    if name[2]=='5':
        print right[i,0],right[i,1]
cm = matplotlib.cm.get_cmap('jet')
vmax = max([np.max(left[:,0]),np.max(right[:,0]),np.max(rightX[:,0]),np.max(rightY[:,0])])
vmin = min([np.min(left[:,0]),np.min(right[:,0]),np.max(rightX[:,0]),np.max(rightY[:,0])])
plt.scatter(left[:,1],left[:,2],c=left[:,0],cmap=cm,vmax=vmax,vmin=vmin,marker='<',alpha=0.5,s=100,label='left')
plt.scatter(leftX[:,1],leftX[:,2],c=leftX[:,0],cmap=cm,vmax=vmax,vmin=vmin,marker='<',alpha=0.5,s=100,label='leftX')
plt.scatter(leftY[:,1],leftY[:,2],c=leftY[:,0],cmap=cm,vmax=vmax,vmin=vmin,marker='<',alpha=0.5,s=100,label='leftX')
plt.scatter(rightY[:,1],rightY[:,2],c=rightY[:,0],cmap=cm,vmax=vmax,vmin=vmin,alpha=0.5,s=100,label='rightY',marker='>')
plt.scatter(rightX[:,1],rightX[:,2],c=rightX[:,0],cmap=cm,vmax=vmax,vmin=vmin,alpha=0.5,s=100,label='rightX',marker='>')
plt.scatter(right[:,1],right[:,2],c=right[:,0],cmap=cm,vmax=vmax,vmin=vmin,alpha=0.5,s=100,label='right',marker='>')
plt.legend()
plt.colorbar()
plt.show()


