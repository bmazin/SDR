#!/bin/bash
ROACHES=(0 1 2 3 4 5 6 7)
CLK="512"
#BOF="chan_if_acc_x_2011_Aug_02_0713.bof" #Palomar 2011 firmware,has deadtime lockout bug, 3-pt trigger bug
#BOF="chan_dtrig_v2_2012_Aug_28_1956.bof" #Has short low pass filter baseline, plus Palomar 2011 bugs
#BOF="btrig_fix_v1_2012_Sep_06_1516.bof" *fixed deadtime lockout, longer low pass filter baseline
BOF="chan_snap_v3_2012_Oct_30_1216.bof" #has snapQDR block for long snapshots, DDS lag: 154
#BOF="chan_snap_v3_2013_Oct_03_1412.bof" #has snapQDR block for long snapshots, DDS lag: 192
#BOF="chan_dead_v2_2013_Oct_07_1841.bof" #short dead time + count rate limiter, DDS lag: 194
#BOF="chan_smart_v1_2013_Nov_13_1403.bof" #has moving average baseline block. DDS lag:

if [ "$1" == "--help" ]; then
	echo "Usage: $0 CLOCK_MHZ [BOF_FILE]"
	exit 0
fi
if [ $# -ge 1 ]; then
	BOF=$1
fi

if [ $# -eq 2 ]; then
	CLK=$2
fi

check_status()
{
    status=$?
    if [ $status -ne 0 ]; then
        echo ""
        echo "ERROR $1"
        exit $status
    fi  
    return 0
}

for i in ${ROACHES[*]}
do
    echo "Roach $i"
    echo -n "Killing running firmware ... "
	ssh root@10.0.0.1$i "killall -q -r \.bof"
    sleep 2s
    echo " done"
    echo -n "Copying latest $BOF to roach ... "
	scp -q boffiles/$BOF root@10.0.0.1$i:/boffiles/
	check_status $i
    echo " done"
    echo -n "Setting clock rates to $CLK MHz ... "
	python lib/clock_pll_setup_$CLK.py 10.0.0.1$i > /dev/null
	check_status $i
    sleep 2s
    echo " done"
    echo -n "Programing firmware on roach ... "
	python lib/program_fpga.py 10.0.0.1$i $BOF > /dev/null
	check_status $i
    echo " done"
done

echo -n "Setting LPF alpha register ... "
python lib/set_alpha.py
check_status -1
echo "DONE"
