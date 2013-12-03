import numpy as np
import random
import os

import matplotlib.pyplot as plt


size = 26
finalSize = 26
initialOffset = 1
offset=1
path = '/Scratch/filterData/20131123/'
pixelList = np.loadtxt(os.path.join(path,'filter_list.txt'))
fig = plt.figure()
ax1 = fig.add_subplot(111)
NRoach = 8
NPixel = 256
defaultFilter = np.loadtxt('matched_50us.txt')
defaultFilter /= np.sum(defaultFilter)
for roachNum in xrange(NRoach):
    allMatched = []
    savefile =os.path.join(path,'dblexp20131125r%d.txt'%roachNum)
    for pixelNum in xrange(NPixel):
        print roachNum,pixelNum 
        try:
            template = np.loadtxt(os.path.join(path,'r%dp%dTemplateFit-2pass26a.dat'%(roachNum,pixelNum)))
            template = np.array(template)[1000-initialOffset:1000-initialOffset+size,1]

            #   Define matched filter, g.
            #plt.matshow(covMatrixInv)
            #plt.colorbar()

            matched = np.array(template)
            matched = matched[initialOffset-offset:initialOffset-offset+finalSize]
            matched/=sum(matched)
            if np.max(matched) > 2e-1:
                matched*=(1e-1/np.max(matched))

            if np.any(np.isnan(matched)):
                matched = np.array(defaultFilter)
                print 'nan: setting to default'
                
            if np.any(matched < 0):
                matched = np.array(defaultFilter)
                print 'negative values: setting to default'

            allMatched.append(matched)
            plt.plot(matched)
        except:
            print 'setting to default'
            matched = np.array(defaultFilter)
            allMatched.append(matched)


    plt.plot(defaultFilter,'k--')
    allMatched = np.array(allMatched)
    print np.shape(allMatched)
    np.savetxt(savefile,allMatched)
    plt.show()

#print 'g reversed: '
#print '[',
#for G in g.tolist.reverse():
#	print G, ',',
#print ']'
    
plt.show()

