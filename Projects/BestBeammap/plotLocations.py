import numpy as np
import matplotlib.pyplot as plt
from arrayPopup import plotArray

basePath = '/mnt/data0/Darkness/20160721/'
if __name__=='__main__':
    labels = ['fl1 neg','fl1 pos','fl2 neg','fl2 pos','fl3 neg','fl3 pos']
    feedlines = [1,1,2,2,3,3]
    paths = ['FL1_neg/Locations_FL1_neg.txt','FL1_pos/Locations_FL1_pos.txt','FL2_neg/Locations_FL2_neg.txt','FL2_pos/Locations_FL2_pos.txt','FL3_neg/Locations_FL3_neg.txt','FL3_pos/Locations_FL3_pos.txt']
    colors = ['cyan','blue','red','darkred','lightgreen','green','magenta']
    yOffsets = [0,0,25,25,50,50]

    nRows = 75
    nCols = 80
    grid = np.zeros((nRows,nCols))
    overlaps = []
    gridDicts = []
    locationData = []
    for iLabel,(label,path) in enumerate(zip(labels,paths)):
        locationData.append(np.loadtxt(path))

    fig,ax = plt.subplots(1,1)
    for iLabel,(label,path) in enumerate(zip(labels,paths)):
        print iLabel
        segmentLocationData = locationData[iLabel]
        yOffset = yOffsets[iLabel]
        xs = np.floor(segmentLocationData[:,1])
        ys = np.floor(segmentLocationData[:,2]) + yOffset
        preciseXs = segmentLocationData[:,1]
        preciseYs = segmentLocationData[:,2]
        ax.scatter(xs,ys,label=label,color=colors[iLabel])
        for (x,y) in zip(xs,ys):
            if 0 <= x and x < nCols and 0 <= y and y < nRows:
                if grid[y,x] != 0:
                    print 'overlap',(x,y),grid[y,x],iLabel+1
                    grid[y,x] = 10
                else:
                    grid[y,x] += iLabel+1
    ax.legend(loc='best')
    ylims = ax.get_ylim()
    ax.set_ylim(ylims[1],ylims[0])

    plotArray(grid,origin='upper')
    plt.show()

