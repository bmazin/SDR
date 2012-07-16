import corr, time, sys
r = str(sys.argv[1])
print "opening client and programming "+r+"...",
roach = corr.katcp_wrapper.FpgaClient(r, 7147)
#roach = corr.katcp_wrapper.FpgaClient(r+'.physics.ucsb.edu', 7147)
#roach = corr.katcp_wrapper.FpgaClient('roach1.physics.ucsb.edu', 7147)
time.sleep(1)
roach.progdev('if_setup.bof')
time.sleep(3)
print "done"


#	Set up CK PLL
#	Write 32 bit word to SER_DI
print "setting up CK PLL for 512 MHz...",
reg5 = 2**22 + 2**2 + 2**0
reg4 = 2**2 + 2**3 + 2**4 + 2**5 + 2**16 + 2**18 + 2**20 + 2**21 + 2**23
reg3 = 2**0 + 2**1 + 2**4 + 2**5 + 2**7 + 2**10
reg2 = 2**27 + 2**26 + 2**14 + 2**11 + 2**10 + 2**9 + 2**7 + 2**6 + 2**1
reg1 = 2**27 + 2**15 + 2**5 + 2**3 + 2**0
reg0 = 2**23 + 2**22 + 2**19 + 2**18 + 2**15 + 2**4 + 2**3
regs = [reg5, reg4, reg3, reg2, reg1, reg0]

for r in regs:
	roach.write_int('CK_SLE', 1)
	roach.write_int('SER_DI', r)
	roach.write_int('start', 1)
	time.sleep(.5)
	roach.write_int('start', 0)
	roach.write_int('CK_SLE', 0)
print "done"



