import tables
import numpy as np
import matplotlib.pyplot as plt
import math
import itertools
from qeforpixelsfunc import *

#savedValues= raw_input('Do you want to used the saved values? Y or enter : ')
roach= input('Which roach do you want to analyze? ') 

#qeDataFilename= '/home/sean/data/20121003/obs_20121003-210815.h5'
#qeObsTime=1349298497
#testbedFileName = '/home/sean/data/QEmeas/20121003_210815_postLick_sci3gamma.txt'
#NSec=1800

#qeDataFilename= '/home/sean/data/20121003/obs_20121003-223105.h5'
#qeObsTime=1349303467
#testbedFileName = '/home/sean/data/QEmeas/20121003_223105_postLick_sci3gamma.txt'
#NSec=2000

#qeDataFilename= '/home/sean/data/20121018/obs_20121019-044657.h5'
#qeObsTime=1350622020
#testbedFileName = '/home/sean/data/QEmeas/SCI4-microlens-20121019-044657.txt'
#NSec=1800

#qeDataFilename= '/home/sean/data/20121010/obs_20121010-215637.h5'
#qeObsTime=1349906199
#testbedFileName = '/home/sean/data/QEmeas/SCI4-nomicrolens-1.txt'
#NSec=1300
#dercutoff=12000, firstpeak=109, time interval 800-810

#qeDataFilename= '/home/sean/data/20121011/qe_20121011-185036.h5'
#qeObsTime=1349981438
#testbedFileName='/home/sean/data/QEmeas/SCI4-nomicrolens-2.txt'
#NSec=1800
#dercutoff=10000, pauseafterpeak 14, firstpeakafterpause=1178, firstpeak=92, time interval 850-860

#qeDataFilename= '/home/sean/data/20121019/obs_20121019-193507.h5'
#qeObsTime=1350675309
#testbedFileName='/home/sean/data/QEmeas/SCI4-microlens-20121019-3.txt'
#NSec=1900
##r0,dercutoff=14000, pauseafterpeak 14, firstpeakafterpause=1178, firstpeak=86, time interval 430-440, range 350-1400

qeDataFilename= '/home/sean/data/20121022/obs_20121022-210829.h5'
qeObsTime=1350940111
testbedFileName='/home/sean/data/QEmeas/SCI4-microlens-20121022-210829.txt'
NSec=2000
#dercutoff=9000, pauseafterpeak 14, firstpeakafterpause=1449, firstpeak=104, time interval 696-712, range 500-600

saveMedQEPlotname='/home/sean/data/qePlots/qe20121022r%d.pdf'%(roach)

NPixels=253
magnificationLick = 1.2
magnificationPalomar = 1.46
areaARCONSwithMicrolens = 222*10**-6
areaDetector = 1*10**-2
IRAreaDetector = 3*10**-3
areaARCONSwithoutMicrolens=40*10**-6

areaARCONS = areaARCONSwithMicrolens
magnification = magnificationPalomar
 
#dectvManual=[0.149,.497,1.156,2.305,3.820,4.762,5.014,5.746,5.232,5.056,6.466,8.5,10.513,11.783]
#wvlManual=range(400,1100,50)


print 'Loading data...\nThis will take a couple minutes...'

#def peakfit(y1,y2,y3):
#    y4=y2-0.125*((y3-y1)**2)/(y3+y1-2*y2)
#    return y4

#def binToDeg_12_9(binOffset12_9):
#	x = binOffset12_9/2.0**9-4.0
#	return x*180.0/np.pi

#view the overall histogram of photons seen by a single roach. Record a good time interval during a strong peak and the time the peaks start 

photonSec=[]

#pulseMask = int(12*'1',2)#bitmask of 12 ones

fid = tables.openFile(qeDataFilename,mode='r')
pulseh=[[] for x in xrange(NSec)]



for pix in xrange(0,NPixels):
      pixelName = '/r%d/p%d/t%d'%(roach,pix,qeObsTime)
#      print pixelName
      dataset=fid.getNode(pixelName)
      for ind, sec in enumerate(dataset):
          for packet in sec:
                pulseh[ind].append(1)
#               packet = int(packet)
#               beforePeak = binToDeg_12_9(packet>>44 & pulseMask)
#               atPeak = binToDeg_12_9(packet>>32 & pulseMask)
#               afterPeak = binToDeg_12_9(packet >> 20 & pulseMask)
#               if beforePeak+afterPeak-2*atPeak != 0:
#                    peak = peakfit(beforePeak,atPeak,afterPeak)
#                    peak = atPeak
#                    pulseh[ind].append(peak)

# the peaks for all photons in each second is in its own row of pulseh
for t in pulseh:
   photonSec.append(len(t))
	
# photonSec has the total number of photons per second, 
print 'Things to record when you view the following plot: \n	time interval during a strong peak\n	time the first peak starts\n	if there is a pause and if so,\n		after what peak does the pause occur\n		the time the first peak after the pause starts'

fig0=plt.figure()
ax0=fig0.add_subplot(111)
ax0.plot(photonSec)
ax0.set_xlabel('Time')
ax0.set_ylabel('Number of Photons')
ax0.set_title('# Photons vs. Time')
ax0.grid(True)
plt.show()
plt.close()

der=[]
   
for t in xrange(0, len(photonSec)-1):
   der.append(photonSec[t+1]-photonSec[t])

status='R'

while status in ('R', "'R'", 'r', "'r'"):
    ncutoff= int(raw_input('What value of the derivative should define a pulse? 10000? '))

    x=[1,NSec/2,NSec]
    y1=[ncutoff,ncutoff,ncutoff]
    y2=[-1*ncutoff,-1*ncutoff,-1*ncutoff]
    fig1=plt.figure()
    ax1=fig1.add_subplot(111)
    ax1.plot(der, 'k', x,y1,'b',x,y2,'b')
    ax1.set_xlabel('Time')
    ax1.set_ylabel('Derivative of the Number of Photons')
    ax1.set_title('Derivative of # Photons vs. Time')
    ax1.grid(True)
    plt.show()
    plt.close()
    status= raw_input("What do you want to do? \nRepick cutoff= R, Quit= Q, or press enter to move on   ")

pause= raw_input("Is there a pause in the middle of the data? Y or press enter ")

if pause in ('Y', "'Y'",'y',"'y'"):
    pause= 'Y'
    pausePeak= int(raw_input('After what peak does the pause occur? '))
    pauseInitial= int(raw_input('What time does the %d th peak start? '%(pausePeak+1)))
else:
    pause= 'N'
    pausePeak=0
    pauseInitial=NSec+20 
 
indi = []
#print pauseInitial-20
for g in xrange(0, len(der)):
   if abs(der[g]) >= ncutoff :
        indi.append(g)
#remove close indices that correspond to the same peak
#print indi
for i in indi:
    x = indi.index(i)
    if x+1 != len(indi) :
        if abs(indi[x+1]-indi[x]) <= 5 :
            del indi[x+1]
x=0
while x!= len(indi):
    if indi[x]>(pauseInitial-20):
#        print indi[x]
        del indi[x]
    else:
    	x=x+1
#print indi
if len(indi)%2 != 0:
    del indi[len(indi)-1]

   # +- 3 so we don't average the first or last 3 sec in each peak
init = indi[0] + 3
numon = len(indi)//2
   
spw = []
stw = []

for j in xrange(0,numon):
    pw = indi[2*j+1]-indi[2*j]
    spw.append(pw)
for k in xrange(0,numon-1):
    tw = indi[2*(k+1)]-indi[2*k+1]
    stw.append(tw)
#print spw
#print stw
peakw = np.average(spw) - 2*3
troughw = np.average(stw) + 2*3
print 'peakw = %f'%peakw
print 'troughw = %f'%troughw

#useCalc= raw_input("Do you want to use the calculated peakw and troughw? type N or press enter: ")
#if useCalc in ('N', "'N'", 'n', "'n'"):
#    peakw = int(raw_input('What do you want to set the peakw as?\n peakw = number of seconds the peak lasts -6 : '))
#    troughw = int(raw_input('What do you want to set the troughw as?\n troughw = number of seconds the between peaks +6 : '))

initial= int(raw_input('What time does the first peak start? '))


if status not in ('Q', 'q', "'Q'", "'q'"):
    print 'We will see how many photons hit each individual pixel during a given time interval'
    intervalStart= int(raw_input('When should the time interval start? '))
    intervalStop= int(raw_input('When should the interval stop? '))

    finish=[]
    Final=[]
    pixels=[]

    for pix in xrange(0,NPixels):
        temp=[]
        dataset=fid.getNode('/r%d/p%d/t%d'%(roach,pix,qeObsTime))
        for t in xrange(intervalStart,intervalStop):	
            temp.append(len(dataset[t])) 
        finish.append([int(np.average(temp)),pix])
    Final=sorted(finish)
    print '# of photons hit during time interval, pixel they hit] in ascending order'
    print Final

    fid.close()

#This program looks at specific pixels (picked by using FindGoodPix.py) and plots the photon histogram and qe for each.
#dectv is the values (x10^7) seen in the comparison detector (not arcons).


#    HaveTestBed = raw_input("Do you have a test bed file loaded? N or press enter: ")
#    if HaveTestBed in ('N', "'N'", 'n', "'n'"):
#        dectv=dectvManual
#        wvl=wvlManual
#    else:
    testbedFile = np.loadtxt(testbedFileName)
    wvl = testbedFile[:,0]
    dectv=testbedFile[:,-1]

    status='R'
    LowPhotonLimit=0
    HighPhotonLimit=0
    while status in ('R', "'R'", 'r', "'r'"):
        LowPhotonLimit=0
        HighPhotonLimit=0
        PixList=Final
        listOrRange= raw_input("Do you want to analyze pixels that recieved a certain level of photons or enter a list of pixel numbers?\nList = L or for Range press enter : ")
        if listOrRange in ('L', "'L'", 'l', "'l'"):
            pixlist= input("What pixels do you want to analyze? \nMake sure you enter a list! [ , , ] : ")
        else:
            LowPhotonLimit= int(raw_input('What is the smallest amount of photons allowed? '))
            HighPhotonLimit= int(raw_input('What is the largest amount of photons allowed? '))
            x=0
            while x != len(PixList):
            	if PixList[x][0]>HighPhotonLimit or PixList[x][0]<LowPhotonLimit:
            		del PixList[x]
            	else:
            		x=x+1
            for pix in xrange(0,len(PixList)):
                PixList[pix]=PixList[pix][1]
            pixlist = PixList
        print 'The pixels selected are'
        print pixlist
        print 'The number of pixels selected are'
        print len(pixlist)
        plotYorN = raw_input("Do you want to plot photons vs. time for each pixel selected? Y or press enter: ")
        if plotYorN in ('Y', "'Y'",'y',"'y'"):
            plotYorN= 'Y'
        else:
            plotYorN= 'N'

        NPulses = NumPhotonInWVLPulses(qeDataFilename, qeObsTime, roach, pixlist, initial, peakw, troughw,  dectv, NSec, len(wvl), plotYorN , pause, pauseInitial, pausePeak)

        print NPulses[0]

        fig2=plt.figure()
        ax2=fig2.add_subplot(111)


        qeresults=[]
        medianQeResults=[]
        meanQeResults=[]
        print 'dectv=',dectv
        print 'NPulses[0]=',NPulses[0][:]
        for j in xrange(0,len(pixlist)):
            qepix=[]
            for i in xrange(0,len(dectv)):
#                print wvl[i]
                if wvl[i]>= 1100:
                    qewvl=(NPulses[j][i]*IRAreaDetector**2)/((dectv[i]*10**7)*(magnification*areaARCONS)**2) 
                else:              
                    qewvl=(NPulses[j][i]*areaDetector**2)/((dectv[i]*10**7)*(magnification*areaARCONS)**2)
#                print qewvl
                qepix.append(qewvl)
            ax2.plot(wvl,qepix,label='r%dp%d'%(roach,pixlist[j]))
            qeresults.append(qepix)
        qeresults = np.array(qeresults)
        print 'qeresult[0]=',qeresults[0]
        for wl in xrange(0,len(qeresults[0])):
            medianQeResults.append(np.median(qeresults[:,wl]))
            meanQeResults.append(np.mean(qeresults[:,wl]))
        print 'medianQE=',medianQeResults
        #print meanQeResults
#-------Some error above.  inputs right, formula right, output not right...------
        ax2.set_xlabel('Frequency (nm)')
        ax2.set_ylabel('QE')
        ax2.set_title('QE of %s in r%d'%(qeDataFilename,roach))
        ax2.grid(True)
        ax2.legend()
        plt.show()
        plt.close()
#        print 'The decimal quantum efficiency of the ADR for 400-1050 wvls are:'
#        print qeresults

        Save= raw_input("Do you want to save this next plot of the median QE vs. wavelength? Y or enter: ")

        fig3=plt.figure()
        ax3=fig3.add_subplot(111)
#        ax3.plot(wvl,medianQeResults)
        ax3.plot(wvl,medianQeResults, label='median')
        ax3.plot(wvl,meanQeResults, label='mean')
        ax3.set_xlabel('Frequency (nm)')
        ax3.set_ylabel('QE')
        ax3.legend()
        ax3.set_title('Median and Mean QE of %s in r%d'%(qeDataFilename,roach), size=12)
        ax3.grid(True)
        if Save in ('Y', "'Y'",'y',"'y'"):
            okName= raw_input("Is %s an ok filename? N or enter: "%(saveMedQEPlotname))
            if okName in ('N', "'N'", 'n', "'n'"):
                saveMedQEPlotname= raw_input('Enter the desired filename: ')
            plt.savefig(saveMedQEPlotname)
        plt.show()
        plt.close()

        status = raw_input("What do you want to do? \nRepeat with different pixels= R or press enter to finish: ")

