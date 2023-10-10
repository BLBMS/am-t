#!/bin/bash

#->  cd ~/ && rm -f ~/active-mrr.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/active-mrr.sh && chmod +x active-mrr.sh

# osveži nov spisek-mrr.list
cd ~/ && rm -f ~/spisek-mrr.list && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/spisek-mrr.list

left3_ip="192.168.100"
active_count=0
inactive_count=0
inactive_ips=""

# Preberi vsak IP naslov in pripadajočo vrednost iz datoteke "spisek-mrr.list"
while read -r ip value; do
    # Tukaj izvedite želene ukaze za vsak IP naslov
#    echo "Processing IP: $left3_ip.$ip = telefon: $value"
    echo -n -e "\r$ip $value "
    if ping -c 1 -W 1 $left3_ip.$ip &>/dev/null; then
#        echo -e "\e[32mActive  : $ip \e[0m"
        ((active_count++))
    else
        echo -n "? "
        sleep 1
        if ping -c 3 -W 1 $left3_ip.$ip &>/dev/null; then
            echo -e -n "\b\b \b"
            ((active_count++))
        else
            echo -e "\e[31mInactive: $ip \e[0m"
            ((inactive_count++))
            inactive_ips+="$ip\n"
        fi
    fi
done < spisek-mrr.list
echo -n -e "\r--------------\n"
echo -e "\e[32mActive  : $active_count \e[0m"
echo -e "\e[31mInactive: $inactive_count \e[0m"
if [ $inactive_count -gt 0 ]; then
    echo -e "Inactive devices:\n$inactive_ips"
    date >> mrr.error
    echo -e "Inactive devices:\n$inactive_ips" >> mrr.error
# na email - ne dela
#    echo -e "Neaktivne naprave:\n$inactive_ips" | mailx -s "Neaktivne naprave">
fi
