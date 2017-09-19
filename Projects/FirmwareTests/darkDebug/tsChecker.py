from Roach2Controls import Roach2Controls
import sys, time, os, datetime, calendar
import numpy as np

if __name__=='__main__':
    paramFile='/mnt/data0/neelay/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param'
    timeInterval = sys.argv[1]
    timeReg = 'timekeeper_sec_now'

    roachList = []
    for ip in sys.argv[2:]:
        roachList.append(Roach2Controls('10.0.0.'+str(ip), paramFile, True, False))

    for roach in roachList: 
        roach.connect()

    while True:
        for roach in roachList:
            curYr = datetime.datetime.utcnow().year
            yrStart = datetime.date(curYr, 1, 1)
            tsOffs = calendar.timegm(yrStart.timetuple())
            curTime = int(time.time())- tsOffs
            roachTime = roach.fpga.read_int(timeReg)
            print roachTime
            if not roachTime==curTime: #make sure mismatch is not due to sync issue
                time.sleep(0.3)
                curTime = int(time.time())-tsOffs
                roachTime = roach.fpga.read_int(timeReg)
                print 'one misalignment'
                if not roachTime==curTime:
                    print 'Correcting timestamp for roach', roach.ip
                    roach.loadCurTimestamp()

        time.sleep(float(timeInterval))


