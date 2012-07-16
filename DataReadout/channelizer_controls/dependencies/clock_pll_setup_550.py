import corr, time, sys
r = str(sys.argv[1])
print "opening client and programming "+r+"...",
roach = corr.katcp_wrapper.FpgaClient(r, 7147)

time.sleep(1)
roach.progdev('if_setup.bof')
time.sleep(3)
print "done"


#	Set up CK PLL
#	Write 32 bit word to SER_DI
print "setting up CK PLL for 550 MHz...",

reg0 = 0x00dc0000
reg1 = 0x08008061
reg2 = 0x00004ec2
reg3 = 0x000004b3
reg4 = 0x00b501fc
reg5 = 2**22 + 2**2 + 2**0



regs = [reg5, reg4, reg3, reg2, reg1, reg0]
 
for r in regs:
	roach.write_int('CK_SLE', 1)
	roach.write_int('SER_DI', r)
	roach.write_int('start', 1)
	time.sleep(.5)
	roach.write_int('start', 0)
	roach.write_int('CK_SLE', 0)
print "done"
