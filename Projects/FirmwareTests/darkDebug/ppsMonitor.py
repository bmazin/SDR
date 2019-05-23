from mkidreadout.channelizer.Roach2Controls import Roach2Controls
import numpy as np
import time
import sys

if __name__=='__main__':
    roachList = []
    for roachNum in sys.argv[1:]:
        ip = '10.0.0.'+roachNum
        roach = Roach2Controls(ip)
        roach.connect()
        roachList.append(roach)
    
    startTime = time.time()
    nMissPPSList = np.zeros(len(roachList))

    while(True):
        for i,roach in enumerate(roachList):
            nMissPPS = roach.fpga.read_int('adc_in_n_miss_pps')
            if nMissPPS>nMissPPSList[i]:
                print 'ROACH '+roach.ip+' missed '+str(nMissPPS)+' '+str(int(time.time()-startTime))+' seconds since start'
                nMissPPSList[i] = nMissPPS

        time.sleep(1)
            
