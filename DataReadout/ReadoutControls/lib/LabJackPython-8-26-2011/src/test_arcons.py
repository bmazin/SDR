"""
   test commands for the Labjack U3-HV.

   author: Danica Marsden                               August 6, 2012
"""

import u3, time

# Open the LabJack
d = u3.U3(debug = True)

# Configure
d.configU3()

print d.configU3()
print d.configIO()


#
#  Control the status LED:
#

d.getFeedback(u3.LED(0))
d.getFeedback(u3.LED(1))


#
#  Example with DAC0 hotwired to AIN0:
#

DAC0_REGISTER = 5000

# Set DAC0 to 1.5 V
d.writeRegister(DAC0_REGISTER, 1.5) 

# Read value
AIN0_REGISTER = 0
d.readRegister(AIN0_REGISTER)

# Set DAC0 to 0.5 V
d.writeRegister(DAC0_REGISTER, .5)
d.readRegister(AIN0_REGISTER)

#
#  Set DAC output levels another way:
#

d.getFeedback(u3.DAC16(Dac=0, Value = 0x7fff))  # ~2.5V = 1/2 of 0xffff
d.getFeedback(u3.DAC16(Dac=1, Value = 0xffff))  # ~4.95V
d.getFeedback(u3.DAC16(Dac=0, Value = 0x0))
d.getFeedback(u3.DAC16(Dac=1, Value = 0x0))


# Close the device
d.close
