#!/usr/bin/env python

"""
A simple server that ckecks IP throughput
"""

import socket, struct
import sys
import time
import random
import string
import os
from subprocess import Popen,PIPE,call

def mysendall(client,data):
	size = len(data)
	totalsent = 0
	while totalsent < 32768:
		sent = client.send(data[totalsent:])
		if sent == 0:
			raise RuntimeError("sent = 0")
		totalsent = totalsent + sent
#data = random.getrandbits(8192)
#N = 1024
#data = ''.join(random.choice(string.printable) for x in range(N))

host = ''
port = 50000
backlog = 1
s = None

# location of ioregs in file structure, assuming pid is passed as argument to function
#if sys.argv[1] == '':
#    print 'Need pid as command line argument'
#    sys.exit(1)

firmware = 'timestamper.bof'
if sys.argv[1] != '':
    firmware = sys.argv[1]
# get the process id automatically
process = Popen(['ps', '-eo' ,'pid,args'], stdout=PIPE, stderr=PIPE)
stdout, notused = process.communicate()
procid = 0
for line in stdout.splitlines():
    tokens = line.split(' ',3)
    for i,token in enumerate(tokens):
    	if(token == '/boffiles/'+firmware):
		procid = tokens[i-1]
if procid == 0:
   print 'Firmware process ' + firmware + ' is not running'
   sys.exit(1)

#procid=sys.argv[1]
print 'Process ',procid
ptrfile =  '/proc/' + procid + '/hw/ioreg/pulses_addr'   
triggerfile = '/proc/' + procid + '/hw/ioreg/startBuffer'   
datafile0 = '/proc/' + procid + '/hw/ioreg/pulses_bram0'   
datafile1 = '/proc/' + procid + '/hw/ioreg/pulses_bram1'
   
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)
    s.bind((host,port))
    s.listen(backlog)
except socket.error, (code,message):
    if s:
        s.close()
    print "Could not open socket: " + message
    sys.exit(1)


while 1:
    # wait for the client to connect
    print 'Waiting for connection.'
    sys.stdout.flush()
    client, address = s.accept()
    
    # set registers to tell ROACH to start taking data
    f = open(triggerfile,'w')
    f.write('\x00\x00\x00\x01')
    f.close()    
    
    # open file/mem location with address pointer and other relevant files
    f = open(ptrfile,'rb')
    d0 = open(datafile0,'rb')
    d1 = open(datafile1,'rb')

    # don't take data until address begins to increment
    #time.sleep(1)
    print 'Starting new observation at: ',time.time()
    f.seek(0)
    start = f.read()
    print start.encode('hex')
    print type(start)
    start = struct.unpack('>l', start)[0]
    print start
    print type(start)
    while 1:
        f.seek(0)
        ptr = f.read()
        ptr = struct.unpack('>l', ptr)[0]
        if ptr > start:
            break
    
    print 'Adr began incrementing at: ',time.time()
        
    t0=0
    lost_count = 0
    packno=0
    # loop to send data
    last = 1
    while 1:
        # read pointer location
        f.seek(0)
        ptr = f.read()
	print 'ptr=',ptr.encode('hex')
        ptr = struct.unpack('>l', ptr)[0]
        print 'ptr_dec=',ptr
        
        # once 32768 bytes of data is ready send it out
        if ptr < 8192:
	    if last == 0:
		    print 'Data Lost: ',time.time()
		    lost_count = lost_count + 1
	    last = 0
            while ptr < 8500:
                time.sleep(0.001)
                f.seek(0)
                ptr = f.read()
                ptr = struct.unpack('>l', ptr)[0]     
            try:
		t = time.time()
                d0.seek(0)
                tmp = d0.read(32768)
                client.sendall(tmp)
                d1.seek(0)
                tmp2 = d1.read(32768)
		if t0 == 0:
			t0 = t
                client.sendall(tmp2)
		t2=time.time()
		print "packet ",packno," pixel ",tmp2[0].encode('hex')," at ",(t-t0)," took",(t2-t)
		packno = packno+1
            except:
                break
        elif ptr >= 8192 and ptr < 16384:
            if last == 1:
                    print 'Data Lost! :',time.time()
		    lost_count = lost_count + 1
            last = 1
            while ptr >= 8192 or ptr < 300:
                time.sleep(0.001)
                f.seek(0)
                ptr = f.read()
                ptr = struct.unpack('>l', ptr)[0]
            try:
		t = time.time()
                d0.seek(32768)
                tmp = d0.read(32768)
                client.sendall(tmp)
                d1.seek(32768)
                tmp2 = d1.read(32768)
                client.sendall(tmp2)
		t2=time.time()
		print "packet ",packno," pixel ",tmp2[0].encode('hex')," at ",(t-t0)," took",(t2-t)
		packno = packno+1
            except:
                break
                   
    # done with data taking
    print 'Cleaning up: ',time.time()
    print "Lost Count = ",lost_count
    try:
        client.close() 
    except:
        pass 
    
    f.close()
    d0.close()
    d1.close()
    
    f = open(triggerfile,'w')
    f.write('\x00\x00\x00\x00')
    f.close()    
        

