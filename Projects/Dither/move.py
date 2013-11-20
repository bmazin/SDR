#!/bin/python
import subprocess
import time

def move(ra,dec):

    commandTemplate ='TELMOVE INSTRUMENT %.2f %.2f SEC_ARC NOWAIT' 
    command = commandTemplate%(ra,dec)

    bashTemplate = '(sleep .5; echo \"%s\") | telnet shard.ucolick.org 2345'
    bashCommand = bashTemplate%command
    timestamp = time.strftime("%Y%m%d-%H%M%S",time.gmtime())
    print timestamp,command
    #subprocess.Popen(bashCommand,shell=True)

    #self.write(command)

def raster(step,numX,numY):
    numXSteps = numX-1
    numYSteps = numY-1
    for iY in range(numYSteps):
        for iX in range(numXSteps):
            move(step,0)
        move(-numXSteps*step,step)

    


    

