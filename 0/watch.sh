#!/bin/bash
# v.2024-07-31
#
# allows access for this IP range. Adjust to your own situation.
# "api-allow": "192.168.100.0/18",
# enables the API by making it listen on the specified IP address and port. 0.0.0.0 signifies all adapters and IPs.
# "api-bind": "0.0.0.0:4068"

# -------------------------------------------------------------
# set refreshing time in minutes

refreshing_min=10                      # refreshing time in min

refreshing=$((refreshing_min * 60))    # refreshing time in sec
# -------------------------------------------------------------

spisek="dev.list"
cd ~/
rm -f $spisek
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$spisek
i=1
echo -e "Not listed:\n"
while read -r line; do
    # Če se vrstica začne z '#' jo izpiše
    if [[ $line =~ ^# ]]; then
        first_field=$(echo "${line:1}" | awk '{print $1}')
        second_field=$(echo "${line:1}" | awk '{print $2}')
        length=${#first_field}
        spaces=$((15 - length))
        space_string=$(printf '%*s' "$spaces")

        lengthi=${#i}
        spacesi=$((3 - lengthi))
        space_stringi=$(printf '%*s' "$spacesi")

        echo -e "\e[0m$i$space_stringi   $first_field$space_string\e[93m   $second_field \e[0m"
        ((i++))
    fi
done < "$HOME/$spisek"
rm -f iteration.txt
echo "0" >> iteration.txt
screen -wipe 1>/dev/null 2>&1
if screen -ls | grep -i Watch; then
  printf "\n\e[93m WATCH is already running! (rw) to see \e[0m\n"
  sleep 2
  screen -r Watch
else
  printf "\n\e[93m Starting WATCH! \e[0m\n"
  screen -S Watch -X quit 1>/dev/null 2>&1
  screen -wipe 1>/dev/null 2>&1
  screen -dmS Watch 1>/dev/null 2>&1
  screen -S Watch -X stuff "clear \n" 1>/dev/null 2>&1
  screen -S Watch -X stuff "watch -c -n $refreshing './watch-screen.sh'\n" 1>/dev/null 2>&1
                                    #  -t
fi
printf "\n\e[93m opening screen WATCH \e[0m\n"
printf "\n\e[93m opening with: screen -r Watch or rw \e[0m\n"
