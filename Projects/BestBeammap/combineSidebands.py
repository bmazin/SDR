import numpy as np
import matplotlib.pyplot as plt
import os

basePath = '/mnt/data0/Darkness/20160721/'

negFilenames = ['ps_FL1_a_neg.txt','ps_FL1_b_neg.txt','ps_FL2_a_neg.txt','ps_FL2_b_neg.txt','ps_FL3_a_neg.txt','ps_FL3_b_neg.txt']
posFilenames = ['ps_FL1_a_pos.txt','ps_FL1_b_pos.txt','ps_FL2_a_pos.txt','ps_FL2_b_pos.txt','ps_FL3_a_pos.txt','ps_FL3_b_pos.txt']
loFreqs = [5.1364336e9,7.3371334e9,5.2588296e9,7.4592113e9,5.3937650e9,7.6962461e9]

for iRoach in range(len(negFilenames)):
    psNeg = np.loadtxt(os.path.join(basePath,negFilenames[iRoach]))
    psPos = np.loadtxt(os.path.join(basePath,posFilenames[iRoach]))
    loFreq = loFreqs[iRoach]

    negFreqs = loFreq - psNeg[:,1]
    posFreqs = psPos[:,1] - loFreq

    negDiff = np.abs(np.diff(negFreqs))
    print np.min(negDiff)
    posDiff = np.abs(np.diff(posFreqs))
    print np.min(posFreqs)

    keepIndices = []
    for iPosFreq,posFreq in enumerate(posFreqs):
        closestNegIndex = np.argmin(np.abs(posFreq-negFreqs))
        closestNegFreq = negFreqs[closestNegIndex]
        dist = np.abs(posFreq-closestNegFreq)
        if dist < 500.e3: #500 kHz, IQ lpfs are set to 250 kHz
            keepIndices.append(iPosFreq)

    print 'keep ',len(keepIndices), ' of ',len(posFreqs), 100.*len(keepIndices)/len(posFreqs)

    keepPsPos = psPos[keepIndices]
    newPs = np.concatenate([psNeg,keepPsPos])
    splitFilename = negFilenames[iRoach].split('neg')
    newFilename = splitFilename[0]+'full'+splitFilename[1]
    np.savetxt(newFilename,newPs,fmt = '%d\t%.9e\t%d')

    
plt.show()

