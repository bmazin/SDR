#!/bin/python
import select
import subprocess
import sys
import time


def heardEnter():
    i,o,e = select.select([sys.stdin],[],[],0.0001)
    for s in i:
        if s == sys.stdin:
            input = sys.stdin.readline()
            return True
    return False

if len(sys.argv) != 2 or int(sys.argv[1]) <= 0:
    print "Usage: %s timeIntervalInSec"%sys.argv[0]
    exit(1)
sleepInterval = int(sys.argv[1])
while heardEnter() == False:
    for iRoach in xrange(8):
        subprocess.Popen('python flashOne.py %d'%iRoach,shell=True)
    time.sleep(sleepInterval)
    print "Hit enter to quit:"
