# v2 keeps socket connection open continuously.  Has a problem with data staying in the socket and responses getting jumbled.

#import standard python libraries
import sys
import time
import struct
import os
from os.path import isfile
import socket

if __name__ == "__main__":
	
	client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			
	#print client.getsockopt(socket.SOL_SOCKET, socket.SO_TYPE)
	#client.setblocking(0)
	#print type(client)
	
	print "Connecting..."
	
	#client.connect(("",60001))
	client.connect(("198.202.125.194", 5004)) #connecting remotely to Palomar
	#client.connect(("10.200.2.11", 49200))
	
	print "Connected!"
	
	while True:
		
		request = raw_input('->')
		
		if request == 'q':
			client.close()
			print "Connection closed."
			break	
		
		elif request == '1':
			client.send('\r')
			print "Header Request sent..."
			response = client.recv(1024)
			print "Received ", repr(response)
			print "Which means:"
			ra_hours,ra_minutes,ra_seconds,ra_hundredth_seconds,dummyword_4,dec_degrees,dec_minutes,dec_seconds,dec_tenth_seconds,dec_sign,lst_hours,lst_minutes,\
			lst_seconds,lst_tenth_seconds,dummyword_14,ha_hours,ha_minutes,ha_seconds,ha_tenth_seconds,ha_direction,ut_hours,ut_minutes,ut_seconds,ut_tenth_seconds,\
			airmass,display_equinox,dummyword_28,dummyword_29,dummyword_30,dummyword_31,dummyword_32,dummyword_33,cass_ring_angle,telescope_focus_mm,telescope_tubelength_mm,\
			ra_offset_arcsec,dec_offset_arcsec,ra_track_rate_arcsec,dec_track_rate_arcsec,dummyword_48,telescope_id =\
			struct.unpack('hhhhhhhhhhhhhhhhhhhhhhhhffhhhhhhfffffffhh', response)
			
			status = (ra_hours,ra_minutes,ra_seconds,ra_hundredth_seconds,dummyword_4,dec_degrees,dec_minutes,dec_seconds,dec_tenth_seconds,dec_sign,lst_hours,lst_minutes,\
			lst_seconds,lst_tenth_seconds,dummyword_14,ha_hours,ha_minutes,ha_seconds,ha_tenth_seconds,ha_direction,ut_hours,ut_minutes,ut_seconds,ut_tenth_seconds,\
			airmass,display_equinox,dummyword_28,dummyword_29,dummyword_30,dummyword_31,dummyword_32,dummyword_33,cass_ring_angle,telescope_focus_mm,telescope_tubelength_mm,\
			ra_offset_arcsec,dec_offset_arcsec,ra_track_rate_arcsec,dec_track_rate_arcsec,dummyword_48,telescope_id)
			print status
			
			
			
		elif request == '2':
			client.send('REQPOS\r')
			print "REQPOS Request sent..."
			response = client.recv(1024)
			print "Received ", repr(response)
			
		elif request == '3':
			client.send('REQSTAT\r')
			print "REQSTAT Request sent..."
			response = client.recv(1024)
			print "Received ", repr(response)
			
		else:
			print "not a valid request. Enter: \n1 for binary header\n2 for REQPOS\n3 for REQSTAT\nq to quit"
				
				
				
				
				
				
				
				
				
