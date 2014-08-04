#!/bin/bash
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

echo -n "Signalling old PulseServer Processes "
for i in ${ROACHES[*]}
do
    ssh root@10.0.0.1$i "touch ~/PulseServer/stopPulseServer.bin; touch ~/PulseServer/restartPulseServer.bin; sleep 0.5; rm ~/PulseServer/restartPulseServer.bin; rm ~/PulseServer/stopPulseServer.bin"
    echo -n " ."
done
echo " done"

echo -n "Killing any remaining old PulseServer Processes "
sleep 1
for i in ${ROACHES[*]}
do
	ssh root@10.0.0.1$i "killall -q PulseServer"
	echo -n " ."
done
echo " done"


echo -n "Copying over lastest PulseServer code "
for i in ${ROACHES[*]}
do
	scp -q lib/PulseServer.c root@10.0.0.1$i:~/PulseServer/
	check_status
	echo -n " ."
done
echo " done"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOGNAME=logs/ps_$TIMESTAMP.log

echo -n "Compiling PulseServer code "
for i in ${ROACHES[*]}
do
	 ssh root@10.0.0.1$i "cd PulseServer;cc -o PulseServer PulseServer.c"
	 check_status
	 echo -n " ."
done
echo " done"

echo  "Starting PulseServer processes "
for i in ${ROACHES[*]}
do
	 ssh -n -f root@10.0.0.1$i "cd PulseServer;nohup ./PulseServer > $LOGNAME &"
	 check_status
done
sleep 0.5
echo " done"
echo "Roaches will save logs in ~/PulseServer/$LOGNAME"
echo "DONE"
