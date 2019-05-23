from mkidreadout.channelizer.Roach2Controls import Roach2Controls
import numpy as np
import time
import sys
import matplotlib.pyplot as plt
import mkidreadout.channelizer.binTools as bt

if __name__=='__main__':
    roachNum = str(sys.argv[1])
    ip = '10.0.0.'+roachNum
    roach = Roach2Controls(ip)
    roach.connect()

    nIters = 500
    sampRate = 0.05

    tsFig = plt.figure()
    tsPlt = tsFig.add_subplot(111)
    tsPlt.set_title('Timestamps')

    rawPPSFig = plt.figure()
    rawPPSPlt = rawPPSFig.add_subplot(111)
    rawPPSPlt.set_title('Raw PPS')
    
    nMissPPSFig = plt.figure()
    nMissPPSPlt = nMissPPSFig.add_subplot(111)
    nMissPPSPlt.set_title('N Miss PPS')

    shortGapFig = plt.figure()
    shortGapPlt = shortGapFig.add_subplot(111)

    ts0List = np.zeros(nIters)
    ts1List = np.zeros(nIters)
    ts2List = np.zeros(nIters)
    ts3List = np.zeros(nIters)

    rawPPSList = np.zeros(nIters)
    nMissPPSList = np.zeros(nIters)

    shortGapList = np.zeros(nIters)

    for i in range(nIters):
        startIterTime = time.time()
        ts3 = roach.fpga.read_int('adc_in_ts3')
        ts2 = roach.fpga.read_int('adc_in_ts2')
        ts1 = roach.fpga.read_int('adc_in_ts1')
        ts0 = roach.fpga.read_int('adc_in_ts0')
        
        ts2 = bt.castBin(ts2, 32, 0)
        ts3 = bt.castBin(ts3, 32, 0)
        ts1 = bt.castBin(ts1, 32, 0)
        ts0 = bt.castBin(ts0, 32, 0)

        ts0List[i] = ts0
        ts1List[i] = ts1
        ts2List[i] = ts2
        ts3List[i] = ts3

        nMissPPSList[i] = roach.fpga.read_int('adc_in_n_miss_pps')
        timeGap32 = bt.castBin(ts3-ts2, 32, 0)
        timeGap21 = bt.castBin(ts2-ts1, 32, 0)
        timeGap10 = bt.castBin(ts1-ts0, 32, 0)
        print 'timegap21', timeGap21
        print 'timegap32', timeGap32
        print 'nMissPPS', nMissPPSList[i]
        print ''
        shortGapList[i] = timeGap32
        # print 'ts3', ts3
        # print 'ts2', ts2
        # print 'ts1', ts1
        # print 'ts0', ts0
        # print 'nMissPPS', nMissPPSList[i] 
        
        rawPPS = roach.fpga.read_int('adc_in_raw_pps')
        rawPPSList[i] = rawPPS
        # print 'rawPPS', rawPPS

        iterTime = time.time()-startIterTime

        if(iterTime<sampRate):
            time.sleep(sampRate-iterTime)
    
    tsPlt.plot(ts0List, label='ts0')
    tsPlt.plot(ts1List, label='ts1')
    tsPlt.plot(ts2List, label='ts2')
    tsPlt.plot(ts3List, label='ts3')
    tsPlt.legend()

    rawPPSPlt.plot(rawPPSList)
    nMissPPSPlt.plot(nMissPPSList)
    shortGapPlt.plot(shortGapList)
    plt.show()

            
