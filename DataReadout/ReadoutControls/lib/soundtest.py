#import standard python libraries
import sys
import time
import datetime
import struct
import socket
import os
import subprocess
from os.path import isfile
import traceback
import pyaudio  
import wave  
#import installed libraries
from matplotlib import pylab
from matplotlib import pyplot as plt
from numpy import *
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
import ephem
#import my functions
from testbuttons_gui import Ui_MainWindow

class StartQt4(QMainWindow):
    def __init__(self,parent=None):
        QWidget.__init__(self, parent)
        
        sys.excepthook = self.handle_exception
        
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        self.sound_thread = sound_Worker(self)
        self.timer_thread = timer_Worker(self)
        self.polling_timer = QTimer()
        
        QObject.connect(self.polling_timer,SIGNAL("timeout()"), self.update_remaining_time)        
        QObject.connect(self.ui.pushButton, SIGNAL("clicked()"), self.playsound1)
        QObject.connect(self.ui.pushButton_2, SIGNAL("clicked()"), self.playsound2)
        QObject.connect(self.ui.pushButton_3, SIGNAL("clicked()"), self.playsound3)
        QObject.connect(self.ui.pushButton_4, SIGNAL("clicked()"), self.playsound4)
        QObject.connect(self.ui.pushButton_5, SIGNAL("clicked()"), self.countdown)
        QObject.connect(self.timer_thread,SIGNAL("timeout()"), self.playsound1)
    
    def handle_exception(self, exc_type, exc_value, exc_traceback):
        self.playsound3()
        print "".join(traceback.format_exception(exc_type, exc_value, exc_traceback))
        
    def playsound(self,file):
        if self.sound_thread.isRunning()==False:
            self.sound_thread.play_wav(file)
        else:
            time.sleep(0.1)
            self.playsound(file)
        
    def playsound1(self):
        file = "ARCON-complete.wav"
        self.playsound(file)
        
    def playsound2(self):
        file = "ARCON-eradicate.wav"
        self.playsound(file)

    def playsound3(self):
        file = "ARCON-nuclear.wav"
        self.playsound(file)

    def playsound4(self):
        file = "ARCON-returned.wav"
        self.playsound(file)

    def countdown(self):
        num = self.ui.spinBox.value()
        if num == 0:
            raise ValueError('timer cannot be 0')
        self.timer_thread.start_timer(num)
        self.polling_timer.start(200)
        arr = [0,1,2,3,4]
        print arr[10]
        
    def update_remaining_time(self):
        try: self.timer_thread and self.timer_thread.isRunning()
        except AttributeError:
            self.ui.lcdNumber.display(self.ui.obs_time_spinBox.value())
        else:
            self.ui.lcdNumber.display(self.timer_thread.remaining_time)

class sound_Worker(QThread):
    def __init__(self, parent = None):
        QThread.__init__(self, parent)
        self.file = file
        self.exiting = False
        self.stopped = False
    def __del__(self):
        self.exiting = True
        self.wait()
    def stop(self):
        self.stopped = True
    def play_wav(self, file):
        self.file = file
        self.start()
    def run(self):
        #define stream chunk   
        chunk = 1024
        #open a wav format music  
        f = wave.open(self.file,"rb")  
        #instantiate PyAudio  
        p = pyaudio.PyAudio()  
        #open stream  
        stream = p.open(format = p.get_format_from_width(f.getsampwidth()),  
                        channels = f.getnchannels(),  
                        rate = f.getframerate(),  
                        output = True)  
        #read data  
        data = f.readframes(chunk)  
        #paly stream  
        while data != '':  
            stream.write(data)  
            data = f.readframes(chunk)  
        #stop stream  
        stream.stop_stream()  
        stream.close()  
        #close PyAudio  
        p.terminate()
        self.stop()

class timer_Worker(QThread):
    def __init__(self, parent = None):
        QThread.__init__(self, parent)
        self.exiting = False
        self.remaining_time = 0
        self.stopped = False
    def __del__(self):
        self.exiting = True
        self.wait()
    def stop(self):
        self.stopped = True
        self.remaining_time = 0
    def start_timer(self, starttime):
        self.starttime = starttime
        self.start()
    def run(self):
        self.stopped = False
        self.remaining_time = self.starttime
        t1 = time.time()
        t2 = time.time()
        while self.stopped == False and self.remaining_time > 0:
            t2 = time.time()
            self.remaining_time = self.starttime - (t2-t1)
            time.sleep(0.1)
        self.emit(SIGNAL("timeout()"))
        self.stop()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    myapp = StartQt4()
    myapp.show()
    app.exec_()

        