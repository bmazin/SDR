import numpy as np
from matplotlib import pyplot as plt
import tables
import re
import collections
import scipy

def createAccuratefQMatrix(bmaptitle, title1,titlefits1,title2,titlefits2,closefcutoff=3):

    freqs0=np.loadtxt('/home/sean/data/%s0.txt'%title1)
    f0=freqs0[:,0]
    f0=f0[1:]
    freqs1=np.loadtxt('/home/sean/data/%s1.txt'%title1)
    f1=freqs1[:,0]
    f1=f1[1:]
    freqs2=np.loadtxt('/home/sean/data/%s2.txt'%title1)
    f2=freqs2[:,0]
    f2=f2[1:]
    freqs3=np.loadtxt('/home/sean/data/%s3.txt'%title1)
    f3=freqs3[:,0]
    f3=f3[1:]
    FL1fits=np.loadtxt('/home/sean/data/%s'%titlefits1)
    approxf1=FL1fits[:,1]
    QFL1=FL1fits[:,2]
    QiFL1=FL1fits[:,4]

    freqs4=np.loadtxt('/home/sean/data/%s4.txt'%title2)
    f4=freqs4[:,0]
    f4=f4[1:]
    freqs5=np.loadtxt('/home/sean/data/%s5.txt'%title2)
    f5=freqs5[:,0]
    f5=f5[1:]
    freqs6=np.loadtxt('/home/sean/data/%s6.txt'%title2)
    f6=freqs6[:,0]
    f6=f6[1:]
    freqs7=np.loadtxt('/home/sean/data/%s7.txt'%title2)
    f7=freqs7[:,0]
    f7=f7[1:]
    FL2fits=np.loadtxt('/home/sean/data/%s'%titlefits2)
    approxf2=FL2fits[:,1]
    QFL2=FL2fits[:,2]
    QiFL2=FL2fits[:,4]

    accuratefs=[f0,f1,f2,f3,f4,f5,f6,f7]

    accuratefQ=[]
    indexofpickedapproxf1=[]
    indexofpickedapproxf2=[]
    indexOfDelAccuratef=[]
    FL1j=0
    FL2j=0

    for roach in xrange(0,4):
        fQroach=[]
        for pixf in xrange(0,len(accuratefs[roach])):
                foundmatch=0
                i=0
                while foundmatch==0:
                    if FL1j+i+1< len(approxf1):
                        if abs(accuratefs[roach][pixf]-approxf1[FL1j+i]) < closefcutoff:
                            fQroach.append([accuratefs[roach][pixf],QFL1[FL1j+i],QiFL1[FL1j+i]])
                            indexofpickedapproxf1.append(FL1j+i)
                            foundmatch=1
                            FL1j=FL1j+i+1
                        else: 
                            i=i+1
                    else: 
                        foundmatch=1
                        indexOfDelAccuratef.append([roach,pixf])
        accuratefQ.append(fQroach)
    for roach in xrange(4,8):
        fQroach=[]
        for pixf in xrange(0,len(accuratefs[roach])):
                foundmatch=0
                i=0
                while foundmatch==0:
                    if FL2j+i+1< len(approxf2):
                        if abs(accuratefs[roach][pixf]-approxf2[FL2j+i]) < closefcutoff:
                            fQroach.append([accuratefs[roach][pixf],QFL2[FL2j+i],QiFL2[FL2j+i]])
                            indexofpickedapproxf2.append(FL2j+i)
                            foundmatch=1
                            FL2j=FL2j+i+1
                        else: 
                            i=i+1
                    else: 
                        foundmatch=1
                        indexOfDelAccuratef.append([roach,pixf])
        accuratefQ.append(fQroach)
    
    approxfPicked2xFL1=[x for x, y in collections.Counter(indexofpickedapproxf1).items() if y > 1]
    approxfPicked2xFL2=[x for x, y in collections.Counter(indexofpickedapproxf2).items() if y > 1]

    #print indexOfDelAccuratef
    #print len(approxf1),len(f0)+len(f1)+len(f2)+len(f3),len(accuratefQ[0])+len(accuratefQ[1])+len(accuratefQ[2])+len(accuratefQ[3])
    #print len(accuratefQ[0]),len(f0),len(accuratefQ[1]),len(f1),len(accuratefQ[2]),len(f2),len(accuratefQ[3]),len(f3)

    #print len(approxf2),len(f4)+len(f5)+len(f6)+len(f7),len(accuratefQ[4])+len(accuratefQ[5])+len(accuratefQ[6])+len(accuratefQ[7])
    #print len(accuratefQ[4]),len(f4),len(accuratefQ[5]),len(f5),len(accuratefQ[6]),len(f6),len(accuratefQ[7]),len(f7)

    return accuratefQ

    #now have accuratefQ. The rows correspond to the roaches (1st row is r0) and the entries contain the f and Q for that pixel (accuratefQ[0][0]= [f,Q] for r0p0)

def getfQforgoodpix(bmaptitle, title1,titlefits1,title2,titlefits2):

    #title1/2 gives the base of the filename for the frequency files for Feedline 1/2 (Don't include '.txt'). 
    #titlefist1/2 gives the filename of the fits file (include '.txt')
    #bmaptitle gives the filename of the beammap (include '.h5')

    closefcutoff=.0007  #when the program compares the approximate freq in frequency files to the accurate frequency in the fit file, it will accept a difference of the closefcutoff (GHz)

    accuratefQ = createAccuratefQMatrix(bmaptitle, title1,titlefits1,title2,titlefits2,closefcutoff)

    #now have accuratefQ. The rows correspond to the roaches (1st row is r0) and the entries contain the f and Q for that pixel (accuratefQ[0][0]= [f,Q] for r0p0)

    fid=tables.openFile(bmaptitle)
    b=fid.root.beammap.beamimage

    pixlist = []
    for row in xrange(0,46):
        for column in xrange(0,44):
            string=b[row][column]
            a=re.findall(r'\d+',string)
            roachNum=int(a[0])
            pixelNum=int(a[1])
            if roachNum<8:
                if pixelNum < len(accuratefQ[roachNum]):
                    pixlist.append([[roachNum,pixelNum],accuratefQ[roachNum][pixelNum]])

    fid.close()

    pixlist=sorted(pixlist)

    return pixlist

