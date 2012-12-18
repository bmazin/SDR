#!/usr/bin/python
import numpy as np
from matplotlib import pyplot as plt

#Plots Histogram of f, Q, and Distance of f to nearest neighbor, Q vs f, Dist to neigh vs f and saves it to a pdf.  You need to change the File and pdftitle (and possibly the text position in line 79

File= '20121030/FL-sci4a-all-fits.txt'
pdftitle='/home/sean/data/fitshist/20121030-SCI4a-DF-all-QvsNN.pdf'
autofit=np.loadtxt('/home/sean/data/%s'%File)

freqs=autofit[:,1]
Qs=autofit[:,2]
Qs=[x/1000 for x in Qs]

ds=[]
fs=[]
freq=sorted(freqs)
for i in xrange(len(freqs)):
    if i-1 >= 0:
        y=abs(freq[i]-freq[i-1])
    else:
        y=abs(freq[i]-freq[i+1])

    if i+1 < len(freqs):
        x=abs(freq[i]-freq[i+1])
    else:
        x=abs(freq[i]-freq[i-1])

    if x>=y:
        ds.append(y)
    else:
        ds.append(x)

    fs.append(freq[i])
ds=[x*1000 for x in ds]

mf=np.median(freqs)
sf=np.std(freqs)
mq=np.median(Qs)
sq=np.std(Qs)
md=np.median(ds)
sd=np.std(ds)
nres=len(freqs)

fig = plt.figure()
ax5=fig.add_subplot(111)
ax5.plot(ds,Qs,'b,')
ax5.set_ylabel('Q(k)', size=8)
ax5.set_xlabel('Distance of f to Nearest Neighbor (MHz)', size=8)
ax5.set_title('Nearest Neighbor vs f0', size=9)
ax5.tick_params(labelsize=8)
#ax5.set_ylim(0,20)


fig.savefig(pdftitle)
plt.show()
plt.close()
