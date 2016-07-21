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
            print 'Closest Left Point:',self.leftNames[iClosestLeft],self.left[iClosestLeft]
            iClosestRight = np.argmin((x-self.right[:,1])**2+(y-self.right[:,2])**2)
            print 'Closest Right Point:',self.rightNames[iClosestRight],self.right[iClosestRight]
            self.axes0.scatter(self.right[iClosestRight,1],self.right[iClosestRight,2],alpha=0.9,s=100,label='right',marker='>',color='c')
            self.canvas.draw()

    def create_main_frame(self):
        self.main_frame = QWidget()
      # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((10.0, 10.0), dpi=self.dpi)
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
        self.left,self.leftNames = getList('freq_atten_x_y_palleft.txt')
        #self.right,self.rightNames = getList('freq_atten_x_y_palright.txt')
        self.right,self.rightNames = getList('freq_atten_x_y_swap.txt')
        for iR,r in enumerate(self.right):
            for iL,l in enumerate(self.left):
                if abs(r[0]-l[0]) < 500e-6 and int(self.rightNames[iR][2])/4 == int(self.leftNames[iL][2])/4:
                    self.axes0.plot([r[1],l[1]],[r[2],l[2]],'-')
        self.axes0.scatter(self.left[:,1],self.left[:,2],marker='o',alpha=0.5,s=100,label='left',color='b')
        self.axes0.scatter(self.right[:,1],self.right[:,2],alpha=0.5,s=100,label='right',marker='>',color='r')
        fid = open('doubles.txt')
        self.iLeftDoubles = []
        for line in fid:
            for iName,name in enumerate(self.leftNames):
                if '/'+line[0:-1]+'/' == name:
                    self.iLeftDoubles.append(iName)
        
        print 'left doubles',self.iLeftDoubles
        fid = open('doublesRight.txt')
        self.iRightDoubles = []
        for line in fid:
            for iName,name in enumerate(self.rightNames):
                if '/'+line[0:-1]+'/' == name:
                    self.iRightDoubles.append(iName)
                
        self.axes0.scatter(self.left[self.iLeftDoubles,1],self.left[self.iLeftDoubles,2],marker='d',alpha=0.3,s=100,label='left',color='y')
        self.axes0.scatter(self.right[self.iRightDoubles,1],self.right[self.iRightDoubles,2],alpha=0.3,s=100,label='right',marker='>',color='y')
        
        self.canvas.draw()

def main():
    app = QApplication(sys.argv)
    form = AppForm()
    form.plot_beammap()
    form.show()
    app.exec_()


if __name__ == "__main__":
    main()
