#!/bin/bash
screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
screen -ls
echo "all killed"
