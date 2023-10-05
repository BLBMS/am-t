#!/bin/bash

# Izvedi ukaz lscpu, poišči "Model name:" in odstrani presledke iz odgovorov
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ')

# Razdeli rezultat na dve spremenljivki, eno za MYCPU1 in drugo za MYCPU2
IFS=$'\n' read -rd '' -a cpus <<< "$output"
MYCPU1="${cpus[0]}"
MYCPU2="${cpus[1]}"

# Izpiši vrednosti
echo "MYCPU1: $MYCPU1"
echo "MYCPU2: $MYCPU2"
