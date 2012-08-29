import fractions
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
print "setting up CK PLL for 532 MHz...",

freq=512.0e6
sweep_freq=0
ref_division_factor=8
f_pfd = 10e6/ref_division_factor
f = freq
	
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
MUX = 0
LOCK_DETECT = 1
PRESCALAR = 1 #4/5 mode f<3GHz
CHARGE_PUMP_CURRENT_SETTING=7
LDP=1# 6 ns
POLARITY=1 #positive
ENABLE_RF_OUTPUT = 1
ENABLE_AUX_OUTPUT = 1
BAND_SELECT_CLOCK_DIVIDER=80
FEEDBACK_SELECT=1#fundamental
DIVIDER_SELECT=3# div factor = 8
CLOCK_DIVIDER_VALUE=150
DBB=1
CTRL_BITS = [0,1,2,3,4,5]
reg5 = (LOCK_DETECT<<22) + CTRL_BITS[5]
reg4 = (FEEDBACK_SELECT<<23) +(DIVIDER_SELECT<<20)+ (BAND_SELECT_CLOCK_DIVIDER<<12) + (ENABLE_AUX_OUTPUT<<8) + (aux_power<<6) + (ENABLE_RF_OUTPUT<<5) + (power<<3) + CTRL_BITS[4]
reg3 = (CLOCK_DIVIDER_VALUE<<3) + CTRL_BITS[3]
reg2 = (MUX<<26) + (R<<14) + (CHARGE_PUMP_CURRENT_SETTING<<9) + (LDP<<7) + (POLARITY<<6) + CTRL_BITS[2]
reg1 = (PRESCALAR<<27) + (PHASE<<15) + (MOD<<3) + CTRL_BITS[1]
reg0 = (INT<<15) + (FRAC<<3)+CTRL_BITS[0]
regs = [reg5, reg4, reg3, reg2, reg1, reg0]
print regs
for r in regs:
	roach.write_int('CK_SLE', 1)
	roach.write_int('SER_DI', r)
	roach.write_int('start', 1)
	time.sleep(.5)
	roach.write_int('start', 0)
	roach.write_int('CK_SLE', 0)
print "done"
