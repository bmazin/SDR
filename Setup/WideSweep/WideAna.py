"""
A replacement for WideAna.pro for those who prefer python to idl.

Usage:  python WideAna.py test/ucsb_100mK_24db_1.txt 

Read the input file.

Interactively add and remove resonance locations.

Create file that plot dB vs frequency, in panels that are 0.15 GHz
wide if it does not exist. This file is the base input file name with
-good.ps appended.

Create file of resonance positions.
This file is the base input file name with -good.txt appended.
This file contains one line for each resonance, with the columns:
  -- id number (sequential from 0)
  -- index of the wavelength in the input file
  -- frequency in GHz

If this file already exists when the program starts, it is moved to
the same file name with at date and time string appended, and a new
copy is made with all found resonances.  The file is updated each time
a line is added or subtracted.

Matt Strader
Chris Stoughton
"""
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4 import QtGui
import matplotlib.pyplot as plt
import numpy as np
import sys, os, time, shutil
from multiprocessing import Process
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
import matplotlib
from functools import partial
from scipy import signal
from scipy.signal import filter_design as fd
from scipy.interpolate import UnivariateSpline
import Peaks as Peaks
from WideAnaFile import WideAnaFile

class WideAna(QMainWindow):
    def __init__(self, parent=None,plotFunc=None,title='',separateProcess=False, image=None,showMe=True, initialFile=None):
        self.parent = parent
        if self.parent == None:
            self.app = QApplication([])
        super(WideAna,self).__init__(parent)
        self.fitParams = { "filter":{"order":4,"rs":40,"wn":0.1},
                           'spline':{"splineS":1,"splineK":3}}
        self.initialFile = initialFile
        self.baseFile = ('.').join(initialFile.split('.')[:-1])
        self.goodFile = self.baseFile+"-good.txt"
        if os.path.exists(self.goodFile):
            shutil.copy(self.goodFile,
                        self.goodFile+time.strftime("-%Y-%m-%d-%H-%M-%S"))
        self.pdfFile = self.baseFile+"-good.pdf"
        self.fitLineEdits = {}
        self.fitLabels = {}
        self.splineS = 1
        self.splineK = 3
        self.setWindowTitle(title)
        self.plotFunc = plotFunc
        self.create_main_frame(title)
        if plotFunc != None:
            plotFunc(fig=self.fig,axes=self.axes)
        if showMe == True:
            self.show()
        self.segment = 0
        self.segmentMax = 80
        self.load_file(initialFile)
        # make the PDF file

        if not os.path.exists(self.pdfFile):
            print "Create overview PDF file:",self.pdfFile
            self.waf.createPdf(self.pdfFile)
        else:
            print "Overview PDF file already on disk:",self.pdfFile
        # plot the first segment
        self.calcXminXmax()
        self.plotSegment()
        print "Ready to add and delete peaks."

    def draw(self):
        self.fig.canvas.draw()

    def on_key_press(self,event):
        if event.key == "right":
            self.segmentIncrement(None,0.1)
            return
        elif event.key == "left":
            self.segmentDecrement(None,0.1)
            return
        elif event.key == "up":
            self.zoom(1.25)
            return
        elif event.key == "down":
            self.zoom(0.8)
            return
        self.on_key_or_button(event, event.key)

    def on_button_press(self,event):
        self.on_key_or_button(event,event.button)


    def on_key_or_button(self, event, pressed):
        xdata = getattr(event, 'xdata', None)
        if xdata is not None:
            ind = np.searchsorted(self.waf.x, xdata)
            xFound = self.waf.x[ind]
            indPk = np.searchsorted(self.waf.pk, ind)
            xPkFound0 = self.waf.x[self.waf.pk[indPk-1]]
            xPkFound1 = self.waf.x[self.waf.pk[indPk]]
            if abs(xPkFound0-xdata) < abs(xPkFound1-xdata):
                bestIndex = indPk-1
            else:
                bestIndex = indPk
            bestWafIndex = self.waf.pk[bestIndex]
            bestX = self.waf.x[bestWafIndex]
            if pressed == 3 or pressed == "d":
                if self.peakMask[bestWafIndex]:
                    self.peakMask[bestWafIndex] = False
                    self.setCountLabel()
                    self.replot()
                    self.writeToGoodFile()

            if pressed == 1 or pressed == "a":
                if not self.peakMask[bestWafIndex]:
                    self.peakMask[bestWafIndex] = True
                    self.setCountLabel()
                    self.replot()
                    self.writeToGoodFile()

    def replot(self):
            xlim = self.axes.set_xlim()
            self.xmin=xlim[0]
            self.xmax=xlim[1]
            self.plotSegment()

    def create_main_frame(self,title):
        self.main_frame = QWidget()

      # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((7, 5), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.canvas.setFocusPolicy(Qt.StrongFocus)
        self.canvas.setFocus()

        self.axes = self.fig.add_subplot(111)
        self.fig.canvas.mpl_connect('key_press_event',self.on_key_press)
        self.fig.canvas.mpl_connect('button_press_event',self.on_button_press)
        # Create the segment slider
        self.segmentSlider = QtGui.QSlider(Qt.Horizontal, self)
        self.segmentSlider.setToolTip("Slide to change segment")
        self.segmentSlider.setRange(0,800)
        self.segmentSlider.setFocusPolicy(Qt.NoFocus)
        self.segmentSlider.setGeometry(30,40,100,30)
        self.segmentSlider.valueChanged[int].connect(self.changeSegmentValue)

        # Create the left and right buttons
        segmentDecrement = QtGui.QPushButton('<',self)
        segmentDecrement.setToolTip("Back to previous segment")
        segmentDecrement.clicked[bool].connect(self.segmentDecrement)
        segmentIncrement = QtGui.QPushButton('>',self)
        segmentIncrement.setToolTip("Forward to next segment")
        segmentIncrement.clicked[bool].connect(self.segmentIncrement)

        # create display mode button
        self.yDisplay = QtGui.QPushButton("raw")
        self.yDisplay.setToolTip("Toggle y axis: raw data or difference=raw-baseline") 
        self.yDisplay.setCheckable(True)
        self.yDisplay.clicked[bool].connect(self.yDisplayClicked)

        # create information boxes
        self.instructionsLabel = QtGui.QLabel()
        self.instructionsLabel.setText("ADD peak:  left click or a;  DELETE peak:  right click or d")
        self.countLabel = QtGui.QLabel()
        self.countLabel.setText("count label")

        self.inputLabel = QtGui.QLabel()
        self.inputLabel.setText("Input File:%s"%self.initialFile)

        self.goodLabel = QtGui.QLabel()
        self.goodLabel.setText("Good File:%s"%self.goodFile)

        # create controls for baseline fitting
        #self.baseline = QtGui.QPushButton("filter")
        #self.baseline.setCheckable(True)
        #self.baseline.clicked[bool].connect(self.baselineClicked)


        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)

        # Do the layout

        # segment box
        segmentBox = QHBoxLayout()
        segmentBox.addWidget(segmentDecrement)
        segmentBox.addWidget(self.segmentSlider)
        segmentBox.addWidget(segmentIncrement)
        segmentBox.addWidget(self.yDisplay)

        # baseline box
        #self.baselineBox = QHBoxLayout()
        #self.updateBaselineBox()

        # info box
        self.infoBox = QVBoxLayout()
        self.infoBox.addWidget(self.inputLabel)
        self.infoBox.addWidget(self.goodLabel)
        self.infoBox.addWidget(self.countLabel)
        self.infoBox.addWidget(self.instructionsLabel)
        # entire box
        vbox = QVBoxLayout()
        vbox.addLayout(self.infoBox)
        vbox.addLayout(segmentBox)
        #vbox.addLayout(self.baselineBox)
        vbox.addWidget(self.canvas)
        vbox.addWidget(self.mpl_toolbar)

        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)
        

    def updateBaselineBox(self):
        for i in range(self.baselineBox.count()):
            print "now remove i=",i
            item = self.baselineBox.itemAt(i)
            self.baselineBox.removeItem(item)
        mode = str(self.baseline.text())
        print "mode=",mode
        self.baseline.setFixedSize(70,40)
        self.baselineBox.addWidget(self.baseline)
        keys = self.fitParams[mode]

    def load_file(self, fileName):
        self.waf = WideAnaFile(fileName)
        #self.waf.fitSpline(splineS=1.0, splineK=1)
        self.waf.fitFilter(wn=0.01)
        self.waf.findPeaks(m=2)
        self.peakMask = np.zeros(len(self.waf.x),dtype=np.bool)
        self.peakMask[self.waf.peaks] = True
        self.xDomain = (self.waf.x[-1]-self.waf.x[0])/self.segmentMax
        self.setCountLabel()
        self.writeToGoodFile()

    def setCountLabel(self):
        self.countLabel.setText("Number of peaks = %d"%self.peakMask.sum())

    def writeToGoodFile(self):
        gf = open(self.goodFile,'wb')
        id = 0
        for index in range(len(self.peakMask)):
            if self.peakMask[index]:
                line = "%8d %12d %16.7f\n"%(id,index,self.waf.x[index])
                gf.write(line)
                id += 1
        gf.close()

    # deal with zooming and plotting one segment
    def zoom(self,zoom):
        self.segment *= zoom
        self.segmentMax *= zoom
        self.xDomain /= zoom
        print "zoom=",zoom,self.segment,self.segmentMax,self.xDomain
        self.calcXminXmax()
        self.plotSegment()

    def changeSegmentValue(self,value):
        self.segment = value/10.0
        self.calcXminXmax()
        self.plotSegment()

    def segmentDecrement(self, value, amount=0.9):
        self.segment = max(0,self.segment-amount)
        self.segmentSlider.setSliderPosition(10*self.segment)

    def segmentIncrement(self, value, amount=0.9):
        self.segment = min(self.segmentMax,self.segment+amount)
        self.segmentSlider.setSliderPosition(10*self.segment)

    def calcXminXmax(self):
        self.xmin = self.waf.x[0] + self.segment*self.xDomain
        self.xmax = self.xmin + self.xDomain


    def plotSegment(self):
        ydText = self.yDisplay.text()
        if self.waf != None:
            if ydText == "raw":
                yNames = ["mag"]
            else:
                self.waf.y["diff"] = self.waf.y["mag"]-self.waf.y["baseline"]
                yNames = ["diff"]
            stride = self.waf.data1.shape[0]/self.segmentMax
            # plot all values and then set xmin and xmax to show this segment
            self.axes.clear()
            for yName in yNames:
                self.axes.plot(self.waf.x, self.waf.y[yName], label=yName)

            for x in self.waf.x[self.peakMask]:
                if x > self.xmin and x < self.xmax:
                    self.axes.axvline(x=x,color='r')

            self.axes.set_xlim((self.xmin,self.xmax))
            self.axes.set_title("segment=%.1f/%.1f"%(self.segment,self.segmentMax))
            self.axes.legend().get_frame().set_alpha(0.5)
            self.draw()




    def yDisplayClicked(self, value):
        print "yDisplayClicked:  value=",value
        if value:
            self.yDisplay.setText("diff")
        else:
            self.yDisplay.setText("raw")
        self.replot()

    def baselineClicked(self,value):
        print "baselineClicked:  value=",value
        if value:
            self.baseline.setText("spline")
        else:
            self.baseline.setText("filter")
        self.updateBaselineBox()

    def show(self):
        super(WideAna,self).show()
        if self.parent == None:
            self.app.exec_()


def main(initialFile=None):
    form = WideAna(showMe=False,title='WideSweep',initialFile=initialFile)
    form.show()

if __name__ == "__main__":
    initialFile = None
    if len(sys.argv) > 1:
        initialFile = sys.argv[1]
    else:
        print "need to specify a filename"
        exit()
    main(initialFile=initialFile)
