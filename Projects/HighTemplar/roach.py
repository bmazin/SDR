import sys, os, time, random, math, array, fractions
from PyQt4 import QtCore
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from Queue import Queue
#from multiprocessing import Process, Queue
import numpy

class Roach():

    def __init__(self, roachNumber=None):
        self.threadClose = 0
        self.state=-1
        self.nextState=RoachState.connect
        self.status = 1						#1 if okay to execute next command
        self.error = 0                      #error code: 0=okay, 1=error in connection, 2=error in loadFreq
        self.num=int(roachNumber)
        self.commandQueue=Queue()
        #a=self.commandQueue.get()
        #if self.num !=3:
        self.commandQueue.put(RoachState.connect)
#        self.commandQueue.join()    #can't put anything in queue until queue is emptied

        self.freqFile = '/home/sean/data/LICK2012/20120903/ps_freq'+str(self.num)+'.txt'
        self.saveDir = '/home/sean/data/LICK2012/20120903/'
        self.loFreq = 3.57e9
        self.ddsSyncLag = 151
        self.inputAtten = 5
        self.startAtten = 10
        self.stopAtten = 10
        self.loSpan = 0.5e9

        self.freqs = numpy.array([0.0]*256)
        self.attens = numpy.array([0]*256)
        

    def connect(self):
        self.status = 0
        #This is where we would connect

        print str(self.num),' ',
        self.state=RoachState.connect
        #self.status = 1

    def loadFreq(self):
        #print 'loading freq'
        self.status=0
        try:
            #self.freqFile='nothing'
            #x=numpy.loadtxt(self.freqFile)
            #load it
            #freqs=x[:,0]
            #attens = x[:,3]
            #print str(self.num),' ',
            self.state=RoachState.loadFreq
            #self.status = 1
        except IOError:
            print 'Roach',self.num,'unable to find freq file',self.freqFile
            #self.emit(QtCore.SIGNAL("roachError(self.num,self.state)")
            self.error=2

    def defineLUT(self):
        self.status = 0
        try:
            #define lut
            #print str(self.num),' ',
            self.state=RoachState.defineLUT
            #self.status = 1
        except IOError:
            pass

    def sweep(self):
        self.status = 0
        try:
            #sweep()
            #print str(self.num),' ',
            self.state=RoachState.sweep
            #self.status = 1
        except IOError:
            pass

    def rotate(self):
        self.status = 0
        try:
            #rotate()
            print str(self.num),' ',
            self.state=RoachState.rotate
            #self.status = 1
        except IOError:
            pass
       
    def center(self):
        self.status = 0
        try:
            #center
            print str(self.num),' ',
            self.state=RoachState.center
            #self.status = 1
        except IOError:
            pass

    def loadFIR(self):
        self.status = 0
        try:
            #loadFIR()
            print str(self.num),' ',
            self.state=RoachState.loadFIR
            #self.status = 1
        except IOError:
            pass

    def loadThreshold(self):
        self.status = 0
        try:
            #loadThreshold
            print str(self.num),' ',
            self.state=RoachState.loadThreshold
            #self.status = 1
        except IOError:
            pass

    def startThread(self):
        self.emit(QtCore.SIGNAL("startThread()"))
    def closeThread(self,setClosed=0):
        self.threadClose = setClosed
        return self.threadClose
            
    def hasCommand(self):
        #print self.commandQueue.empty()
        return (not self.commandQueue.empty())
    def popCommand(self):
        if not self.commandQueue.empty():
            return self.commandQueue.get()
        else:
            return None
    def pushCommand(self,com):
        self.commandQueue.put(com)
        #self.status = 1
    def emptyCommandQueue(self):
        while not self.commandQueue.empty():
            self.commandQueue.get()


    def getError(self):
        return self.error
    def resetError(self):
        self.error=0

    #def setState(self,newState):
    #    self.state=newState
    def setNextState(self,newState):
        self.nextState = newState
    def getNextState(self):
        return self.nextState
    def getState(self):
        return self.state

    def getNextStatus(self):
        return self.nextStatus
    def setNextStatus(self,newNextStatus):
        self.nextStatus = newNextStatus
    def setStatus(self,newStatus):
        self.status=newStatus
    def getStatus(self):
        #print 'status:',self.status
        return self.status

    def getNum(self):
        return int(self.num)

    def getLoFreq(self):
        return self.loFreq
    def setLoFreq(self, newLoFreq):
        self.loFreq=newLoFreq

    def getFreqFile(self):
        return self.freqFile
    def setFreqFile(self,newFreqFile):
        self.freqFile = newFreqFile

    def getSaveDir(self):
        return self.saveDir
    def setSaveDir(self,newSaveDir):
        self.saveDir = newSaveDir

    def getDdsSyncLag(self):
        return self.ddsSyncLag
    def setDdsSyncLag(self,newDdsSyncLag):
        self.ddsSyncLag = newDdsSyncLag

    def getInputAtten(self):
        return self.inputAtten
    def setInputAtten(self,newInputAtten):
        self.inputAtten = newInputAtten

    def getStartAtten(self):
        return self.startAtten
    def setStartAtten(self,newStartAtten):
        self.startAtten = newStartAtten

    def getStopAtten(self):
        return self.stopAtten
    def setStopAtten(self,newStopAtten):
        self.stopAtten = newStopAtten

    def getLoSpan(self):
        return self.loSpan
    def setLoSpan(self,newLoSpan):
        self.loSpan = newLoSpan

class RoachState(object):
    connect,loadFreq,defineLUT,sweep,rotate,center,loadFIR,loadThreshold = range(8)
    
    @staticmethod
    def parseState(state):
        stateString=['connect','loadFreq','defineLUT','sweep','rotate','center','loadFIR','loadThreshold']
        return stateString[state]
