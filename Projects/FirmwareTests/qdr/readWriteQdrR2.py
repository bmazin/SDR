import matplotlib, time, struct
import numpy as np
import matplotlib.pyplot as plt
import casperfpga
import corr
import logging

def readMemory(roach,memName,nSamples,nBytesPerSample=4,bQdrFlip=False):
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
    memValues = list(struct.unpack('>{}{}'.format(nSamples,formatChar),memStr))
    if bQdrFlip:
        memValues = np.right_shift(memValues,32)+np.left_shift(np.bitwise_and(memValues, int('1'*32,2)),32)
    return list(memValues)

def writeQdr(roach,memName,valuesToWrite,nBytesPerSample=4,start=0,bQdrFlip=False):
    if nBytesPerSample == 4:
        formatChar = 'L'
    elif nBytesPerSample == 8:
        formatChar = 'Q'
    else:
        raise TypeError('nBytesPerSample must be 4 or 8')

    memValues = np.array(valuesToWrite)
    if bQdrFlip:
        memValues = np.right_shift(memValues,32)+np.left_shift(np.bitwise_and(memValues, int('1'*32,2)),32)
    toWriteStr = struct.pack('>{}{}'.format(nQdrRows,formatChar),*memValues)
    roach.blindwrite(qdrMemName,toWriteStr,start)

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
    ip='10.0.0.112'
    bCorr = False
    bRoach2 = True
    bQdrCal = True
    calVerbosity = 1
    qdrMemName = 'qdr0_memory'

    if bCorr:
        roach = corr.katcp_wrapper.FpgaClient(ip,7147,timeout=20.)
        print 'Fpga Clock Rate:',roach.estimate_fpga_clock()
    else:
        roach = casperfpga.katcp_fpga.KatcpFpga(ip,timeout=40.)
        print 'Fpga Clock Rate:',roach.estimate_fpga_clock()
        if bQdrCal:

            roach.get_system_information()
            results = {}
            for qdr in roach.qdrs:
                results[qdr.name] = qdr.qdr_cal(fail_hard=False,verbosity=calVerbosity)

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
    snapSampleSizes = [4,8,8,4] #in bytes


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

        roach.write_int('addrTrig',2**19-nSnapSamples//2)
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

        qdrVals = readMemory(roach,qdrMemName,nQdrSamples,nBytesPerQdrSample,bQdrFlip=True)
        roach.write_int('read_qdr',0)
        #just print the first few and last few
        print 'read-by-katcp','\t',qdrVals[0:nSnapSamples],'\t',qdrVals[-nSnapSamples:]



    #Now try loading qdr with various values, and reading it out both in firmware
    # and by katcp

    print 'write twos to qdr within firmware'
    print ' addr increases every other cycle from 0 to 524287'
    print ' every data value read should be two'
    loadQdrInFirmware(roach,loadChoice=2)
    readAllMem(roach)

    print ''
    print 'write sequence to qdr within firmware'
    print ' dataIn, dataOut, and read-by-katcp should be a sequence from 0 to 1048575'
    print ' read-by-katcp may be offset by one'
    loadQdrInFirmware(roach,loadChoice=3)
    readAllMem(roach)

    everyOtherBit = int('10'*32,2)
    print ''
    print 'write every other bit in qdr within firmware'
    print ' every value should be',everyOtherBit,'which is',bin(everyOtherBit)
    loadQdrInFirmware(roach,loadChoice=7)
    readAllMem(roach)


    byteSortVal = 578437695752307201L #each of 8 bytes is a different value
    print ''
    print 'write a different value to each byte within firmware'
    print ' each value should be',byteSortVal,'which is',bin(byteSortVal)
    loadQdrInFirmware(roach,loadChoice=4)
    readAllMem(roach)

    print ''
    print 'clearing qdr'
    loadQdrInFirmware(roach,loadChoice=0)

    print ''
    print 'writing sequence by katcp'
    print ' dataIn should be all zeros'
    print ' dataOut and read-by-katcp should be a sequence from 0 to 1048575'
    print ' dataOut may be offset by one'
    toWrite = np.arange(nQdrRows)
    print 'katcp-to-write','\t',toWrite[0:nSnapSamples],'\t',toWrite[-nSnapSamples:]
    writeQdr(roach,qdrMemName,toWrite,nBytesPerQdrSample,bQdrFlip=True)
    #toWrite = np.ones(nQdrSamples)
    #toWrite = np.zeros(nQdrSamples)
#    toWriteStr = struct.pack('>{}{}'.format(nQdrRows,qdrFormatCode),*toWrite)
#    qdrValues = struct.unpack('>{}{}'.format(nQdrRows,qdrFormatCode),toWriteStr)
#    print 'katcp-to-write','\t',qdrValues[0:nSnapSamples],'\t',qdrValues[-nSnapSamples:]
#    roach.blindwrite(qdrMemName,toWriteStr)
    time.sleep(.5)
    readAllMem(roach)

    allOnes64 = int('1'*64,2)
    print ''
    print 'setting all bits to 1\'s by katcp'
    print ' dataIn should be all zeros'
    print ' other values should be',allOnes64,'which is',bin(allOnes64)
    toWrite = np.ones(nQdrRows,dtype=np.uint64)*allOnes64
    print toWrite[0]
    toWriteStr = struct.pack('>{}{}'.format(nQdrRows,qdrFormatCode),*toWrite)
    qdrValues = list(struct.unpack('>{}{}'.format(nQdrRows,qdrFormatCode),toWriteStr))
    print 'katcp-to-write','\t',qdrValues[0:nSnapSamples],'\t',qdrValues[-nSnapSamples:]
    roach.blindwrite(qdrMemName,toWriteStr)
    time.sleep(.5)
    readAllMem(roach)

    print ''
    print 'setting every other bit to 1 by katcp'
    print ' dataIn should be all zeros'
    print ' other values should be',everyOtherBit,'which is',bin(everyOtherBit)
    toWrite = np.ones(nQdrRows,dtype=np.uint64)*everyOtherBit
    print toWrite[0]
    toWriteStr = struct.pack('>{}{}'.format(nQdrRows,qdrFormatCode),*toWrite)
    qdrValues = list(struct.unpack('>{}{}'.format(nQdrRows,qdrFormatCode),toWriteStr))
    print 'katcp-to-write','\t',qdrValues[0:nSnapSamples],'\t',qdrValues[-nSnapSamples:]
    roach.blindwrite(qdrMemName,toWriteStr)
    time.sleep(.5)
    readAllMem(roach)

    print ''
    print 'setting each byte to a different value, repeat for all rows, by katcp'
    print ' dataIn should be all zeros'
    print ' other values should be',byteSortVal,'which is ',bin(byteSortVal)
    toWrite = np.ones(nQdrRows,dtype=np.uint64)*byteSortVal
    print 'katcp-to-write','\t',toWrite[0:nSnapSamples],'\t',toWrite[-nSnapSamples:]

    writeQdr(roach,qdrMemName,toWrite,nBytesPerQdrSample,bQdrFlip=True)
    #print toWrite[0]
    #toWriteStr = struct.pack('>{}{}'.format(nQdrRows,qdrFormatCode),*toWrite)
    #roach.blindwrite(qdrMemName,toWriteStr)
    time.sleep(.5)
    readAllMem(roach)

