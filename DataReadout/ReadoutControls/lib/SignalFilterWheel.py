"""
   SignalFilterWheel.py was written to send a LabView filter wheel an active low
   pulse over BNC to move it one filter position.

   author: Seth Meeker                               August 29, 2012
"""

import u3, time, sys

def SignalFilterWheel():
    
    basevoltage = 4.5
    triggervoltage = 0.0
    
    # Open the LabJack
    d = u3.U3()
    
    # Configure
    d.configU3()
    
    DAC1_REGISTER = 5002
    d.writeRegister(DAC1_REGISTER, basevoltage)
    #print "Switched voltage to " + str(basevoltage)
    time.sleep(0.5)
    
    d.writeRegister(DAC1_REGISTER, triggervoltage)
    #print "Switched voltage to " + str(triggervoltage)
    time.sleep(0.5)
    
    d.writeRegister(DAC1_REGISTER,basevoltage)
    #print "Switched voltage to " + str(basevoltage)
    #time.sleep(0.5)
    
    d.close

if __name__ == '__main__':
    SignalFilterWheel()