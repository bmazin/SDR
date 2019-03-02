from Roach2Controls import Roach2Controls
import numpy as np
from binTools import *
import time

def runTest(channel, phase):
    phaseInt = castBin(phase, nBits=18, binaryPoint=15)
    roach.fpga.write_int('phase', phaseInt)
    roach.fpga.write_int('channel', channel)
    roach.fpga.write_int('enable', 0)
    time.sleep(0.1)
    roach.fpga.write_int('enable', 1)
    time.sleep(0.1)
    result = roach.fpga.read_int('energy_out')

    expectedResult = a_coeffs[channel]*phase**2 + b_coeffs[channel]*phase + c_coeffs[channel]
    
    print 'expected result:', expectedResult
    print 'actual result:', result/2.**14
    print 'bin actual result:', bin(result)

ip = '10.0.0.115'
nCoeffs = 100
bitmask = 2**21-1

roach = Roach2Controls(ip, '/mnt/data0/MkidDigitalReadout/DataReadout/ChannelizerControls/DarknessFpga_V2.param', verbose=True)
roach.connect()

a_coeffs = 10*np.random.rand(nCoeffs)-5
b_coeffs = 0.004*np.random.rand(nCoeffs)-0.002
c_coeffs = 10*10**-4*np.random.rand(nCoeffs)-5*10**-5

a_coeff_ints = np.array(a_coeffs*2**14, dtype=np.int64)
b_coeff_ints = np.array(b_coeffs*2**14, dtype=np.int64)
c_coeff_ints = np.array(c_coeffs*2**14, dtype=np.int64)

a_neg_inds = np.where(a_coeff_ints<0)[0]
a_coeff_ints[a_neg_inds] = -a_coeff_ints[a_neg_inds]
a_coeff_ints[a_neg_inds] = ((~a_coeff_ints)&bitmask) + 1

b_neg_inds = np.where(b_coeff_ints<0)[0]
b_coeff_ints[b_neg_inds] = -b_coeff_ints[b_neg_inds]
b_coeff_ints[b_neg_inds] = ((~b_coeff_ints)&bitmask) + 1

c_neg_inds = np.where(c_coeff_ints<0)[0]
c_coeff_ints[c_neg_inds] = -c_coeff_ints[c_neg_inds]
c_coeff_ints[c_neg_inds] = ((~c_coeff_ints)&bitmask) + 1

coeff_arr = a_coeff_ints & bitmask + ((b_coeff_ints & bitmask) << 21) + ((c_coeff_ints & bitmask) << 42)

print coeff_arr

roach.writeBram('energy_cal_lut_energy_coeffs', coeff_arr, nBytesPerSample=8)

runTest(60, -np.pi/2)
runTest(80, -np.pi/3)


