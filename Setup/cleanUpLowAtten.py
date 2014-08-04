import os
import numpy
import pylab as plt
import sys
#import matplotlib.mlab as mlab
#import matplotlib.pyplot as plt

#with open('~data/20120812adr/FL1-ps_freq0.txt', 'r') as f:

if len(sys.argv) != 2:
    print 'Usage: ',sys.argv[0],' zero-based roachNum'
    exit(1)
roachNum = int(sys.argv[1])

#path='/home/sean/data/sci4alpha/'
path = os.environ['MKID_DATA_DIR']
filename = 'ps_freq%d'%roachNum
outfilename = filename + '-old'


os.rename(os.path.join(path,filename+'.txt'),os.path.join(path,outfilename+'.txt'))

numBin=20

data=numpy.loadtxt(os.path.join(path,outfilename+'.txt'))
print data[1:,3]
print 'median: ', numpy.median(data[1:,3])
avg=numpy.mean(data[1:,3])
print 'average is: ', avg
print 'min is: ', min(data[1:,3])
sig=numpy.std(data[1:,3])
print 'standard deviation: ',sig

h=plt.hist(data[1:,3],bins=numBin)

plt.xlabel('Attenuations')
plt.ylabel('Number')
plt.title('title')

#plt.ion()
#plt.draw()

plt.show()

newData=data[1:,3]
minAtten=input('Input min Attenuation: ')

for i in range(len(newData)):
    if newData[i] < minAtten:
        #print newData[i]
        newData[i]=minAtten

print newData
h2=plt.hist(newData,bins=numBin)

#plt.draw()
plt.show()
#enter=input('Press any key to continue...')


data[1:,3]=newData
#numpy.savetxt(path+outfilename+'txt',data,delimiter='/t')

outFn = os.path.join(path,filename+'.txt') 
print "save final answers to outFn=",outFn
f=open(outFn,'w')
f.write('\n\n')
for i in range(len(data[1:,3])):
    #f.write(str((data[i,0],'\t',data[i,1],'\t',data[i,2],'\t',data[i,3])))
    f.write(str(data[i,0]))
    f.write('\t')
    f.write(str(int(data[i,1])))
    f.write('\t')
    f.write(str(int(data[i,2])))
    f.write('\t')
    f.write(str(int(data[i,3])))
    f.write('\n')



f.close()
p=plt.show()

#numpy.savetxt('testReaddata.txt',[[4,2,3,4],[8,6,7,8],[29,23,25,27]],fmt=['%f','%d','%d','%d'],delimiter='\t')
