#!/usr/bin/python
import numpy as np
from matplotlib import pyplot as plt

autofit=np.loadtxt('/home/sean/data/20120725/SCI3-60nm-FL1-fits.txt')

freqs=autofit[:,1]
Qs=autofit[:,2]

print np.median(freqs)
print np.median(Qs)

fig = plt.figure()
ax=fig.add_subplot(111)
ax.hist(Qs,bins=100)
plt.show()
