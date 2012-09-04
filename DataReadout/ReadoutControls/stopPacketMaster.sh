#!/bin/bash
echo -n "Signalling PacketMaster"
touch stopPacketMaster.bin
sleep 0.5
rm stopPacketMaster.bin
echo ". done"

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
	ssh root@10.0.0.1$i "touch ~/PulseServer/restartPulseServer.bin; sleep 0.5; rm ~/PulseServer/restartPulseServer.bin"
	echo -n " ."
done
echo " DONE"

