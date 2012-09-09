"""
   laserBoxControl.py was written to turn Marty's laser box on/off
   with the Labjack U3-HV.

   The laser box 1PPS signal should be tied to DAC0.

   author: Danica Marsden                          September 5, 2012
"""

import u3, time, sys

#u3.listAll(3)

# Open the LabJack
#d = u3.U3(debug = True)
d = u3.U3()

# Configure
d.configU3()

#print d.configU3()
#print d.configIO()

onval  = 0xffff
offval = 0x0


if (len(sys.argv) < 2):
    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'>"
    sys.exit(1)

actionReq = sys.argv[1]

if ((actionReq != 'on') * (actionReq != 'off')):
    print "Syntax is:  >>> python laserBoxControl.py <'on' or 'off'>"
    sys.exit(1)

if (actionReq == 'on'):
   valReq = onval
if (actionReq == 'off'):
    valReq = offval


d.getFeedback(u3.DAC16(Dac=0, Value = valReq))

print "Turning lasers ", actionReq

# Close the device
d.close
