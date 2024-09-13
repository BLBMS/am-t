#!/bin/bash
# v.2024-09-14

echo "Starting third_miner.sh"
nohup bash "$HOME/third_miner.sh" > "$HOME/third.log" 2>&1 &
