#!/bin/bash

#usage: dur [seconds] [command]
#usage: dur [seconds] ["command -arg"]

runtime=${1:-1m}
mypid=$$
shift
$@ &
cpid=$!
sleep $runtime
kill -s SIGTERM $cpid
