"""
   laserBoxControl.py was written to turn Marty's laser box on/off
   with the Labjack U3-HV.

   The laser box 1PPS signal should be tied to DAC1.

   author: Danica Marsden                          September 5, 2012
"""

import u3, time, sys

#u3.listAll(3)

# Open the LabJack
#d = u3.U3(debug = True)
d = u3.U3()

# Configure
d.configU3()

DAC1_Register = 5002
FIO6_Register = 6106
FIO7_Register = 6107
FIO6_State = 6006
FIO7_State = 6007

# Set FIO6 and 7 to digital output
d.writeRegister(FIO6_Register,1)
d.writeRegister(FIO7_Register,1)

#print d.configU3()
#print d.configIO()

#onval  = 0xffff
#offval = 0x0

#onval = 5.0
#offval = 0.0

if (len(sys.argv) < 3):
    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'> <'blue' or 'red' or 'ir'>"
    sys.exit(1)

#if (len(sys.argv) < 2):
#    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'>"
#    sys.exit(1)

actionReq = sys.argv[1]
laserReq = sys.argv[2]

if ((actionReq != 'on') * (actionReq != 'off')):
    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'> <'blue' or 'red' or 'ir'>"
    #print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'>"
    sys.exit(1)

if ((laserReq != 'blue')*(laserReq != 'red')*(laserReq != 'ir')):
    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'> <'blue' or 'red' or 'ir'>"
    sys.exit(1)

if (actionReq == 'on'):
    if (laserReq == 'blue'):
       d.writeRegister(DAC1_Register, 5.0)
    if (laserReq == 'red'):
       d.writeRegister(FIO6_State, 1)
    if (laserReq == 'ir'):
       d.writeRegister(FIO7_State, 1)
if (actionReq == 'off'):
    if (laserReq == 'blue'):
       d.writeRegister(DAC1_Register, 0.0)
    if (laserReq == 'red'):
       d.writeRegister(FIO6_State, 0)
    if (laserReq == 'ir'):
       d.writeRegister(FIO7_State, 0)

#print "Turning lasers ", actionReq
print "Turning ", laserReq, " laser ", actionReq

# Close the device
d.close
