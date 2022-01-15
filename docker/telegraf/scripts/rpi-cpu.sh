#!/bin/bash

# Output is in MHz
frequency="$(( $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000 ))"

# Output is in Celcius
temperature=$(awk '{print $1/1000}' /sys/class/thermal/thermal_zone0/temp)

echo rpi_cpu,host=$HOSTNAME freq=$frequency,temp=$temperature