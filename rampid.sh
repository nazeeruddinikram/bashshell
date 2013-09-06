#!/bin/bash
# you would call this like
# get_node_ram.sh 1234

pid="${1}"


totalRam=`cat /proc/meminfo | grep MemTotal | cut -d":" -f2 | /
sed 's# ##g' | sed 's#[a-zA-Z]*##g'`

measured=`cat /proc/meminfo | grep MemTotal | cut -d":" -f2 | /
sed 's# ##g' | sed 's#[0-9]*##g'`

case $measured in

mB) div=1;
;;
kB) div=1024;
;;
B) div=1048576;
;;
*) echo "Error";
exit
;;
esac

cur_per=`ps -p ${pid} -o pmem | tail -1`
amount=`echo -e "scale=2\n(${totalRam}/100*${cur_per})/${div}" | bc`
echo ${amount} MB
