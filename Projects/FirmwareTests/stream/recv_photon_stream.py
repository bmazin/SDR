"""
File:      recv_64b_phase_stream.py
Author:    Matt Strader
Date:      Jan 11, 2016
Firmware:  ctr_64b_gbe.fpg

Modified by Neelay Fruiwala on June 17, 2016
"""

import matplotlib, time, struct, shutil
import numpy as np
import matplotlib.pyplot as plt
import sys
import socket

if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = '10.0.0.' + sys.argv[1]
    else:
        ip='10.0.0.112'
    host = '10.0.0.51'
    port = 50000
    # create dgram udp socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    except socket.error:
        print 'Failed to create socket'
        sys.exit()

    # Bind socket to local host and port
    try:
        sock.bind((host, port))
    except socket.error , msg:
        print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
        sys.exit()
    print 'Socket bind complete'

    keepGoing = True
    bufferSize = int(808) #100 8-byte values
    iFrame = 0
    nFramesLost = 0
    lastPack = -1
    expectedPackDiff = -1
    frameData = ''

    dumpFile = open('photonStreamDump.bin', 'w')

    try:
        while keepGoing:
            frame = sock.recvfrom(bufferSize)
            frameData += frame[0]
            #print len(frameData)
            #packs = struct.unpack('>{}Q'.format(len(frameData)/8),frameData)
            #if iFrame > 3:
            #    packDiff = packs[1] - lastPack
            #    if expectedPackDiff == -1:
            #        expectedPackDiff = packDiff
            #        print 'expected diff',expectedPackDiff
            #    else:
            #        if packDiff > expectedPackDiff:
            #            nFramesLost += packDiff/expectedPackDiff
            #            print 'lost {} frames total by frame {}'.format(nFramesLost,iFrame)
            iFrame += 1
            #lastPack = packs[1]

    except KeyboardInterrupt:
        print 'Exiting'
        sock.close()
        dumpFile.write(frameData)
        dumpFile.close()

    sock.close()
    dumpFile.close()

        
    


    


