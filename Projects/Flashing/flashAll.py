#!/bin/python
import numpy as np
import corr
import time
import struct
import sys 

#for i in xrange(8):
#    roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%i,7147)
#    programAttenuators(roach,5,0)
#


def programAttenuators(iRoach, atten_in_desired, atten_out_desired):
        #    There are eight settings for each attenuator:
        #    0db, -0.5, -1, -2, -4, -8, -16, and -31.5, which
        #    are listed in order in "attenuations."    
        roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%iRoach,7147)
        time.sleep(.001)
        atten_in = 63 - int(atten_in_desired*2)
        
        if atten_out_desired <= 31.5:
            atten_out0 = 63
            atten_out1 = 63 - int(atten_out_desired*2)
        else:
            atten_out0 = 63 - int((atten_out_desired-31.5)*2)
            atten_out1 = 0

        reg = np.binary_repr((atten_in<<12)+(atten_out0<<6)+(atten_out1<<0))
        b = '0'*(18-len(reg)) + reg
        roach.write_int('regs', (0<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        roach.write_int('if_switch', 1)
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[0])<<2)+(0<<1)+(0<<0))

        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[1])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[2])<<2)+(0<<1)+(0<<0))

        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[3])<<2)+(0<<1)+(0<<0))

        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[4])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[5])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[6])<<2)+(0<<1)+(0<<0))

        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[7])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[8])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[9])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[10])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[11])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[12])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[13])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[14])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[15])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[16])<<2)+(0<<1)+(0<<0))
        
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(1<<1)+(0<<0))
        roach.write_int('regs', (0<<4)+(1<<3)+(int(b[17])<<2)+(0<<1)+(0<<0))
        roach.write_int('regs', (1<<4)+(1<<3)+(0<<2)+(0<<1)+(0<<0))
        roach.write_int('if_switch', 0)

t0=time.time()
for r in xrange(8):
    atten_in = 5
    attens = [12,6,5,5,7,7,6,4]
    atten_out = attens[r]
    high_power = 0
    programAttenuators(r,atten_in,high_power)
    programAttenuators(r,atten_in,atten_out)
    print 'Flash on Roach ',r
