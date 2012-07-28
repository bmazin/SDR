#!/bin/sh
check_status()
{
    status=$?
    if [ $status -ne 0 ]; then
        echo ""
        echo "ERROR"
        exit $status
    fi  
    return 0
}

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPTIME=10
LOGNAME=~/DataReadout/logs/pm$TIMESTAMP.log
OBSNAME=~/DataReadout/data/obs_$TIMESTAMP.h5
echo -n "Copying ${EXPTIME}s obs file to data folder ..."
cp ~/Matt/DataReadout/obs_${EXPTIME}s.h5 $OBSNAME 
check_status
echo " done"

echo -n "Compiling PulseServer code ... "
h5cc -shlib -pthread -o ~/DataReadout/PacketMaster lib/PacketMaster_select.c
check_status
echo " done"

#echo "PacketMaster will save logs in $LOGNAME"
echo "Data in $OBSNAME"
sudo nice -n -10 ~/DataReadout/PacketMaster $OBSNAME
check_status
#tail $LOGNAME
echo "DONE"


