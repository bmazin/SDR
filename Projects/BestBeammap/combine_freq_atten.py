import numpy as np

def getList(file):
    posList= np.recfromtxt(file)
    l = [posList['f0'],posList['f2'],posList['f3']]    
    attens = posList['f1']
    l = np.array(l)
    l = l.T 
    names = posList['f4']
    return l,names


def getSwapList(file):
    posList= np.recfromtxt(file,usecols=(0,1,2,3,4))
    l = [posList['f1'],posList['f2'],posList['f3']]    
    l = np.array(l)
    l = l.T 
    oldNames = posList['f0']
    newNames = posList['f4']
    return l,oldNames,newNames

left,leftNames = getList('freq_atten_x_y_palleft.txt')
swap,swapOldNames,swapNewNames = getSwapList('swap_format.txt')

fid = open('doubles.txt')
for line in fid:
    iName = 0
    while iName < len(leftNames):
        if leftNames[iName][1:-1] == line[0:-1]:
            print 'delete double',leftNames[iName]
            leftNames=np.delete(leftNames,iName,0)
            left=np.delete(left,iName,0)
        else:
            iName += 1

iName = 0
while iName < len(leftNames):
    name = leftNames[iName]
    iRoach = int(name[2])
    iPixel = int(name.split('p')[1][0:-1])
    if iRoach == 0 and iPixel == 91:
        print 'delete r0p91'
        print leftNames[iName-2:iName+3]
        leftNames=np.delete(leftNames,iName,0)
        print leftNames[iName-2:iName+3]
        left=np.delete(left,iName,0)
    elif iRoach == 0 and iPixel > 91:
        iPixel -= 1
        print 'decrement r0p>91'
        print leftNames[iName-2:iName+3]
        leftNames[iName] = '/r%d/p%d/'%(iRoach,iPixel)
        print leftNames[iName-2:iName+3]
        iName += 1
    elif iRoach == 1 and iPixel >= 91:
        iPixel += 1
        print 'increment r1p>=91'
        print leftNames[iName-2:iName+3]
        leftNames[iName] = '/r%d/p%d/'%(iRoach,iPixel)
        print leftNames[iName-2:iName+3]
        iName += 1
    elif iRoach == 7 and iPixel == 131:
        print 'delete r7p131'
        print leftNames[iName-2:iName+3]
        leftNames=np.delete(leftNames,iName,0)
        print leftNames[iName-2:iName+3]
        left=np.delete(left,iName,0)
    elif iRoach == 7 and iPixel > 131:
        iPixel -= 1
        print 'decrement r7p>131'
        print leftNames[iName-2:iName+3]
        leftNames[iName] = '/r%d/p%d/'%(iRoach,iPixel)
        print leftNames[iName-2:iName+3]
        iName += 1
    else:
        iName += 1

print left
for iNew,newName in enumerate(swapNewNames):
    found = 0
    for iLeft,leftName in enumerate(leftNames):
        if newName == leftName:
            found = 1
            left[iLeft] = swap[iNew]
    if found == 0:
        left = np.vstack([left,swap[iNew]])
        leftNames=np.array(leftNames.tolist()+[newName])
        print 'appending',newName

fid = open('freq_atten_x_y_swap2.txt','w')
for iName,name in enumerate(leftNames):
    fid.write('%f\t%f\t%f\t%f\t%s\n'%(left[iName,0],0.0,left[iName,1],left[iName,2],name))

        
