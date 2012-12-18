#!/bin/bash
ROACHES=$1
CLK="512"
#BOF="chan_dtrig_v2_2012_Aug_28_1956.bof"
BOF="chan_if_acc_x_2011_Aug_02_0713.bof"

if [ "$1" == "--help" ]; then
	echo "Usage: $0 ROACH_NUM [BOF_FILE]"
	exit 0
fi
if [ $# -ge 2 ]; then
	BOF=$2
fi


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

echo -n "Killing running firmware "
for i in ${ROACHES[*]}
do
	ssh root@10.0.0.1$i "killall -q -r \.bof"
	echo -n " ."
done
sleep 2s
echo " done"

echo -n "Copying latest $BOF to roaches "
for i in ${ROACHES[*]}
do
	scp -q boffiles/$BOF root@10.0.0.1$i:/boffiles/
	check_status
	echo -n " ."
done
echo " done"

echo -n "Setting clock rates to $CLK MHz "
for i in ${ROACHES[*]}
do
	python lib/clock_pll_setup_$CLK.py 10.0.0.1$i > /dev/null
	check_status
	echo -n " ."
done
sleep 2s
echo " done"

echo -n "Programing firmware on roaches "
for i in ${ROACHES[*]}
do
	python lib/program_fpga.py 10.0.0.1$i $BOF > /dev/null
	check_status
	echo -n " ."
done
echo " done"

echo "DONE"