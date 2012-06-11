#!/bin/sh
for i in $(cat /proc/cpuinfo|grep processor|awk {'print $3'}); do
  cpufreq-set -g $1 -c $i
done
