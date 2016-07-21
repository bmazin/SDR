from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4 import QtGui
import matplotlib.pyplot as plt
import numpy as np
import sys
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure

def getList(file):
    posList= np.recfromtxt(file)
    l = [posList['f0'],posList['f2'],posList['f3']]
    l = np.array(l)
    l = l.T 
    names = posList['f4']
    return l,names

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.setWindowTitle('Beammap Chooser')
        self.create_main_frame()
        self.create_status_bar()

    def lookupPoint(self,event):
        x = event.xdata
        y = event.ydata
        if y != None and x != None and self.mpl_toolbar.mode == '':
            iClosestLeft = np.argmin((x-self.left[:,1])**2+(y-self.left[:,2])**2)
            print 'Closest Pixel:',self.leftNames[iClosestLeft],self.left[iClosestLeft]
            self.axes0.scatter(self.left[iClosestLeft,1],self.left[iClosestLeft,2],alpha=0.9,s=100,label='left',marker='o',color='c')
            self.canvas.draw()

    def create_main_frame(self):
        self.main_frame = QWidget()
      # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((15.0, 15.0), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes0 = self.fig.add_subplot(111)
        cid=self.canvas.mpl_connect('button_press_event', self.lookupPoint)

        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        vbox = QVBoxLayout()
        vbox.addWidget(self.canvas)
        vbox.addWidget(self.mpl_toolbar)
        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)

    def create_status_bar(self):
        self.status_text = QLabel("Awaiting orders.")
        self.statusBar().addWidget(self.status_text, 1)

    def plot_beammap(self):
        self.left,self.leftNames = getList('freq_atten_x_y_swap.txt')
        self.axes0.scatter(self.left[:,1],self.left[:,2],marker='o',alpha=0.5,s=100,label='left',color='b')
                
        self.canvas.draw()

def main():
    app = QApplication(sys.argv)
    form = AppForm()
    form.plot_beammap()
    form.show()
    app.exec_()


if __name__ == "__main__":
    main()
