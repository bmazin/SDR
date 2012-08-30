"""
   SignalFilterWheel.py was written to send a LabView filter wheel an active low
   pulse over BNC to move it one filter position.

   author: Seth Meeker                               August 29, 2012
"""

import u3, time, sys

#u3.listAll(3)

# Open the LabJack
#d = u3.U3(debug = True)
d = u3.U3()

# Configure
d.configU3()

DAC1_REGISTER = 5002
d.writeRegister(DAC1_REGISTER, 3.0)
time.sleep(0.4)

d.writeRegister(DAC1_REGISTER, 0)
time.sleep(0.1)

d.writeRegister(DAC1_REGISTER,3.0)
time.sleep(0.4)

#print d.configU3()
#print d.configIO()

#d.getFeedback( u3.Timer0Config(TimerMode = 0, Value = int(baseValue*dutyCycle)) )
#d.getFeedback(u3.DAC16(Dac=1, Value = 0x0))

# Close the device
d.close
