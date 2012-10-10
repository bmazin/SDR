#!/usr/bin/python
import numpy as np
from matplotlib import pyplot as plt

#Plots Histogram of f, Q, and Distance of f to nearest neighbor, Q vs f, Dist to neigh vs f and saves it to a pdf.  You need to change the File and pdftitle (and possibly the text position in line 79

File= '20121006/20121006-SCI4-DF-FL1-fits.txt'
pdftitle='/home/sean/data/fitshist/20121006-SCI4-DF-FL1-fits-hist.pdf'
autofit=np.loadtxt('/home/sean/data/%s'%File)

freqs=autofit[:,1]
Qs=autofit[:,2]
Qs=[x/1000 for x in Qs]

ds=[]
fs=[]
freq=sorted(freqs)
for i in xrange(1,len(freqs)-1):
	x=abs(freq[i]-freq[i+1])
	y=abs(freq[i]-freq[i-1])
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

fig = plt.figure(figsize=(6,8))
plt.subplots_adjust(left = 0.1, right= 0.96, bottom= .07, top= .96, wspace=0.3, hspace=0.4)


ax=fig.add_subplot(321)
ax.hist(freqs,bins=100, color='k')
ax.set_xlabel('Frequency (GHz)\nmedian=%f, std=%f'%(mf,sf), size=8)
ax.set_ylabel('Number', size=8)
ax.set_title('Histogram of Frequency', size=9)
ax.tick_params(labelsize=8)

ax2=fig.add_subplot(323)
ax2.hist(Qs, bins=100, color='k')
ax2.set_xlabel('Q(k)\nmedian=%f, std=%f'%(mq,sq), size=8)
ax2.set_ylabel('Number', size=8)
ax2.set_title('Histogram of Q', size=9)
ax2.set_xlim(0,300)
ax2.tick_params(labelsize=8)

ax3=fig.add_subplot(325)
ax3.hist(ds, bins=100, color='k')
ax3.set_xlabel('Distance to Nearest Neighbor (MHz)\nmedian=%f, std=%f'%(md,sd), size=8)
ax3.set_ylabel('Number', size=8)
ax3.set_title('Distance of f0 to Nearest Neighbor', size=9)
ax3.set_xlim(0,6)
ax3.tick_params(labelsize=8)

ax4=fig.add_subplot(322)
ax4.plot(freqs,Qs,'r,')
ax4.set_xlabel('Resonant Frequency (GHz)', size=8)
ax4.set_ylabel('Q(k)', size=8)
ax4.set_title('Q vs f0', size=9)
ax4.tick_params(labelsize=8)
ax4.set_ylim(0,300)

ax5=fig.add_subplot(324)
ax5.plot(fs,ds,'b,')
ax5.set_xlabel('Resonant Frequency (GHz)', size=8)
ax5.set_ylabel('Distance of f to Nearest Neighbor (MHz)', size=8)
ax5.set_title('Nearest Neighbor vs f0', size=9)
ax5.tick_params(labelsize=8)
ax5.set_ylim(0,20)
ax5.text(2.8,-15,'file name=\n%s\nnumber of resonators = %d'%(File, nres), size=8.5)


fig.savefig(pdftitle)
plt.show()
plt.close()
