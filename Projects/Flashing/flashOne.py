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
def programAttenuators(roach, atten_in_desired, atten_out_desired):
    #    There are eight settings for each attenuator:
    #    0db, -0.5, -1, -2, -4, -8, -16, and -31.5, which
    #    are listed in order in "attenuations."
    #atten_in_desired = float(textbox_atten_in.text())
    atten_in = 63 - int(atten_in_desired*2)

    #atten_out_desired = float(textbox_atten_out.text())
    if atten_out_desired <= 31.5:
        atten_out0 = 63
        atten_out1 = 63 - int(atten_out_desired*2)
    else:
        atten_out0 = 63 - int((atten_out_desired-31.5)*2)
        atten_out1 = 0

    reg = np.binary_repr((atten_in<<12)+(atten_out0<<6)+(atten_out1<<0))
    regStr = '0'*(18-len(reg)) + reg
    SW_STB = 0
    SER_CLK = 1
    SER_DI = 2
    LO_SLE = 3
    SWAT_LE = 4
    roach.write_int('regs',int('01000',base=2) )
    roach.write_int('if_switch', 1)

    #make a list of bitlists to be written to regs regsiter in seqence
    regs_seq=[list('01000') for i in range(3*len(regStr))]
    #set the data bit for bit to be written
    for i in range(len(regs_seq)):
        regs_seq[i][SER_DI]=regStr[int((i)/3)]
    #LO_SLE must be set on and off for each data bit to be written
    for i in range(1,len(regs_seq),3):
        regs_seq[i][LO_SLE]='1'
    #concatenate each bitlist into a bitstring
    for i in range(len(regs_seq)):
        regs_seq[i]=''.join(regs_seq[i])
    #convert bitstrings to integers and write to regs register in sequence
    for i in range(1,len(regs_seq)):
        roach.write_int('regs',int(regs_seq[i],base=2) )

    roach.write_int('regs',int('11000',base=2) )
    roach.write_int('if_switch', 0)

if len(sys.argv) != 2:
    print 'Usage: %s roachNumber'%sys.argv[0]
    exit(1)
t0=time.time()
r=int(sys.argv[1])
roach = corr.katcp_wrapper.FpgaClient('10.0.0.1%d'%r,7147)
time.sleep(0.01)
atten_in = 5
attens = [12,6,5,5,7,7,6,4]
atten_out = attens[r]
high_power = 0
programAttenuators(roach,atten_in,high_power)
programAttenuators(roach,atten_in,atten_out)
print 'Flash on Roach ',r
