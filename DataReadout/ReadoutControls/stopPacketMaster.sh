#!/bin/bash
echo -n "Signalling PacketMaster"
touch stopPacketMaster.bin
sleep 0.5
rm stopPacketMaster.bin
echo ". done"

#!/bin/bash
#ROACHES=(0 1 2 3 4 5 6 7)
ROACHES=(0)

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

stopOnePulseServer()
{
    ssh root@10.0.0.1$1 "touch ~/PulseServer/restartPulseServer.bin; sleep 0.5; rm ~/PulseServer/restartPulseServer.bin"
    echo " $1"
}

echo  "Signalling old PulseServer Processes "
for i in ${ROACHES[*]}
do
    stopOnePulseServer $i &
done


