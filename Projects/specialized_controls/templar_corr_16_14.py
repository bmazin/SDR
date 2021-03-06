import sys, os, random, math, array, fractions
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import socket
import matplotlib, corr, time, struct, numpy
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt4agg import NavigationToolbar2QTAgg as NavigationToolbar
from matplotlib.figure import Figure
from tables import *
import iqsweep

class AppForm(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.setWindowTitle('Templar_noise')
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
        self.iq_centers = numpy.array([0.+0j]*256)
        
    def openClient(self):
        self.roach = corr.katcp_wrapper.FpgaClient(self.textbox_roachIP.text(),7147)
        time.sleep(2)
        self.status_text.setText('connection established')
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
        """
        self.roach.write_int('SER_DI', (atten_in<<26)+(atten_out0<<20)+(atten_out1<<14))
        self.roach.write_int('SWAT_LE', 1)
        self.roach.write_int('start', 1)
        self.roach.write_int('start', 0)
        self.roach.write_int('SWAT_LE', 0)
        self.status_text.setText('Attenuators programmed. ')
        """
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
        self.status_text.setText('LO programmed. ')

    def freqCombLUT(self, echo, freq, sampleRate, resolution, amplitude=[1.]*256, phase=[0.]*256, random_phase = 'yes'):
        offset = int(self.textbox_offset.text())
        amp_full_scale = 2**15-1
        N_freqs = len(freq)
        size = int(sampleRate/resolution)
        I, Q = numpy.array([0.]*size), numpy.array([0.]*size)
        single_I, single_Q = numpy.array([0.]*size), numpy.array([0.]*size)
        
        #numpy.random.seed(1000)
        for n in range(N_freqs):
            if random_phase == 'yes':
                phase[n] = numpy.random.uniform(0, 2*numpy.pi)
                
            x = [2*numpy.pi*freq[n]*(t+offset)/sampleRate+phase[n] for t in range(size)]
            y = [2*numpy.pi*freq[n]*t/sampleRate+phase[n] for t in range(size)]

            single_I = amplitude[n]*numpy.cos(x)
            single_Q = amplitude[n]*numpy.sin(y)
            
            I = I + single_I
            Q = Q + single_Q
        
        a = numpy.array([abs(I).max(), abs(Q).max()])
        I = numpy.array([int(i*amp_full_scale/a.max()) for i in I])
        Q = numpy.array([int(q*amp_full_scale/a.max()) for q in Q])
        if echo == 'yes':
            print 'scale factor: ', a.max()
            self.scale_factor = a.max()
            print 'Set atten_out to: ', 20*numpy.log10(self.previous_scale_factor/self.scale_factor) + self.minimumAttenuation
        return I, Q
        
    def define_DAC_LUT(self):
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        f_base = float(self.textbox_loFreq.text())
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + 512e6
        self.freqs_dac = [round((f-f_base)/self.freqRes)*self.freqRes for f in freqs]
        atten_min = self.attens.min()
        print "minimum attenuation: ", self.minimumAttenuation
        amplitudes = [10**(+(atten_min-a)/20.) for a in self.attens]
        self.I_dac, self.Q_dac = self.freqCombLUT('yes', self.freqs_dac, self.sampleRate, self.freqRes, amplitudes)
        self.status_text.setText('done defining DAC freqs. ')

    def defne_noiseRO(self, freq=10e6):
		sampleRate = 512e6
		size = int(512e6/7812.5)

		start_x = 2*numpy.pi*freq/sampleRate
		end_x = 2*numpy.pi*freq*size/sampleRate
		x = numpy.linspace(start_x, end_x, size)
		start_y = 0
		end_y = 0 + 2*numpy.pi*freq*(size)/sampleRate
		y = numpy.linspace(start_y, end_y, size)
		
		I = numpy.cos(x)
		Q = numpy.sin(y)
	
		sigma = 10.
		iq = numpy.array([0+0j]*size)
		for i in range(size):
			I[i] = I[i] + random.gauss(0, sigma)
			Q[i] = Q[i] + random.gauss(0, sigma)

		amp_full_scale = 2**15-1
		a = numpy.array([abs(I).max(), abs(Q).max()])
		I = numpy.array([int(i*amp_full_scale/a.max()) for i in I])
		Q = numpy.array([int(q*amp_full_scale/a.max()) for q in Q])

		return I, Q
	
    def noiseRO(self):
		freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
		f_base = float(self.textbox_loFreq.text())
		for n in range(len(freqs)):
			if freqs[n] < f_base:
				freqs[n] = freqs[n] + 512e6
		self.freqs_dac = [round((f-f_base)/self.freqRes)*self.freqRes for f in freqs]
		atten_min = self.attens.min()
		amplitudes = [10**(+(atten_min-a)/20.) for a in self.attens]
		self.I_dac, self.Q_dac = self.define_noiseRO(self.freqs_dac[0])
		self.status_text.setText('done defining noise RO. ')
		
    def define_DDS_LUT(self, phase = [0.]*256):
        ch_shift = 147  # This number should be verified in the utility ddc2x_v*.py
        freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        f_base = float(self.textbox_loFreq.text())
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + 512e6

        freqs_dds = [0 for j in range(256)]
        for n in range(len(freqs)):
            freqs_dds[n] = round((freqs[n]-f_base)/self.freqRes)*self.freqRes

        freq_residuals = self.select_bins(freqs_dds)

        L = int(self.sampleRate/self.freqRes)
        self.I_dds, self.Q_dds = [0.]*L, [0.]*L
        for m in range(256):
            I, Q = self.freqCombLUT('no', [freq_residuals[m]], 2e6, self.freqRes, [1.], [phase[m]], 'no')
            for j in range(len(I)/2):
                self.I_dds[j*512+2*((m+ch_shift)%256)] = I[2*j]
                self.I_dds[j*512+2*((m+ch_shift)%256)+1] = I[2*j+1]
                self.Q_dds[j*512+2*((m+ch_shift)%256)] = Q[2*j]
                self.Q_dds[j*512+2*((m+ch_shift)%256)+1] = Q[2*j+1]

        self.axes0.clear()
        self.axes0.plot(self.I_dds, '.', self.Q_dds, '.')
        self.canvas.draw()
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
        self.status_text.setText('done writing LUTs. ')
        return residuals
    
    def write_LUTs(self):
        if self.dacStatus == 'off':
            self.roach.write_int('startDAC', 0)
        else:
            self.toggleDAC()
            
        binaryData = ''
        print len(self.I_dac)
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
        f = open(saveDir + 'luts.dat', 'w')
        f.write(binaryData)
        f.close()

    def loadIQcenters(self):
        saveDir = str(self.textbox_saveDir.text())
        #saveDir = str(os.environ['PWD'] + '/'+ self.textbox_saveDir.text())
        centers_for_file = [[0., 0.]]*256
        for ch in range(256):
            I_c = int(self.iq_centers[ch].real/2**3)
            Q_c = int(self.iq_centers[ch].imag/2**3)

            center = (I_c<<16) + (Q_c<<0)
            self.roach.write_int('conv_phase_centers', center)
            self.roach.write_int('conv_phase_load_centers', (ch<<1)+(1<<0))
            self.roach.write_int('conv_phase_load_centers', 0)
        
            centers_for_file[ch] = [self.iq_centers[ch].real, self.iq_centers[ch].imag]
            
        numpy.savetxt(saveDir+'centers.dat', centers_for_file)

    def findIQcenters(self, I, Q):
        I_0 = (I.max()+I.min())/2.
        Q_0 = (Q.max()+Q.min())/2.
                
        return complex(I_0, Q_0)
  
    def rotateLoops(self):
		print "Calculating loop rotations..."
		L = 2**15
		bin_data_phase = ''
		self.roach.write_int('startSnap', 0)
		self.roach.write_int('snapI_ctrl', 1)
		self.roach.write_int('snapI_ctrl', 0)
		self.roach.write_int('snapQ_ctrl', 1)
		self.roach.write_int('snapQ_ctrl', 0)
		self.roach.write_int('startSnap', 1)
		time.sleep(0.1)
		bin_data_I = self.roach.read('snapI_bram', 4*L)
		bin_data_Q = self.roach.read('snapQ_bram', 4*L)
		I = numpy.array([0]*L)
		Q = numpy.array([0]*L)
		for m in range(L):
			I[m] = struct.unpack('>l', bin_data_I[m*4:m*4+4])[0]/2**14 - self.iq_centers[0].real
			Q[m] = struct.unpack('>l', bin_data_Q[m*4:m*4+4])[0]/2**14 - self.iq_centers[1].imag

		phase = [0.]*256
		phase[0] = numpy.arctan2(Q.mean(), I.mean())
        
		self.define_DDS_LUT(phase)
		self.write_LUTs()
		print "done."

    """            
    def sweepLO(self):
		atten_in = float(self.textbox_atten_in.text())
		saveDir = str(self.textbox_saveDir.text())
		savefile = saveDir + 'ps_' + time.strftime("%Y%m%d-%H%M%S",time.localtime()) + '.h5'
		dac_freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
		self.N_freqs = len(dac_freqs)
		f_base = float(self.textbox_loFreq.text())

		if f_base >= 4.4e9:
			self.programRFswitches('10010')
			print 'LO doubled.'
		else:
			#self.programRFswitches('10100')
			self.programRFswitches('10110')
			print 'LO normal operation.'
		loSpan = float(self.textbox_loSpan.text())
		# spanShift = 0.5 --> a sweep centered on the resonant freq.
		spanShift = float(self.textbox_spanShift.text())
		df = 1e4
		steps = int(loSpan/df)
		print "LO steps: ", steps
		# Frequency span is off-center to account for freq. shift to higher values for atten -> inf.
		lo_freqs = [f_base+i*df-spanShift*steps*df for i in range(steps)]

		atten_start = int(self.textbox_powerSweepStart.text())
		atten_stop = int(self.textbox_powerSweepStop.text())
		attens = [i for i in range(atten_start, atten_stop+1)]
        
        self.roach.write_int('ch_we0', 1)
        self.roach.write_int('ch_we1', 1)
		
        for a in attens:	
			print a
			self.programAttenuators(atten_in, a)
			time.sleep(0.5)
			f_span = []
			l = 0
			self.f_span = [[0]*steps]*self.N_freqs
			for f in dac_freqs:
				f_span = f_span + [f-spanShift*steps*df+n*df for n in range(steps)]
				self.f_span[l] = [f-spanShift*steps*df+n*df for n in range(steps)]
				l = l + 1
			I = numpy.zeros(self.N_freqs*steps, dtype='float32')
			Q = numpy.zeros(self.N_freqs*steps, dtype='float32')

			self.I, self.Q = numpy.array([[0.]*steps]*self.N_freqs),numpy.array([[0.]*steps]*self.N_freqs)
			for i in range(steps):
				self.programLO(lo_freqs[i],1)
				L = 2**15
				bin_data_phase = ''
				self.roach.write_int('startSnap', 0)
				self.roach.write_int('snapI_ctrl', 1)
				self.roach.write_int('snapI_ctrl', 0)
				self.roach.write_int('snapQ_ctrl', 1)
				self.roach.write_int('snapQ_ctrl', 0)
				self.roach.write_int('startSnap', 1)
				time.sleep(0.1)
				bin_data_I = self.roach.read('snapI_bram', 4*L)
				bin_data_Q = self.roach.read('snapQ_bram', 4*L)
				I = numpy.array([0]*L)
				Q = numpy.array([0]*L)
				for m in range(L):
					I[m] = struct.unpack('>l', bin_data_I[m*4:m*4+4])[0]/2**14
					Q[m] = struct.unpack('>l', bin_data_Q[m*4:m*4+4])[0]/2**14
				self.I[0,i] = I.mean()
				self.Q[0,i] = Q.mean()

			self.programLO(f_base,1)
            
            # Find IQ centers.
			self.I_on_res, self.Q_on_res = [0.]*self.N_freqs, [0.]*self.N_freqs
			bin_data_phase = ''
			self.roach.write_int('startSnap', 0)
			self.roach.write_int('snapI_ctrl', 1)
			self.roach.write_int('snapI_ctrl', 0)
			self.roach.write_int('snapQ_ctrl', 1)
			self.roach.write_int('snapQ_ctrl', 0)
			self.roach.write_int('startSnap', 1)
			time.sleep(0.1)
			bin_data_I = self.roach.read('snapI_bram', 4*L)
			bin_data_Q = self.roach.read('snapQ_bram', 4*L)
			I = numpy.array([0]*L)
			Q = numpy.array([0]*L)
			for m in range(L):
				I[m] = struct.unpack('>l', bin_data_I[m*4:m*4+4])[0]/2**14
				Q[m] = struct.unpack('>l', bin_data_Q[m*4:m*4+4])[0]/2**14
			self.I_on_res[0] = I.mean()
			self.Q_on_res[0] = Q.mean()
			self.iq_centers[0] = self.findIQcenters(self.I[0,:],self.Q[0,:])

			N = steps*self.N_freqs

		self.axes0.clear()
		self.axes1.clear()
		self.axes0.semilogy((self.I[0,:]**2 + self.Q[0,:]**2)**.5, '.-')
        #self.axes0.semilogy(f_span, (self.I[0,:]**2 + self.Q[0,:]**2)**.5, '.-')
        #self.axes0.semilogy(f_span, (I**2 + Q**2)**.5, '.-')
		self.axes1.plot(self.I[0,:], self.Q[0,:], '.-', self.iq_centers.real[0:self.N_freqs], self.iq_centers.imag[0:self.N_freqs], '.', self.I_on_res, self.Q_on_res, '.')
		#self.axes1.plot(f_span[0:N-1], dist, '.-')
		#self.axes1.set_xlim((-100000,100000))
		#self.axes1.set_ylim((-100000,100000))
		self.canvas.draw()
    """

    def sweepLO(self):
        atten_in = float(self.textbox_atten_in.text())
        saveDir = str(self.textbox_saveDir.text())
        #saveDir = str(os.environ['PWD'] + '/'+ self.textbox_saveDir.text())
        savefile = saveDir + 'ps_' + time.strftime("%Y%m%d-%H%M%S",time.localtime()) + '.h5'
        dac_freqs = map(float, unicode(self.textedit_DACfreqs.toPlainText()).split())
        self.N_freqs = len(dac_freqs)
        f_base = float(self.textbox_loFreq.text())
        
        if f_base >= 4.4e9:
            self.programRFswitches('10010')
            print 'LO doubled.'
        else:
            #self.programRFswitches('10100')
            self.programRFswitches('10110')
            print 'LO normal operation.'
        loSpan = float(self.textbox_loSpan.text())
        # spanShift = 0.5 --> a sweep centered on the resonant freq.
        spanShift = float(self.textbox_spanShift.text())
        df = 1e4
        steps = int(loSpan/df)
        print "LO steps: ", steps
        # Frequency span is off-center to account for freq. shift to higher values for atten -> inf.
        lo_freqs = [f_base+i*df-spanShift*steps*df for i in range(steps)]
        
        atten_start = int(self.textbox_powerSweepStart.text())
        atten_stop = int(self.textbox_powerSweepStop.text())
        attens = [i for i in range(atten_start, atten_stop+1)]

        for a in attens:    
            print a
            self.programAttenuators(atten_in, a)
            time.sleep(0.5)
            f_span = []
            l = 0
            self.f_span = [[0]*steps]*self.N_freqs
            for f in dac_freqs:
                f_span = f_span + [f-spanShift*steps*df+n*df for n in range(steps)]
                self.f_span[l] = [f-spanShift*steps*df+n*df for n in range(steps)]
                l = l + 1
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
            
        numpy.savetxt('centers.dat', [self.iq_centers.real, self.iq_centers.imag])

        self.axes1.clear()
        self.axes0.semilogy(f_span, (I**2 + Q**2)**.5, '.-')
        self.axes1.plot(I, Q, '.-', self.iq_centers.real[0:self.N_freqs], self.iq_centers.imag[0:self.N_freqs], '.', self.I_on_res, self.Q_on_res, '.')
        self.canvas.draw()

    def toggleDAC(self):
        if self.dacStatus == 'off':
            print "Starting LUT...",
            self.roach.write_int('startDAC', 1)
            time.sleep(1)
            while self.roach.read_int('DRAM_LUT_rd_valid') != 0:
		print self.roach.read_int('DRAM_LUT_rd_valid')
                self.roach.write_int('startDAC', 0)
                time.sleep(0.35)
                self.roach.write_int('startDAC', 1)
                time.sleep(1)
                print ".",
            print "done."
            self.button_startDAC.setText('Stop DAC')
            self.dacStatus = 'on'
	    self.status_text.setText('DAC turned on. ')       
        else:
            self.roach.write_int('startDAC', 0)
            self.button_startDAC.setText('Start DAC')
            self.dacStatus = 'off'
	    self.status_text.setText('DAC turned off. ')       
   
    def loadFreqsAttens(self):
        f_base = float(self.textbox_loFreq.text())
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
        self.minimumAttenuation = numpy.array(x[1:,3]).min()
        self.textedit_DACfreqs.setText(x_string)
        
    def loadLUTs(self):
        self.scale_factor = 1.
        self.iq_centers = numpy.array([0.+0j]*256)
        
        # Loads the DAC and DDS LUTs from file.  As well as the IQ loop centers.
        if self.dacStatus == 'off':
            self.roach.write_int('startDAC', 0)
        else:
            self.toggleDAC()

        saveDir = str(self.textbox_saveDir.text())
        #saveDir = str(os.environ['PWD'] + '/'+ self.textbox_saveDir.text())            
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

    def channelIncUp(self):
        ch = int(self.textbox_channel.text())
        ch = ch + 1
        ch = ch%self.N_freqs
        self.textbox_channel.setText(str(ch))
        self.axes0.clear()
        self.axes1.clear()
        self.axes0.semilogy(self.f_span[ch], (self.I[ch]**2 + self.Q[ch]**2)**.5, '.-')
        self.axes1.plot(self.I[ch], self.Q[ch], '.-', self.iq_centers.real[ch], self.iq_centers.imag[ch], '.', self.I_on_res[ch], self.Q_on_res[ch], '.')
	#self.axes1.set_xlim((-10000,10000))
    #self.axes1.set_ylim((-10000,10000))
	self.canvas.draw()
        
    def channelIncDown(self):
        ch = int(self.textbox_channel.text())
        ch = ch - 1
        ch = ch%self.N_freqs
        self.textbox_channel.setText(str(ch))
        self.axes0.clear()
        self.axes1.clear()
        self.axes0.semilogy(self.f_span[ch], (self.I[ch]**2 + self.Q[ch]**2)**.5, '.-')
        self.axes1.plot(self.I[ch], self.Q[ch], '.-', self.iq_centers.real[ch], self.iq_centers.imag[ch], '.', self.I_on_res[ch], self.Q_on_res[ch], '.')
        #self.axes1.set_xlim((-10000,10000))
        #self.axes1.set_ylim((-10000,10000))
        self.canvas.draw()

    def changeCenter(self, event):
        I = event.xdata
        Q = event.ydata
        #ch = int(self.textbox_channel.text())
        #print ch
        #self.iq_centers.real[ch] = I
        #self.iq_centers.imag[ch] = Q
        #self.axes1.plot(I, Q, '.')
        #self.canvas.draw()

    def snapshot(self):
        for r in range(self.N_freqs):
            self.roach.write_int('ch_we'+str(r), r)
            #self.roach.write_int('ch_we'+str(r), 1)
        for r in range(4-self.N_freqs):
            self.roach.write_int('ch_we'+str(r), 0)
            
        steps = int(self.textbox_noiseSteps.text())
        L = 2**15
        I, Q = [], []
        for n in range(steps):
            print n
            self.roach.write_int('startSnap', 0)
            self.roach.write_int('snapI_ctrl', 1)
            self.roach.write_int('snapI_ctrl', 0)
            self.roach.write_int('snapQ_ctrl', 1)
            self.roach.write_int('snapQ_ctrl', 0)
            self.roach.write_int('startSnap', 1)
            time.sleep(0.1)
            bin_data_I = self.roach.read('snapI_bram', 4*L)
            bin_data_Q = self.roach.read('snapQ_bram', 4*L)
            for m in range(L*2):#two 16 bit values in each 32-bit word
				#low order bits are an earlier value
                i = struct.unpack('>h', bin_data_I[m*2:m*2+2])[0]
                q = struct.unpack('>h', bin_data_Q[m*2:m*2+2])[0]
                I.append(i)
                Q.append(q)
        
        numpy.savetxt('test.dat', [I,Q])

        self.axes1.clear()
        self.axes1.plot(I,'.-',  Q, '.-')
        self.canvas.draw()

    def create_main_frame(self):
        self.main_frame = QWidget()
        
        # Create the mpl Figure and FigCanvas objects. 
        self.dpi = 100
        self.fig = Figure((9.0, 5.0), dpi=self.dpi)
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self.main_frame)
        self.axes0 = self.fig.add_subplot(121)
        #self.axes3 = self.axes0.twinx()
        self.axes1 = self.fig.add_subplot(122)
        
        cid=self.canvas.mpl_connect('button_press_event', self.changeCenter)
        
        # Create the navigation toolbar, tied to the canvas
        self.mpl_toolbar = NavigationToolbar(self.canvas, self.main_frame)
        
        # Roach board's IP address
        self.textbox_roachIP = QLineEdit('10.0.0.14')
        self.textbox_roachIP.setMaximumWidth(200)
        label_roachIP = QLabel('Roach IP Address:')

        # Start connection to roach.
        self.button_openClient = QPushButton("&Open Client")
        self.button_openClient.setMaximumWidth(100)
        self.connect(self.button_openClient, SIGNAL('clicked()'), self.openClient)
        
        # LO frequency.
        self.textbox_loFreq = QLineEdit('5.07e9')
        self.textbox_loFreq.setMaximumWidth(100)
        label_loFreq = QLabel('LO frequency:')

        # Program LO.
        self.button_programLO = QPushButton("&Prog.")
        self.button_programLO.setMaximumWidth(100)
        self.connect(self.button_programLO, SIGNAL('clicked()'), self.programLO)
        label_programLO = QLabel('')

        # Sweep span
        self.textbox_loSpan = QLineEdit('0.5e6')
        self.textbox_loSpan.setMaximumWidth(50)
        label_loSpan = QLabel('LO Span')
        
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
        self.textbox_atten_in = QLineEdit('0')
        self.textbox_atten_in.setMaximumWidth(50)
        label_atten_in = QLabel('atten. (in)')

        # offset in lut
        self.textbox_offset = QLineEdit('0')
        self.textbox_offset.setMaximumWidth(50)

        # Power sweep range. 
        self.textbox_powerSweepStart = QLineEdit('16')
        self.textbox_powerSweepStart.setMaximumWidth(50)
        label_powerSweepStart = QLabel('Start Atten')
        self.textbox_powerSweepStop = QLineEdit('16')
        self.textbox_powerSweepStop.setMaximumWidth(50)
        label_powerSweepStop = QLabel('Stop Atten')

        # Save directory
        self.textbox_saveDir = QLineEdit('/home/sean/data/20111115/r0/')
        self.textbox_saveDir.setMaximumWidth(50)
        label_saveDir = QLabel('Save directory')
        label_saveDir.setMaximumWidth(150)
    
        # File with frequencies/attens
        self.textbox_freqFile = QLineEdit('freqs.txt')
        self.textbox_freqFile.setMaximumWidth(200)

        # Load freqs and attens from file.
        self.button_loadFreqsAttens = QPushButton("Load freqs/attens")
        self.button_loadFreqsAttens.setMaximumWidth(200)
        self.connect(self.button_loadFreqsAttens, SIGNAL('clicked()'), self.loadFreqsAttens)

        # Load freqs onto FPGA.
        self.button_write_LUTs = QPushButton("&Load LUTs")
        self.button_write_LUTs.setMaximumWidth(200)
        self.connect(self.button_write_LUTs, SIGNAL('clicked()'), self.write_LUTs)
      
        # Define noise readout.
        self.button_noiseRO = QPushButton("noise RO")
        self.button_noiseRO.setMaximumWidth(200)
        self.connect(self.button_noiseRO, SIGNAL('clicked()'), self.noiseRO)

        # Take snapshot.
        self.button_snapshot = QPushButton("Snapshot")
        self.button_snapshot.setMaximumWidth(200)
        self.connect(self.button_snapshot, SIGNAL('clicked()'), self.snapshot)
        
        # Noise data steps
        self.textbox_noiseSteps = QLineEdit('1')
        self.textbox_noiseSteps.setMaximumWidth(50)
        
		# Rotate IQ loops.
        self.button_rotateLoops = QPushButton("Rot. Loops")
        self.button_rotateLoops.setMaximumWidth(200)
        self.connect(self.button_rotateLoops, SIGNAL('clicked()'), self.rotateLoops)        

        # Translate IQ loops.
        self.button_translateLoops = QPushButton("Trans. Loops")
        self.button_translateLoops.setMaximumWidth(200)
        self.connect(self.button_translateLoops, SIGNAL('clicked()'), self.loadIQcenters)
        
        # DAC start button.
        self.button_startDAC = QPushButton("&Start DAC")
        self.button_startDAC.setMaximumWidth(200)
        self.connect(self.button_startDAC, SIGNAL('clicked()'), self.toggleDAC)

        # define DDS frequencies. 
        self.button_define_DDS_LUT= QPushButton("&Define DDS")
        self.button_define_DDS_LUT.setMaximumWidth(200)
        self.connect(self.button_define_DDS_LUT, SIGNAL('clicked()'), self.define_DDS_LUT)
        
        # define DAC frequencies. 
        self.button_define_DAC_LUT= QPushButton("&Define DAC LUT")
        self.button_define_DAC_LUT.setMaximumWidth(200)
        self.connect(self.button_define_DAC_LUT, SIGNAL('clicked()'), self.define_DAC_LUT)

        # Sweep LO
        self.button_sweepLO = QPushButton("Sweep LO")
        self.button_sweepLO.setMaximumWidth(340)
        self.connect(self.button_sweepLO, SIGNAL('clicked()'), self.sweepLO) 
        
        # load LUT and IQ centers from file
        self.button_loadLUTs = QPushButton("Load LUTs and centers")
        self.button_loadLUTs.setMaximumWidth(340)
        self.connect(self.button_loadLUTs, SIGNAL('clicked()'), self.loadLUTs)       
          
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
        self.textbox_channel.setMaximumWidth(100)
        
        # Add widgets to window.
        gbox0 = QVBoxLayout()
        hbox01 = QHBoxLayout()
        hbox01.addWidget(self.textbox_roachIP)
        hbox01.addWidget(self.button_openClient)
        gbox0.addLayout(hbox01)
        gbox030 = QVBoxLayout()
        gbox030.addWidget(label_loFreq)
        gbox030.addWidget(self.textbox_loFreq)
        gbox032 = QVBoxLayout()
        gbox032.addWidget(label_programLO)
        gbox032.addWidget(self.button_programLO)
        gbox033 = QVBoxLayout()
        gbox033.addWidget(label_loSpan)
        gbox033.addWidget(self.textbox_loSpan)
        gbox034 = QVBoxLayout()
        gbox034.addWidget(label_spanShift)
        gbox034.addWidget(self.textbox_spanShift)
        gbox12 = QVBoxLayout()
        gbox12.addWidget(label_atten_in)
        gbox12.addWidget(self.textbox_atten_in)
        gbox10 = QVBoxLayout()
        gbox10.addWidget(label_powerSweepStart)
        gbox10.addWidget(self.textbox_powerSweepStart)
        gbox11 = QVBoxLayout()
        gbox11.addWidget(label_powerSweepStop)
        gbox11.addWidget(self.textbox_powerSweepStop)
        hbox11 = QHBoxLayout()
        hbox11.addLayout(gbox12)
        hbox11.addLayout(gbox10)
        hbox11.addLayout(gbox11)
        hbox11.addWidget(self.textbox_offset)
        hbox03 = QHBoxLayout()
        hbox03.addLayout(gbox030)
        hbox03.addLayout(gbox032)
        hbox03.addLayout(gbox033)
        hbox03.addLayout(gbox034)
        gbox0.addLayout(hbox03)
        gbox0.addLayout(hbox11)


        gbox1 = QVBoxLayout()
        gbox1.addWidget(label_DACfreqs)
        gbox1.addWidget(self.textedit_DACfreqs)
        hbox12 = QHBoxLayout()
        hbox12.addWidget(label_saveDir)
        hbox12.addWidget(self.textbox_saveDir)
        gbox1.addLayout(hbox12)
        hbox13 = QHBoxLayout()
        hbox13.addWidget(self.textbox_channel)
        hbox13.addWidget(self.button_channelIncDown)
        hbox13.addWidget(self.button_channelIncUp)
        gbox1.addLayout(hbox13)

        gbox2 = QVBoxLayout()
        hbox23 = QHBoxLayout()
        hbox23.addWidget(self.textbox_freqFile)
        hbox23.addWidget(self.button_loadFreqsAttens)
        gbox2.addLayout(hbox23)
        hbox20 = QHBoxLayout()
        hbox20.addWidget(self.button_define_DAC_LUT)
        hbox20.addWidget(self.button_define_DDS_LUT)
        gbox2.addLayout(hbox20)

        hbox25 = QHBoxLayout()
        hbox25.addWidget(self.button_noiseRO)
        hbox25.addWidget(self.textbox_noiseSteps)
        hbox25.addWidget(self.button_snapshot)
        gbox2.addLayout(hbox25)

        hbox24 = QHBoxLayout()
        hbox24.addWidget(self.button_write_LUTs)
        hbox24.addWidget(self.button_startDAC)
        gbox2.addLayout(hbox24)
        gbox2.addWidget(self.button_sweepLO)
        hbox22 = QHBoxLayout()
        hbox22.addWidget(self.button_rotateLoops)
        hbox22.addWidget(self.button_translateLoops)
        gbox2.addLayout(hbox22)
        gbox2.addWidget(self.button_loadLUTs)
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
