#!/bin/bash
ROACHES=(1)

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

echo -n "Killing old PulseServer Processes "
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
LOGNAME=logs/ps.log

echo -n "Compiling PulseServer code "
for i in ${ROACHES[*]}
do
	 ssh root@10.0.0.1$i "cd PulseServer;cc -o PulseServer PulseServer.c"
	 check_status
	 echo -n " ."
done
echo " done"

echo -n "Starting PulseServer processes "
for i in ${ROACHES[*]}
do
	 ssh -n -f root@10.0.0.1$i "cd PulseServer;nohup ./PulseServer > $LOGNAME &"
	 check_status
	 echo -n " ."
done
echo " done"
echo "Roaches will save logs in ~/PulseServer/$LOGNAME"
echo "DONE"
