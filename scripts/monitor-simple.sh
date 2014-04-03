#!/bin/bash
while [ 1 ]; do
    day=`date +"%Y-%m-%d"`
    file="/data/soft/monitor/monitor-simple-"$day".dat"
    d=`date +"%Y-%m-%d.%H:%M:%S"`
    l=`uptime | awk '{print "load:"$(NF-2)}' | awk -F, '{print $1}'`
    m=`free -m | head -n3 | tail -n1 | awk '{print "mem:"$4/1000"G"}'`
    c=`top -b -n 1 | head -n 3 | tail -n 1 | awk '{print $5}' | awk -F% '{print "cpu.idle:"$1"%"}'`
    echo -e "$d:\t$l \t$m \t$c" >> $file
    sleep 0.6 
done
