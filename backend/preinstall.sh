#!/bin/bash

#disable hyperthreading
for cpunum in $(
    cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list |
    cut -s -d, -f2- | tr ',' '\n' | sort -un); do
    echo 0 > /sys/devices/system/cpu/cpu$cpunum/online
done

#Do not limit core file creation
echo "ulimit -c unlimited >/dev/null 2>&1" > /etc/profile.d/ulimit.sh
