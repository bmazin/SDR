import numpy as np
import matplotlib.pyplot as plt
from arrayPopup import plotArray
import os

basePath = '/mnt/data0/Darkness/20160721/'
if __name__=='__main__':
    labels = ['fl1 neg','fl2 neg','fl3 neg']
    feedlines = [1,2,3]

    filenames = ['beamlist_FL1_neg.txt','beamlist_FL2_neg.txt','beamlist_FL3_neg.txt']
    colors = ['blue','cyan','red','darkred','darkblue','green','magenta']
    yOffsets = [0,25,50]

    nRows = 75
    nCols = 80
    grid = np.zeros((nRows,nCols))
    overlaps = []
    gridDicts = []
    locationData = []
    for iLabel,(label,filename) in enumerate(zip(labels,filenames)):
        locationData.append(np.loadtxt(os.path.join(basePath,filename)))

    fig,ax = plt.subplots(1,1)
    for iLabel,(label,filename) in enumerate(zip(labels,filenames)):
        segmentLocationData = locationData[iLabel]
        yOffset = yOffsets[iLabel]
        xs = np.floor(segmentLocationData[:,2])
        ys = np.floor(segmentLocationData[:,3]) + yOffset
        preciseXs = segmentLocationData[:,2]
        preciseYs = segmentLocationData[:,3]
        ax.scatter(xs,ys,label=label,color=colors[iLabel])
        for (x,y) in zip(xs,ys):
            if 0 <= x and x < nCols and 0 <= y and y < nRows:
                if grid[y,x] != 0:
                    grid[y,x] = 10
                else:
                    grid[y,x] += iLabel+1
    ax.legend(loc='best')
    ylims = ax.get_ylim()
    ax.set_ylim(ylims[1],ylims[0])

    plotArray(grid,origin='upper')

    #now try to clean up overlapping pixels
    for iLabel,(label,filename) in enumerate(zip(labels,filenames)):
        print iLabel
        yOffset = yOffsets[iLabel]
        resIds = locationData[iLabel][:,0]
        failedBeammaps = locationData[iLabel][:,1]
        xs = np.floor(locationData[iLabel][:,2])
        ys = np.floor(locationData[iLabel][:,3]) + yOffset
        ys[xs==-1] = -1
        preciseXs = locationData[iLabel][:,2]
        preciseYs = locationData[iLabel][:,3]
        for i in range(len(locationData[iLabel])):
            resId = resIds[i]
            distVector = (preciseXs[i]-(xs[i]+.5),preciseYs[i]-(ys[i]+.5))
            distMag = np.sqrt(distVector[0]**2 + distVector[1]**2)
            gridDicts.append({'x':xs[i],'y':ys[i],'preciseX':preciseXs[i],'preciseY':preciseYs[i],'distMag':distMag,'segment':iLabel,'resId':resId})

    gridDicts = np.array(gridDicts)

    for entry in gridDicts:
        x = entry['x']
        y = entry['y']
        if x != -1 and y != -1:
            overlapItems = [(item,k) for (k,item) in enumerate(gridDicts) if (item['x'] == entry['x'] and item['y'] == entry['y'])]
            overlapItems,gridIndices = zip(*overlapItems) #unzip
            nPixelsAssigned = len(overlapItems)
            if nPixelsAssigned > 1:
                closestPixelIndex = np.argmin([item['distMag'] for item in overlapItems])
                print nPixelsAssigned, 'pixels assigned to',(x,y)
                for j in range(len(overlapItems)):
                    if j != closestPixelIndex:
                        #print move all the assigned pixels but the closest elsewhere
                        #find the closest open pixel, prefarably in 
                        #the direction the distVector is pointing
                        unassignedCoords = np.where(grid==0)
                        unassignedCoords = zip(unassignedCoords[1],unassignedCoords[0]) #x,y
                        unassignedNeighbors = [coord for coord in unassignedCoords if (np.abs(coord[0]-x)<=1 and np.abs(coord[1]-y)<=1)]

                        try:
                            bestUnassignedNeighbor = np.argmin([np.sqrt((coord[0]+.5-overlapItems[j]['preciseX'])**2 + (coord[1]+.5-overlapItems[j]['preciseY'])**2)])
                            newX = unassignedNeighbors[bestUnassignedNeighbor][0]
                            newY = unassignedNeighbors[bestUnassignedNeighbor][1]
                            print 'best unassigned neighbor',bestUnassignedNeighbor,newX,newY
                            #gridDicts[gridIndices[j]]['x'] = newX
                            #gridDicts[gridIndices[j]]['y'] = newY
                        except IndexError:
                            print 'no neighbor could be found'
                        except:
                            print 'other error'

    plotArray(grid,origin='upper')
    plt.show()
    print 'next'
    newLocationData = np.concatenate(locationData)

    for i in range(len(newLocationData)):
        gridEntry = [item for item in gridDicts if item['resId']==newLocationData[i][0]]
        print newLocationData[i]
        gridEntry = gridEntry[0]
        newLocationData[i,2] = gridEntry['x']
        newLocationData[i,3] = gridEntry['y']
        print newLocationData[i]
        
    np.savetxt('adjusted_beammap.txt',newLocationData,fmt='%d %d %d %d')
    print 'done!'


