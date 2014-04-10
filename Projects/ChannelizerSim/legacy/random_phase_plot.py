import numpy, pylab, random

M = 1001

def freqCombLUT(echo, freq, sampleRate, resolution, amplitude=[1.]*M, phase=[0.]*M, random_phase = 'yes'):
        amp_full_scale = 2**15-1
        N_freqs = len(freq)
        size = int(sampleRate/resolution)
        I = numpy.array([0.]*size)
        single_I = numpy.array([0.]*size)

        for n in range(N_freqs):
            if random_phase == 'yes':
                phase[n] = numpy.random.uniform(0, 2*numpy.pi)

            start_x = phase[n]+2*numpy.pi*freq[n]/sampleRate
            end_x = phase[n]+2*numpy.pi*freq[n]*(size)/sampleRate
            x = numpy.linspace(start_x, end_x, size)

            single_I = amplitude[n]*numpy.cos(x)
            I = I + single_I

	return abs(I).max()


def define_DAC_LUT(freqs):
	freqRes = 7812.5
	sampleRate = 512e6
        f_base = 3.5e9
        for n in range(len(freqs)):
            if freqs[n] < f_base:
                freqs[n] = freqs[n] + 512e6
        
	freqs_dac = [round(f/freqRes)*freqRes for f in freqs]
	#freqs_dac = [round((f-f_base)/freqRes)*freqRes for f in freqs]
        amplitudes = [1.0 for a in freqs]
        a = freqCombLUT('yes', freqs_dac, sampleRate, freqRes, amplitudes)
	return a


M = 257
a = []
for N in range(1, M, 10):
	df = 512e6/(N+1)
	freqs = numpy.array([i*df for i in range(N)])
	ave = 0.
	for i in range(10):
		ave = ave + define_DAC_LUT(freqs)
	print ave/10.
	a.append(ave/10.)

fn = [i for i in range(1, M, 10)]
pylab.plot(a, '.-')
pylab.show()
