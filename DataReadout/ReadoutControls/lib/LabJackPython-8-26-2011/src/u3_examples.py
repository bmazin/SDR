"""
   u3_examples.py was written to test comands for the Labjack U3-HV.

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


#
#  Blink the U3's status LED until the AIN0 input exceeds a limit value.
#  Any voltage source with a range between 0 and 5VDC will work as AIN0
#  input.  Touching a jumper wire between AIN0 and any VS terminal will
#  also work.
#

LEDoff = u3.LED(0)
LEDon = u3.LED(1)
AINcmd = u3.AIN(0, 31, False, False)

toggle = 0

while True:

    # blink the LED while looping
    if toggle == 0:
        d.getFeedback(LEDon)
        toggle = 1
    else:
        d.getFeedback(LEDoff)
        toggle = 0
        
    # getFeedback returns a list with a single element
    inval = d.getFeedback(AINcmd)[0]
    print inval
    if inval > 40000:
        break
    time.sleep(1)

d.getFeedback(LEDon)
print "Done."


#
#  FIO4 ( a digital output) rapidly toggled on and off:
#  (It’s fast, you’ll need an oscilloscope if you want to see this activity)
#

biton = u3.BitStateWrite(4,1)
bitoff = u3.BitStateWrite(4,0)
d.getFeedback(bitoff, biton, bitoff, biton, bitoff)




# Close the device
d.close

##############################

#a list of the FeedbackCommand derived class commands in the u3.py module: 
# AIN(PositiveChannel, NegativeChannel=31, LongSettling=False, QuickSample=False)
# WaitShort(Time)
# WaitLong(Time)   (python's sleep() method is better!)
# LED(State)
# BitStateRead(IONumber)
# BitStateWrite(IONumber, State)
# BitDirRead(IONumber)
# BitDirWrite(IONumber, Direction)
# PortStateRead()
# PortStateWrite(State, WriteMask=[0xff, 0xff, 0xff])
# PortDirRead()
# PortDirWrite(Direction, WriteMask=[0xff, 0xff, 0xff])
# DAC8(Dac, Value)
# DAC0_8(Value)
# DAC1_8(Value)
# DAC16(Dac, Value)
# DAC0_16(Value)
# DAC1_16(Value)
# Timer(timer, UpdateReset=False, Value=0, Mode=None)
# Timer0(UpdateReset=False, Value=0, Mode=None)
# Timer1(UpdateReset=False, Value=0, Mode=None)
# QuadratureInputTimer(UpdateReset=False, Value=0)
# TimerStopInput1(UpdateReset=False, Value=0)
# TimerConfig(timer, TimerMode, Value=0)
# Timer0Config(TimerMode, Value=0)
# Timer1Config(TimerMode, Value=0)
# Counter(counter, Reset=False)
# Counter0(Reset=False)
# Counter1(Reset=False)

# class U3 functions:
# asynchConfig()
# asynchRX()
# asynchTX()
# binaryToCalibratedAnalogVoltage()
# configAnalog()
# configDigital()
# configIO()
# configTimerClock()
# configU3()
# eraseCal()
# eraseMem()
# exportConfig()
# getAIN()
# getCalibrationData()
# getFIOState()
# getFeedback()
# i2c()
# loadConfig()
# open()
# processStreamData()
# readCal()
# readDefaultsConfig()
# readMem()
# reset()
# setFIOState()
# sht1x()
# spi()
# streamConfig()
# toggleLED()
# voltageToDACBits()
# watchdog()
# writeCal()
# writeMem()

# class Device:
# breakupPackets()
# close()
# getName()
# open()
# ping()
# read()
# readCurrent()
# readDefaults()
# readRegister()
# reset()
# samplesFromPacket()
# setDIOState()
# setDefaults()
# setName()
# setToFactoryDefaults()
# streamData()
# streamStart()
# streamStop()
# write()
# writeRegister()



