#!/bin/sh
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOGNAME=~/DataReadout/logs/pm$TIMESTAMP.log
cp ~/Matt/DataReadout/obs_10s.h5 ~/DataReadout/data/obs_$TIMESTAMP.h5

h5cc -shlib -pthread -o ~/DataReadout/PacketMaster lib/PacketMaster.c
#echo "PacketMaster will save logs in $LOGNAME"
sudo nice -n -10 ~/DataReadout/PacketMaster obs_$TIMESTAMP.h5


