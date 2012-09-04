"""
   mirrorGoHome.py was written to send the 8711HV digital rotary servo 
   to the home position and turn off the laser box with the Labjack U3-HV
   if need be.

   author: Danica Marsden                               August 13, 2012
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

home =  0.467    # 0 degrees
endpt = 0.8095   # 145 degrees
center = 0.62891 # corresponds to 1.52ms "on"/high
rangeOfServo = 145.  # degrees

if (len(sys.argv) < 2):
    print "Syntax is:  >>> python mirrorGoToAngle.py <angle [degrees]>"
    sys.exit(1)

angleReq = float(sys.argv[1])  # Note: motion is CCW!

if (angleReq > rangeOfServo):
    print "Need to specify an angle <= ", rangeOfServo
    sys.exit(1)
if (angleReq < 0.):
    print "Need to specify an angle >= 0"
    sys.exit(1)

dutyReq = ((endpt-home)/rangeOfServo)*angleReq + home


# Set the timer clock to be 48 MHz/divisor with a divisor of 3
d.configTimerClock(TimerClockBase = 6, TimerClockDivisor = 3)

# Enable the timer, at FIO4
d.configIO(TimerCounterPinOffset = 4, NumberOfTimersEnabled = 1)

# Configure the timer for 16 bit PWM, with a duty cycle of a given %, where duty
# cycle is the amount of time "off"/down.  This creates an overall PWM frequency
# of ~244.1Hz (4.1ms period) with (1 - dutyCycle)*4.1 ms "on"/high.

baseValue = 65536
dutyCycle = dutyReq
d.getFeedback( u3.Timer0Config(TimerMode = 0, Value = int(baseValue*dutyCycle)) )
d.getFeedback(u3.DAC16(Dac=0, Value = 0x0))

# Close the device
d.close
