import numpy as np
import matplotlib.pyplot as plt
from arrayPopup import plotArray
import os

basePath = '/mnt/data0/Darkness/20160721/'
psBasePath = '/mnt/data0/Darkness/20160722/'
if __name__=='__main__':
    labels = ['fl1 neg','fl1 pos','fl2 neg','fl2 pos','fl3 neg','fl3 pos']
    feedlines = [1,1,2,2,3,3]
    paths = ['beamlist_FL1_neg.txt','beamlist_FL1_pos.txt','beamlist_FL2_neg.txt','beamlist_FL2_pos.txt','beamlist_FL3_neg.txt','beamlist_FL3_pos.txt']
    psAPaths = ['ps_FL1_a_full.txt','ps_FL1_a_full.txt','ps_FL2_a_full.txt','ps_FL2_a_full.txt','ps_FL3_a_full.txt','ps_FL3_a_full.txt']
    psBPaths = ['ps_FL1_b_full.txt','ps_FL1_b_full.txt','ps_FL2_b_full.txt','ps_FL2_b_full.txt','ps_FL3_b_full.txt','ps_FL3_b_full.txt']
    colors = ['cyan','blue','red','darkred','lightgreen','green','magenta']
    yOffsets = [0,0,25,25,50,50]

    nRows = 75
    nCols = 80
    grid = np.zeros((nRows,nCols))
    grid2 = np.zeros((nRows,nCols))
    overlaps = []
    gridDicts = []
    locationData = []
    freqData = []
    for iLabel,(label,path) in enumerate(zip(labels,paths)):
        locationData.append(np.loadtxt(os.path.join(basePath,path)))
        aPath = os.path.join(psBasePath,psAPaths[iLabel])
        freqDataA = np.loadtxt(aPath)
        bPath = os.path.join(psBasePath,psBPaths[iLabel])
        freqDataB = np.loadtxt(bPath)
        freqData.append(np.concatenate([freqDataA,freqDataB]))

    fig,ax = plt.subplots(1,1)
    fig2,ax2 = plt.subplots(1,1)
    for iLabel,(label,path) in enumerate(zip(labels,paths)):
        print iLabel
        segmentLocationData = locationData[iLabel]

        yOffset = yOffsets[iLabel]
        resIds = segmentLocationData[:,0]
        fails = np.array(segmentLocationData[:,1],dtype=np.bool)
        xs = np.floor(segmentLocationData[:,2])
        ys = np.floor(segmentLocationData[:,3]) + yOffset
        preciseXs = segmentLocationData[:,2]
        preciseYs = segmentLocationData[:,3]
        goodMask = (~fails) & (xs != -1) & (ys != -1)
        keepMask = np.array([(resId in freqData[iLabel][:,0]) for resId in resIds],dtype=np.bool)
        keepMask = keepMask & goodMask

        ax.scatter(xs[goodMask],ys[goodMask],label=label,color=colors[iLabel])
        ax2.scatter(xs[keepMask],ys[keepMask],label=label,color=colors[iLabel])
        for (x,y) in zip(xs[goodMask],ys[goodMask]):
            if 0 <= x and x < nCols and 0 <= y and y < nRows:
                if grid[y,x] != 0:
                    grid[y,x] = 10
                else:
                    grid[y,x] += iLabel+1
        for (x,y) in zip(xs[keepMask],ys[keepMask]):
            if 0 <= x and x < nCols and 0 <= y and y < nRows:
                if grid2[y,x] != 0:
                    grid2[y,x] = 10
                else:
                    grid2[y,x] += iLabel+1
    ax.legend(loc='best')
    ylims = ax.get_ylim()
    ylims2 = ax2.get_ylim()
    #reverse the y direction so (0,0) is top left corner
    ax.set_ylim(ylims[1],ylims[0])
    ax2.set_ylim(ylims2[1],ylims2[0])

    plotArray(grid,origin='upper')
    plotArray(grid2,origin='upper')
    plt.show()

