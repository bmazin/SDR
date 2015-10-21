#!/bin/bash
#ROACHES=(0 1 2 3 4 5 6 7)
ROACHES=$MKID_ROACHES
echo "begin restartPulseServers.sh with ROACHES=$ROACHES"
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

for i in ${ROACHES[*]}
do
        echo -n "Signalling old PulseServer Processes in roach $i"
	ssh root@10.0.0.1$i "touch ~/PulseServer/restartPulseServer.bin; sleep 0.5; rm ~/PulseServer/restartPulseServer.bin"
	echo -n " ."
done
echo
echo " DONE"

