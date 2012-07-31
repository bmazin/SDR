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

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
EXPTIME=2
DIR="$MKID_DATA_DIR"
LOGNAME="$DIR/logs/pm$TIMESTAMP.log"
OBSNAME="$DIR/obs_$TIMESTAMP.h5"

echo -n "Copying ${EXPTIME}s obs file to data folder $DIR..."
cp ~/Matt/DataReadout/obs_${EXPTIME}s.h5 $OBSNAME 
check_status
echo " done"

echo -n "Copying beamimage file to data folder $DIR..."
cp ~/Matt/DataReadout/beamimage.h5 $DIR 
check_status
echo " done"

echo -n "Compiling PulseServer code ... "
h5cc -shlib -pthread -o bin/PacketMaster lib/PacketMaster.c
check_status
echo " done"

#echo "PacketMaster will save logs in $LOGNAME"
echo "Data in $OBSNAME"
sudo nice -n -10 bin/PacketMaster $OBSNAME
check_status
#tail $LOGNAME
echo "DONE"


