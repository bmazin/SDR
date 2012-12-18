#!/bin/python
import matplotlib.pyplot as plt
import subprocess
import time
import sys
import socket
import numpy as np
from utils import confirm

class TCS:
    recvSize = 1024

    def move(self,ra,dec,confirmed=False):
        #try:
        commandTemplate = 'PT %.2f %.2f\r'
        command  = commandTemplate%(ra,dec)
        timestamp = time.strftime("%Y%m%d_%H%M%S",time.gmtime())
        self.x += ra
        self.y += dec 
        print command[0:-1]
        print timestamp, self.x,self.y
        self.client.send(command)
        response = self.client.recv(TCS.recvSize)
        #print 'Reply: ',repr(response)
        if confirmed == True:
            while confirm('Is position at %d,%d'%(self.x,self.y),defaultResponse=True) == False:
                self.print_pos()
                self.client.send(command)
                response = self.client.recv(TCS.recvSize)
        #except:

    def print_pos(self):
        self.client.send('REQPOS\r')
        response = self.client.recv(TCS.recvSize)
        print repr(response)
        return response

    def connect(self):
        self.client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        hostname = '198.202.125.194'
        port = 5004
        self.client.connect((hostname,port))
        time.sleep(1)
        print 'Connected'

    def close(self):
        print 'Closing session'
        self.client.close()

    def raster(self,step=1,numX=5,numY=5,integrateTime=20,confirmed=False):
        numXSteps = numX-1
        numYSteps = numY-1
        moveTime = 1 
        firstX = -numXSteps/2.0*step
        firstY = -numYSteps/2.0*step
        self.move(firstX,firstY,confirmed)
        time.sleep(integrateTime)

        for iY in range(numY):
            for iX in range(numXSteps):
                self.move(step,0,confirmed)
                time.sleep(integrateTime)
            if iY < numY - 1:
                self.move(-numXSteps*step,step,confirmed)

            time.sleep(integrateTime)

        self.move(firstX,firstY,confirmed)

    def follow_list(self,xVals,yVals,integrateTime=20,confirmed=False):
        dx = [float('%.2f'%i) for i in np.diff(xVals)]
        dy = [float('%.2f'%i) for i in np.diff(yVals)]
        firstX = float('%.2f'%xVals[0])
        firstY = float('%.2f'%yVals[0])
        x = np.cumsum(dx)+firstX
        y = np.cumsum(dy)+firstY
        lastX = x[-1]
        lastY = y[-1]
        self.move(firstX,firstY,confirmed)
        time.sleep(integrateTime)

        for i in range(len(dx)):
            self.move(dx[i],dy[i],confirmed)
            time.sleep(integrateTime)

        self.move(-lastX,-lastY,confirmed)
                
    
    def lisajous(self,a=5.0,b=1.0,Npoints=100,amp=40.0,integrateTime=20,confirmed=False):
        t = np.linspace(0,2*np.pi,Npoints)
        x = amp/2.0*np.cos(a*t)
        y = amp/2.0*np.sin(b*t)
        fig = plt.figure()
        ax = fig.add_subplot(111)
        ax.plot(x,y,'.')
        plt.show()
        self.follow_list(x,y,integrateTime,confirmed)


    def __init__(self):
        self.connect()
        self.x = 0 
        self.y = 0 

    def __del__(self):
        self.close()
