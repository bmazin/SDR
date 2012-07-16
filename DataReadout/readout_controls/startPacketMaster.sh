#!/bin/sh
LOGNAME=~/DataReadout/logs/pm$(date +%Y%m%d-%H%M%S).log
cp ~/Matt/DataReadout/obs_10s.h5 ~/DataReadout/obs_2s.h5

h5cc -shlib -pthread -o ~/DataReadout/PacketMaster lib/PacketMaster.c
#echo "PacketMaster will save logs in $LOGNAME"
sudo nice -n -10 ~/DataReadout/PacketMaster obs_2s.h5


