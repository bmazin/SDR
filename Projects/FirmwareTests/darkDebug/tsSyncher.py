from Roach2Controls import Roach2Controls
import sys, time, os, datetime, calendar
import numpy as np

if __name__=='__main__':
    paramFile='/mnt/data0/neelay/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param'
    timeInterval = float(sys.argv[1])
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
            roachTime = roach.fpga.read_int(timeReg)
            for i in range(int(2./timeInterval)):
                curTime = int(time.time()) - tsOffs
                roachTime = roach.fpga.read_int(timeReg)
                print 'curTime', curTime
                print 'roachTime', roachTime
                if(curTime != roachTime):
                    roach.loadCurTimestamp()
                    print 'Timestamp corrected for Roach', roach.ip
                else:
                    print 'TS correct'
                time.sleep(timeInterval)



