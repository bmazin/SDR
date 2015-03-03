import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr

def readMemory(roach,memName,nSamples,nBytesPerSample=4):
    """
    read a byte string from a bram or qdr, and parse it into an array
    """
    if nBytesPerSample == 4:
        formatChar = 'L'
    elif nBytesPerSample == 8:
        formatChar = 'Q'
    else:
        raise TypeError('nBytesPerSample must be 4 or 8')

    memStr = roach.read(memName,nSamples*nBytesPerSample)
    memValues = struct.unpack('>{}{}'.format(nSamples,formatChar),memStr)
    return memValues

def loadQdrInFirmware(roach,loadChoice=0):
    """
    load the qdr with values within the fpga
    loadChoice can be 0 for loading all zeros
     1 for loading all ones
     2 for loading all twos
     3 for loading a sequence that matches the row number
     4 to set 32 bits to 1
     5 to load 36 bits to 1
     6 to set every other bit in 32 bits to 1, starting with a 1
     7 to set every other bit in 36 bits to 1,
    """

    roach.write_int('load_qdr',0)
    roach.write_int('read_qdr',0)
    roach.write_int('load_data_choice',loadChoice) #2, for all twos
    time.sleep(.2)
    roach.write_int('load_qdr',1)
    time.sleep(2)
    roach.write_int('load_qdr',0)
    time.sleep(1)


if __name__=='__main__':
    ip='10.0.0.12'
    bCorr = True
    bRoach2 = False
    bQdrCal = False
    if bCorr:
        roach = corr.katcp_wrapper.FpgaClient(ip,7147,timeout=20.)
    else:
        roach = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=20.)
        if bQdrCal:
            roach.get_system_information()
            results = {}
            for qdr in roach.qdrs:
                results[qdr.name] = qdr.qdr_cal(fail_hard=False)

            print 'qdr cal results:',results

    time.sleep(2)

    #define some globals
    #nQdrSamples=2**11
    nQdrSamples=2**20 #2**5
    nQdrRows = 2**20
    nBytesPerSample=4
    if bRoach2:
        nBytesPerQdrSample=8
        qdrFormatCode = 'Q'
    else:
        nBytesPerQdrSample=4
        qdrFormatCode = 'L'
    nSnapSamples = 10 #2**5
    nBytesPerSnapSample=4
    qdrSize=2**20*nBytesPerSample

    #snapCtrls = ['addr_ctrl','dataOut_ctrl','dataIn_ctrl','dataValid_ctrl','dataIn64_ctrl']
    #snapBrams = ['addr_bram','dataOut_bram','dataIn_bram','dataValid_bram','dataIn64_bram']
    #snapSampleSizes = [4,4,4,4,8] #in bytes
    snapCtrls = ['addr_ctrl','dataIn64_ctrl','dataOut64_ctrl']
    snapBrams = ['addr_bram','dataIn64_bram','dataOut64_bram']
    snapSampleSizes = [4,8,8] #in bytes


    #be sloppy and define a function here that uses the above variables
    def readAllMem(roach):
        """
        trigger all snapblocks, read them, then read the qdr
        """

        roach.write_int('read_qdr',1)
        time.sleep(.5)
        #prime registers and trigger
        roach.write_int('addrTrig',0)
        time.sleep(.5)
        roach.write_int('snap',0)
        for ctrl in snapCtrls:#prime snapshot blocks
            roach.write_int(ctrl,0)
            roach.write_int(ctrl,1)
        roach.write_int('snap',1)
        time.sleep(.5)
        roach.write_int('snap',0)
            
        valDict = {}
        for bram,nBytesPerSample in zip(snapBrams,snapSampleSizes):
            valDict[bram] = readMemory(roach,bram,nSnapSamples,nBytesPerSample)

        roach.write_int('addrTrig',2**19-5)
        time.sleep(.5)
        roach.write_int('snap',0)
        for ctrl in snapCtrls:#prime snapshot blocks
            roach.write_int(ctrl,0)
            roach.write_int(ctrl,1)
        roach.write_int('snap',1)
        time.sleep(.5)
        roach.write_int('snap',0)

        valDictEnd = {}
        for bram,nBytesPerSample in zip(snapBrams,snapSampleSizes):
            valDictEnd[bram] = readMemory(roach,bram,nSnapSamples,nBytesPerSample)

        for bram in snapBrams:
            print bram,'\t',valDict[bram],'\t',valDictEnd[bram]

        qdrVals = readMemory(roach,'qdr0_memory',nQdrSamples,nBytesPerQdrSample)
        roach.write_int('read_qdr',0)
        #just print the first few and last few
        print 'read by katcp','\t',qdrVals[0:nSnapSamples],'\t',qdrVals[-nSnapSamples:]



    #Now try loading qdr with various values, and reading it out both in firmware
    # and by katcp

    print 'write twos to qdr within firmware'
    loadQdrInFirmware(roach,loadChoice=2)
    readAllMem(roach)

    print ''
    print 'write sequence to qdr within firmware'
    print ' read by katcp may be offset by one'
    loadQdrInFirmware(roach,loadChoice=3)
    readAllMem(roach)

    print ''
    print 'write every other bit in qdr within firmware'
    print ' this demonstrates that qdr uses 36 bit words, but'
    print ' katcp can only access 32 bits'
    loadQdrInFirmware(roach,loadChoice=7)
    readAllMem(roach)

    print ''
    print 'clearing qdr'
    loadQdrInFirmware(roach,loadChoice=0)

    print ''
    print 'writing sequence by katcp'
    print ' dataOut may be offset by one'
    toWrite = np.arange(nQdrRows)
    #toWrite = np.ones(nQdrSamples)
    #toWrite = np.zeros(nQdrSamples)
    toWriteStr = struct.pack('>{}{}'.format(nQdrRows,qdrFormatCode),*toWrite)
    qdrValues = struct.unpack('>{}{}'.format(nQdrRows,qdrFormatCode),toWriteStr)
    print 'katcp towrite','\t',qdrValues[0:nSnapSamples],'\t',qdrValues[-nSnapSamples:]
    roach.blindwrite('qdr0_memory',toWriteStr)
    time.sleep(.5)
    readAllMem(roach)

