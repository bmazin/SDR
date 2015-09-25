import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr
import logging
from myQdr import Qdr as myQdr
import types
import sys
from Utils import bin
import functools
import os


if __name__=='__main__':

    if len(sys.argv) > 1:
        ip = sys.argv[1]
    else:
        ip='10.0.0.112'
    bQdrFlip = True
    calVerbosity = 0
    qdrMemNames = ['qdr0_memory','qdr1_memory','qdr2_memory']
    qdrMemNames = ['qdr0_memory']
    qdrNames = ['dds_lut_qdr0','dds_lut_qdr1','dds_lut_qdr2']
    qdrNames = ['dds_lut_qdr0']

    fpga = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=50.)
    if not fpga.is_running():
        fpgPath = os.environ['FPG_PATH']
        print 'Programming board with fpg:',fpgPath
        fpga.upload_to_ram_and_program(fpgPath)

    print 'Fpga Clock Rate:',fpga.estimate_fpga_clock()

    bQdrCal = True
    if bQdrCal:
        bFailHard = False
        fpga.get_system_information()
        results = {}
        for iQdr,qdr in enumerate(fpga.qdrs):
            mqdr = myQdr.from_qdr(qdr)
            print qdr.name
            results[qdr.name] = mqdr.qdr_cal2(fail_hard=bFailHard,verbosity=calVerbosity)

        print 'Qdr cal results:',results
        for qdrName in qdrNames:
            if not results[qdrName]:
                exit(1)

    time.sleep(1)
    print 'done!'







