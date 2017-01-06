"""
File:      ctr_64b_gbe_new_hdr.py
Author:    Matt Strader/Neelay Fruitwala
Date:      Jan 6, 2016
Firmware:  ctr_64b_gbe_hdr3_nfstest_Jun_2x.fpg

Tells the firmware to start sending udp packets along with what rate to send them.
"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import logging
import types
import sys
import functools

if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = '10.0.0.' + sys.argv[1]
        boardNum = int(sys.argv[1])-100
    else:
        ip='10.0.0.111'
        boardNum = 11
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware first!'
        exit(0)

    fpga.get_system_information()

    dest_ip  = 167772211 #corresponds to IP 10.0.0.51
    fabric_port=50000
    pktPeriod = 122
    pktsPerFrame = 100
    runTime = 20 #run for 20 sec
    maxFramePeriod = 50000
    #maxFramePeriod = 560000
    

    fpga.write_int('run',0)

    bytesSent = fpga.read_int('word_ctr')
#    eofSent = fpga.read_int('eof_cnt')
    almostFullTxBuffers = fpga.read_int('gbe64_tx_afull')
    overrunTxBuffers = fpga.read_int('gbe64_tx_overrun')
    print 'since start'
    print bytesSent, 'packs sent'
#    print eofSent, 'frames sent'
    print 'almost full:',almostFullTxBuffers
    print 'overrun:',overrunTxBuffers

    print 'restarting'
    fpga.write_int('gbe64_dest_ip',dest_ip)
    fpga.write_int('gbe64_dest_port',fabric_port)
    fpga.write_int('pkt_period',pktPeriod)
    fpga.write_int('gbe64_words_per_frame',pktsPerFrame)
    fpga.write_int('gbe64_max_frame_period',maxFramePeriod)
    fpga.write_int('board_num',boardNum)

    time.sleep(.1)
    fpga.write_int('gbe64_rst',1)
    time.sleep(.1)
    fpga.write_int('gbe64_rst',0)

    time.sleep(1)
    fpga.write_int('timekeeper_base_ts',int(time.time()%31536000))
    fpga.write_int('run',1)

    time.sleep(runTime)

    bytesSent = fpga.read_int('word_ctr')
#    eofSent = fpga.read_int('eof_cnt')
#    almostFullTxBuffers = fpga.read_int('gbe64_tx_afull')
#    overrunTxBuffers = fpga.read_int('gbe64_tx_overrun')

    print 'after {} sec'.format(runTime)
    print bytesSent, 'packs sent'
    almostFullTxBuffers = fpga.read_int('gbe64_tx_afull')
    overrunTxBuffers = fpga.read_int('gbe64_tx_overrun')
#    print eofSent, 'frames sent'
    print 'almost full:',almostFullTxBuffers
    print 'overrun:',overrunTxBuffers
#    print eofSent, 'frames sent'
#    print 'almost full:',almostFullTxBuffers
#    print 'overrun:',overrunTxBuffers
    
    fpga.write_int('run',0)

    print 'off'

    
