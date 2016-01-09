"""
File:      ctr_8b_gbe.py
Author:    Matt Strader
Date:      Jan 6, 2016
Firmware:  ctr_8b_gbe_2016_Jan_06_1053.fpg

"""

import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr
import logging
import types
import sys
import functools

if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.111'
    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    time.sleep(1)

    if not fpga.is_running():
        print 'Firmware is not running. Start firmware first!'
        exit(0)

    fpga.get_system_information()

    dest_ip  =167772210 #corresponds to IP 10.0.0.50
    fabric_port=34939
    pktPeriod = 2**5
    pktsPerFrame = 170

    fpga.write_int('run',0)

    bytesSent = fpga.read_int('byte_cnt')
    eofSent = fpga.read_int('eof_cnt')
    almostFullTxBuffers = fpga.read_int('gbe64_tx_afull')
    overrunTxBuffers = fpga.read_int('gbe64_tx_overrun')
    print 'since start'
    print bytesSent, 'packs sent'
    print eofSent, 'frames sent'
    print 'almost full:',almostFullTxBuffers
    print 'overrun:',overrunTxBuffers

    print 'restarting'
    fpga.write_int('gbe64_dest_ip',dest_ip)
    fpga.write_int('gbe64_dest_port',fabric_port)
    fpga.write_int('pkt_period',pktPeriod)
    fpga.write_int('pkts_per_frame',pktsPerFrame)

    time.sleep(.1)
    fpga.write_int('gbe64_rst',1)
    time.sleep(.1)
    fpga.write_int('gbe64_rst',0)

    time.sleep(1)
    fpga.write_int('run',1)

    time.sleep(1)

    bytesSent = fpga.read_int('byte_cnt')
    eofSent = fpga.read_int('eof_cnt')
    almostFullTxBuffers = fpga.read_int('gbe64_tx_afull')
    overrunTxBuffers = fpga.read_int('gbe64_tx_overrun')

    print 'after 1 sec'
    print bytesSent, 'packs sent'
    print eofSent, 'frames sent'
    print 'almost full:',almostFullTxBuffers
    print 'overrun:',overrunTxBuffers

    fpga.snapshots['snp_ss'].arm(man_valid=True, man_trig=True)

    fpga.write_int('trig',0)
    time.sleep(.1)
    fpga.write_int('trig',1)
    time.sleep(.1)
    fpga.write_int('trig',0)

    snpData = fpga.snapshots['snp_ss'].read(timeout=10,arm=False)['data']
    #fpga.write_int('run',0)
    for key in snpData:
        print key,snpData[key][0:20]
