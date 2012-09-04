#!/bin/bash
ROACHES=(0 1 2 3 4 5 6 7)

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

echo -n "Signalling old PulseServer Processes "
for i in ${ROACHES[*]}
do
	ssh root@10.0.0.1$i "touch ~/PulseServer/restartPulseServer.bin"
	ssh root@10.0.0.1$i "rm ~/PulseServer/restartPulseServer.bin"
	echo -n " ."
done
echo " DONE"

