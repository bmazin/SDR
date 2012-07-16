#!/bin/sh
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOGNAME=~/DataReadout/logs/pm$TIMESTAMP.log
OBSNAME=~/DataReadout/data/obs_$TIMESTAMP.h5
cp ~/Matt/DataReadout/obs_600s.h5 $OBSNAME 

h5cc -shlib -pthread -o ~/DataReadout/PacketMaster lib/PacketMaster_select.c
#echo "PacketMaster will save logs in $LOGNAME"
echo "Data in $OBSNAME"
sudo nice -n -10 ~/DataReadout/PacketMaster $OBSNAME


