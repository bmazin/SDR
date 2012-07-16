#-----------------------------------
# h5quicklook_v2.py
#
# Written by Seth Meeker 07/16/11
#
# standalone program for generating images and pulse height histograms from h5 observation files
# inherits most of its functionality from the arcons GUI's quicklook imaging
# ----------------------------------

#import standard python libraries
import sys
import time
import struct
import os
from os.path import isfile
#import installed libraries
from matplotlib import pylab
from matplotlib import pyplot as plt
from numpy import *
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from tables import *
#import my functions
#from make_image_v2 import make_image as make_image_import
from iqsweep import *
from PSFit_GUI import Ui_MainWindow

class StartQt4(QMainWindow):
	def __init__(self,parent=None):
		QWidget.__init__(self, parent)
		self.ui = Ui_MainWindow()
		self.ui.setupUi(self)
	
		self.atten = 12
		self.ui.atten.setValue(self.atten)	
		self.resnum = 0
		self.indx=0
		
		QObject.connect(self.ui.open_browse, SIGNAL("clicked()"), self.open_dialog)
		QObject.connect(self.ui.save_browse, SIGNAL("clicked()"), self.save_dialog)
		QObject.connect(self.ui.atten, SIGNAL("valueChanged(int)"), self.setnewatten)
		QObject.connect(self.ui.savevalues, SIGNAL("clicked()"), self.savevalues)
		QObject.connect(self.ui.jumptores, SIGNAL("clicked()"), self.jumptores)
		
	def open_dialog(self):
		self.openfile = QFileDialog.getOpenFileName(parent=None, caption=QString(str("Choose PS File")),directory = ".",filter=QString(str("H5 (*.h5)")))
		self.ui.open_filename.setText(str(self.openfile))
		self.loadps()
		
	def save_dialog(self):
		self.savefile = QFileDialog.getOpenFileName(parent=None, caption=QString(str("Choose Save File")),directory = ".")
		self.ui.save_filename.setText(str(self.savefile))
		self.f = open(str(self.savefile), 'a')
		self.f.close()
	
	def loadps(self):
		hd5file=openFile(str(self.openfile),mode='r')
		group = hd5file.getNode('/','r0')
		self.freq=empty(0,dtype='float32')
		for sweep in group._f_walkNodes('Leaf'):
			k=sweep.read()
			self.scale = k['scale'][0]
			#print "Scale factor is ", self.scale
			self.freq=append(self.freq,[k['f0'][0]])
		hd5file.close()
		self.makeplots()
	
	def on_press(self, event):
		self.resfreq = event.xdata
		self.ui.frequency.setText(str(self.resfreq))
		self.ui.plot_3.canvas.ax.plot(self.Res1.I[self.indx],self.Res1.Q[self.indx],'b.')
		self.indx=where(self.Res1.freq >= self.resfreq)[0][0]
		self.ui.plot_2.canvas.ax.plot(self.Res1.freq[self.indx],self.res1_iq_vel[self.indx])
		self.ui.plot_2.canvas.draw()
		self.ui.plot_3.canvas.ax.plot(self.Res1.I[self.indx],self.Res1.Q[self.indx],'r.')
		self.ui.plot_3.canvas.draw()
	
	def makeplots(self):
		self.ui.res_num.setText(str(self.resnum))
		self.atten = self.ui.atten.value()
		self.resfreq = self.resnum
		self.ui.frequency.setText(str(self.resfreq))

		self.Res1=IQsweep()

		try:
			self.Res1.Load(str(self.openfile), 'r0', self.freq[self.resnum], int32(self.atten))
			res1_iq_amp=sqrt((self.Res1.Q)**2+(self.Res1.I)**2)
			self.res1_iq_vel=zeros(self.Res1.fsteps-1)
	        
			for i in range(self.Res1.fsteps-2):
				self.res1_iq_vel[i]=sqrt((self.Res1.Q[i+1]-self.Res1.Q[i])**2+(self.Res1.I[i+1]-self.Res1.I[i])**2)

			self.ui.res_num.setText(str(self.resnum))

			self.ui.plot_1.canvas.ax.clear()
			self.ui.plot_1.canvas.ax.semilogy(self.Res1.freq,res1_iq_amp,'.-')
			#self.ui.plot_1.canvas.format_labels()
			self.ui.plot_1.canvas.draw()
			
			self.ui.plot_2.canvas.ax.clear()
			self.ui.plot_2.canvas.ax.plot(self.Res1.freq[:-1],self.res1_iq_vel,'.-')
			#self.ui.plot_2.canvas.format_labels()
			cid=self.ui.plot_2.canvas.mpl_connect('button_press_event', self.on_press)
			self.ui.plot_2.canvas.draw()

			self.ui.plot_3.canvas.ax.clear()
			self.ui.plot_3.canvas.ax.plot(self.Res1.I,self.Res1.Q,'.-')
			#self.ui.plot_3.canvas.format_labels()
			self.ui.plot_3.canvas.draw()
		except IndexError:
			self.f.close()
			print "reached end of resonator list, saving file"
			print "closing GUI"
			sys.exit()

	def jumptores(self):
		try:
			self.ui.atten.setValue(12)
			self.resnum = self.ui.jumptonum.value()
			self.resfreq = self.resnum
			self.makeplots()
		except IndexError:
			print "Res value out of bounds."
			self.ui.plot_1.canvas.ax.clear()
			self.ui.plot_2.canvas.ax.clear()
			self.ui.plot_3.canvas.ax.clear()
			self.ui.plot_1.canvas.draw()
			self.ui.plot_2.canvas.draw()
			self.ui.plot_3.canvas.draw()
			

	def setnewatten(self):
		self.atten = self.ui.atten.value()
		self.makeplots()

	def savevalues(self):
		if self.resnum == 0:
			self.f = open(str(self.savefile), 'a')
			self.f.write(str(self.scale)+'\t'+str(self.scale)+'\t'+str(self.scale)+'\t'+str(self.scale)+'\n')
			self.f.close()
		Icen=0
		Qcen=0
		self.f = open(str(self.savefile), 'a')
		self.f.write(str(self.resfreq)+'\t'+str(Icen)+'\t'+str(Qcen)+'\t'+str(self.atten)+'\n')
		self.f.close()
		self.resnum += 1
		self.atten = 12
		self.ui.atten.setValue(self.atten)
		self.makeplots()

				
if __name__ == "__main__":
	app = QApplication(sys.argv)
	myapp = StartQt4()
	myapp.show()
	app.exec_()
