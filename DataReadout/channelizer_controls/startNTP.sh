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

echo -n "Restarting ntpd"
sudo /sbin/service ntpd restart > /dev/null
check_status
echo " . done"
echo -n "Lowering arcons Firewall"
sudo /sbin/service iptables stop > /dev/null
sleep 1s
echo " . done"

echo -n "Updating ntp on roaches "
for i in ${ROACHES[*]}
do
	ssh root@10.0.0.1$i /etc/init.d/ntp stop > /dev/null
	check_status
	ssh root@10.0.0.1$i ntpdate 10.0.0.50 > /dev/null
	check_status
	ssh root@10.0.0.1$i /etc/init.d/ntp start > /dev/null
	check_status
	echo -n " ."
done
echo " done"

echo -n "Raising Firewall on arcons "
sudo /sbin/service iptables start > /dev/null
check_status
echo ". done"
