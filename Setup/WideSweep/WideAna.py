"""
A replacement for WideAna.pro for those who prefer python to idl.

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

class PopUp(QMainWindow):
    def __init__(self, parent=None,plotFunc=None,title='',separateProcess=False, image=None,showMe=True, initialFile=None):
        self.parent = parent
        if self.parent == None:
            self.app = QApplication([])
        super(PopUp,self).__init__(parent)
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
        self.data1 = None
        if initialFile:
            print "now open initialFile=",initialFile
            self.load_file(initialFile)
            self.plotSegment()

    def draw(self):
        self.fig.canvas.draw()

    def create_main_frame(self,title):
        self.main_frame = QWidget()
      # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((7, 5), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes = self.fig.add_subplot(111)

        # Create the segment slider
        self.segmentSlider = QtGui.QSlider(Qt.Horizontal, self)
        self.segmentSlider.setRange(0,80)
        self.segmentSlider.setFocusPolicy(Qt.NoFocus)
        self.segmentSlider.setGeometry(30,40,100,30)
        self.segmentSlider.valueChanged[int].connect(self.changeSegmentValue)

        # Create the left and right buttons
        segmentDecrement = QtGui.QPushButton('<',self)
        segmentDecrement.clicked[bool].connect(self.segmentDecrement)
        segmentIncrement = QtGui.QPushButton('>',self)
        segmentIncrement.clicked[bool].connect(self.segmentIncrement)

        # create text input for splineK
        
        self.yDisplay = QtGui.QPushButton("raw")
        self.yDisplay.setCheckable(True)
        self.yDisplay.clicked[bool].connect(self.yDisplayClicked)
        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)

        # Do the layout

        # segment box
        segmentBox = QHBoxLayout()
        segmentBox.addWidget(segmentDecrement)
        segmentBox.addWidget(self.segmentSlider)
        segmentBox.addWidget(segmentIncrement)
        segmentBox.addWidget(self.yDisplay)
        # entire box
        vbox = QVBoxLayout()
        vbox.addLayout(segmentBox)
        vbox.addWidget(self.canvas)
        vbox.addWidget(self.mpl_toolbar)

        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)
        
        # Manu Bars and Actions
        self.file_menu = self.menuBar().addMenu("&File")
        self.file_menu.addAction(
            self.create_action("&Read", 
                               shortcut="Ctrl+R", 
                               slot=self.read_file,
                               tip="Read File"))

    def read_file(self):
        fileName = str(QFileDialog.getOpenFileName(parent=None, 
                                    caption=QString(str("Choose Wide File")), 
                                    directory="/Users/stoughto/wideAna/20131122"))
        self.load_file(fileName)

    def load_file(self, fileName):
        file = open(fileName,'r')
        (self.fr1,self.fspan1,self.fsteps1,self.atten1) = file.readline().split()
        (self.fr2,self.fspan2,self.fsteps2,self.atten2) = file.readline().split()
        (self.ts,self.te) = file.readline().split()
        (self.Iz1,self.Izsd1) = file.readline().split()
        (self.Qz1,self.Qzsd1) = file.readline().split()
        (self.Iz2,self.Izsd2) = file.readline().split()
        (self.Qz2,self.Qzsd2) = file.readline().split()
        file.close()
        self.data1 = np.loadtxt(fileName, skiprows=7, usecols=(0,1,3))
        self.loadedFileName=fileName
        self.y = {}
        self.y['mag']=np.sqrt(np.power(self.data1[:,1]-float(self.Iz2),2) + np.power(self.data1[:,2]-float(self.Qz2),2))
        self.yToShow = {'mag':True}
        
        # do this automatically...for now, or forever?
        #self.calcSpeed()
        #self.yToShow['magSpeed'] = True
        #self.calcGauss()
        #self.yToShow['magGauss'] = True
        #self.calcBessel()
        #self.yToShow['magBessel'] = True
        self.calcUSpline()
        self.yToShow['magUSpline'] = True
    def segmentDecrement(self, value):
        self.segment = max(0,self.segment-1)
        self.segmentSlider.setSliderPosition(self.segment)

    def segmentIncrement(self, value):
        self.segment = min(self.segmentMax,self.segment+1)
        self.segmentSlider.setSliderPosition(self.segment)

    def yDisplayClicked(self, value):
        print "yDisplayClicked:  value=",value
        if value:
            self.yDisplay.setText("diff")
        else:
            self.yDisplay.setText("raw")
        self.plotSegment()

    def changeSegmentValue(self,value):
        self.segment = value
        self.plotSegment()

    def plotSegment(self):
        ydText = self.yDisplay.text()
        print "in plotSegment for segment=",self.segment,ydText
        
        if self.data1 != None:
            if ydText == "raw":
                yNames = ["mag","magUSpline"]
            else:
                self.y["diff"] = self.y["mag"]-self.y["magUSpline"]
                yNames = ["diff"]
                self.yToShow["diff"] = True
            stride = self.data1.shape[0]/self.segmentMax
            i0 = self.segment*stride
            i1 = i0+stride
            self.axes.clear()
            for yName in yNames:
                print "now yName=",yName
                if self.yToShow[yName]:
                    xx = self.data1[i0:i1,0]
                    yy = self.y[yName][i0:i1]
                    # differences, filters, and convolutions shorten yy
                    self.axes.plot(xx[0:len(yy)],yy, label=yName)
            self.axes.set_title("segment=%d"%self.segment)
            self.axes.legend()
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

    def calcUSpline(self):
        x = self.data1[:,0]
        y = self.y['mag']
        
        spline = UnivariateSpline(x,y,s=self.splineS, k=self.splineK)
        self.y['magUSpline'] = spline(x)

    def tempSmoothing(self):
        #polyOrder=40
        #self.poly=np.poly1d(np.polyfit(self.data1[:,0],self.mag,polyOrder))
        #self.polyFit = self.poly(self.data1[:,0])
        #self.changeSegmentValue(0)
        """ placeholder """
        nSmooth=5
        norm_pass = 1/float(nSmooth)
        norm_stop = 1.5*norm_pass
        (N,Wn) = signal.buttord(wp=norm_pass, ws=norm_stop,
                                gpass=2, gstop=30,analog=0)
        (b,a) = signal.butter(N, Wn, btype='low', analog=0, output='ba')
        yFiltered = signal.lfilter(b,a,yy)
        self.axes.plot(xx,yFiltered,label="butter")
        
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
        super(PopUp,self).show()
        if self.parent == None:
            self.app.exec_()

    #def create_status_bar(self):
        #self.status_text = QLabel("Awaiting orders.")
        #self.statusBar().addWidget(self.status_text, 1)

def main(initialFile=None):
    form = PopUp(showMe=False,title='WideSweep',initialFile=initialFile)
    form.show()

if __name__ == "__main__":
    initialFile = None
    if len(sys.argv) > 1:
        initialFile = sys.argv[1]
    main(initialFile=initialFile)
