#!/bin/sh
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOGNAME=logs/pm$TIMESTAMP.log
OBSNAME=data/obs_$TIMESTAMP.h5
cp ~/Matt/DataReadout/obs_600s.h5 $OBSNAME 

h5cc -shlib -pthread -o PacketMaster PacketMaster_select.c
#echo "PacketMaster will save logs in $LOGNAME"
echo "Data in $OBSNAME"
sudo nice -n -10 ./PacketMaster $OBSNAME


