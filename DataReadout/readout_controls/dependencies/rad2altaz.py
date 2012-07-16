#rad2altaz.py
#Written 9/28/10 by Seth Meeker

from numpy import *

def rad2altaz(ra, dec, lon, lat, time=None):
	'''callable python program for converting RA/Dec coordinates to Alt/Az.
	Inputs: Right Ascension and Declination of object
			Latitude and Longitude of observing site
			Time of observation (in format of python's time.gmtime() function call).
				Defaults to current time if none given.
	Outputs: Altitude, Azimuth, Hour Angle, and Local Sidereal Time of object
	
	Sidereal Time calculated using J2000 epoch
	'''
	
	#calculate days since J2000
	#days = days in previous years + extra days for leap years + days this year + fraction from today
	years = time.tm_year - 2000
	today = (time.tm_hour+(time.tm_min/60.)+(time.tm_sec/3600.))/24. 
	days = 365*(years-1) + (years-1)/4 + (time.tm_yday -1) + today
	
	#calculate Local Sidereal Time from longitude and days from the epoch
	LST = 100.46 + 0.985647*days + lon + 15*(today*24)
	LST %= 360
	
	#calculate Hour Angle of object
	HA = LST - ra
	
	#setup conversions from degrees to radians and radians to degrees
	d2r = pi/180
	r2d = 180/pi

	#calculate altitude
	alt = r2d*arcsin((sin(dec*d2r)*sin(lat*d2r))+(cos(dec*d2r)*cos(lat*d2r)*cos(HA*d2r)))
	
	#calculate azimuth
	A = r2d*arccos((sin(dec*d2r)-sin(alt*d2r)*sin(lat*d2r))/(cos(alt*d2r)*cos(lat*d2r)))
	az = 360-A
	
	return alt, az, LST, HA