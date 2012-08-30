import sys, os, random, math, array, fractions
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import socket
import matplotlib, corr, time, struct, numpy
from bitstring import BitArray
import matplotlib.pyplot as mpl
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
from tables import *
from lib import iqsweep

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.setWindowTitle('Channelizer 2')
        self.create_menu()
        self.create_main_frame()
        self.create_status_bar()
        self.dacStatus = 'off'
        self.dramStatus = 'off'
        self.tapStatus = 'off'
        self.socketStatus = 'off'
        self.ch_all = []
        self.attens = numpy.array([1. for i in range(256)])
        self.freqRes = 7812.5
        self.sampleRate = 512e6
        self.zeroChannels = [0]*256
        self.thresholds, self.medians = numpy.array([0.]*256), numpy.array([0.]*256)
        
    def openClient(self):
        self.roach = corr.katcp_wrapper.FpgaClient(self.textbox_roachIP.text(),7147)
        time.sleep(2)
        self.status_text.setText('connection established')
        self.button_openClient.setDisabled(True)

    def loadFIRcoeffs(self):
        N_freqs = len(map(float, unicode(self.textedit_DACfreqs.toPlainText()).split()))
        taps = 26
        
        for ch in range(N_freqs):
            # If the dark count rate is very high, the channel will be zeroed.
            if self.zeroChannels[ch]:
                lpf = numpy.array([0.]*taps)*(2**11-1)
            else:
                print ch
                #lpf = numpy.array([1.]+[0]*(taps-1))*(2**11-1)
		#    26 tap, 25 us matched fir
		#lpf = numpy.array([0.0875788844768 , 0.0840583257978 , 0.0810527406206 , 0.0779008825067 , 0.075106964962 , 0.0721712998256 , 0.0689723729398 , 0.066450095496 , 0.0638302570705 , 0.0613005685486 , 0.0589247737004 , 0.0565981917436 , 0.0544878914297 , 0.0524710948658 , 0.0503447054014 , 0.0483170854189 , 0.0463121066637 , 0.044504238059 , 0.0428469827102 , 0.0410615366471 , 0.0395570640218 , 0.0380071830756 , 0.0364836787854 , 0.034960959124 , 0.033456372241 , 0.0321854467182])*(2**11-1)
                #lpf = lpf[::-1]
                #    26 tap, lpf, 250 kHz,
                lpf = numpy.array([-0 , 0.000166959420533 , 0.00173811663844 , 0.00420937801998 , 0.00333739357391 , -0.0056305703275 , -0.0212738104942 , -0.0318529375832 , -0.0193635986879 , 0.0285916612022 , 0.106763943766 , 0.18981814328 , 0.243495321192 , 0.243495321192 , 0.18981814328 , 0.106763943766 , 0.0285916612022 , -0.0193635986879 , -0.0318529375832 , -0.0212738104942 , -0.0056305703275 , 0.00333739357391 , 0.00420937801998 , 0.00173811663844 , 0.000166959420533 , -0])*(2**11-1)
                #    26 tap, lpf, 125 kHz.
                #lpf = numpy.array([0 , -0.000431898216436 , -0.00157886921107 , -0.00255492263971 , -0.00171727439076 , 0.00289724121972 , 0.0129123447233 , 0.0289345497995 , 0.0500906370566 , 0.0739622085341 , 0.0969821586979 , 0.115211955161 , 0.125291869266 , 0.125291869266 , 0.115211955161 , 0.0969821586979 , 0.0739622085341 , 0.0500906370566 , 0.0289345497995 , 0.0129123447233 , 0.00289724121972 , -0.00171727439076 , -0.00255492263971 , -0.00157886921107 , -0.000431898216436 , -0])*(2**11-1)
                #    Generic 40 tap matched filter for 25 us lifetime pulse
                #lpf = numpy.array([0.153725595011 , 0.141052390733 , 0.129753816201 , 0.119528429291 , 0.110045314901 , 0.101336838027 , 0.0933265803805 , 0.0862038188673 , 0.0794067694409 , 0.0729543134914 , 0.0674101836798 , 0.0618283869464 , 0.0567253144676 , 0.0519730940444 , 0.047978953698 , 0.043791412767 , 0.0404560656757 , 0.0372466775252 , 0.0345000956808 , 0.0319243455811 , 0.0293425115323 , 0.0268372778298 , 0.0245216835234 , 0.0226817116475 , 0.0208024488535 , 0.0189575043357 , 0.0174290665862 , 0.0158791788119 , 0.0144611054123 , 0.0132599563305 , 0.0121083419203 , 0.0109003580368 , 0.0100328742978 , 0.00939328253743 , 0.00842247241585 , 0.00789304712484 , 0.00725494259117 , 0.00664528407122 , 0.00606688645845 , 0.00552041438208])*(2**11-1)                
                #lpf = lpf[::-1]
            for n in range(taps/2):
                coeff0 = int(lpf[2*n])
                coeff1 = int(lpf[2*n+1])
                coeff0 = numpy.binary_repr(int(lpf[2*n]), 12)
                coeff1 = numpy.binary_repr(int(lpf[2*n+1]), 12)
                coeffs = int(coeff1+coeff0, 2)
                coeffs_bin = struct.pack('>l', coeffs)
                register_name = 'FIR_b' + str(2*n) + 'b' + str(2*n+1)
                self.roach.write(register_name, coeffs_bin)
                self.roach.write_int('FIR_load_coeff', (ch<<1) + (1<<0))
                self.roach.write_int('FIR_load_coeff', (ch<<1) + (0<<0))
        
        # Inactive channels will also be zeroed.
        lpf = numpy.array([0.]*taps)
        for ch in range(N_freqs, 256):
            for n in range(taps/2):
                #coeffs = struct.pack('>h', lpf[2*n]) + struct.pack('>h', lpf[2*n+1])
                coeffs = struct.pack('>h', lpf[2*n+1]) + struct.pack('>h', lpf[2*n])
                register_name = 'FIR_b' + str(2*n) + 'b' + str(2*n+1)
                self.roach.write(register_name, coeffs)
                self.roach.write_int('FIR_load_coeff', (ch<<1) + (1<<0))
                self.roach.write_int('FIR_load_coeff', (ch<<1) + (0<<0))
                
        print 'done loading fir.' 
     
    def find_nearest(self, array, value):
        idx=(numpy.abs(array-value)).argmin()
        return idx

    def loadThresholds(self):
        """    Takes two time streams and concatenates together for a longer sample.
                median is used instead of mean.
                """
        x = raw_input('Is the lamp off? ')
        Nsigma = float(self.textbox_Nsigma.text())
        N_freqs = len(map(float, unicode(self.textedit_DACfreqs.toPlainText()).split()))
        self.thresholds, self.medians = numpy.array([0.]*N_freqs), numpy.array([0.]*N_freqs)
        steps = int(self.textbox_timeLengths.text())
        L = 2**10
        for ch in range(N_freqs):
            bin_data_phase = ''
            for n in range(steps):
                self.roach.write_int('ch_we', ch)
                self.roach.write_int('startSnap', 0)
                self.roach.write_int('snapPhase_ctrl', 1)
                self.roach.write_int('snapPhase_ctrl', 0)
                self.roach.write_int('startSnap', 1)
                time.sleep(0.001)
                bin_data_phase = bin_data_phase + self.roach.read('snapPhase_bram', 4*L)    
            
            phase = []
            for m in range(steps*L):
                phase.append(struct.unpack('>h', bin_data_phase[m*4+2:m*4+4])[0])
                phase.append(struct.unpack('>h', bin_data_phase[m*4+0:m*4+2])[0])
            phase = numpy.array(phase)
            #phase_avg = numpy.median(phase)
            #sigma = phase.std()

            n,bins= numpy.histogram(phase,bins=100)
            n = numpy.array(n,dtype='float32')/numpy.sum(n)
            tot = numpy.zeros(len(bins))
            for i in xrange(len(bins)):
                tot[i] = numpy.sum(n[:i])
            bins1 = .5*(bins[1:]+bins[:-1])
            med = bins[self.find_nearest(tot,0.5)]
            thresh = bins[self.find_nearest(tot,0.05)]
            #threshold = int(med-Nsigma*abs(med-thresh))
            threshold = int(-Nsigma*abs(med-thresh))
            
            scale_to_angle = 360./2**16*4/numpy.pi
            #threshold = int((phase_avg - Nsigma*sigma))
            # -25736 = -180 degrees
            if threshold < -25736:
                threshold = -25736
            self.thresholds[ch] = scale_to_angle*threshold
            self.medians[ch] = scale_to_angle*med

            self.roach.write_int('capture_threshold', threshold)
            self.roach.write_int('capture_load_thresh', (ch<<1)+(1<<0))
            self.roach.write_int('capture_load_thresh', (ch<<1)+(0<<0))
            print "channel: ", ch, "median: ", scale_to_angle*med, "threshold: ", scale_to_angle*threshold
            #print "channel: ", ch, "avg: ", scale_to_angle*phase_avg, "sigma: ", scale_to_angle*sigma, "threshold: ", scale_to_angle*threshold
        
    def snapshot(self):        
        ch_we = int(self.textbox_channel.text())
        self.roach.write_int('ch_we', ch_we)
        #print self.roach.read_int('ch_we')
        
        steps = int(self.textbox_timeLengths.text())
        L = 2**10
        bin_data_phase = ''
        for n in range(steps):
            self.roach.write_int('startSnap', 0)
            self.roach.write_int('snapPhase_ctrl', 1)
            self.roach.write_int('snapPhase_ctrl', 0)
            self.roach.write_int('startSnap', 1)
            time.sleep(0.001)
            bin_data_phase = bin_data_phase + self.roach.read('snapPhase_bram', 4*L)    
            
        phase = []
        for m in range(steps*L):
            phase.append(struct.unpack('>h', bin_data_phase[m*4+2:m*4+4])[0])
            phase.append(struct.unpack('>h', bin_data_phase[m*4+0:m*4+2])[0])
        phase = numpy.array(phase)*360./2**16*4/numpy.pi

        self.axes1.clear()
        #self.axes1.plot(phase, '.-', [self.thresholds[ch_we]]*2*L*steps, 'r.', [self.medians[ch_we]]*2*L*steps, 'g.')
        self.axes1.plot(phase, '.-', [self.thresholds[ch_we]+self.medians[ch_we]]*2*L*steps, 'r.', [self.medians[ch_we]]*2*L*steps, 'g.')
        self.canvas.draw()

    def readPulses(self):
        scale_to_degrees = 360./2**12*4/numpy.pi
        channel_count = [0]*256
        p1 = [[]]*256
        timestamp = [[]]*256
        for i in range(256):
            p1[i] = [0]
            timestamp[i] = [0]
            
        seconds = int(self.textbox_seconds.text())
        self.roach.write_int('startBuffer', 1)
        for n in range(seconds):
            addr0 = self.roach.read_int('pulses_addr')
            time.sleep(1.0)
            addr1 = self.roach.read_int('pulses_addr')
            bin_data_0 = self.roach.read('pulses_bram0', 4*2**14)
            bin_data_1 = self.roach.read('pulses_bram1', 4*2**14)

            if addr1 >= addr0:
                total_counts = addr1-addr0
                for n in range(addr0, addr1):
                    raw_data_1 = struct.unpack('>L', bin_data_1[n*4:n*4+4])[0]
                    raw_data_0 = struct.unpack('>L', bin_data_0[n*4:n*4+4])[0]
                    ch = raw_data_1/2**24
                    channel_count[ch] = channel_count[ch] + 1
                    p1[ch].append((raw_data_1%2**12 - 2**11)*scale_to_degrees)
                    timestamp[ch].append(raw_data_0%2**20)
            else:
                total_counts = addr1+2**14-addr0
                for n in range(addr0, 2**14):
                    raw_data_1 = struct.unpack('>L', bin_data_1[n*4:n*4+4])[0]
                    raw_data_0 = struct.unpack('>L', bin_data_0[n*4:n*4+4])[0]
                    ch = raw_data_1/2**24
                    channel_count[ch] = channel_count[ch] + 1
                    p1[ch].append((raw_data_1%2**12 - 2**11)*scale_to_degrees)
                    timestamp[ch].append(raw_data_0%2**20)
                for n in range(0, addr1):
                    raw_data_1 = struct.unpack('>L', bin_data_1[n*4:n*4+4])[0]
                    raw_data_0 = struct.unpack('>L', bin_data_0[n*4:n*4+4])[0]
                    ch = raw_data_1/2**24
                    channel_count[ch] = channel_count[ch] + 1
                    p1[ch].append((raw_data_1%2**12 - 2**11)*scale_to_degrees)
                    timestamp[ch].append(raw_data_0%2**20)
            print total_counts
        self.roach.write_int('startBuffer', 0)

        print channel_count
        ch = int(self.textbox_channel.text())
        numpy.savetxt('/home/sean/data/restest/test.dat', p1[ch])
        
        # With lamp off, run "readPulses."  If count rate is above 50, it's anamolous 
        # and it's FIR should be set to 0.
        #for n in range(256):
         #   if channel_count[n] > 100:
          #      self.zeroChannels[n] = 1   
        
        #x = numpy.arange(-270, 0, 3)
        #y = numpy.histogram(data, 90)
        self.axes0.clear()
        self.axes0.plot(timestamp[ch], '.')
        self.canvas.draw()

    def channelInc(self):
        ch_we = int(self.textbox_channel.text())
        ch_we = ch_we + 1
        self.textbox_channel.setText(str(ch_we))
        
    def toggleDAC(self):
        if self.dacStatus == 'off':
            print "Starting LUT...",
            self.roach.write_int('startDAC', 1)
            time.sleep(1)
            while self.roach.read_int('DRAM_LUT_rd_valid') != 0:
                self.roach.write_int('startDAC', 0)
                time.sleep(0.25)
                self.roach.write_int('startDAC', 1)
                time.sleep(1)
                print ".",
            print "done."
            #self.button_startDAC.setText('Stop DAC')
            self.dacStatus = 'on'
	    self.status_text.setText('DAC turned on. ')       
        else:
            self.roach.write_int('startDAC', 0)
            #self.button_startDAC.setText('Start DAC')
            self.dacStatus = 'off'
	    self.status_text.setText('DAC turned off. ')       

    def loadIQcenters(self):
        for ch in range(256):
            I_c = int(self.iq_centers[ch].real/2**3)
            Q_c = int(self.iq_centers[ch].imag/2**3)

            center = (I_c<<16) + (Q_c<<0)
            self.roach.write_int('conv_phase_centers', center)
            self.roach.write_int('conv_phase_load_centers', (ch<<1)+(1<<0))
            self.roach.write_int('conv_phase_load_centers', 0)

    def select_bins(self, readout_freqs):
        fft_len = 2**9
        bins = ''
        i = 0
        residuals = []
        for f in readout_freqs:
            fft_bin = int(round(f*fft_len/self.sampleRate))
            fft_freq = fft_bin*self.sampleRate/fft_len
            freq_residual = round((f - fft_freq)/self.freqRes)*self.freqRes
            residuals.append(freq_residual)
            bins = bins + struct.pack('>l', fft_bin)
            self.roach.write_int('bins', fft_bin)
            self.roach.write_int('load_bins', (i<<1) + (1<<0))
            self.roach.write_int('load_bins', (i<<1) + (0<<0))
            i = i + 1
        self.status_text.setText('done writing LUTs. ')
        return residuals
  
    def loadLUTs(self):
        self.scale_factor = 1.
        self.iq_centers = numpy.array([0.+0j]*256)
        
        # Loads the DAC and DDS LUTs from file.  As well as the IQ loop centers.
        if self.dacStatus == 'off':
            self.roach.write_int('startDAC', 0)
        else:
            self.toggleDAC()

        saveDir = str(self.textbox_lutDir.text())
        #saveDir = str(os.environ['PWD'] + '/'+ self.textbox_lutDir.text())            
        f = open(saveDir+'luts.dat', 'r')
        binaryData = f.read()

        self.roach.write('dram_memory', binaryData)

        x = numpy.loadtxt(saveDir+'centers.dat')
        N_freqs = len(x[:,0])
        for n in range(N_freqs):
            self.iq_centers[n] = complex(x[n,0], x[n,1])
        
        #    Select and write bins for first stage of channelizer.
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        f_base = float(self.textbox_loFreq.text())
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + 512e6
        freqs_dds = [0 for j in range(256)]
        for n in range(len(freqs)):
            freqs_dds[n] = round((freqs[n]-f_base)/self.freqRes)*self.freqRes
        freq_residuals = self.select_bins(freqs_dds)
        
        print 'LUTs and IQ centers loaded from file.'
        self.loadIQcenters()
        self.toggleDAC()
   
    def importFreqs(self):
        freqFile =str(self.textbox_freqFile.text())
        x = numpy.loadtxt(freqFile) 
        x_string = ''
        
        self.previous_scale_factor = x[0,0] 
        N_freqs = len(x[1:,0])
        for l in x[1:,0]:
            x_string = x_string + str(l*1e9) + '\n'
            
        self.iq_centers = numpy.array([0.+0j]*256)
        for n in range(N_freqs):
            #for n in range(256):
            self.iq_centers[n] = complex(x[n+1,1], x[n+1,2])
            
        self.attens = x[1:,3]
        self.textedit_DACfreqs.setText(x_string)

        self.zeroChannels = [0]*256
        
    def importFIRcoeffs(self):
        coeffsFile =str(self.textbox_coeffsFile.text())
        x = numpy.loadtxt(coeffsFile)
  
    def file_dialog(self):
        print 'add dialog box here'
        #self.newdatadir = QFileDialog.getExistingDirectory(self, str("Choose SaveDirectory"), "",QFileDialog.ShowDirsOnly)
         #if len(self.newdatadir) > 0:
          #   self.datadir = self.newdatadir
           #  print self.datadir
             #self.ui.data_directory_lineEdit.setText(self.datadir) #put new path name in line edit
            # self.button_saveDir.setText(str(self.datadir))
             
    def create_main_frame(self):
        self.main_frame = QWidget()
        
        # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((9.0, 5.0), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes0 = self.fig.add_subplot(121)
        self.axes1 = self.fig.add_subplot(122)
        
        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        
        # Roach board's IP address
        self.textbox_roachIP = QLineEdit('10.0.0.10')
        self.textbox_roachIP.setMaximumWidth(200)
        label_roachIP = QLabel('Roach IP Address:')

        # Start connection to roach.
        self.button_openClient = QPushButton("(1)Open Client")
        self.button_openClient.setMaximumWidth(100)
        self.connect(self.button_openClient, SIGNAL('clicked()'), self.openClient)
        
        # DAC Frequencies.
        self.textedit_DACfreqs = QTextEdit()
        self.textedit_DACfreqs.setMaximumWidth(170)
        self.textedit_DACfreqs.setMaximumHeight(100)
        label_DACfreqs = QLabel('DAC Freqs:')
    
        # File with frequencies/attens
        self.textbox_freqFile = QLineEdit('/home/sean/data/20120827/ps_freq0.txt')
        self.textbox_freqFile.setMaximumWidth(200)

        # Import freqs from file.
        self.button_importFreqs = QPushButton("(2)Load freqs")
        self.button_importFreqs.setMaximumWidth(200)
        self.connect(self.button_importFreqs, SIGNAL('clicked()'), self.importFreqs)   

        # File with FIR coefficients
        self.textbox_coeffsFile = QLineEdit('/home/sean/data/20110803/r0/')
        self.textbox_coeffsFile.setMaximumWidth(200)

        # Import FIR coefficients from file.
        self.button_importFIRcoeffs = QPushButton("Import FIR coeffs.")
        self.button_importFIRcoeffs.setMaximumWidth(200)
        self.connect(self.button_importFIRcoeffs, SIGNAL('clicked()'), self.importFIRcoeffs) 

        # Channel increment by 1.
        self.button_channelInc = QPushButton("Channel++")
        self.button_channelInc.setMaximumWidth(100)
        self.connect(self.button_channelInc, SIGNAL('clicked()'), self.channelInc)

        # Load FIR coefficients.
        self.button_loadFIRcoeffs = QPushButton("(3)load FIR")
        self.button_loadFIRcoeffs.setMaximumWidth(170)
        self.connect(self.button_loadFIRcoeffs, SIGNAL('clicked()'), self.loadFIRcoeffs)

        # Load thresholds.
        self.button_loadThresholds = QPushButton("(4)load thresholds")
        self.button_loadThresholds.setMaximumWidth(170)
        self.connect(self.button_loadThresholds, SIGNAL('clicked()'), self.loadThresholds)
        
        # Channel to measure
        self.textbox_channel = QLineEdit('0')
        self.textbox_channel.setMaximumWidth(50)

        # threshold N*sigma
        self.textbox_Nsigma = QLineEdit('5.0')
        self.textbox_Nsigma.setMaximumWidth(50)
        label_Nsigma = QLabel('sigma       ')
        
        # Time snapshot of a single channel
        self.button_snapshot = QPushButton("snapshot")
        self.button_snapshot.setMaximumWidth(170)
        self.connect(self.button_snapshot, SIGNAL('clicked()'), self.snapshot)            
        
        # Read pulses
        self.button_readPulses = QPushButton("Read pulses")
        self.button_readPulses.setMaximumWidth(170)
        self.connect(self.button_readPulses, SIGNAL('clicked()'), self.readPulses)   
        
        # Seconds for "read pulses."
        self.textbox_seconds = QLineEdit('10')
        self.textbox_seconds.setMaximumWidth(50)
        
        # lengths of 1 ms for defining thresholds.
        self.textbox_timeLengths = QLineEdit('10')
        self.textbox_timeLengths.setMaximumWidth(50)
        label_timeLengths = QLabel('mSeconds       ')
        
        # Add widgets to window.
        gbox0 = QVBoxLayout()
        hbox00 = QHBoxLayout()
        hbox00.addWidget(self.textbox_roachIP)
        hbox00.addWidget(self.button_openClient)
        gbox0.addLayout(hbox00)
        hbox01 = QHBoxLayout()
        hbox01.addWidget(self.textbox_freqFile)
        hbox01.addWidget(self.button_importFreqs)
        gbox0.addLayout(hbox01)
        hbox02 = QHBoxLayout()
        hbox02.addWidget(self.textbox_coeffsFile)
        hbox02.addWidget(self.button_importFIRcoeffs)
        hbox02.addWidget(self.button_loadFIRcoeffs)
        gbox0.addLayout(hbox02)
        hbox03 = QHBoxLayout()
        hbox03.addWidget(self.textbox_timeLengths)
        hbox03.addWidget(label_timeLengths)
        hbox03.addWidget(self.textbox_Nsigma)
        hbox03.addWidget(label_Nsigma)
        hbox03.addWidget(self.button_loadThresholds)
        gbox0.addLayout(hbox03)
        
        gbox1 = QVBoxLayout()
        gbox1.addWidget(label_DACfreqs)
        gbox1.addWidget(self.textedit_DACfreqs)

        gbox2 = QVBoxLayout()
        hbox20 = QHBoxLayout()
        hbox20.addWidget(self.textbox_channel)
        hbox20.addWidget(self.button_channelInc)
        gbox2.addLayout(hbox20)
        gbox2.addWidget(self.button_snapshot)
        hbox21 = QHBoxLayout()
        hbox21.addWidget(self.textbox_seconds)
        hbox21.addWidget(self.button_readPulses)
        gbox2.addLayout(hbox21)


        hbox = QHBoxLayout()
        hbox.addLayout(gbox0)
        hbox.addLayout(gbox1)     
        hbox.addLayout(gbox2)
        
        vbox = QVBoxLayout()
        vbox.addWidget(self.canvas)
        vbox.addWidget(self.mpl_toolbar)
        vbox.addLayout(hbox)
        
        self.main_frame.setLayout(vbox)
        self.setCentralWidget(self.main_frame)
  
    def create_status_bar(self):
        self.status_text = QLabel("Awaiting orders.")
        self.statusBar().addWidget(self.status_text, 1)
        
    def create_menu(self):        
        self.file_menu = self.menuBar().addMenu("&File")
        
        load_file_action = self.create_action("&Save plot",shortcut="Ctrl+S", slot=self.save_plot, tip="Save the plot")
        quit_action = self.create_action("&Quit", slot=self.close, shortcut="Ctrl+Q", tip="Close the application")
        
        self.add_actions(self.file_menu, (load_file_action, None, quit_action))
        
        self.help_menu = self.menuBar().addMenu("&Help")
        about_action = self.create_action("&About", shortcut='F1', slot=self.on_about, tip='About the demo')
        
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
        path = unicode(QFileDialog.getSaveFileName(self, 'Save file', '',file_choices))
        if path:
            self.canvas.print_figure(path, dpi=self.dpi)
            self.statusBar().showMessage('Saved to %s' % path, 2000)
    
    def on_about(self):
        msg = """ Message to user goes here.
        """
        QMessageBox.about(self, "MKID-ROACH software demo", msg.strip())

def main():
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    app.exec_()


if __name__ == "__main__":
    main()
