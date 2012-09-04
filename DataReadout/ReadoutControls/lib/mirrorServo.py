"""
   mirrorServo.py was written to control the 8711HV digital rotary servo
   and Marty's laser box with the Labjack U3-HV for the wavelength
   calibration setup.

   The laser box 1PPS signal should be tied to DAC0, and the signal for
   the servo is FIO4, routed through a single supply opamp to ensure
   high enough voltage on the signal line.

   author: Danica Marsden                               August 6, 2012
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
maxTime = 5. * 60.   # 5 minutes

if (len(sys.argv) < 3):
    print "Syntax is:  >>> python mirrorServo.py <angle [degrees]> <time [s]>"
    sys.exit(1)

angleReq = float(sys.argv[1])  # Note: motion is CCW!

if (angleReq > rangeOfServo):
    print "Need to specify an angle <= ", rangeOfServo
    sys.exit(1)
if (angleReq < 0.):
    print "Need to specify an angle >= 0"
    sys.exit(1)

dutyReq = ((endpt-home)/rangeOfServo)*angleReq + home
#print dutyReq

waitTime = 1
calObsTime = float(sys.argv[2])

if (calObsTime > maxTime):
    print "Need to specify a time <= 5 minutes"
    sys.exit(1)
if (calObsTime < 0.):
    print "Need to specify a time >= 0"
    sys.exit(1)

# Set the timer clock to be 48 MHz/divisor with a divisor of 3
d.configTimerClock(TimerClockBase = 6, TimerClockDivisor = 3)

# Enable the timer, at FIO4
d.configIO(TimerCounterPinOffset = 4, NumberOfTimersEnabled = 1)

# Configure the timer for 16 bit PWM, with a duty cycle of a given %, where duty
# cycle is the amount of time "off"/down.  This creates an overall PWM frequency
# of ~244.1Hz (4.1ms period) with (1 - dutyCycle)*4.1 ms "on"/high.

baseValue = 65536
dutyCycle = home
d.getFeedback( u3.Timer0Config(TimerMode = 0, Value = int(baseValue*dutyCycle)) )
d.getFeedback(u3.DAC16(Dac=0, Value = 0x0))

# Wait at home
time.sleep(waitTime)


# Update the duty cycle and apply for the specified time

print "Turning lasers on"

dutyCycle = dutyReq
d.getFeedback( u3.Timer0( Value = int(baseValue*dutyCycle), UpdateReset = True ) )

d.getFeedback(u3.DAC16(Dac=0, Value = 0xffff))

time.sleep(calObsTime)


# Go home, turn off laser

print "Turning lasers off"

dutyCycle = home
d.getFeedback( u3.Timer0( Value = int(baseValue*dutyCycle), UpdateReset = True ) )
d.getFeedback(u3.DAC16(Dac=0, Value = 0x0))

# Close the device
d.close
