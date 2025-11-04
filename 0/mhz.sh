#!/bin/bash
# v.2025-11-04
# by blbMS

for i in {0..7}; do
  echo "CPU$i: $(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo "Ni podatka")"
done

