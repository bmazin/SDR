import numpy as np
def peaks(y,nsig, m=2, returnDict=False):
    """
    Find the peaks in a vector (spectrum) which lie nsig above the
    standard deviation of all peaks in the spectrum.

    y -- vector in which to locate peaks
    nsig -- number of sigma above the standard deviation of all peaks to search

    return -- vector holding indices of peak locations in y

    Intended to duplicate logic of peaks.pro

    nsig is NOT the number of sigma above the noise in the spectrum. 
    It's instead a measure of the significance of a peak. First, all
    peaks are located. Then the standard deviation of the peaks is 
    calculated using ROBUST_SIGMA (see Goddard routines online). Then
    peaks which are NSIG above the sigma of all peaks are selected.

    """

    print "begin Peaks.peaks with nsig,m=",nsig,m
    d0 = y - np.roll(y,-1)
    d1 = y - np.roll(y,1)
    pk = np.arange(y.size)[np.logical_and(d0>0, d1>0)]
    npk = pk.size
    yp = y[pk]
    # reject outliers more than m=2 sigma from median
    delta = np.abs(yp - np.median(yp))
    mdev = np.median(delta)
    s = delta/mdev if mdev else 0
    ypGood = y[np.where(s<m)] # using a subset of y
    mn = ypGood.mean()
    sig = ypGood.std()
    big = pk[yp > mn + nsig*sig]
    
    #to remove multiple identifications of the same peak (not collisions)
    minPeakDist = 60
    cluster = []
    clusters=[]
    for pks in range(len(big)-1):
        dist = abs(big[pks]-big[pks+1])
        cluster.append(pks)
        if dist > minPeakDist:
            clusters.append(cluster)
            cluster=[]

    indrem=[]
    for c in range(len(clusters)):
        try:
            trueind = np.argmax( y[big[clusters[c]]] )
            falseind = np.where(big[clusters[c]] != big[clusters[c]][trueind])[0]
            indrem = np.concatenate((indrem, np.array(clusters[c])[falseind]))
        except ValueError:
            pass
    big = np.delete(big,indrem)

    if returnDict:
        return {"big":big, "pk":pk, "yp":yp, "m":m}
    else:
        return big
