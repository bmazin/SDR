import numpy as np
import scipy

sqDimOpt=10

binaryPixArray=scipy.random.random((46,44))
binaryPixArray=np.around(binaryPixArray)


yvariation=int((46-sqDimOpt)/2)
xvariation=int((44-sqDimOpt)/2)

binaryPixArray=np.array(binaryPixArray)
impSection=binaryPixArray[yvariation:(46-yvariation),xvariation:(44-xvariation)]
percentgood=np.sum(impSection)/(sqDimOpt**2.)

resultPercent=[]
for j in xrange(-xvariation,xvariation+1):
    for i in xrange(-yvariation, yvariation+1):
        ditherArray=np.array([[None for col in range(sqDimOpt)] for row in range(sqDimOpt)])
        for row in xrange(0, sqDimOpt):
            for column in xrange(0, sqDimOpt):
                ditherArray[row,column]=binaryPixArray[row+yvariation,column+xvariation]+binaryPixArray[(row+yvariation),(column+xvariation+j)]+binaryPixArray[(row+yvariation+i),(column+xvariation)]+binaryPixArray[(row+yvariation+i),(column+xvariation+j)]
        resultPercent.append([sum(sum(1 for i in row if i>0) for row in ditherArray)/(sqDimOpt**2.),i,j])
resultPercent=sorted(resultPercent)

i=resultPercent[len(resultPercent)-1][1]
j=resultPercent[len(resultPercent)-1][2]
ditherArray=np.array([[None for col in range(sqDimOpt)] for row in range(sqDimOpt)])
for row in xrange(0, sqDimOpt):
    for column in xrange(0, sqDimOpt):
        ditherArray[row,column]=binaryPixArray[row+yvariation,column+xvariation]+binaryPixArray[(row+yvariation),(column+xvariation+j)]+binaryPixArray[(row+yvariation+i),(column+xvariation)]+binaryPixArray[(row+yvariation+i),(column+xvariation+j)]
finalresultPercent=sum(sum(1 for i in row if i>0) for row in ditherArray)/(sqDimOpt**2.)
print impSection
print ditherArray

print 'Considering the middle %dx%d pixels'%(impSection.shape[0],impSection.shape[1])
print 'The percent of working pixels initially is %f'%percentgood
print 'The percent with 4 dithers in rect. formation is %f'%finalresultPercent
print 'best dither position: up %d rows and %d columns to the right'%(i,j)

