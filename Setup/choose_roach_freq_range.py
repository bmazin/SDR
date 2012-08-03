import numpy as np
import pylab as plt

table = np.loadtxt('20120611adr-FL2-ws.txt')


freqs = table[:,2]
freqs.sort()
fig = plt.figure()
ax=fig.add_subplot(111)

lo=freqs.min()
hi=freqs.max()
print len(freqs)
print freqs.min()
print freqs.min()+0.512
print freqs.max()-0.512
print freqs.max()

freq1=freqs[freqs<(lo+0.512)]
print len(freq1)
freq2=freqs[freqs>(lo+0.612)]
freq2=freq2[freq2<(lo+0.612+0.512)]
print len(freq2)

freq3=freqs[freqs>(lo+0.512)]
freq3=freq3[np.logical_or(freq3<(lo+0.612),freq3>(lo+0.612+0.512))]
print len(freq3)

ax.hist(freq1,bins=20,color='red')
ax.hist(freq2,bins=20,color='blue')
ax.hist(freq3,bins=40,color='green')

plt.show()
table1=np.zeros((len(freq1)+1,4))
table1[0,:]=np.ones((1,4))
table1[1:,0]=freq1
table1[1:,3]=[1]*len(freq1)
print table1[0:5,:]
table2=np.zeros((len(freq2)+1,4))
table2[0,:]=np.ones((1,4))
table2[1:,0]=freq2
table2[1:,3]=[1]*len(freq2)
print table2[0:5,:]

f1 = open('freq_list2.txt','w')
f1.write('1\t1\t1\t1\n')
for f in freq1:
	f1.write('%.5f\t0\t0\t1\n'%f)

f1.close()

f2 = open('freq_list3.txt','w')
f2.write('1\t1\t1\t1\n')
for f in freq2:
	f2.write('%.5f\t0\t0\t1\n'%f)

f2.close()


