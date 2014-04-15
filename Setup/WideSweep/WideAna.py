"""
A replacement for WideAna.pro for those who prefer python to idl.

Usage:  python WideAna.py test/ucsb_100mK_24db_1.txt 
Matt Strader
Chris Stoughton
"""
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4 import QtGui
import matplotlib.pyplot as plt
import numpy as np
import sys
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
        self.goodFile = initialFile+".good"
        self.fitLineEdits = {}
        self.fitLabels = {}
        #for mode in self.fitParams.keys():
        #    self.fitLineEdits[mode] = {}
        #    self.fitLabels[mode] = {}
        #    for param in self.fitParams[mode].keys():
        #        self.fitLineEdits[mode][param] = QtGui.QLineEdit()
        #        self.fitLabels[mode][param] = QtGui.QLabel()
        self.splineS = 1
        self.splineK = 3
        self.setWindowTitle(title)
        self.plotFunc = plotFunc
        self.create_main_frame(title)
        self.create_status_bar()
        if plotFunc != None:
            plotFunc(fig=self.fig,axes=self.axes)
        if showMe == True:
            self.show()
        self.segment = 0
        self.segmentMax = 80
        self.load_file(initialFile)
        # plot the first segment
        self.calcXminXmax()
        self.plotSegment()

    def draw(self):
        self.fig.canvas.draw()

    def on_key_press(self,event):
        print "on_key_press:  key pressed is ==>%s===<"%event.key
        if event.key == "right":
            self.segmentIncrement(None,0.1)
        elif event.key == "left":
            self.segmentDecrement(None,0.1)

    def on_button_press(self,event):
        print "on_button_press:  button pressed is ==>%s===<"%event.button,event.xdata,event.ydata
        if event.button == 3:
            self.replot()

    def replot(self):
            xlim = self.axes.set_xlim()
            print "replot with xlim=",xlim
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
        self.countLabel = QtGui.QLabel()
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
        self.infoBox.addWidget(self.countLabel)

        # entire box
        vbox = QVBoxLayout()
        vbox.addLayout(segmentBox)
        #vbox.addLayout(self.baselineBox)
        vbox.addLayout(self.infoBox)
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

        self.xDomain = (self.waf.x[-1]-self.waf.x[0])/self.segmentMax


    def segmentDecrement(self, value, amount=0.9):
        self.segment = max(0,self.segment-amount)
        print "decrement:  segment=",self.segment
        self.segmentSlider.setSliderPosition(10*self.segment)

    def segmentIncrement(self, value, amount=0.9):
        self.segment = min(self.segmentMax,self.segment+amount)
        self.segmentSlider.setSliderPosition(10*self.segment)

    def calcXminXmax(self):
        self.xmin = self.waf.x[0] + self.segment*self.xDomain
        self.xmax = self.xmin + self.xDomain

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

    def changeSegmentValue(self,value):
        self.segment = value/10.0
        self.calcXminXmax()
        self.plotSegment()

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

            # vertical line at each peak position
            for peak in self.waf.peaks:
                x = self.waf.x[peak]
                if x > self.xmin and x < self.xmax:
                    self.axes.axvline(x=x,color='r')
            self.axes.set_xlim((self.xmin,self.xmax))
            self.axes.set_title("segment=%.1f"%self.segment)
            self.axes.legend().get_frame().set_alpha(0.5)
            self.draw()
    def calcSpeed(self):
        """ calculate the speed at each point """
        mag = self.y['mag']
        self.y['magSpeed'] = mag[1:]-mag[:-1]

    def calcGauss(self,sigma=2):
        """ convolve with a gaussian of width sigma"""
        m = int(sigma*5)
        gauss = signal.gaussian(m,sigma)
        gauss /= gauss.sum()
        mag = self.y['mag']
        self.y['magGauss'] = signal.convolve(mag,gauss,mode='same')

    def calcBessel(self,nSmooth=50):
        Wp = 1/float(nSmooth)
        (b,a) = fd.iirfilter(8, Wp, btype='highpass', ftype='bessel')
        print "b=",b
        print "a=",a
        mag = self.y['mag']
        self.y['magBessel'] = signal.lfilter(b,a,mag)


    def create_action(self, text, slot=None, shortcut=None,
                      icon=None,tip=None,checkable=False,signal="triggered()"):
        action = QAction(text, self)
        if icon is not None:
            action.setIcon(QIcon(":/%s.png" % icon))
        if shortcut is not None:
            action.setShortcut(shortcut)
        if tip is not None:
            action.setToolTip(tip)
            action.setStatusTip(tip)
        if slot is not None:
            self.connect(action, SIGNAL(signal), slot)
        if checkable:
            action.setCheckable(True)
        return action

    def create_status_bar(self):
        self.status_text = QLabel("")
        self.statusBar().addWidget(self.status_text, 1)

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
