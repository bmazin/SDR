import sys, os, random, math, array, fractions
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4 import QtGui
import socket
import matplotlib, corr, time, struct, numpy
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
from tables import *
from lib import iqsweep


#Things to update:
#DONE...make filename_NEW.txt only hold information for channel that is changed
#DONE...delete resonator (change FIR?)
#click to change freq
#custom set center



if __name__ == '__main__':
    if len(sys.argv) != 2:
        print 'Usage: ',sys.argv[0],' roachNo'
        exit(1)
    roachNo = int(sys.argv[1])
    datadir = os.environ['MKID_FREQ_PATH']#'/home/sean/data/20121105adr/'
    print datadir
    configFile = numpy.loadtxt(os.path.join(datadir,'roachConfig.txt'))
    configFile = numpy.reshape(configFile,(-1,2))
    try:
        scaleFactorFile = numpy.loadtxt(os.path.join(datadir,'scaleFactors.txt'))
        defaultScale = float(scaleFactorFile[:,1][roachNo])
    except:
        defaultScale = 10.
    defaultLOFreqs = configFile[:,0]
    defaultAttens = configFile[:,1]
    defaultLOFreq = defaultLOFreqs[roachNo]
    defaultAtten = int(defaultAttens[roachNo])


    MAX_ATTEN = 99

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.setWindowTitle('Templar_2')
        self.create_menu()
        self.create_main_frame()
        self.create_status_bar()
        self.dacStatus = 'off'
        self.dramStatus = 'off'
        self.tapStatus = 'off'
        self.socketStatus = 'off'
        self.ch_all = []
        self.attens = numpy.array([1. for i in range(256)])
        #self.freqRes = 1953.125
        #self.freqRes = 7812.5
        self.sampleRate = 512e6
        N_lut_entries = 2**16
        self.freqRes = self.sampleRate/N_lut_entries
        #self.iq_centers = numpy.array([0.+0j]*256)
        self.customResonators=numpy.array([[0.0,-1]]*256)	#customResonator[ch]=[freq,atten]
        self.last_I_on_res = None
        self.last_Q_on_res = None
        self.last_I = None
        self.last_Q = None
        self.last_iq_centers = None
        self.last_IQ_vels = None
        self.last_f_span = None
        self.I = None
        self.Q = None
        self.I_on_res = None
        self.Q_on_res = None
        self.iq_centers = None
        self.IQ_vels = None
        self.f_span = None
        self.last_scale_factor = None

        
    def openClient(self):
        self.status_text.setText('connecting...')
        #self.QApplication.processEvents()
        print 'connecting...'
        self.roach = corr.katcp_wrapper.FpgaClient(self.textbox_roachIP.text(),7147)
        time.sleep(2)
        self.status_text.setText('connection established')
        print 'connection established to',self.textbox_roachIP.text()
        self.button_openClient.setDisabled(True)

    def programRFswitches(self, regStr = '10110'):
        #    5 bit word: LO_int/ext, RF_loop, LO_source(doubler), BB_loop, Ck_int/ext
        #regStr = self.textbox_rfSwReg.text()
        print int(regStr[0]), int(regStr[1]), int(regStr[2]),int(regStr[3]), int(regStr[4])

        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('if_switch', 1)
        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[0])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[0])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[0])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[1])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[1])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[1])<<2)+(0<<1)+(0<<0))                
        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[2])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[2])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[2])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[3])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[3])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[3])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[4])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[4])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(int(regStr[4])<<2)+(0<<1)+(0<<0))   

        # Now clock out the data written to the reg.
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))   
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))                        
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(1<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('if_switch', 0)
        
    def programAttenuators(self, atten_in_desired, atten_out_desired):
        #    There are eight settings for each attenuator:
        #    0db, -0.5, -1, -2, -4, -8, -16, and -31.5, which
        #    are listed in order in "attenuations."    
        #atten_in_desired = float(self.textbox_atten_in.text())
        atten_in = 63 - int(atten_in_desired*2)
        
        #atten_out_desired = float(self.textbox_atten_out.text())
        if atten_out_desired <= 31.5:
            atten_out0 = 63
            atten_out1 = 63 - int(atten_out_desired*2)
        else:
            atten_out0 = 63 - int((atten_out_desired-31.5)*2)
            atten_out1 = 0

        print "templarCustom.programAttenuators:  atten_in_desired=",atten_in_desired," atten_out_desired=",atten_out_desired," atten_out0=",atten_out0," atten_out1=",atten_out1
        reg = numpy.binary_repr((atten_in<<12)+(atten_out0<<6)+(atten_out1<<0))
        b = '0'*(18-len(reg)) + reg
        print reg, len(reg)
        self.roach.write_int('regs', (0<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('if_switch', 1)
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(0<<1)+(0<<0))

        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(0<<1)+(0<<0))

        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(0<<1)+(0<<0))

        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(0<<1)+(0<<0))
        
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(1<<1)+(0<<0))
        self.roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(0<<1)+(0<<0))
        self.roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        self.roach.write_int('if_switch', 0)
        
    def programLO(self, freq=3.2e9, sweep_freq=0):
        f_pfd = 10e6
        if sweep_freq:
            f = freq
        else:
            f = float(self.textbox_loFreq.text())
        if f >= 4.4e9:
            f = f/2
            
        INT = int(f)/int(f_pfd)
        MOD = 2000
        FRAC = int(round(MOD*(f/f_pfd-INT)))
        if FRAC != 0:
            gcd = fractions.gcd(MOD,FRAC)
            if gcd != 1:
                MOD = MOD/gcd
                FRAC = int(FRAC/gcd)
        PHASE = 1
        R = 1
        power = 3
        #print "aux Power = 0"
        aux_power = 3
        MUX = 3
        LOCK_DETECT = 1
        reg5 = (LOCK_DETECT<<22) + (1<<2) + (1<<0)
        reg4 = (1<<23) + (1<<18) + (1<<16) + (1<<8) + (aux_power<<6) + (1<<5) + (power<<3) + (1<<2)
        reg3 = (1<<10) + (1<<7) + (1<<5) + (1<<4) + (1<<1) + (1<<0)
        reg2 = (MUX<<26) + (R<<14) + (1<<11) + (1<<10) + (1<<9) + (1<<7) + (1<<6) + (1<<1)
        reg1 = (1<<27) + (PHASE<<15) + (MOD<<3) + (1<<0)
        reg0 = (INT<<15) + (FRAC<<3)
        
        regs = [reg5, reg4, reg3, reg2, reg1, reg0]
        
        for r in regs:
            self.roach.write_int('SER_DI', r)
            self.roach.write_int('LO_SLE', 1)
            self.roach.write_int('start', 1)
            self.roach.write_int('start', 0)
            self.roach.write_int('LO_SLE', 0)

        #self.status_text.setText('LO programmed. ')
        #print 'LO programmed. '

    def define_LUTs(self):
        if hasattr(self,'roach'):
            if hasattr(self,'minimumAttenuation'):
                print 'Defining LUTs...'
                self.status_text.setText('Defining LUTs.')
                self.iq_centers = numpy.array([0.+0j]*256)
                self.define_DAC_LUT()
                self.status_text.setText('Defining LUTs..')
                self.define_DDS_LUT()
                self.status_text.setText('Defining LUTs...')
                self.write_LUTs()
                #self.loadLUTs()
                self.status_text.setText('done writing LUTs. ')
                print "luts defined and loaded."
            else:
                self.status_text.setText('Need to load Freq/Atten first')
                print "AttributeError: 'AppForm' object has no attribute 'minimumAttenuation'"
        else:
            self.status_text.setText('Need to connect to roach first')
            print "AttributeError: 'AppForm' object has no attribute 'roach'"
        
    def freqCombLUT(self, echo, freq, sampleRate, resolution, amplitude=[1.]*256, phase=[0.]*256, random_phase = 'yes'):
        offset = int(self.textbox_offset.text())
        bKeepOldScale = self.cbox_keepScaleFactor.isChecked()
        bUseCustomScale = self.cbox_useScaleFactor.isChecked()
        amp_full_scale = 2**15-1
        N_freqs = len(freq)
        size = int(sampleRate/resolution)
        I, Q = numpy.array([0.]*size), numpy.array([0.]*size)
        single_I, single_Q = numpy.array([0.]*size), numpy.array([0.]*size)
        
        numpy.random.seed(1000)
        for n in range(N_freqs):
            if random_phase == 'yes':
                phase[n] = numpy.random.uniform(0, 2*numpy.pi)
                
            #start_x = phase[n]+2*numpy.pi*freq[n]*offset/sampleRate
            #end_x = phase[n]+2*numpy.pi*freq[n]*(size+offset)/sampleRate
            #x = numpy.linspace(start_x, end_x, size)
            
            #start_y = phase[n]
            #end_y = phase[n]+2*numpy.pi*freq[n]*(size)/sampleRate
            #y = numpy.linspace(start_y, end_y, size)
            
            x = [2*numpy.pi*freq[n]*(t+offset)/sampleRate+phase[n] for t in range(size)]
            y = [2*numpy.pi*freq[n]*t/sampleRate+phase[n] for t in range(size)]
            
            single_I = amplitude[n]*numpy.cos(x)
            single_Q = amplitude[n]*numpy.sin(y)

            I = I + single_I
            Q = Q + single_Q
        
        a = numpy.array([abs(I).max(), abs(Q).max()])
        scale_factor = a.max()
        scaleFudgeFactor = 1.1 #don't scale to the max value, but get close
        if echo == 'yes':
            scale_factor = scaleFudgeFactor*scale_factor
            if bKeepOldScale == True and self.last_scale_factor != None:
                scale_factor = self.last_scale_factor
            if bUseCustomScale == True:
                scale_factor = float(self.textbox_customScale.text())
            self.scale_factor = scale_factor
        I = numpy.array([int(i*amp_full_scale/scale_factor) for i in I])
        Q = numpy.array([int(q*amp_full_scale/scale_factor) for q in Q])
        if echo == 'yes':
            self.last_scale_factor = self.scale_factor
            print 'max V value:', a.max()
            print 'scale factor: ', self.scale_factor
            atten_out_guess=20*numpy.log10(self.previous_scale_factor/self.scale_factor) + self.minimumAttenuation
            print 'Set atten_out to: ', atten_out_guess
            atten_out_guess=int(atten_out_guess)+1
            if atten_out_guess < 0:
                atten_out_guess = -1*atten_out_guess
            #self.textbox_powerSweepStart.setText(str(atten_out_guess))
            #self.textbox_powerSweepStop.setText(str(atten_out_guess))
            
        return I, Q
        
    def define_DAC_LUT(self):
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        f_base = float(self.textbox_loFreq.text())
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + self.sampleRate  #512e6
        self.freqs_dac = [round((f-f_base)/self.freqRes)*self.freqRes for f in freqs]
        atten_min = self.attens.min()
        print "minimum attenuation: ", self.minimumAttenuation
        amplitudes = [10**(+(atten_min-a)/20.) for a in self.attens]
        self.I_dac, self.Q_dac = self.freqCombLUT('yes', self.freqs_dac, self.sampleRate, self.freqRes, amplitudes)
        #self.status_text.setText('done defining DAC freqs. ')
        print 'done defining DAC freqs.'
        
    def define_DDS_LUT(self, phase = [0.]*256):
        fft_len=2**9
        ch_shift = int(self.textbox_dds_shift.text())
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        f_base = float(self.textbox_loFreq.text())
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + self.sampleRate  #512e6

        freqs_dds = [0 for j in range(256)]
        for n in range(len(freqs)):
            freqs_dds[n] = round((freqs[n]-f_base)/self.freqRes)*self.freqRes

        freq_residuals = self.select_bins(freqs_dds)

        L = int(self.sampleRate/self.freqRes)
        self.I_dds, self.Q_dds = [0.]*L, [0.]*L
        for m in range(256):
            #I, Q = self.freqCombLUT('no', [freq_residuals[m]], 2e6, self.freqRes, [1.], [phase[m]], 'no')
            I, Q = self.freqCombLUT('no', [freq_residuals[m]], self.sampleRate/fft_len*2, self.freqRes, [1.], [phase[m]], 'no')
            for j in range(len(I)/2):
                self.I_dds[j*512+2*((m+ch_shift)%256)] = I[2*j]
                self.I_dds[j*512+2*((m+ch_shift)%256)+1] = I[2*j+1]
                self.Q_dds[j*512+2*((m+ch_shift)%256)] = Q[2*j]
                self.Q_dds[j*512+2*((m+ch_shift)%256)+1] = Q[2*j+1]

        print "done defing dds freqs. "

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
        #self.status_text.setText('done writing LUTs. ')
        return residuals
    
    def write_LUTs(self):
        if self.dacStatus == 'off':
            self.roach.write_int('startDAC', 0)		#make sure it's actually off
        else:
            self.toggleDAC()
            
        numpy.savez('dac.npy',I_dac=self.I_dac,Q_dac=self.Q_dac,I_dds=self.I_dds,Q_dds=self.Q_dds)
        binaryData = ''
        for n in range(len(self.I_dac)/2):
            i_dac_0 = struct.pack('>h', self.I_dac[2*n])
            i_dac_1 = struct.pack('>h', self.I_dac[2*n+1])
            i_dds_0 = struct.pack('>h', self.I_dds[2*n])
            i_dds_1 = struct.pack('>h', self.I_dds[2*n+1])
            q_dac_0 = struct.pack('>h', self.Q_dac[2*n])
            q_dac_1 = struct.pack('>h', self.Q_dac[2*n+1])
            q_dds_0 = struct.pack('>h', self.Q_dds[2*n])
            q_dds_1 = struct.pack('>h', self.Q_dds[2*n+1])
            binaryData = binaryData + q_dds_1 + q_dds_0 + q_dac_1 + q_dac_0 + i_dds_1 + i_dds_0 + i_dac_1 + i_dac_0
        self.roach.write('dram_memory', binaryData)


        # Write LUTs to file.
        saveDir = str(self.textbox_saveDir.text())
        f = open(os.path.join(saveDir,'luts.dat'), 'w')
        f.write(binaryData)
        f.close()
        print 'LUTs saved in: ',saveDir

    def translateLoops(self):
        if not hasattr(self,'iq_centers'):
            self.status_text.setText('Need to load Freq/Atten first')
            print "AttributeError: 'AppForm' object has no attribute 'iq_centers'"
        elif not hasattr(self,'roach'):
            self.status_text.setText('Need to connect to roach first')
            print "AttributeError: 'AppForm' object has no attribute 'roach'"
        else:
            self.status_text.setText('Translating...')
            print "Starting loop translation"
            self.loadIQcenters()
            print "Done loop translations"
            self.status_text.setText('Translations...DONE')
            

    def loadIQcenters(self):
        saveDir = str(self.textbox_saveDir.text())
        centers_for_file = [[0., 0.]]*256
        for ch in range(256):
            I_c = int(self.iq_centers[ch].real/2**3)
            Q_c = int(self.iq_centers[ch].imag/2**3)

            center = (I_c<<16) + (Q_c<<0)
            self.roach.write_int('conv_phase_centers', center)
            self.roach.write_int('conv_phase_load_centers', (ch<<1)+(1<<0))
            self.roach.write_int('conv_phase_load_centers', 0)
        
            centers_for_file[ch] = [self.iq_centers[ch].real, self.iq_centers[ch].imag]
            
        numpy.savetxt(os.path.join(saveDir,'centers.dat'), centers_for_file)

    def findIQcenters(self, I, Q):
        I_0 = (I.max()+I.min())/2.
        Q_0 = (Q.max()+Q.min())/2.
                
        return complex(I_0, Q_0)
    
    def rotateLoops(self):
        if not hasattr(self,'roach'):
            self.status_text.setText('Need to connect to roach first')
            print "AttributeError: 'AppForm' object has no attribute 'roach'"
        #elif not hasattr(self,'iq_centers'):
        #    self.status_text.setText('Need to load Freq/Atten first')
        #    print "AttributeError: 'AppForm' object has no attribute 'iq_centers'"
        elif not hasattr(self,'I_dac'):
            self.status_text.setText('Need to define LUTs first')
            print "AttributeError: 'AppForm' object has no attribute 'scale_factor'"
        else:
            if self.dacStatus == 'off':
                print 'Error: The DAC is currently off!'
            self.status_text.setText('Rotating...')
            print "Starting loop rotations"
            self.rotateLoopsReady()
            self.status_text.setText('Rotations...DONE')

    def rotateLoopsReady(self):
        print "Calculating loop rotations..."
        self.status_text.setText('Calculating loop rotations...')
        dac_freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        N_freqs = len(dac_freqs)
        phase = [0.]*256
        
        self.roach.write_int('startAccumulator', 0)
        self.roach.write_int('avgIQ_ctrl', 1)
        self.roach.write_int('avgIQ_ctrl', 0)
        self.roach.write_int('startAccumulator', 1)
        time.sleep(0.001)
        data = self.roach.read('avgIQ_bram', 4*2*256)
        for n in range(N_freqs):
            I = struct.unpack('>l', data[4*n:4*n+4])[0]-self.iq_centers[n].real
            Q = struct.unpack('>l', data[4*(n+256):4*(n+256)+4])[0]-self.iq_centers[n].imag
            
            phase[n] = numpy.arctan2(Q, I)

        self.define_DDS_LUT(phase)
        self.write_LUTs()
        """ Since the DAC is toggled OFF in write_LUTs, it needs to be turned back on with the following.
            """
        self.toggleDAC()
        self.sweepLO()
            
    def sweepLO(self):
        if not hasattr(self,'roach'):
            self.status_text.setText('Need to connect to roach first')
            print "AttributeError: 'AppForm' object has no attribute 'roach'"
        elif not hasattr(self,'iq_centers'):
            self.status_text.setText('Need to load Freq/Atten first')
            print "AttributeError: 'AppForm' object has no attribute 'iq_centers'"
        elif not hasattr(self,'scale_factor'):
            self.status_text.setText('Need to define LUTs first')
            print "AttributeError: 'AppForm' object has no attribute 'scale_factor'"
        else:
            if self.dacStatus == 'off':
                print 'Error: The DAC is currently off!'
            self.status_text.setText('Sweeping.')
            print "Starting sweep"
            self.sweepLOready()
            self.status_text.setText('Sweeping...DONE')

    def toggleShowPrevious(self):
        self.showPrevious = not self.showPrevious
        if self.showPrevious:
            self.button_showPrevious.setStyleSheet("background-color: #00ff00")
        else:
            self.button_showPrevious.setStyleSheet("background-color: #ff0000")
        print "in toggleShowPrevious:  showPrevious=",self.showPrevious

    def sweepLOready(self):
        atten_in = float(self.textbox_atten_in.text())
        saveDir = str(self.textbox_saveDir.text())
        savefile = os.path.join(saveDir,'ps_r%d_'%roachNo + time.strftime("%Y%m%d-%H%M%S",time.localtime())+'.h5')
        print "in sweelLOready:  savefile=",savefile
        dac_freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        self.N_freqs = len(dac_freqs)
        f_base = float(self.textbox_loFreq.text())
        
        if f_base >= 4.4e9:
            self.programRFswitches('10010')
            print 'LO doubled.'
        else:
            self.programRFswitches('10110')
            print 'LO normal operation.'
        loSpan = float(self.textbox_loSpan.text())
        df = 1e4
        steps = int(loSpan/df)
        print "LO steps: ", steps
        lo_freqs = [f_base+i*df-0.5*steps*df for i in range(steps)]
        
        atten_start = int(self.textbox_powerSweepStart.text())
        atten_stop = int(self.textbox_powerSweepStop.text())
        if atten_start <= atten_stop:
            attens = [i for i in range(atten_start, atten_stop+1)]
        else:
            attens = [i for i in range(atten_start, atten_stop-1, -1)]

        if len(attens) > 1:
            print 'Saving to ',savefile
        for a in attens:
            print a
            self.programAttenuators(atten_in, a)
            time.sleep(0.5)
            if self.f_span != None:
                self.last_f_span = self.f_span
            f_span = []
            l = 0
            self.f_span = [[0]*steps]*self.N_freqs
            for f in dac_freqs:
                f_span = f_span + [f-0.5*steps*df+n*df for n in range(steps)]
                self.f_span[l] = [f-0.5*steps*df+n*df for n in range(steps)]
                l = l + 1

            if self.I != None:
               self.last_I = numpy.array(self.I) 
               self.last_Q = numpy.array(self.Q) 
               self.last_I_on_res = numpy.array(self.I_on_res) 
               self.last_Q_on_res = numpy.array(self.Q_on_res) 
               self.last_iq_centers = numpy.array(self.iq_centers) 
            I = numpy.zeros(self.N_freqs*steps, dtype='float32')
            Q = numpy.zeros(self.N_freqs*steps, dtype='float32')
            I_std = numpy.zeros(self.N_freqs*steps, dtype='float32')
            Q_std = numpy.zeros(self.N_freqs*steps, dtype='float32')

            self.I, self.Q = numpy.array([[0.]*steps]*self.N_freqs),numpy.array([[0.]*steps]*self.N_freqs)
            for i in range(steps):
                #print i
                self.programLO(lo_freqs[i],1)
                self.roach.write_int('startAccumulator', 0)
                self.roach.write_int('avgIQ_ctrl', 1)
                self.roach.write_int('avgIQ_ctrl', 0)
                self.roach.write_int('startAccumulator', 1)
                time.sleep(0.001)
                data = self.roach.read('avgIQ_bram', 4*2*256)
                for j in range(self.N_freqs):
                    I[j*steps+i] = struct.unpack('>l', data[4*j:4*j+4])[0]
                    Q[j*steps+i] = struct.unpack('>l', data[4*(j+256):4*(j+256)+4])[0]
                    I_std[j*steps+i] = 0
                    Q_std[j*steps+i] = 0
                    self.I[j, i] = I[j*steps+i]
                    self.Q[j, i] = Q[j*steps+i]
            self.programLO(f_base,1)
            
            # Find IQ centers.
            self.I_on_res, self.Q_on_res = [0.]*self.N_freqs, [0.]*self.N_freqs
            self.roach.write_int('startAccumulator', 0)
            self.roach.write_int('avgIQ_ctrl', 1)
            self.roach.write_int('avgIQ_ctrl', 0)
            self.roach.write_int('startAccumulator', 1)
            time.sleep(0.001)
            data = self.roach.read('avgIQ_bram', 4*2*256)
            for j in range(self.N_freqs):
                self.I_on_res[j] = struct.unpack('>l', data[4*j:4*j+4])[0]
                self.Q_on_res[j] = struct.unpack('>l', data[4*(j+256):4*(j+256)+4])[0]
                self.iq_centers[j] = self.findIQcenters(I[j*steps:j*steps+steps],Q[j*steps:j*steps+steps])
            
            
            N = steps*self.N_freqs
            #calculate IQ velocities (distances between points in IQ loop)
            if self.IQ_vels != None:
                self.last_IQ_vels = self.IQ_vels
            self.IQ_vels = numpy.zeros([self.N_freqs,steps-1])
            for ch in range(self.N_freqs):
                for iFreq,freq in enumerate(self.f_span[ch][0:-1]):
                    dI = self.I[ch][iFreq]-self.I[ch][iFreq+1]
                    dQ = self.Q[ch][iFreq]-self.Q[ch][iFreq+1]
                    self.IQ_vels[ch][iFreq] = numpy.sqrt(dI**2+dQ**2)

            if len(attens) > 1:
                for n in range(self.N_freqs):
                    w = iqsweep.IQsweep()
                    w.f0 = dac_freqs[n]/1e9
                    w.span = steps*df/1e6
                    w.fsteps = steps
                    #w.atten1 = a
                    w.atten1 = a + self.attens[n]
                    #w.atten1 = atten
                    # w.atten2 is actually the "scale factor" used in the DAC LUT
                    # generation.
                    w.atten2 = 0
                    w.scale = self.scale_factor
                    w.PreadoutdB = -w.atten1 - 20*numpy.log10(self.scale_factor)
                    w.Tstart = 0.100
                    w.Tend = 0.100
                    w.I0 = 0.0
                    w.Q0 = 0.0
                    w.resnum = n
                    w.freq =  numpy.array(f_span[n*steps:(n+1)*steps], dtype='float32')/1e9
                    w.I = I[n*steps:(n+1)*steps]
                    w.Q = Q[n*steps:(n+1)*steps]
                    w.Isd = I_std[n*steps:(n+1)*steps]
                    w.Qsd = Q_std[n*steps:(n+1)*steps]
                    w.time = time.time()
                    w.savenoise = 0
                    w.Save(savefile,'r0', 'a')
        self.axes0.clear()
        self.axes1.clear()
        try:
            self.axes0.semilogy(f_span, (I**2 + Q**2)**.5, '.-')
        except ValueError:
            pass
            
        self.axes1.plot(I, Q, '.-', self.iq_centers.real[0:self.N_freqs], self.iq_centers.imag[0:self.N_freqs], '.', self.I_on_res, self.Q_on_res, '.')
        self.canvas.draw()

    def toggleDAC(self):
        if self.dacStatus == 'off':
            if hasattr(self,'roach'):
                print "Starting DAC...",
                self.roach.write_int('startDAC', 1)
                time.sleep(1)
                while self.roach.read_int('DRAM_LUT_rd_valid') != 0:
                    time.sleep(0.25)
                    print "DRAM_LUD_rd_valid is not zero",self.roach.read_int('DRAM_LUT_rd_valid') 
                    self.roach.write_int('startDAC', 0)
                    time.sleep(0.25)
                    self.roach.write_int('startDAC', 1)
                    time.sleep(1)
                    print ".",
                    sys.stdout.flush()
                print "done."
                self.button_startDAC.setText('Stop DAC')
                self.dacStatus = 'on'
                self.status_text.setText('DAC turned on. ')
                self.square_DACindicate.setStyleSheet("QFrame { background-color: #00ff00 }")
                self.square_DACindicate.setFrameShadow(QtGui.QFrame.Sunken)
                self.square_DACindicate.setText('on')
            else:
                self.status_text.setText('Need to connect to roach first')
                print "AttributeError: 'AppForm' object has no attribute 'roach'"      
        else:
            self.roach.write_int('startDAC', 0)
            self.button_startDAC.setText('Start DAC')
            self.dacStatus = 'off'
            self.status_text.setText('DAC turned off. ')
            print 'DAC turned off'
            self.square_DACindicate.setStyleSheet("QFrame { background-color: #ff0000 }")
            self.square_DACindicate.setFrameShadow(QtGui.QFrame.Raised)
            self.square_DACindicate.setText('off')       

    def loadCustomAtten(self):
        freqFile =str(self.textbox_freqFile.text())
        newFreqFile = freqFile[:-4] + '_NEW.txt'
        self.customResonators=numpy.array([[0.0,-1]]*256)
        try:
            y=numpy.loadtxt(newFreqFile)
            #self.customResonators=numpy.array([[0.0,-1]]*256)
            if type(y[0]) == numpy.ndarray:
                for arr in y:
                    self.customResonators[int(arr[0])]=arr[1:3]
            else:
                self.customResonators[int(y[0])]=y[1:3]
            print 'Loaded custom resonator freq/atten from',newFreqFile
        except IOError:
            pass

    def loadFreqsAttens(self):
        f_base = float(self.textbox_loFreq.text())
        freqFile =str(self.textbox_freqFile.text())
        #print freqFile
        #newFreqFile = freqFile[:-4] + '_NEW.txt'
        #print newFreqFile
        self.loadCustomAtten()

        try:
            x = numpy.loadtxt(freqFile) 
            x_string = ''
            for i in range(len(self.customResonators)):
                if self.customResonators[i][1]!=-1:
                    x[i+1,0]=self.customResonators[i][0]
                    x[i+1,3]=self.customResonators[i][1]
        
            self.previous_scale_factor = x[0,0] 
            N_freqs = len(x[1:,0])
            f_offset = float(self.textbox_freqOffset.text())
            for l in x[1:,0]:
                x_string = x_string + str(l*1e9+f_offset) + '\n'
            
            self.iq_centers = numpy.array([0.+0j]*256)
            for n in range(N_freqs):
                #for n in range(256):
                self.iq_centers[n] = complex(x[n+1,1], x[n+1,2])
            
            self.attens = x[1:,3]
            #print 'attens list',self.attens
            #print self.attens[4]
            self.minimumAttenuation = numpy.array(x[1:,3]).min()
            self.textedit_DACfreqs.setText(x_string)
            print 'Freq/Atten loaded from',freqFile
            self.status_text.setText('Freq/Atten loaded')
        except IOError:
            print 'No such file or directory:',freqFile
            self.status_text.setText('IOError')
        

    def channelIncUp(self):
        ch = int(self.textbox_channel.text())
        ch = ch + 1
        ch = ch%self.N_freqs
        self.textbox_channel.setText(str(ch))
        self.showChannel(ch)

    def showChannel(self,ch=None):
        if ch == None:
            ch = int(self.textbox_channel.text())
        self.axes0.clear()
        self.axes1.clear()
        self.axes0.semilogy(self.f_span[ch], (self.I[ch]**2 + self.Q[ch]**2)**.5, '.-')
        self.axes0.semilogy(self.f_span[ch][0:-1], self.IQ_vels[ch],'g.-')
        if self.last_IQ_vels != None and self.showPrevious:
            self.axes0.semilogy(self.last_f_span[ch][0:-1], self.last_IQ_vels[ch],'c.-',alpha=0.5)
        self.axes1.plot(self.I[ch], self.Q[ch], '.-', self.iq_centers.real[ch], self.iq_centers.imag[ch], '.', self.I_on_res[ch], self.Q_on_res[ch], '.')
        if self.last_I != None and self.showPrevious:
            self.axes1.plot(self.last_I[ch], self.last_Q[ch], 'c.-', self.last_iq_centers.real[ch], self.last_iq_centers.imag[ch], '.', self.last_I_on_res[ch], self.last_Q_on_res[ch], '.',alpha=0.5)
        self.canvas.draw()

        
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        freq=freqs[ch]/10**9
        atten=self.attens[ch]
        
        if self.customResonators[ch][1]!=-1:
            #freq=self.customResonators[ch][0]
            atten=self.customResonators[ch][1]
        self.textbox_freq.setText(str(freq))
        self.spinbox_attenuation.setValue(int(atten))

    def channelIncDown(self):
        ch = int(self.textbox_channel.text())
        ch = ch - 1
        ch = ch%self.N_freqs
        self.textbox_channel.setText(str(ch))
        self.showChannel(ch)

    def changeCenter(self, event):
        I = event.xdata
        Q = event.ydata
        ch = int(self.textbox_channel.text())
        print ch
        self.iq_centers.real[ch] = I
        self.iq_centers.imag[ch] = Q
        self.axes1.plot(I, Q, '.')
        self.canvas.draw()

    def snapResFreq(self):
        ch = int(self.textbox_channel.text())
        iMaxIQVel = numpy.argmax(self.IQ_vels[ch])
        #The longest edge is identified, choose which vertex of the edge
        #is the resonant frequency by checking the neighboring edges
        #len(IQ_vels[ch]) == len(f_span)-1, so iMaxIQVel is the index
        #of the lower frequency vertex of the longest edge
        if iMaxIQVel+1 < len(self.IQ_vels[ch]) and self.IQ_vels[ch][iMaxIQVel-1] < self.IQ_vels[ch][iMaxIQVel+1]:
            iNewResFreq = iMaxIQVel+1
        else:
            iNewResFreq = iMaxIQVel

        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        currentFreq=freqs[ch]/10**9
        newFreq = self.f_span[ch][iNewResFreq]
        newFreq = newFreq/1e9
        self.updateResFreq(ch=ch,freq=newFreq)

    def snapAllResFreqs(self):
        ch = int(self.textbox_channel.text())
        for ch in range(self.N_freqs):
            iMaxIQVel = numpy.argmax(self.IQ_vels[ch])
            #The longest edge is identified, choose which vertex of the edge
            #is the resonant frequency by checking the neighboring edges
            #len(IQ_vels[ch]) == len(f_span)-1, so iMaxIQVel is the index
            #of the lower frequency vertex of the longest edge
            if iMaxIQVel+1 < len(self.IQ_vels[ch]) and self.IQ_vels[ch][iMaxIQVel-1] < self.IQ_vels[ch][iMaxIQVel+1]:
                iNewResFreq = iMaxIQVel+1
            else:
                iNewResFreq = iMaxIQVel

            maxJump = float(self.textbox_freqAutoLimit.text())#10e-5# don't jump further than 100kHz/10 points
            freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
            currentFreq=freqs[ch]/10**9
            newFreq = self.f_span[ch][iNewResFreq]
            newFreq = newFreq/1e9
            if (abs(newFreq-currentFreq) <= maxJump):
                self.updateResFreq(ch=ch,freq=newFreq)

    def updateResFreq(self,ch,freq):
        freqFile =str(self.textbox_freqFile.text())
        freqFile=freqFile[:-4] + '_NEW.txt'
        try:
            f=open(freqFile,'a')
            atten = self.attens[ch]
            f.write(str(int(ch))+'\t'+str(freq)+'\t'+str(atten)+'\n')
            f.close()

            self.customResonators[ch]=[freq,atten]
            print 'ch:',ch,'freq:',freq,'atten:',atten
        except IOError:
            print 'IOERROR! Trouble opening',freqFile

    def updateResonator(self,atten=-1,ch=None):
        freqFile =str(self.textbox_freqFile.text())
        freqFile=freqFile[:-4] + '_NEW.txt'
        if ch == None:
            ch = int(self.textbox_channel.text())
        try:
            
            f=open(freqFile,'a')
            if atten == -1:
                atten=self.spinbox_attenuation.value()
            freq=float(self.textbox_freq.text())
            if atten == -1:
                atten=self.spinbox_attenuation.value()
            f.write(str(int(ch))+'\t'+str(freq)+'\t'+str(atten)+'\n')
            f.close()
            self.customResonators[ch]=[freq,atten]
            print 'ch:',ch,'freq:',freq,'atten:',atten
        except IOError:
            print 'IOERROR! Trouble opening',freqFile


    def deleteResonator(self):
        self.updateResonator(MAX_ATTEN)
        print 'Set attenuation on ch',self.textbox_channel.text(),'really high'
        #print 'removed resonator by flagging attenuation as -1'


 
    def create_main_frame(self):
        self.main_frame = QWidget()
        
        # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((9.0, 5.0), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes0 = self.fig.add_subplot(121)
        self.axes1 = self.fig.add_subplot(122)
        
        cid=self.canvas.mpl_connect('button_press_event', self.changeCenter)
        
        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        
        # Roach board's IP address
        roachIP = roachNo
#        if roachNo == 6:
#            roachIP = 7
#        elif roachNo == 7:
#            roachIP = 6
        self.textbox_roachIP = QLineEdit('10.0.0.1%d'%roachIP)
        self.textbox_roachIP.setMaximumWidth(200)
        label_roachIP = QLabel('Roach IP Address:')

        # Start connection to roach.
        self.button_openClient = QPushButton("(1)Open Client")
        self.button_openClient.setMaximumWidth(100)
        self.connect(self.button_openClient, SIGNAL('clicked()'), self.openClient)
        
        # LO frequency.
        self.textbox_loFreq = QLineEdit('%fe9'%defaultLOFreq)
        self.textbox_loFreq.setMaximumWidth(100)
        label_loFreq = QLabel('LO frequency:')

        # Global freq offset.
        self.textbox_freqOffset = QLineEdit('0e3')
        self.textbox_freqOffset.setMaximumWidth(100)
        label_freqOffset = QLabel('Freq Offset:')

        # Sweep span
        self.textbox_loSpan = QLineEdit('0.5e6')
        self.textbox_loSpan.setMaximumWidth(50)
        label_loSpan = QLabel('LO Span:')
        
        # Frequency span shift
        # A span shift of 0.75 shifts 75% of sweep span to the lower portion of the range.
        self.textbox_spanShift = QLineEdit('0.5')
        self.textbox_spanShift.setMaximumWidth(50)
        label_spanShift = QLabel('Span shift')
        
        # DAC Frequencies.
        self.textedit_DACfreqs = QTextEdit()
        self.textedit_DACfreqs.setMaximumWidth(170)
        self.textedit_DACfreqs.setMaximumHeight(100)
        label_DACfreqs = QLabel('DAC Freqs:')

        # Input attenuation.
        self.textbox_atten_in = QLineEdit('5')
        self.textbox_atten_in.setMaximumWidth(50)
        label_atten_in = QLabel('Input atten.:')

        # offset in lut
        self.textbox_offset = QLineEdit('0')
        self.textbox_offset.setMaximumWidth(50)
        label_offset = QLabel('DAC sync. lag:')

        # offset in lut
        #self.textbox_dds_shift = QLineEdit('140')	#chan_512_packet_2012_Aug_20_1207.bof
        #self.textbox_dds_shift = QLineEdit('149')	#chan_512_nodead_2012_Sep_05_1346.bof
        #self.textbox_dds_shift = QLineEdit('147')	#chan_if_acc_x_2011_Aug_02_0713.bof
        #self.textbox_dds_shift = QLineEdit('153')	#chan_dtrig_2012_Aug_28_1204.bof
        self.textbox_dds_shift = QLineEdit(os.environ['MKID_DDS_LAG'])       
        self.textbox_dds_shift.setMaximumWidth(50)
        label_dds_shift = QLabel('DDS sync. lag:')

        # Power sweep range. 
        self.textbox_powerSweepStart = QLineEdit(str(defaultAtten))
        self.textbox_powerSweepStart.setMaximumWidth(50)
        label_powerSweepStart = QLabel('Start atten.:')
        self.textbox_powerSweepStop = QLineEdit(str(defaultAtten))
        self.textbox_powerSweepStop.setMaximumWidth(50)
        label_powerSweepStop = QLabel('Stop atten:')

        # Save directory
        self.textbox_saveDir = QLineEdit(datadir)
        self.textbox_saveDir.setMaximumWidth(250)
        label_saveDir = QLabel('Save directory:')
        label_saveDir.setMaximumWidth(150)
    
        # File with frequencies/attens
        self.textbox_freqFile = QLineEdit(os.path.join(datadir,'ps_freq%d.txt'%roachNo))
        self.textbox_freqFile.setMaximumWidth(200)

        # Load freqs and attens from file.
        self.button_loadFreqsAttens = QPushButton("(2)Load freqs/attens")
        self.button_loadFreqsAttens.setMaximumWidth(200)
        self.connect(self.button_loadFreqsAttens, SIGNAL('clicked()'), self.loadFreqsAttens)
        
        # Rotate IQ loops.
        self.button_rotateLoops = QPushButton("(6)Rot. Loops")
        self.button_rotateLoops.setMaximumWidth(150)
        self.connect(self.button_rotateLoops, SIGNAL('clicked()'), self.rotateLoops)        

        # Translate IQ loops.
        self.button_translateLoops = QPushButton("(7)Trans. Loops")
        self.button_translateLoops.setMaximumWidth(150)
        self.connect(self.button_translateLoops, SIGNAL('clicked()'), self.translateLoops)
        
        # DAC start button.
        self.button_startDAC = QPushButton("(4)Start DAC")
        self.button_startDAC.setMaximumWidth(200)
        self.connect(self.button_startDAC, SIGNAL('clicked()'), self.toggleDAC)

        #DAC Indicator Square
        self.square_DACindicate = QtGui.QLabel(self)
        self.square_DACindicate.setMaximumWidth(30)
        self.square_DACindicate.setStyleSheet("QFrame { background-color: #ff0000 }")
        self.square_DACindicate.setFrameShadow(QtGui.QFrame.Raised)
        self.square_DACindicate.setFrameShape(QtGui.QFrame.Panel)
        self.square_DACindicate.setLineWidth(3)
        self.square_DACindicate.setMidLineWidth(3)
        self.square_DACindicate.setText('off')
        

        self.cbox_keepScaleFactor = QCheckBox("Keep Last Scale")
        self.cbox_useScaleFactor = QCheckBox("Use Scale")
        self.textbox_customScale = QLineEdit(str(defaultScale))
        self.textbox_customScale.setMaximumWidth(60)

        # define DAC/DDS frequencies and load LUTs. 
        self.button_define_LUTs= QPushButton("(3)Define LUTs")
        self.button_define_LUTs.setMaximumWidth(200)
        self.connect(self.button_define_LUTs, SIGNAL('clicked()'), self.define_LUTs)

        # Sweep LO
        self.button_sweepLO = QPushButton("(5)Sweep LO")
        self.button_sweepLO.setMaximumWidth(340)
        self.connect(self.button_sweepLO, SIGNAL('clicked()'), self.sweepLO)    
        # Toggle whether to show previous or not
        self.button_showPrevious = QPushButton("Show Prev")
        self.button_showPrevious.setMaximumWidth(200)
        self.connect(self.button_showPrevious, SIGNAL('clicked()'),
                     self.toggleShowPrevious)
        self.showPrevious = False
        self.toggleShowPrevious()

        # Channel increment up 1.
        self.button_channelIncUp = QPushButton("+")
        self.button_channelIncUp.setMaximumWidth(50)
        self.connect(self.button_channelIncUp, SIGNAL('clicked()'), self.channelIncUp)
        
        # Channel increment down 1.
        self.button_channelIncDown = QPushButton("-")
        self.button_channelIncDown.setMaximumWidth(50)
        self.connect(self.button_channelIncDown, SIGNAL('clicked()'), self.channelIncDown)
        
        # Channel to measure
        self.textbox_channel = QLineEdit('0')
        self.textbox_channel.setMaximumWidth(40)
        label_channel = QLabel('Ch:')
        label_channel.setMaximumWidth(50)

        #Spinbox adjustment of Attenuation of current resonater
        self.spinbox_attenuation = QSpinBox()
        self.spinbox_attenuation.setMaximum(MAX_ATTEN)
        label_attenuation = QLabel('Atten:')
        
        #textbox for adjusting frequency
        self.textbox_freq = QLineEdit('0')
        self.textbox_freq.setMaximumWidth(90)
        label_freq = QLabel('Freq (GHz):')
        

        #button to snap resonant frequency to peak IQ velocity
        self.button_autoFreq = QPushButton("Auto Freq")
        self.button_autoFreq.setMaximumWidth(170)
        self.connect(self.button_autoFreq, SIGNAL('clicked()'), self.snapResFreq)

        #button to submit frequency and attenuation changes
        self.button_updateResonator = QPushButton("Submit")
        self.button_updateResonator.setMaximumWidth(170)
        self.connect(self.button_updateResonator, SIGNAL('clicked()'), self.updateResonator)
        
 
        #button to 'delete' resonator by setting attenuation really high
        self.button_deleteResonator = QPushButton('Remove')
        self.button_deleteResonator.setMaximumWidth(170)
        self.connect(self.button_deleteResonator, SIGNAL('clicked()'), self.deleteResonator)
        
        #button to snap resonant frequency to peak IQ velocity
        self.button_autoFreqs = QPushButton("Auto All Freqs")
        self.button_autoFreqs.setMaximumWidth(170)
        self.connect(self.button_autoFreqs, SIGNAL('clicked()'), self.snapAllResFreqs)

        self.textbox_freqAutoLimit = QLineEdit('10e-5')
        self.textbox_freqAutoLimit.setMaximumWidth(70)
        label_freqAutoLimit = QLabel('Max Freq Jump (GHz):')
        
        # Add widgets to window.
        gbox0 = QVBoxLayout()
        hbox00 = QHBoxLayout()
        hbox00.addWidget(self.textbox_roachIP)
        hbox00.addWidget(self.button_openClient)
        gbox0.addLayout(hbox00)
        hbox01 = QHBoxLayout()
        hbox01.addWidget(self.textbox_freqFile)
        hbox01.addWidget(self.button_loadFreqsAttens)
        gbox0.addLayout(hbox01)
        hbox02 = QHBoxLayout()
        hbox02.addWidget(label_saveDir)
        hbox02.addWidget(self.textbox_saveDir)
        gbox0.addLayout(hbox02)
        hbox03 = QHBoxLayout()
        hbox03.addWidget(label_loFreq)
        hbox03.addWidget(self.textbox_loFreq)
        gbox0.addLayout(hbox03)
        hbox04 = QHBoxLayout()
        hbox04.addWidget(label_freqOffset)
        hbox04.addWidget(self.textbox_freqOffset)
        gbox0.addLayout(hbox04)

        gbox1 = QVBoxLayout()
        gbox1.addWidget(label_DACfreqs)
        gbox1.addWidget(self.textedit_DACfreqs)
        hbox10 = QHBoxLayout()
        hbox10.addWidget(label_offset)
        hbox10.addWidget(self.textbox_offset)
        hbox11 = QHBoxLayout()
        hbox11.addWidget(label_dds_shift)
        hbox11.addWidget(self.textbox_dds_shift)
        gbox1.addLayout(hbox10)
        gbox1.addLayout(hbox11)
        gbox1.addWidget(self.cbox_keepScaleFactor)
        hbox111 = QHBoxLayout()
        hbox111.addWidget(self.cbox_useScaleFactor)
        hbox111.addWidget(self.textbox_customScale)
        gbox1.addLayout(hbox111)
        gbox1.addWidget(self.button_define_LUTs)
        #gbox1.addWidget(self.button_startDAC)
        hbox12 = QHBoxLayout()
        hbox12.addWidget(self.button_startDAC)
        hbox12.addWidget(self.square_DACindicate)
        gbox1.addLayout(hbox12)

        gbox2 = QVBoxLayout()
        hbox20 = QHBoxLayout()
        hbox20.addWidget(label_atten_in)
        hbox20.addWidget(self.textbox_atten_in)
        hbox20.addWidget(label_powerSweepStart)
        hbox20.addWidget(self.textbox_powerSweepStart)
        hbox20.addWidget(label_powerSweepStop)
        hbox20.addWidget(self.textbox_powerSweepStop)
        gbox2.addLayout(hbox20)
        hbox21 = QHBoxLayout()
        hbox21.addWidget(label_loSpan)
        hbox21.addWidget(self.textbox_loSpan)
        hbox21.addWidget(self.button_sweepLO)
        hbox21.addWidget(self.button_showPrevious)
        gbox2.addLayout(hbox21)
        hbox22 = QHBoxLayout()
        hbox22.addWidget(label_channel)
        hbox22.addWidget(self.textbox_channel)
        hbox22.addWidget(self.button_channelIncDown)
        hbox22.addWidget(self.button_channelIncUp)
        gbox2.addLayout(hbox22)
        hbox23 = QHBoxLayout()
        hbox23.addWidget(label_attenuation)
        hbox23.addWidget(self.spinbox_attenuation)
        hbox23.addWidget(label_freq)
        hbox23.addWidget(self.textbox_freq)
        hbox23.addWidget(self.button_updateResonator)
        hbox23.addWidget(self.button_autoFreq)
        hbox23.addWidget(self.button_deleteResonator)
        gbox2.addLayout(hbox23)
        hbox24 = QHBoxLayout()
        hbox24.addWidget(label_freqAutoLimit)
        hbox24.addWidget(self.textbox_freqAutoLimit)
        hbox24.addWidget(self.button_autoFreqs)
        gbox2.addLayout(hbox24)
        hbox25 = QHBoxLayout()
        hbox25.addWidget(self.button_rotateLoops)
        hbox25.addWidget(self.button_translateLoops)
        gbox2.addLayout(hbox25)
 
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
        
        load_file_action = self.create_action("&Save plot",

            shortcut="Ctrl+S", slot=self.save_plot, 
            tip="Save the plot")
        quit_action = self.create_action("&Quit", slot=self.close, 
            shortcut="Ctrl+Q", tip="Close the application")
        
        self.add_actions(self.file_menu, 
            (load_file_action, None, quit_action))
        
        self.help_menu = self.menuBar().addMenu("&Help")
        about_action = self.create_action("&About", 
            shortcut='F1', slot=self.on_about, 
            tip='About the demo')
        
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
        msg = """ I'm cool, but not as cool as High Templar will be
        """
        QMessageBox.about(self, "MKID-ROACH software demo", msg.strip())

def main():
    app = QApplication(sys.argv)
    form = AppForm()
    form.show()
    app.exec_()


if __name__ == "__main__":
    main()
