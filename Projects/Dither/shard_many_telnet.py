#!/bin/python
import subprocess
import time

def move(ra,dec):

    commandTemplate ='TELMOVE INSTRUMENT %.2f %.2f SEC_ARC NOWAIT' 
    command = commandTemplate%(ra,dec)

    bashTemplate = '(sleep 1; echo \"%s\") | telnet shard.ucolick.org 2345'# 2> /dev/null > /dev/null'
    bashCommand = bashTemplate%command
    timestamp = time.strftime("%Y%m%d-%H%M%S",time.gmtime())
    print timestamp,command
    subprocess.Popen(bashCommand,shell=True)


def raster(step=1,numX=5,numY=5,integrateTime=20):
    numXSteps = numX-1
    numYSteps = numY-1
    moveTime = 1
    firstX = -numXSteps/2.0*step
    firstY = -numYSteps/2.0*step
    move(firstX,firstY)
    time.sleep(integrateTime)

    for iY in range(numY):
        for iX in range(numXSteps):
            move(step,0)
            time.sleep(integrateTime)
        if iY < numY - 1:
            move(-numXSteps*step,step)

        time.sleep(integrateTime)

    move(firstX,firstY)

    


    

