#!/bin/bash
# v.2024-09-13

# podaj številko epoch-e
# e.g. 126

if [ "$#" -ne 1 ]; then
    echo -e "\e[31mPodaj številko epoche\e[0m"
    exit 1
fi

epoch="$1"
homedir="$HOME/apoolminer/"
cd "$homedir"
epochdir="${homedir}epoch_$epoch"
