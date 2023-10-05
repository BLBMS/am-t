#!/bin/bash

# Izvedi ukaz lscpu, poišči "Model name:" in odstrani presledke iz odgovorov
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ')

# Razdeli rezultat na dve spremenljivki, eno za MYCPU1 in drugo za MYCPU2
IFS=$'\n' read -rd '' -a cpus <<< "$output"
MYCPU1="${cpus[0]}"
MYCPU2="${cpus[1]}"

echo "MYCPU1: $MYCPU1"
echo "MYCPU2: $MYCPU2"

# V male črke
MYCPU1=$(echo "$MYCPU1" | tr '[:upper:]' '[:lower:]')
MYCPU2=$(echo "$MYCPU2" | tr '[:upper:]' '[:lower:]')

# Izpiši vrednosti
echo "MYCPU1: $MYCPU1"
echo "MYCPU2: $MYCPU2"
