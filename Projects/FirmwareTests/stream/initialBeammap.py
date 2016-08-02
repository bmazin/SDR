import numpy as np
import matplotlib.pyplot as plt

nRows = 125
nRowsPerFeedline = 25
nCols = 80
nRowsPerSideband = 6
#make a list of sidebands in order of increasing frequency and increasing row number
sidebandLabels = [{'sideband':'neg','boardRange':'a'},{'sideband':'pos','boardRange':'a'},{'sideband':'neg','boardRange':'b'},{'sideband':'pos','boardRange':'b'}]

def xyPack(feedline=1,boardRange='a',sideband='pos',channel=0):
    yFeedlineOffset = (feedline-1)*nRowsPerFeedline
    if sideband == 'neg' and (boardRange == 'a' or boardRange == 'low'):
        ySidebandOffset = 0
    elif sideband == 'pos' and (boardRange == 'a' or boardRange == 'low'):
        ySidebandOffset = nRowsPerSideband
    elif sideband == 'neg' and (boardRange == 'b' or boardRange == 'high'):
        ySidebandOffset = 2*nRowsPerSideband
    elif sideband == 'pos' and (boardRange == 'b' or boardRange == 'high'):
        ySidebandOffset = 3*nRowsPerSideband
    else:
        raise ValueError('boardRange must be a/low or b/high, sideband must be pos or neg')

    yChannelOffset = channel // nCols #for each filled row (containing nCols), wrap to the next row
    y = yChannelOffset + ySidebandOffset + yFeedlineOffset
    x = channel % nCols #x position is remainder after filling rows
    return {'x':x,'y':y,'row':y,'col':x,'feedline':feedline,'sideband':sideband,'boardRange':boardRange,'channel':channel}

def xyUnpack(**kwargs):
    #use kwargs to force use of keywords x,y or row,col to reduce confusion
    #of which goes first
    x = kwargs.get('x',None)
    y = kwargs.get('y',None)
    row = kwargs.get('row',None)
    col = kwargs.get('col',None)
    if (x is None or y is None) and (row is None or col is None):
        raise ValueError('must specify either x,y or row,col')
    if x is None:
        x = col
    if y is None:
        y = row

    feedline = (y // nRowsPerFeedline) + 1
    yFeedlineOffset = (feedline - 1)*nRowsPerFeedline
    yRemainingOffset = y - yFeedlineOffset

    nSidebands = yRemainingOffset // nRowsPerSideband
    ySidebandOffset = nSidebands*nRowsPerSideband

    sidebandDict = sidebandLabels[nSidebands]
    sideband = sidebandDict['sideband']
    boardRange = sidebandDict['boardRange']

    yChannelOffset = yRemainingOffset - ySidebandOffset
    channel = (yChannelOffset * nCols) + x
    return {'x':x,'y':y,'row':y,'col':x,'feedline':feedline,'sideband':sideband,'boardRange':boardRange,'channel':channel}

    

