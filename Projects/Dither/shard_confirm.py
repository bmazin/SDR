#!/bin/python
import subprocess
import time
from confirm import confirm

class Shard:
    def move(self,ra,dec):

        commandTemplate ='TELMOVE INSTRUMENT %.2f %.2f SEC_ARC NOWAIT' 
        command = commandTemplate%(ra,dec)

        bashTemplate = '(sleep 1; echo \"%s\") | telnet shard.ucolick.org 2345 2> /dev/null > /dev/null'
        bashCommand = bashTemplate%command
        timestamp = time.strftime("%Y%m%d-%H%M%S",time.gmtime())
        print timestamp,command
        subprocess.Popen(bashCommand,shell=True)


    def confirmed_move(self,ra,dec):
        self.x += ra
        self.y += dec
        self.move(ra,dec)
        while confirm('Is position at %d,%d'%(self.x,self.y),resp=True) == False:
            self.move(ra,dec)

    def raster(self,step=1,numX=5,numY=5,integrateTime=20):
        numXSteps = numX-1
        numYSteps = numY-1
        moveTime = 1
        firstX = -numXSteps/2.0*step
        firstY = -numYSteps/2.0*step
        print 'Starting at ',self.x,self.y
        self.confirmed_move(firstX,firstY)
        time.sleep(integrateTime)
        x = 0
        y = 0

        for iY in range(numY):
            for iX in range(numXSteps):
                self.confirmed_move(step,0)
                time.sleep(integrateTime)
            if iY < numY - 1:
                self.confirmed_move(-numXSteps*step,step)

            time.sleep(integrateTime)

        self.confirmed_move(firstX,firstY)
    def __init__(self):
        self.x = 0
        self.y = 0

    


    

