#!/bin/bash

# Output is in MHz

echo "$(( $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000 ))"