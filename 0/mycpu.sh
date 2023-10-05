#!/bin/bash

# Izvedi ukaz lscpu, poišči "Model name:" in odstrani presledke iz odgovorov
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ')

# Razdeli rezultat na dve spremenljivki, eno za CPU1 in drugo za CPU2
IFS=$'\n' read -rd '' -a cpus <<< "$output"
CPU1="${cpus[0]}"
CPU2="${cpus[1]}"

# Izpiši vrednosti
echo "CPU1: $CPU1"
echo "CPU2: $CPU2"
