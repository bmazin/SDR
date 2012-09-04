import sys, os, time, random, math, array, fractions
from PyQt4 import QtCore
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from roach import Roach, RoachState
import socket
import matplotlib, corr, time, struct, numpy
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
#from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from customNavToolBar import customNavToolBar
from matplotlib.figure import Figure
from tables import *
from lib import iqsweep

MAX_ATTEN=99

class RoachThread(QtCore.QThread):
    def __init__(self,roachObject=None, command=None):
        QtCore.QThread.__init__(self)
        self.roach=roachObject
        self.com=command

    def __del__(self):
        self.wait()

    def run(self):
        #time.sleep((20-2*self.roach.getNum())/5.0)
        self.roach.setStatus(0)
        time.sleep(random.randint(1,5))
        
        if self.com=='connect':
            self.roach.connect()
            self.emit(QtCore.SIGNAL("connectedRoach()"))
        if self.com=='loadFreq':
            self.roach.loadFreq()
            self.emit(QtCore.SIGNAL("loadedFrequency()"))
        #else:		#gives errors
        #    self.roach.setStatus(1)
        #    print 'No such command here'
        return


class highTemplar(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.setWindowTitle('High Templar Resonator Setup')
        self.create_menu()
        self.create_main_frame()
        self.create_status_bar()
        #self.disableCommandButtons()
        
        self.threadPool=[]
        self.numThreadsRunning=0
        self.currentChannel=[0,0,0,0,0,0,0,0]
        #self.roachStatus=[0,0,0,0,0,0,0,0]
        
        self.roach0=Roach(0)
        self.roach1=Roach(1)
        self.roach2=Roach(2)
        self.roach3=Roach(3)
        self.roach4=Roach(4)
        self.roach5=Roach(5)
        self.roach6=Roach(6)
        self.roach7=Roach(7)
        self.roaches=[self.roach0,self.roach1,self.roach2,self.roach3,self.roach4,self.roach5,self.roach6,self.roach7]
        
        self.showControls()
        QTimer.singleShot(0, self.connectRoaches)

    def connectRoaches(self):
        self.status_text.setText('Connecting Roaches...')
        print 'Connecting Roches...'
        self.numThreadsRunning=8
        for roach in self.roaches:
            self.threadPool.append(RoachThread(roach,'connect'))
        for thread in self.threadPool:
            self.connect(thread,QtCore.SIGNAL("connectedRoach()"),self.catchRoachConnectionSignal)
            thread.start()    

    def catchRoachConnectionSignal(self):
        #print 'Connected roach!'
        self.numThreadsRunning-=1
        if self.numThreadsRunning==0:
            self.threadPool=[]
            self.enableCommandButtons()
            if self.checkRoachErrors(RoachState.connect)==0:
                self.status_text.setText('All roaches connected')
                print '...Done connecting Roaches!'
            else:
                #errors!
                pass
 

    def catchRoachLoadFreqSignal(self):
        self.numThreadsRunning-=1
        if self.numThreadsRunning == 0:
            self.threadPool=[]
            self.enableCommandButtons()
            if self.checkRoachErrors(RoachState.loadFreq)==0:
                print 'roaches finished loading freq file!'
                self.status_text.setText('roaches finished loading freq file')
            else:
                #errors!
                pass

    def commandButtonClicked(self):
        source = self.sender()
        print 'Roach: ',source.roach,'Command: ',source.command
        if source.command == 'loadFreq':
            self.disableCommandButtons()
            self.status_text.setText('Loading Frequency Files for Roach:'+str(source.roach))
            print 'Loading Frequency Files for Roach:',str(source.roach)
            #This is where the GUI grabs the freqFile and gives it to the roaches
            #freqFile=self.label_freqFile_0.text()
            #roach0.setFreqFile(freqFile)

            #print 'nums:',source.roach
            self.status=0
            for i in source.roach:
                #print 'i:',i
                self.threadPool.append(RoachThread(self.roaches[i],'loadFreq'))
                self.connect(self.threadPool[len(self.threadPool)-1],QtCore.SIGNAL("loadedFrequency()"),self.catchRoachLoadFreqSignal)
                self.threadPool[len(self.threadPool)-1].start()
                self.numThreadsRunning+=1
        else:
            print 'No such command',source.command, 'from roach',source.roach

    def commandRoach(self,roachNum,command):
        if command == 'loadFreq':
            
            return 1  

    def checkRoachErrors(self,command):
        errors=0
        for roach in self.roaches:
            if roach.getState == command and roach.getStatus==0:
                print 'roach',roach.getNum,'failed command',command
                errors+=1
                roach.setStatus(1)
        return errors

    def radioRoachChanged(self):
        source=self.sender()

        if source.isChecked():
            #time.sleep(.1)
            #self.showControls(source.roach)
            pass
        else:       #signal from the radio roach that was turned off
            self.saveControls(source.roach)

    def showControls(self):
        """change plot, resonator characteristics etc"""
       
        roachNum=-1
        for radio in self.radioRoaches:
            if radio.isChecked():
                roachNum = radio.roach
        #print 'changing',roachNum
        roach=self.roaches[int(roachNum)]
        self.textbox_loFreq.setText('%e'%roach.getLoFreq())
        self.textbox_freqFile.setText(str(roach.getFreqFile()))
        self.textbox_saveDir.setText(str(roach.getSaveDir()))
        self.textbox_loSpan.setText('%e'%float(roach.getLoSpan()))
        self.textbox_inputAtten.setText(str(roach.getInputAtten()))
        self.textbox_startAtten.setText(str(roach.getStartAtten()))
        self.textbox_stopAtten.setText(str(roach.getStopAtten()))
        self.textbox_ddsSyncLag.setText(str(roach.getDdsSyncLag()))

    def saveControls(self,roachNum):
        """save current resonator characteristics etc"""
        roach=self.roaches[int(roachNum)]
        roach.setLoFreq(float(self.textbox_loFreq.text()))
        roach.setFreqFile(self.textbox_freqFile.text())
        roach.setSaveDir(self.textbox_saveDir.text())
        roach.setLoSpan(float(self.textbox_loSpan.text()))
        roach.setInputAtten(int(self.textbox_inputAtten.text()))
        roach.setStartAtten(int(self.textbox_startAtten.text()))
        roach.setStopAtten(int(self.textbox_stopAtten.text()))
        roach.setDdsSyncLag(int(self.textbox_ddsSyncLag.text()))
        #print 'saved',roachNum
        self.showControls()
        

    def deleteResonator(self):
        print 'delete resonator'

    def updateResonator(self):
        print 'update resonator'

    def disableCommandButtons(self):
        for arr in self.commandButtons:
            for button in arr:
                button.setEnabled(False)

    def enableCommandButtons(self):
        for arr in self.commandButtons:
            for button in arr:
                button.setEnabled(True)
                button.setPalette(self.redButtonPalette)

    def create_main_frame(self):
        self.main_frame = QWidget()

        # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((9.0, 5.0), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes0 = self.fig.add_subplot(121)
        self.axes1 = self.fig.add_subplot(122)

        #cid=self.canvas.mpl_connect('button_press_event', self.changeCenter)
        
        # Create the navigation toolbar, tied to the canvas
        #self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        self.mpl_toolbar = customNavToolBar(self.canvas,self.main_frame)
        
        #button color palettes        
        self.greenButtonPalette = QPalette()
        self.greenButtonPalette.setColor(QPalette.Button,Qt.green)
        self.redButtonPalette = QPalette()
        self.redButtonPalette.setColor(QPalette.Button,Qt.darkRed)
        self.grayButtonPalette = QPalette()
        self.grayButtonPalette.setColor(QPalette.Button,Qt.gray)

        #Command Labels:
        self.label_loadFreq = QLabel('Load Freq/Atten:')
        self.label_defineLUT = QLabel("Define LUT's:")
        self.label_sweep = QLabel('Sweep:')
        self.label_rotate = QLabel('Rotate Loops:')
        self.label_center = QLabel('Center Loops:')
        self.label_loadFIR = QLabel("Load FIR's:")
        self.label_loadThreshold = QLabel('Load Thresholds:')
        self.commandLabels=[self.label_loadFreq,self.label_defineLUT,self.label_sweep,self.label_rotate,self.label_center,self.label_loadFIR,self.label_loadThreshold]
        for label in self.commandLabels:
            label.setMaximumWidth(110)
            label.setMinimumWidth(110)

        #Roach Labels
        self.label_roachNum = QLabel('Roach:')
        self.label_roach0 = QLabel('roach 0')
        self.label_roach1 = QLabel('roach 1')
        self.label_roach2 = QLabel('roach 2')
        self.label_roach3 = QLabel('roach 3')
        self.label_roach4 = QLabel('roach 4')
        self.label_roach5 = QLabel('roach 5')
        self.label_roach6 = QLabel('roach 6')
        self.label_roach7 = QLabel('roach 7')
        self.label_allRoaches = QLabel('All')
        self.roachLabels=[self.label_roachNum,self.label_roach0,self.label_roach1,self.label_roach2,self.label_roach3,self.label_roach4,self.label_roach5,self.label_roach6,self.label_roach7,self.label_allRoaches]
        for label in self.roachLabels[1:]:
            label.setMaximumWidth(50)
            label.setMinimumWidth(50)
        self.label_roachNum.setMaximumWidth(110)
        self.label_roachNum.setMinimumWidth(110)

        #Roach 0 command buttons
        self.button_loadFreq_0 = QPushButton()
        self.button_defineLUT_0 = QPushButton()
        self.button_sweep_0 = QPushButton()
        self.button_rotate_0 = QPushButton()
        self.button_center_0 = QPushButton()
        self.button_loadFIR_0 = QPushButton()
        self.button_loadThreshold_0 = QPushButton()
        roach0CommandButtons =[self.button_loadFreq_0,self.button_defineLUT_0,self.button_sweep_0,self.button_rotate_0,self.button_center_0,self.button_loadFIR_0,self.button_loadThreshold_0]
        
        #Roach 1 command buttons
        self.button_loadFreq_1 = QPushButton()
        self.button_defineLUT_1 = QPushButton()
        self.button_sweep_1 = QPushButton()
        self.button_rotate_1 = QPushButton()
        self.button_center_1 = QPushButton()
        self.button_loadFIR_1 = QPushButton()
        self.button_loadThreshold_1 = QPushButton()
        roach1CommandButtons =[self.button_loadFreq_1,self.button_defineLUT_1,self.button_sweep_1,self.button_rotate_1,self.button_center_1,self.button_loadFIR_1,self.button_loadThreshold_1]

        #Roach 2 command buttons
        self.button_loadFreq_2 = QPushButton()
        self.button_defineLUT_2 = QPushButton()
        self.button_sweep_2 = QPushButton()
        self.button_rotate_2 = QPushButton()
        self.button_center_2 = QPushButton()
        self.button_loadFIR_2 = QPushButton()
        self.button_loadThreshold_2 = QPushButton()
        roach2CommandButtons =[self.button_loadFreq_2,self.button_defineLUT_2,self.button_sweep_2,self.button_rotate_2,self.button_center_2,self.button_loadFIR_2,self.button_loadThreshold_2]

        #Roach 3 command buttons
        self.button_loadFreq_3 = QPushButton()
        self.button_defineLUT_3 = QPushButton()
        self.button_sweep_3 = QPushButton()
        self.button_rotate_3 = QPushButton()
        self.button_center_3 = QPushButton()
        self.button_loadFIR_3 = QPushButton()
        self.button_loadThreshold_3 = QPushButton()
        roach3CommandButtons =[self.button_loadFreq_3,self.button_defineLUT_3,self.button_sweep_3,self.button_rotate_3,self.button_center_3,self.button_loadFIR_3,self.button_loadThreshold_3]

        #Roach 4 command buttons
        self.button_loadFreq_4 = QPushButton()
        self.button_defineLUT_4 = QPushButton()
        self.button_sweep_4 = QPushButton()
        self.button_rotate_4 = QPushButton()
        self.button_center_4 = QPushButton()
        self.button_loadFIR_4 = QPushButton()
        self.button_loadThreshold_4 = QPushButton()
        roach4CommandButtons =[self.button_loadFreq_4,self.button_defineLUT_4,self.button_sweep_4,self.button_rotate_4,self.button_center_4,self.button_loadFIR_4,self.button_loadThreshold_4]

        #Roach 5 command buttons
        self.button_loadFreq_5 = QPushButton()
        self.button_defineLUT_5 = QPushButton()
        self.button_sweep_5 = QPushButton()
        self.button_rotate_5 = QPushButton()
        self.button_center_5 = QPushButton()
        self.button_loadFIR_5 = QPushButton()
        self.button_loadThreshold_5 = QPushButton()
        roach5CommandButtons =[self.button_loadFreq_5,self.button_defineLUT_5,self.button_sweep_5,self.button_rotate_5,self.button_center_5,self.button_loadFIR_5,self.button_loadThreshold_5]

        #Roach 6 command buttons
        self.button_loadFreq_6 = QPushButton()
        self.button_defineLUT_6 = QPushButton()
        self.button_sweep_6 = QPushButton()
        self.button_rotate_6 = QPushButton()
        self.button_center_6 = QPushButton()
        self.button_loadFIR_6 = QPushButton()
        self.button_loadThreshold_6 = QPushButton()
        roach6CommandButtons =[self.button_loadFreq_6,self.button_defineLUT_6,self.button_sweep_6,self.button_rotate_6,self.button_center_6,self.button_loadFIR_6,self.button_loadThreshold_6]

        #Roach 7 command buttons
        self.button_loadFreq_7 = QPushButton()
        self.button_defineLUT_7 = QPushButton()
        self.button_sweep_7 = QPushButton()
        self.button_rotate_7 = QPushButton()
        self.button_center_7 = QPushButton()
        self.button_loadFIR_7 = QPushButton()
        self.button_loadThreshold_7 = QPushButton()
        roach7CommandButtons =[self.button_loadFreq_7,self.button_defineLUT_7,self.button_sweep_7,self.button_rotate_7,self.button_center_7,self.button_loadFIR_7,self.button_loadThreshold_7]

        #all Roaches command buttons
        self.button_loadFreq = QPushButton()
        self.button_defineLUT = QPushButton()
        self.button_sweep = QPushButton()
        self.button_rotate = QPushButton()
        self.button_center = QPushButton()
        self.button_loadFIR = QPushButton()
        self.button_loadThreshold = QPushButton()
        roachCommandButtons =[self.button_loadFreq,self.button_defineLUT,self.button_sweep,self.button_rotate,self.button_center,self.button_loadFIR,self.button_loadThreshold]

        #Matrix of roach command buttons
        self.commandButtons=[roach0CommandButtons,roach1CommandButtons,roach2CommandButtons,roach3CommandButtons,roach4CommandButtons,roach5CommandButtons,roach6CommandButtons,roach7CommandButtons,roachCommandButtons]

        for i in range(len(self.commandLabels)):
            
            for j in range(len(self.commandButtons)):
                self.commandButtons[j][i].setMaximumWidth(50)
                self.commandButtons[j][i].setMaximumHeight(50)
                self.commandButtons[j][i].setMinimumHeight(50)
                self.commandButtons[j][i].setEnabled(False)
                self.commandButtons[j][i].setMinimumWidth(50)
                self.commandButtons[j][i].setPalette(self.grayButtonPalette)
                self.commandButtons[j][i].roach = [j]
                if j==len(self.commandButtons)-1:
                    self.commandButtons[j][i].roach = [0,1,2,3,4,5,6,7]        #button forall roaches
                self.connect(self.commandButtons[j][i],SIGNAL('clicked()'),self.commandButtonClicked)
                if i==0:
                    self.commandButtons[j][i].command = 'loadFreq'
                if i==1:
                    self.commandButtons[j][i].command = 'defineLUT'
                if i==2:
                    self.commandButtons[j][i].command = 'sweep'
                if i==3:
                    self.commandButtons[j][i].command = 'rotate'
                if i==4:
                    self.commandButtons[j][i].command = 'center'
                if i==5:
                    self.commandButtons[j][i].command = 'loadFIR'
                if i==6:
                    self.commandButtons[j][i].command = 'loadThreshold'


        #Roach radio buttons
        self.radio_roach_0 = QRadioButton('Roach 0')
        self.radio_roach_0.setChecked(True)
        self.radio_roach_1 = QRadioButton('Roach 1')
        self.radio_roach_2 = QRadioButton('Roach 2')
        self.radio_roach_3 = QRadioButton('Roach 3')
        self.radio_roach_4 = QRadioButton('Roach 4')
        self.radio_roach_5 = QRadioButton('Roach 5')
        self.radio_roach_6 = QRadioButton('Roach 6')
        self.radio_roach_7 = QRadioButton('Roach 7')
        self.radioRoaches = [self.radio_roach_0,self.radio_roach_1,self.radio_roach_2,self.radio_roach_3,self.radio_roach_4,self.radio_roach_5,self.radio_roach_6,self.radio_roach_7]
        for i in range(len(self.radioRoaches)):
            self.connect(self.radioRoaches[i],SIGNAL('toggled(bool)'),self.radioRoachChanged)
            self.radioRoaches[i].roach=i
        

        #Channel Characteristics labels and textboxes
        self.label_channel = QLabel('CH: ')
        self.textbox_channel = QLineEdit('0')
        #atten spinbox, freq textbox, submit button
        self.spinbox_attenuation = QSpinBox()
        self.spinbox_attenuation.setMaximum(MAX_ATTEN)
        self.label_attenuation = QLabel('Atten:')
        self.textbox_freq = QLineEdit('0')
        self.textbox_freq.setMaximumWidth(130)
        self.label_freq = QLabel('Freq (GHz):')
        #median textbox, threshold textbox, submit button
        self.textbox_med = QLineEdit('0.0')
        self.textbox_med.setMaximumWidth(130)
        self.label_med = QLabel('median:')
        self.textbox_threshold = QLineEdit('0.0')
        self.textbox_threshold.setMaximumWidth(130)
        self.label_threshold = QLabel('threshold:')
        #update resonator button, remove resonator button
        self.button_deleteResonator = QPushButton('Remove Resonator')
        self.button_deleteResonator.setMaximumWidth(170)
        self.connect(self.button_deleteResonator, SIGNAL('clicked()'), self.deleteResonator)
        self.button_updateResonator = QPushButton("Update Resonator")
        self.button_updateResonator.setMaximumWidth(170)
        self.connect(self.button_updateResonator, SIGNAL('clicked()'), self.updateResonator)


        #Roach Properties
        self.label_freqFile = QLabel('Freq/Atten file:')
        self.label_freqFile.setMaximumWidth(100)
        self.textbox_freqFile = QLineEdit('ps_freq0.txt')
        self.textbox_freqFile.setMaximumWidth(200)
        self.label_saveDir = QLabel('Save Dir:')
        self.label_saveDir.setMaximumWidth(100)
        self.textbox_saveDir = QLineEdit('/home/sean/data/')
        self.textbox_saveDir.setMaximumWidth(200)
        self.label_loFreq = QLabel('LO Freq:')
        self.label_loFreq.setMaximumWidth(100)
        self.textbox_loFreq = QLineEdit('0')
        self.textbox_loFreq.setMaximumWidth(100)
        self.label_ddsSyncLag = QLabel('DDS Sync Lag:')
        self.label_ddsSyncLag.setMaximumWidth(100)
        self.textbox_ddsSyncLag = QLineEdit('151')
        self.textbox_ddsSyncLag.setMaximumWidth(100)
        self.label_inputAtten = QLabel('Input Atten:')
        self.label_inputAtten.setMaximumWidth(100)
        self.textbox_inputAtten = QLineEdit('5')
        self.textbox_inputAtten.setMaximumWidth(100)
        self.label_startAtten = QLabel('Start Atten:')
        self.label_startAtten.setMaximumWidth(100)
        self.textbox_startAtten = QLineEdit('10')
        self.textbox_startAtten.setMaximumWidth(100)
        self.label_stopAtten = QLabel('Stop Atten:')
        self.label_stopAtten.setMaximumWidth(100)
        self.textbox_stopAtten = QLineEdit('10')
        self.textbox_stopAtten.setMaximumWidth(100)
        self.label_loSpan = QLabel('LO Span:')
        self.label_loSpan.setMaximumWidth(100)
        self.textbox_loSpan = QLineEdit('0.5e9')
        self.textbox_loSpan.setMaximumWidth(100)

        
        
        #command buttons/labels
        vbox0=QVBoxLayout(spacing = 50)    #change spacing until looks good
        hbox00=QHBoxLayout(spacing=10)
        for label in self.roachLabels:
            hbox00.addWidget(label)
        vbox0.addLayout(hbox00)
        hbox01=QHBoxLayout(spacing=35)
        hbox02=QHBoxLayout(spacing=35)
        hbox03=QHBoxLayout(spacing=35)
        hbox04=QHBoxLayout(spacing=35)
        hbox05=QHBoxLayout(spacing=35)
        hbox06=QHBoxLayout(spacing=35)
        hbox07=QHBoxLayout(spacing=35)
        hbox08=QHBoxLayout(spacing=35)
        hboxes=[hbox01,hbox02,hbox03,hbox04,hbox05,hbox06,hbox07,hbox08]
        for i in range(len(self.commandLabels)):
            hboxes[i].addWidget(self.commandLabels[i])
            for j in range(len(self.commandButtons)):
                hboxes[i].addWidget(self.commandButtons[j][i])
            vbox0.addLayout(hboxes[i])

        #radio buttons
        vbox1 = QVBoxLayout()
        hbox10 = QHBoxLayout()
        for i in range(len(self.radioRoaches)/2+int(len(self.radioRoaches))%2):
            hbox10.addWidget(self.radioRoaches[i])
        hbox11 = QHBoxLayout()
        for i in range(len(self.radioRoaches)/2):
            hbox11.addWidget(self.radioRoaches[i+len(self.radioRoaches)/2+int(len(self.radioRoaches))%2])
        vbox1.addLayout(hbox10)
        vbox1.addLayout(hbox11)

        #figures
        vbox1.addWidget(self.canvas)
        vbox1.addWidget(self.mpl_toolbar)

        #channel characteristics
        hbox12=QHBoxLayout()
        hbox12.addWidget(self.label_channel)
        hbox12.addWidget(self.textbox_channel)
        hbox12.addWidget(self.button_updateResonator)
        hbox12.addWidget(self.button_deleteResonator)
        vbox1.addLayout(hbox12)
        hbox13 = QHBoxLayout()
        hbox13.addWidget(self.label_attenuation)
        hbox13.addWidget(self.spinbox_attenuation)  
        hbox13.addWidget(self.label_freq)
        hbox13.addWidget(self.textbox_freq)
        hbox13.addWidget(self.label_med)      
        hbox13.addWidget(self.textbox_med)
        hbox13.addWidget(self.label_threshold)
        hbox13.addWidget(self.textbox_threshold)
        vbox1.addLayout(hbox13)


        #roach properties
        hbox14=QHBoxLayout()
        hbox14.addWidget(self.label_loFreq)
        hbox14.addWidget(self.textbox_loFreq)
        hbox14.addWidget(self.label_freqFile)
        hbox14.addWidget(self.textbox_freqFile)
        hbox14.addWidget(self.label_saveDir)
        hbox14.addWidget(self.textbox_saveDir)
        vbox1.addLayout(hbox14)
        hbox15=QHBoxLayout()
        hbox15.addWidget(self.label_loSpan)
        hbox15.addWidget(self.textbox_loSpan)
        hbox15.addWidget(self.label_inputAtten)
        hbox15.addWidget(self.textbox_inputAtten)
        hbox15.addWidget(self.label_startAtten)
        hbox15.addWidget(self.textbox_startAtten)
        hbox15.addWidget(self.label_stopAtten)
        hbox15.addWidget(self.textbox_stopAtten)
        vbox1.addLayout(hbox15)
        hbox16=QHBoxLayout()
        hbox16.addWidget(self.label_ddsSyncLag)
        hbox16.addWidget(self.textbox_ddsSyncLag)
        vbox1.addLayout(hbox16)



        hbox = QHBoxLayout()
        hbox.addLayout(vbox0)
        hbox.addLayout(vbox1)
        
        vbox = QVBoxLayout()
        vbox.addLayout(hbox)

        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)

    def create_status_bar(self):
        self.status_text = QLabel("Awaiting orders.")
        self.statusBar().addWidget(self.status_text, 1)

    def create_menu(self):        
        self.file_menu = self.menuBar().addMenu("&File")
        
        load_file_action = self.create_action("&Save plot",shortcut="Ctrl+S",slot=self.save_plot, tip="Save the plot")
        quit_action = self.create_action("&Quit", slot=self.close,shortcut="Ctrl+Q", tip="Close the application")
        
        self.add_actions(self.file_menu, (load_file_action, None, quit_action))
        
        self.help_menu = self.menuBar().addMenu("&Help")
        about_action = self.create_action("&About", shortcut='F1',slot=self.on_about, tip='About the demo')
        
        self.add_actions(self.help_menu, (about_action,))

    def add_actions(self, target, actions):
        for action in actions:
            if action is None:
                target.addSeparator()
            else:
                target.addAction(action)

    def create_action(  self, text, slot=None, shortcut=None, 
                        icon=None, tip=None, checkable=False, 
                        signal="triggered()"):
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

    def save_plot(self):
        file_choices = "PNG (*.png)|*.png"
        
        path = unicode(QFileDialog.getSaveFileName(self, 
                        'Save file', '', 
                        file_choices))
        if path:
            self.canvas.print_figure(path, dpi=self.dpi)
            self.statusBar().showMessage('Saved to %s' % path, 2000)

    def on_about(self):
        msg = """ Message to user goes here.
        """
        QMessageBox.about(self, "MKID-ROACH software demo", msg.strip())

def main():
    app = QApplication(sys.argv)
    form = highTemplar()
    form.show()
    app.exec_()


if __name__ == "__main__":
    main()
