import matplotlib.pyplot as plt

wvl=range(550,1150,50)
print wvl
NPulses=[5,8,10,8,8,10,15,28,50,80,15,185]
dectv=[126,.185,.137,.15,.225,.468,.857,1.76,3.49,4.905,6.765,9.407]
qeDataFilename= '/home/sean/data/20121003/obs_20121003-210815.h5'

magnification = 1.2
#magnification = 1.46
areaARCONS = 222*10**-6
areaDetector = 1*10**-2
IRAreaDetector = 3*10**-3
noMicroareaARCONS=40*10**-6

qeresults=[]
medianQeResults=[]
meanQeResults=[]

roach=2
pix=104


qepix=[]
for i in xrange(0,len(dectv)):
#                print wvl[i]

        qewvl=(NPulses[i]*areaDetector**2)/((dectv[i]*10**7)*(magnification*areaARCONS)**2) 
        qepix.append(qewvl)
print qepix

fig2=plt.figure()
ax2=fig2.add_subplot(111)
ax2.plot(wvl,qepix,label='r%dp%d'%(roach,pix))
ax2.set_xlabel('Frequency (nm)')
ax2.set_ylabel('QE')
ax2.set_title('QE of %s in r%d'%(qeDataFilename,roach))
ax2.grid(True)
ax2.legend()
plt.savefig('/home/sean/data/qePlots/20121003-210815r2p104.pdf')
plt.show()
plt.close()
