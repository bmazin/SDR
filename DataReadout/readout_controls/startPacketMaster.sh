#!/bin/sh
LOGNAME=logs/pm$(date +%Y%m%d-%H%M%S).log
cp ~/Matt/DataReadout/obs_10s.h5 obs_2s.h5

h5cc -shlib -pthread -o PacketMaster PacketMaster.c
#echo "PacketMaster will save logs in $LOGNAME"
sudo nice -n -10 ./PacketMaster obs_2s.h5


